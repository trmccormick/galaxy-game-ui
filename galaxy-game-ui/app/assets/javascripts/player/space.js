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
  const systemNames = Object.fromEntries(data.universe.systems.map((system) => [system.id, system.name]));

  function element(name, attrs = {}, text = null) {
    const node = document.createElementNS(svgNS, name);
    Object.entries(attrs).forEach(([key, value]) => node.setAttribute(key, value));
    if (text !== null) node.textContent = text;
    return node;
  }

  function attachMapControls(svg, key) {
    const state = { x: 0, y: 0, scale: 1, dragging: false, startX: 0, startY: 0, originX: 0, originY: 0 };
    const group = element("g", { class: "map-world" });
    svg.appendChild(group);
    const apply = () => group.setAttribute("transform", `translate(${state.x} ${state.y}) scale(${state.scale})`);
    svg.setAttribute("viewBox", "0 0 1000 500");
    svg.setAttribute("preserveAspectRatio", "xMidYMid meet");
    svg.addEventListener("pointerdown", (event) => {
      if (event.target.closest(".space-map-node")) return;
      state.dragging = true; state.startX = event.clientX; state.startY = event.clientY;
      state.originX = state.x; state.originY = state.y; svg.setPointerCapture(event.pointerId);
    });
    svg.addEventListener("pointermove", (event) => {
      if (!state.dragging) return;
      const bounds = svg.getBoundingClientRect();
      state.x = state.originX + (event.clientX - state.startX) * 1000 / bounds.width;
      state.y = state.originY + (event.clientY - state.startY) * 500 / bounds.height;
      apply();
    });
    const stop = () => { state.dragging = false; };
    svg.addEventListener("pointerup", stop); svg.addEventListener("pointercancel", stop);
    svg.addEventListener("wheel", (event) => {
      event.preventDefault();
      const factor = event.deltaY < 0 ? 1.12 : 0.89;
      state.scale = Math.max(.65, Math.min(3.2, state.scale * factor)); apply();
    }, { passive: false });
    root.querySelector(`[data-map-reset="${key}"]`)?.addEventListener("click", () => {
      state.x = 0; state.y = 0; state.scale = 1; apply();
    });
    return group;
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
      const select = () => { window.location.assign(`/player/space?system_id=${encodeURIComponent(system.id)}&craft_id=${encodeURIComponent(selectedCraft?.id || "")}`); };
      node.addEventListener("click", select);
      node.addEventListener("keydown", (event) => { if (event.key === "Enter" || event.key === " ") { event.preventDefault(); select(); } });
      world.appendChild(node);
    });
  }

  function renderSystem() {
    const svg = root.querySelector("#space-system-map");
    svg.replaceChildren();
    const world = attachMapControls(svg, "system");
    const system = data.system;
    const star = system.star || {};
    const cx = 500, cy = 245;
    [75, 135, 205, 285, 365].forEach((radius) => world.appendChild(element("ellipse", { cx, cy, rx: radius, ry: radius * .43, class: "space-system-orbit" })));
    world.appendChild(element("circle", { cx, cy, r: 19, fill: "#f3c76d", stroke: "#fff0bf", "stroke-width": "2", filter: "drop-shadow(0 0 12px #e7b95a)" }));
    world.appendChild(element("text", { x: cx, y: cy + 38, class: "space-map-label", "text-anchor": "middle" }, star.name || system.name));

    (system.bodies || []).forEach((body, index) => {
      const p = body.map_position || { x: 20 + index * 13, y: 45 + (index % 2) * 12 };
      const x = p.x * 10, y = p.y * 5;
      const isStar = body.kind === "star";
      world.appendChild(element("circle", { cx: x, cy: y, r: isStar ? 9 : 6, fill: isStar ? "#e8c16e" : "#7ca9c7", stroke: "#d7e6ef", "stroke-width": "1" }));
      world.appendChild(element("text", { x, y: y + 18, class: "space-map-label", "text-anchor": "middle" }, body.name));
    });

    (system.stations || []).forEach((station) => {
      const p = station.map_position || { x: 50, y: 50 };
      const x = p.x * 10, y = p.y * 5;
      world.appendChild(element("rect", { x: x - 6, y: y - 6, width: 12, height: 12, rx: 2, fill: "#43d39a", stroke: "#d6fff0", "stroke-width": "1" }));
      world.appendChild(element("text", { x, y: y + 18, class: "space-map-label", "text-anchor": "middle" }, station.name));
    });

    const localCraft = data.craft.filter((craft) => craft.location_system_id === system.system_id);
    localCraft.forEach((craft, index) => {
      const x = 120 + index * 78, y = 390 - index * 35;
      const marker = element("g", { class: "space-map-node", tabindex: "0", role: "button", "aria-label": `Select ${craft.name}` });
      marker.appendChild(element("circle", { cx: x, cy: y, r: 13, class: "node-halo" }));
      marker.appendChild(element("path", { d: `M ${x} ${y - 8} L ${x + 7} ${y + 7} L ${x - 7} ${y + 7} Z`, fill: craft.id === selectedCraft?.id ? "#ffbf66" : "#d48e42", stroke: "#ffe1b8", "stroke-width": "1" }));
      marker.appendChild(element("text", { x, y: y + 22, class: "space-map-label", "text-anchor": "middle" }, craft.name));
      const choose = () => selectCraft(craft.id);
      marker.addEventListener("click", choose);
      marker.addEventListener("keydown", (event) => { if (event.key === "Enter" || event.key === " ") { event.preventDefault(); choose(); } });
      world.appendChild(marker);
    });
    if (!localCraft.length) world.appendChild(element("text", { x: 500, y: 465, class: "space-map-subtitle", "text-anchor": "middle" }, "No prototype craft currently assigned to this system"));
  }

  function selectCraft(id) {
    selectedCraft = byId(data.craft, id) || selectedCraft;
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
      "space-inspector-operation": selectedCraft.operation,
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
  }

  root.querySelectorAll("[data-craft-id]").forEach((button) => button.addEventListener("click", () => selectCraft(button.dataset.craftId)));
  root.querySelector("#space-system-select")?.addEventListener("change", (event) => {
    window.location.assign(`/player/space?system_id=${encodeURIComponent(event.target.value)}&craft_id=${encodeURIComponent(selectedCraft?.id || "")}`);
  });

  renderNetwork();
  renderSystem();
  updateInspector();
})();