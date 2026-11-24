(() => {
  const root = document.querySelector("[data-space-root]");
  const payloadNode = document.getElementById("space-view-data");
  if (!root || !payloadNode) return;

  let data;
  try { data = JSON.parse(payloadNode.textContent); } catch (error) { console.error("Unable to read Player Space fixture payload", error); return; }

  const svgNS = "http://www.w3.org/2000/svg";
  const byId = (items, id) => items.find((item) => item.id === id);
  let selectedCraft = byId(data.craft, data.selected_craft_id) || data.craft[0];
  let selectedSystem = data.selected_system_id;
  const workspacePath = root.dataset.workspace === "fleet_manager" ? "/player/fleet-manager" : "/player/space";
  const systemNames = Object.fromEntries(data.universe.systems.map((system) => [system.id, system.name]));

  function element(name, attrs = {}, text = null) {
    const node = document.createElementNS(svgNS, name);
    Object.entries(attrs).forEach(([key, value]) => node.setAttribute(key, value));
    if (text !== null) node.textContent = text;
    return node;
  }

  function attachMapControls(svg, key) {
    const initial = { x: 0, y: 0, width: 1000, height: 500 };
    const view = { ...initial, dragging: false, startX: 0, startY: 0, origin: null };
    const world = element("g", { class: "map-world" });
    svg.appendChild(world);
    svg.setAttribute("viewBox", "0 0 1000 500");
    svg.setAttribute("preserveAspectRatio", "xMidYMid meet");

    const apply = () => svg.setAttribute("viewBox", [view.x, view.y, view.width, view.height].map((n) => n.toFixed(2)).join(" "));
    const reset = () => {
      view.x = initial.x; view.y = initial.y; view.width = initial.width; view.height = initial.height;
      apply();
    };

    svg.addEventListener("pointerdown", (event) => {
      if (event.target.closest(".space-map-node")) return;
      view.dragging = true;
      view.startX = event.clientX; view.startY = event.clientY;
      view.origin = { x: view.x, y: view.y, width: view.width, height: view.height };
      svg.setPointerCapture(event.pointerId);
    });
    svg.addEventListener("pointermove", (event) => {
      if (!view.dragging || !view.origin) return;
      const bounds = svg.getBoundingClientRect();
      if (!bounds.width || !bounds.height) return;
      view.x = view.origin.x - (event.clientX - view.startX) * view.origin.width / bounds.width;
      view.y = view.origin.y - (event.clientY - view.startY) * view.origin.height / bounds.height;
      apply();
    });
    const stop = () => { view.dragging = false; view.origin = null; };
    svg.addEventListener("pointerup", stop);
    svg.addEventListener("pointercancel", stop);
    svg.addEventListener("wheel", (event) => {
      event.preventDefault();
      const bounds = svg.getBoundingClientRect();
      if (!bounds.width || !bounds.height) return;
      const fractionX = (event.clientX - bounds.left) / bounds.width;
      const fractionY = (event.clientY - bounds.top) / bounds.height;
      const worldX = view.x + fractionX * view.width;
      const worldY = view.y + fractionY * view.height;
      const factor = event.deltaY < 0 ? 1 / 1.2 : 1.2;
      const nextWidth = Math.max(180, Math.min(1600, view.width * factor));
      const nextHeight = nextWidth / 2;
      view.x = worldX - fractionX * nextWidth;
      view.y = worldY - fractionY * nextHeight;
      view.width = nextWidth;
      view.height = nextHeight;
      apply();
    }, { passive: false });

    root.querySelector(`[data-map-reset="${key}"]`)?.addEventListener("click", reset);
    return world;
  }

  function renderNetwork() {
    const svg = root.querySelector("#space-network-map");
    svg.replaceChildren();
    const world = attachMapControls(svg, "network");
    const systems = data.universe.systems;
    const edges = data.universe.connections || [];
    const point = (system) => ({ x: system.map_position.x * 10, y: system.map_position.y * 5 });
    const routeIds = new Set(selectedCraft?.route || []);

    edges.forEach((edge) => {
      const from = byId(systems, edge.from), to = byId(systems, edge.to);
      if (!from || !to) return;
      const a = point(from), b = point(to);
      world.appendChild(element("line", { x1: a.x, y1: a.y, x2: b.x, y2: b.y, class: `space-network-edge ${edge.kind === "natural" ? "natural" : ""}` }));
      world.appendChild(element("text", { x: (a.x + b.x) / 2, y: (a.y + b.y) / 2 - 10, class: "space-network-edge-label", "text-anchor": "middle" }, edge.kind === "natural" ? "NATURAL" : edge.kind.toUpperCase()));
    });

    systems.forEach((system) => {
      const p = point(system);
      const node = element("g", { class: `space-map-node ${system.id === selectedSystem ? "is-selected" : ""}`, tabindex: "0", role: "button", "aria-label": `Select ${system.name}` });
      node.appendChild(element("circle", { cx: p.x, cy: p.y, r: 22, class: "node-halo" }));
      node.appendChild(element("circle", { cx: p.x, cy: p.y, r: system.id === "SOL" ? 9 : 7, fill: system.id === "SOL" ? "#36a9f5" : system.access === "natural_connection" ? "#43d39a" : "#778795", stroke: "#d6e5ef", "stroke-width": "1.2" }));
      if (routeIds.has(system.id)) node.appendChild(element("circle", { cx: p.x, cy: p.y, r: 14, fill: "none", stroke: "#eab65c", "stroke-width": "1.2", "stroke-dasharray": "3 3" }));
      node.appendChild(element("text", { x: p.x, y: p.y + 29, class: "space-map-label", "text-anchor": "middle" }, system.name));
      node.appendChild(element("text", { x: p.x, y: p.y + 43, class: "space-map-subtitle", "text-anchor": "middle" }, system.subtitle || system.id));
      const select = () => { window.location.assign(`${workspacePath}?system_id=${encodeURIComponent(system.id)}&craft_id=${encodeURIComponent(selectedCraft?.id || "")}`); };
      node.addEventListener("click", select);
      node.addEventListener("keydown", (event) => { if (event.key === "Enter" || event.key === " ") { event.preventDefault(); select(); } });
      world.appendChild(node);
    });
  }

  function spatialCoordinates(item) {
    const location = item?.spatial_location;
    if (!location) return null;
    const x = Number(location.x_coordinate), y = Number(location.y_coordinate), z = Number(location.z_coordinate ?? 0);
    return [x, y, z].every(Number.isFinite) ? { x, y, z } : null;
  }

  function renderSystem() {
    const svg = root.querySelector("#space-system-map");
    svg.replaceChildren();
    const world = attachMapControls(svg, "system");
    const system = data.system;
    const localCraft = data.craft.filter((craft) => craft.location_system_id === system.system_id);
    const bodies = system.bodies || [];
    const stations = system.stations || [];
    const star = system.star || {};

    // The API's spatial locations are authoritative when available. All objects
    // are interpreted in the system's declared coordinate frame; the renderer
    // does not assume that a star occupies the origin.
    const objects = [
      ...(star.id && (spatialCoordinates(star) || star.map_position) ? [star] : []),
      ...bodies,
      ...stations,
      ...localCraft
    ];
    const hasSpatialFrame = objects.length > 0 && objects.every((item) => spatialCoordinates(item));
    const positionFor = (item) => {
      if (hasSpatialFrame) return spatialCoordinates(item);
      const p = item.map_position;
      return p && Number.isFinite(Number(p.x)) && Number.isFinite(Number(p.y))
        ? { x: Number(p.x), y: Number(p.y), z: 0 }
        : null;
    };

    const positioned = objects.map((item) => ({ item, position: positionFor(item) })).filter(({ position }) => position);
    if (!positioned.length) {
      world.appendChild(element("text", { x: 500, y: 250, class: "space-map-subtitle", "text-anchor": "middle" }, "No spatial positions reported for this system"));
      return;
    }

    const frame = system.coordinate_frame || {};
    const origin = frame.origin || {};
    const originCoordinates = origin.coordinates || {};
    const originX = Number(originCoordinates.x_coordinate ?? 0);
    const originY = Number(originCoordinates.y_coordinate ?? 0);
    const points = positioned.map(({ position }) => ({
      x: position.x - (hasSpatialFrame ? originX : 0),
      y: position.y - (hasSpatialFrame ? originY : 0)
    }));
    const minX = Math.min(...points.map((p) => p.x)), maxX = Math.max(...points.map((p) => p.x));
    const minY = Math.min(...points.map((p) => p.y)), maxY = Math.max(...points.map((p) => p.y));
    const spanX = Math.max(maxX - minX, 1), spanY = Math.max(maxY - minY, 1);
    const scale = Math.min(820 / spanX, 390 / spanY);
    const offsetX = 500 - ((minX + maxX) / 2) * scale;
    const offsetY = 245 + ((minY + maxY) / 2) * scale;
    const screenPoint = (item) => {
      const position = positionFor(item);
      if (!position) return null;
      const x = position.x - (hasSpatialFrame ? originX : 0);
      const y = position.y - (hasSpatialFrame ? originY : 0);
      if (hasSpatialFrame) return { x: offsetX + x * scale, y: offsetY - y * scale };
      return { x: x * 10, y: y * 5 };
    };

    // A barycenter is a coordinate origin, not an additional star to draw.
    if (hasSpatialFrame && origin.type === "barycenter") {
      const p = hasSpatialFrame
        ? { x: offsetX, y: offsetY }
        : { x: 500, y: 245 };
      world.appendChild(element("path", {
        d: `M ${p.x - 7} ${p.y} H ${p.x + 7} M ${p.x} ${p.y - 7} V ${p.y + 7}`,
        class: "space-system-origin"
      }));
      world.appendChild(element("text", { x: p.x + 10, y: p.y - 10, class: "space-map-subtitle" }, origin.name || "System barycenter"));
    }

    positioned.forEach(({ item }) => {
      const p = screenPoint(item);
      if (!p) return;
      const isStar = item.kind === "star" || item.type === "star" || item.id === star.id;
      const isStation = stations.includes(item);
      const radius = isStar ? 10 : 6;
      if (isStation) {
        world.appendChild(element("rect", { x: p.x - 6, y: p.y - 6, width: 12, height: 12, rx: 2, fill: "#43d39a", stroke: "#d6fff0", "stroke-width": "1" }));
      } else {
        world.appendChild(element("circle", {
          cx: p.x, cy: p.y, r: radius,
          fill: isStar ? "#e8c16e" : "#7ca9c7",
          stroke: "#d7e6ef", "stroke-width": isStar ? "1.5" : "1"
        }));
      }
      world.appendChild(element("text", { x: p.x, y: p.y + (isStar ? 20 : 17), class: "space-map-label", "text-anchor": "middle" }, item.name || item.id));
    });

    // Craft use the same coordinate frame as every other spatial object.
    localCraft.forEach((craft) => {
      const p = screenPoint(craft);
      if (!p) return;
      const marker = element("g", { class: `space-map-node ${craft.id === selectedCraft?.id ? "is-selected" : ""}`, tabindex: "0", role: "button", "aria-label": `Select ${craft.name}` });
      marker.appendChild(element("circle", { cx: p.x, cy: p.y, r: 13, class: "node-halo" }));
      marker.appendChild(element("path", { d: `M ${p.x} ${p.y - 8} L ${p.x + 7} ${p.y + 7} L ${p.x - 7} ${p.y + 7} Z`, fill: craft.id === selectedCraft?.id ? "#ffbf66" : "#d48e42", stroke: "#ffe1b8", "stroke-width": "1" }));
      marker.appendChild(element("text", { x: p.x, y: p.y + 22, class: "space-map-label", "text-anchor": "middle" }, craft.name));
      const choose = () => selectCraft(craft.id);
      marker.addEventListener("click", choose);
      marker.addEventListener("keydown", (event) => { if (event.key === "Enter" || event.key === " ") { event.preventDefault(); choose(); } });
      world.appendChild(marker);
    });

    // Do not invent a straight-line route between current waypoints. Draw a
    // trajectory only when the API supplies its time-dependent path points.
    const trajectory = selectedCraft?.location_system_id === system.system_id ? selectedCraft.trajectory : null;
    const trajectoryPoints = (trajectory?.points || []).map((point) => {
      const x = Number(point.x_coordinate), y = Number(point.y_coordinate);
      if (!Number.isFinite(x) || !Number.isFinite(y)) return null;
      const px = hasSpatialFrame ? offsetX + (x - originX) * scale : x * 10;
      const py = hasSpatialFrame ? offsetY - (y - originY) * scale : y * 5;
      return [px, py];
    }).filter(Boolean);
    if (trajectoryPoints.length > 1) {
      world.appendChild(element("polyline", {
        points: trajectoryPoints.map(([x, y]) => `${x},${y}`).join(" "),
        fill: "none", stroke: "#00d4ff", "stroke-width": "2.5", "stroke-dasharray": "7 5",
        "stroke-linecap": "round", "stroke-linejoin": "round", opacity: ".9"
      }));
    }

    if (!positioned.length) world.appendChild(element("text", { x: 500, y: 465, class: "space-map-subtitle", "text-anchor": "middle" }, "No spatial objects are currently reported for this system"));
  }

  function selectCraft(id) {
    const nextCraft = byId(data.craft, id);
    if (!nextCraft) return;
    if (nextCraft.location_system_id && nextCraft.location_system_id !== selectedSystem) {
      window.location.assign(`${workspacePath}?system_id=${encodeURIComponent(nextCraft.location_system_id)}&craft_id=${encodeURIComponent(nextCraft.id)}`);
      return;
    }
    selectedCraft = nextCraft;
    root.querySelectorAll("[data-craft-id]").forEach((button) => button.classList.toggle("is-selected", button.dataset.craftId === id));
    updateInspector();
    renderNetwork();
    renderSystem();
  }

  function updateInspector() {
    if (!selectedCraft) return;
    const values = {
      "space-inspector-name": selectedCraft.name,
      "space-inspector-status": selectedCraft.status,
      "space-inspector-type": selectedCraft.type,
      "space-inspector-location": selectedCraft.location,
      "space-inspector-destination": selectedCraft.destination,
      "space-inspector-operation": `${selectedCraft.assignment_type} · ${selectedCraft.operation}`,
      "space-inspector-updated": selectedCraft.updated,
      "space-inspector-progress": `${selectedCraft.progress}%`
    };
    Object.entries(values).forEach(([id, value]) => { const node = document.getElementById(id); if (node) node.textContent = value; });
    const fill = document.getElementById("space-progress-fill");
    if (fill) fill.style.width = `${selectedCraft.progress}%`;
    const list = document.getElementById("space-route-list");
    if (list) {
      list.replaceChildren();
      (selectedCraft.route || []).forEach((id) => list.appendChild(document.createElement("li")).textContent = systemNames[id] || id);
    }
    const localList = document.getElementById("space-local-route-list");
    if (localList) {
      localList.replaceChildren();
      (selectedCraft.local_route || []).forEach((id) => {
        const body = (data.system.bodies || []).find((item) => item.id === id);
        const station = (data.system.stations || []).find((item) => item.id === id);
        localList.appendChild(document.createElement("li")).textContent = body?.name || station?.name || id.replace(/-/g, " ");
      });
    }
  }

  root.querySelectorAll("[data-craft-id]").forEach((button) => button.addEventListener("click", () => selectCraft(button.dataset.craftId)));
  root.querySelector("#space-system-select")?.addEventListener("change", (event) => {
    window.location.assign(`${workspacePath}?system_id=${encodeURIComponent(event.target.value)}&craft_id=${encodeURIComponent(selectedCraft?.id || "")}`);
  });

  renderNetwork();
  renderSystem();
  updateInspector();
})();