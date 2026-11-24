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
  const neighborhoodForFocus = () => {
    const catalog = data.galaxy_catalog;
    return catalog?.reference_system_id === selectedSystem && Array.isArray(catalog.systems) ? catalog : null;
  };
  const nearbySystemsForFocus = () => (neighborhoodForFocus()?.systems || []).filter((item) => item.position?.cartesian_ly);
  let selectedGalaxySystemId = selectedSystem;
  let showOrbitReferences = true;
  const workspacePath = root.dataset.workspace === "fleet_manager" ? "/player/fleet-manager" : "/player/space";
  const systemNames = Object.fromEntries(data.universe.systems.map((system) => [system.id, system.name]));

  function element(name, attrs = {}, text = null) {
    const node = document.createElementNS(svgNS, name);
    Object.entries(attrs).forEach(([key, value]) => node.setAttribute(key, value));
    if (text !== null) node.textContent = text;
    return node;
  }

  // Place labels in map coordinates without allowing adjacent names to collide.
  // Markers remain selectable and expose their full name through an SVG title.
  function addDeclutteredLabel(world, text, x, y, className, occupied, options = {}) {
    const fontSize = options.fontSize || 11;
    const width = Math.max(24, String(text).length * fontSize * 0.56);
    const height = fontSize * 1.35;
    const gap = options.gap ?? 7;
    const candidates = [
      { x: x + 9, y: y - 8, anchor: "start", left: x + 9, right: x + 9 + width },
      { x: x - 9, y: y - 8, anchor: "end", left: x - 9 - width, right: x - 9 },
      { x: x + 9, y: y + height, anchor: "start", left: x + 9, right: x + 9 + width },
      { x: x - 9, y: y + height, anchor: "end", left: x - 9 - width, right: x - 9 },
      { x: x, y: y - 15, anchor: "middle", left: x - width / 2, right: x + width / 2 }
    ];
    const chosen = candidates.find((candidate) => {
      const box = { left: candidate.left - gap, right: candidate.right + gap, top: candidate.y - height, bottom: candidate.y + gap };
      return box.left >= 4 && box.right <= 996 && box.top >= 4 && box.bottom <= 496 &&
        !occupied.some((other) => box.left < other.right && box.right > other.left && box.top < other.bottom && box.bottom > other.top);
    });
    if (!chosen) return false;
    occupied.push({ left: chosen.left - gap, right: chosen.right + gap, top: chosen.y - height, bottom: chosen.y + gap });
    world.appendChild(element("text", {
      x: chosen.x, y: chosen.y, class: className,
      "text-anchor": chosen.anchor, "font-size": fontSize
    }, text));
    return true;
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

  const galaxySpatialSvg = root.querySelector("#space-galaxy-map");
  const constellationSvg = root.querySelector("#space-constellation-map");
  const galaxySpatialWorld = galaxySpatialSvg ? attachMapControls(galaxySpatialSvg, "galaxy-spatial") : null;
  const constellationWorld = constellationSvg ? attachMapControls(constellationSvg, "galaxy-sky") : null;

  function updateGalaxySelection() {
    const name = document.getElementById("galaxy-selection-name");
    const details = document.getElementById("galaxy-selection-details");
    if (!name || !details) return;
    const focused = data.universe.systems.find((item) => item.id === selectedSystem);
    const focusedName = focused?.name || data.system.name || selectedSystem || "System focus unavailable";
    const catalog = neighborhoodForFocus();
    const nearby = nearbySystemsForFocus();
    name.textContent = focusedName;
    if (!catalog || nearby.length === 0) {
      details.textContent = "Neighborhood data unavailable · no sourced positions for nearby systems are available.";
      return;
    }
    details.textContent = selectedSystem === "SOL"
      ? `Reference origin · 0.00 ly · ${nearby.length} nearby systems`
      : `${nearby.length} nearby systems · neighborhood centered on ${focusedName}`;
  }

  function chooseGalaxySystem(system) {
    selectedGalaxySystemId = system.id;
    const systemEntry = data.universe.systems.find((item) => item.id === system.seed_identifier || item.id === system.id);
    if (systemEntry && systemEntry.id !== selectedSystem) {
      window.location.assign(`${workspacePath}?system_id=${encodeURIComponent(systemEntry.id)}`);
      return;
    }
    renderGalaxySpatial();
    renderGalaxySky();
    updateGalaxySelection();
  }

  function renderGalaxySpatial() {
    if (!galaxySpatialWorld) return;
    galaxySpatialWorld.replaceChildren();
    const catalog = neighborhoodForFocus();
    const systems = nearbySystemsForFocus();
    const focused = Boolean(catalog && systems.length);
    const focusedName = data.universe.systems.find((item) => item.id === selectedSystem)?.name || data.system.name || selectedSystem;
    const stage = root.querySelector('[data-galaxy-canvas="spatial"]');
    const canvas = stage?.querySelector(".space-map-canvas");
    const unavailable = stage?.querySelector('[data-galaxy-unavailable="spatial"]');
    if (canvas) canvas.hidden = !focused;
    if (unavailable) {
      unavailable.hidden = focused;
      unavailable.textContent = `Neighborhood data unavailable for ${focusedName}. No sourced positions for nearby systems are available, so the neighborhood map cannot be populated.`;
    }
    const footnote = stage?.querySelector(".galaxy-map-footnote");
    if (footnote) {
      footnote.hidden = !focused;
      if (selectedSystem === "SOL") {
        footnote.textContent = "Local Bubble is a physical interstellar region. Its boundary is intentionally not drawn because this catalog does not include a sourced 3D boundary model.";
      } else {
        footnote.textContent = `This map is centered on ${focusedName}. It includes only nearby systems with sourced positions relative to this system; missing positions are not inferred.`;
      }
    }
    const caption = stage?.querySelector("[data-galaxy-caption='spatial']");
    if (caption) caption.textContent = selectedSystem === "SOL"
      ? "SOL-CENTERED NEIGHBORHOOD · EQUATORIAL CARTESIAN PROJECTION · LIGHT-YEARS"
      : `${focusedName.toUpperCase()}-CENTERED NEIGHBORHOOD · LOCAL CARTESIAN PROJECTION · LIGHT-YEARS`;
    if (!focused) return;

    const center = {
      id: selectedSystem,
      name: focusedName,
      isCenter: true,
      position: { cartesian_ly: { x: 0, y: 0, z: 0 }, distance_ly: 0 }
    };
    const objects = [center, ...systems];
    const project = (position) => {
      const p = position?.cartesian_ly;
      if (!p) return null;
      return { x: Number(p.x) - Number(p.y) * 0.5, y: Number(p.z) - (Number(p.x) + Number(p.y)) * 0.25 };
    };
    const projected = objects.map((item) => ({ item, point: project(item.position) })).filter((item) => item.point);
    if (!projected.length) return;
    const extentX = Math.max(1, ...projected.map(({ point }) => Math.abs(point.x)));
    const extentY = Math.max(1, ...projected.map(({ point }) => Math.abs(point.y)));
    // Keep the focused system at the visual origin; scale the neighborhood
    // around it rather than centering the bounding box of the surrounding stars.
    const scale = Math.min(420 / extentX, 215 / extentY);
    const offsetX = 500;
    const offsetY = 250;

    const galaxyLabelBoxes = [];
    const labelCandidates = projected.slice().sort((a, b) => {
      const score = (entry) => entry.item.isCenter ? -10000 : entry.item.id === selectedGalaxySystemId ? -9000 : entry.item.position.distance_ly;
      return score(a) - score(b);
    });
    const labelableIds = new Set();
    labelCandidates.forEach(({ item, point }) => {
      if (labelableIds.size >= 15) return;
      const p = { x: offsetX + point.x * scale, y: offsetY - point.y * scale };
      const label = item.isCenter ? focusedName : item.name + " · " + item.position.distance_ly.toFixed(1) + " ly";
      if (addDeclutteredLabel(galaxySpatialWorld, label, p.x, p.y, "space-map-label galaxy-system-label", galaxyLabelBoxes, { fontSize: 11, gap: 8 })) {
        labelableIds.add(item.id);
      }
    });

    // The selected system is the origin of its own local neighborhood frame.
    galaxySpatialWorld.appendChild(element("line", { x1: 500, y1: 35, x2: 500, y2: 465, class: "galaxy-axis" }));
    galaxySpatialWorld.appendChild(element("line", { x1: 80, y1: 250, x2: 920, y2: 250, class: "galaxy-axis" }));
    projected.forEach(({ item, point }) => {
      const p = { x: offsetX + point.x * scale, y: offsetY - point.y * scale };
      const isCenter = Boolean(item.isCenter);
      const selected = item.id === selectedGalaxySystemId;
      const node = element("g", { class: `space-map-node galaxy-system-node ${selected || isCenter ? "is-selected" : ""}`, tabindex: "0", role: "button", "aria-label": isCenter ? `${item.name}, neighborhood center` : `Select ${item.name}` });
      node.appendChild(element("circle", { cx: p.x, cy: p.y, r: selected ? 15 : 11, class: "node-halo" }));
      node.appendChild(element("circle", { cx: p.x, cy: p.y, r: isCenter ? 6 : 4.5, class: isCenter ? "galaxy-center-point" : "galaxy-star-point" }));
      node.appendChild(element("title", {}, item.name + (isCenter ? " · neighborhood center" : " · " + item.position.distance_ly.toFixed(2) + " ly")));
      const choose = () => { if (!isCenter) chooseGalaxySystem(item); };
      node.addEventListener("click", choose);
      node.addEventListener("keydown", (event) => { if (event.key === "Enter" || event.key === " ") { event.preventDefault(); choose(); } });
      galaxySpatialWorld.appendChild(node);
    });
    galaxySpatialWorld.appendChild(element("text", { x: 18, y: 482, class: "space-map-subtitle" }, "System-centered Cartesian neighborhood · depth compressed for display"));
  }

  function renderGalaxySky() {
    if (!constellationWorld) return;
    constellationWorld.replaceChildren();
    const stage = root.querySelector('[data-galaxy-canvas="sky"]');
    const canvas = stage?.querySelector(".space-map-canvas");
    const unavailable = stage?.querySelector('[data-galaxy-unavailable="sky"]');
    const solObserverContext = selectedSystem === "SOL";
    if (canvas) canvas.hidden = !solObserverContext;
    if (unavailable) {
      unavailable.hidden = solObserverContext;
      unavailable.textContent = `Constellation sky context unavailable for ${data.universe.systems.find((item) => item.id === selectedSystem)?.name || selectedSystem}. The loaded IAU boundary chart is specifically the sky as observed from Sol; no observer-specific chart is supplied for this system.`;
    }
    const footnote = stage?.querySelector(".galaxy-map-footnote");
    if (footnote) footnote.hidden = !solObserverContext;
    if (!solObserverContext) return;
    const catalog = data.constellation_catalog || {};
    const features = catalog.boundaries?.features || [];
    const project = (ra, dec) => {
      let longitude = Number(ra);
      while (longitude < -180) longitude += 360;
      while (longitude > 180) longitude -= 360;
      return { x: (longitude + 180) / 360 * 1000, y: (90 - Number(dec)) / 180 * 500 };
    };

    features.forEach((feature) => {
      const rings = feature.geometry?.coordinates || [];
      rings.forEach((ring) => {
        let segment = [];
        const flush = () => {
          if (segment.length > 1) constellationWorld.appendChild(element("polyline", { points: segment.map((p) => `${p.x.toFixed(2)},${p.y.toFixed(2)}`).join(" "), class: "constellation-boundary" }));
          segment = [];
        };
        ring.forEach((coordinate, index) => {
          const point = project(coordinate[0], coordinate[1]);
          if (index > 0 && Math.abs(point.x - segment[segment.length - 1].x) > 500) flush();
          segment.push(point);
        });
        flush();
      });
    });

    (catalog.constellations || []).forEach((constellation) => {
      const center = constellation.center;
      if (!center) return;
      const p = project(center[0], center[1]);
      constellationWorld.appendChild(element("text", { x: p.x, y: p.y, class: "constellation-label", "text-anchor": "middle" }, constellation.abbreviation));
    });

    (catalog.systems || []).forEach((system) => {
      const p = project(system.position.right_ascension_degrees, system.position.declination_degrees);
      const selected = system.id === selectedGalaxySystemId;
      const node = element("g", { class: `space-map-node galaxy-sky-node ${selected ? "is-selected" : ""}`, tabindex: "0", role: "button", "aria-label": `Select ${system.name}` });
      node.appendChild(element("circle", { cx: p.x, cy: p.y, r: selected ? 8 : 4, class: "galaxy-sky-point" }));
      node.appendChild(element("circle", { cx: p.x, cy: p.y, r: 12, class: "node-halo" }));
      node.appendChild(element("title", {}, `${system.name} · ${system.position.distance_ly.toFixed(2)} ly`));
      const choose = () => chooseGalaxySystem(system);
      node.addEventListener("click", choose);
      node.addEventListener("keydown", (event) => { if (event.key === "Enter" || event.key === " ") { event.preventDefault(); choose(); } });
      constellationWorld.appendChild(node);
    });
    constellationWorld.appendChild(element("text", { x: 18, y: 482, class: "space-map-subtitle" }, "RA increases to the left · boundary coordinates are angular sky regions"));
  }

  function renderGalaxy() {
    renderGalaxySpatial();
    renderGalaxySky();
    updateGalaxySelection();
    root.querySelectorAll("[data-galaxy-mode]").forEach((button) => {
      button.addEventListener("click", () => {
        const mode = button.dataset.galaxyMode;
        root.querySelectorAll("[data-galaxy-mode]").forEach((item) => item.setAttribute("aria-pressed", String(item === button)));
        root.querySelectorAll("[data-galaxy-canvas]").forEach((panel) => { panel.hidden = panel.dataset.galaxyCanvas !== mode; });
        root.querySelector('[data-map-reset="galaxy-spatial"]').hidden = mode !== "spatial";
        root.querySelector('[data-map-reset="galaxy-sky"]').hidden = mode !== "sky";
      });
    });
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
      const select = () => { window.location.assign(`${workspacePath}?system_id=${encodeURIComponent(system.id)}`); };
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
    const stars = system.stars || (system.star ? [system.star] : []);
    const systemObjects = [...stars, ...bodies, ...stations];
    const hasSystemSpatialData = systemObjects.some((item) => {
      if (spatialCoordinates(item)) return true;
      const p = item.display_position || item.map_position;
      return p && Number.isFinite(Number(p.x)) && Number.isFinite(Number(p.y));
    });
    if (!hasSystemSpatialData) {
      world.appendChild(element("text", {
        x: 500, y: 250, class: "space-map-subtitle", "text-anchor": "middle"
      }, `System spatial data unavailable for ${system.name || selectedSystem}. No celestial-body or facility positions are supplied.`));
      return;
    }

    // Never mix coordinate systems on one canvas. Craft are plotted only when
    // their position is explicitly local to this system (SpatialLocation in a
    // shared authoritative frame, or display_position in the fixture frame).
    // A generic craft map_position is not a system-local coordinate.
    const hasSystemSpatialFrame = systemObjects.length > 0 && systemObjects.every((item) => spatialCoordinates(item));
    const craftWithLocalPositions = localCraft.filter((craft) => {
      if (hasSystemSpatialFrame) return Boolean(spatialCoordinates(craft));
      const p = craft.display_position;
      return p && Number.isFinite(Number(p.x)) && Number.isFinite(Number(p.y));
    });
    const objects = [...systemObjects, ...craftWithLocalPositions];
    const hasSpatialFrame = objects.length > 0 && objects.every((item) => spatialCoordinates(item));
    const positionFor = (item) => {
      if (hasSpatialFrame) return spatialCoordinates(item);
      const p = item.display_position || item.map_position;
      return p && Number.isFinite(Number(p.x)) && Number.isFinite(Number(p.y))
        ? { x: Number(p.x), y: Number(p.y), z: 0 }
        : null;
    };
    const objectById = new Map(systemObjects.map((item) => [item.id, item]));
    const objectByName = new Map(systemObjects.map((item) => [item.name, item]));
    const orbitFor = (body) => {
      if (body.orbit) return body.orbit;
      if (Array.isArray(body.orbits) && body.orbits.length) return body.orbits[0];
      return null;
    };
    const parentObjectFor = (body, orbit) => {
      const reference = body.parent_id || body.parent_star || orbit?.around;
      return objectById.get(reference) || objectByName.get(reference) ||
        (reference === "Primary Star" || !reference ? stars[0] : null);
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
    const primaryStarPosition = stars[0] ? positionFor(stars[0]) : null;
    const displayOffsetX = primaryStarPosition ? 500 - primaryStarPosition.x * 10 : 0;
    const displayOffsetY = primaryStarPosition ? 250 - primaryStarPosition.y * 5 : 0;
    const screenPoint = (item) => {
      const position = positionFor(item);
      if (!position) return null;
      const x = position.x - (hasSpatialFrame ? originX : 0);
      const y = position.y - (hasSpatialFrame ? originY : 0);
      if (hasSpatialFrame) return { x: offsetX + x * scale, y: offsetY - y * scale };
      return { x: x * 10 + displayOffsetX, y: y * 5 + displayOffsetY };
    };

    // When orbital elements are absent, retain clearly schematic guide rings
    // from fixture display positions. Planets orbit the primary star; moons
    // use their declared parent body. These guides are not physical elements.
    if (!hasSpatialFrame && showOrbitReferences) {
      bodies.forEach((body) => {
        if (orbitFor(body)) return;
        const parent = parentObjectFor(body, null);
        const center = parent && screenPoint(parent);
        const point = screenPoint(body);
        if (!center || !point) return;
        const radius = Math.hypot(point.x - center.x, point.y - center.y);
        if (radius < 12) return;
        const ring = element("circle", {
          cx: center.x, cy: center.y, r: radius.toFixed(2),
          class: "space-orbit-reference", "data-orbit-body": body.id,
          "data-orbit-parent": parent.id || parent.name
        });
        ring.appendChild(element("title", {}, `Schematic guide for ${body.name || body.id} around ${parent.name || parent.id}; derived from display positions, not orbital elements.`));
        world.appendChild(ring);
      });
    }

    // Draw parent-centered orbital paths from source orbital elements. These
    // are geometric paths, not a live ephemeris. Missing eccentricity/inclination
    // are shown as circular, face-on schematic paths and remain marked as such.
    const displayScale = Number(system.display_layout?.au_to_map_units || 4);
    const frameUnits = String(frame.units || "").toLowerCase();
    const auToFrameUnits = frameUnits === "au" ? 1
      : frameUnits === "m" || frameUnits === "meter" || frameUnits === "meters" ? 149597870700
      : frameUnits === "km" || frameUnits === "kilometer" || frameUnits === "kilometers" ? 149597870.7
      : null;
    const orbitScale = hasSpatialFrame ? auToFrameUnits : displayScale;
    const orbitScreenPoint = (center, x, y) => ({
      x: center.x + x * (hasSpatialFrame ? scale : 10),
      y: center.y - y * (hasSpatialFrame ? scale : 10)
    });
    if (showOrbitReferences) bodies.forEach((body) => {
      const orbit = orbitFor(body);
      const parent = orbit && parentObjectFor(body, orbit);
      if (!orbit || !parent || !Number.isFinite(orbitScale)) return;
      const a = Number(orbit.semi_major_axis_au ?? orbit.source_distance_au);
      if (!Number.isFinite(a) || a <= 0) return;
      const eccentricity = Number.isFinite(Number(orbit.eccentricity)) ? Math.max(0, Math.min(0.95, Number(orbit.eccentricity))) : 0;
      const inclination = Number.isFinite(Number(orbit.inclination_deg)) ? Number(orbit.inclination_deg) : 0;
      const center = screenPoint(parent);
      if (!center) return;
      const path = [];
      for (let step = 0; step <= 120; step += 1) {
        const theta = (step / 120) * Math.PI * 2;
        const radius = a * (1 - eccentricity * eccentricity) / (1 + eccentricity * Math.cos(theta));
        const localX = radius * Math.cos(theta) * Math.cos(0) * orbitScale;
        const localY = radius * Math.sin(theta) * Math.cos(inclination * Math.PI / 180) * orbitScale;
        const point = orbitScreenPoint(center, localX, localY);
        path.push(`${point.x.toFixed(2)},${point.y.toFixed(2)}`);
      }
      const orbitPath = element("polyline", {
        points: path.join(" "),
        fill: "none",
        stroke: "#6f8798",
        "stroke-width": "1.1",
        "stroke-dasharray": "4 5",
        opacity: ".72",
        class: "space-orbit-path"
      });
      orbitPath.appendChild(element("title", {}, `Orbital path for ${body.name || body.id} around ${parent.name || parent.id}, rendered from supplied orbital elements.`));
      world.appendChild(orbitPath);
    });

    // In fixture mode, place bodies on their schematic orbit at the supplied
    // display phase. This is deliberately not an asserted physical position.
    const orbitDisplayPoint = (body) => {
      if (hasSpatialFrame || !system.display_layout?.phase_values_are_illustrative) return null;
      const orbit = orbitFor(body);
      const parent = orbit && parentObjectFor(body, orbit);
      const center = parent && screenPoint(parent);
      const a = Number(orbit?.semi_major_axis_au ?? orbit?.source_distance_au);
      if (!center || !Number.isFinite(a) || a <= 0) return null;
      const e = Number.isFinite(Number(orbit.eccentricity)) ? Number(orbit.eccentricity) : 0;
      const phase = Number(body.display_phase_deg || 0) * Math.PI / 180;
      const radius = a * (1 - e * e) / (1 + e * Math.cos(phase));
      const inclination = Number.isFinite(Number(orbit.inclination_deg)) ? Number(orbit.inclination_deg) : 0;
      const dx = radius * Math.cos(phase) * displayScale;
      const dy = radius * Math.sin(phase) * Math.cos(inclination * Math.PI / 180) * displayScale;
      return orbitScreenPoint(center, dx, dy);
    };

    // A barycenter is a coordinate origin, not an additional star to draw.
    if (origin.type === "barycenter") {
      const p = hasSpatialFrame
        ? { x: offsetX, y: offsetY }
        : origin.map_position
          ? { x: Number(origin.map_position.x) * 10 + displayOffsetX, y: Number(origin.map_position.y) * 5 + displayOffsetY }
          : null;
      if (p) {
        world.appendChild(element("path", {
          d: `M ${p.x - 7} ${p.y} H ${p.x + 7} M ${p.x} ${p.y - 7} V ${p.y + 7}`,
          fill: "none", stroke: "#9aaebc", "stroke-width": "1.2", "stroke-dasharray": "2 3"
        }));
        world.appendChild(element("text", { x: p.x + 10, y: p.y - 10, class: "space-map-subtitle" }, origin.name || "System barycenter"));
      }
    }

    const systemLabelBoxes = [];
    positioned.forEach(({ item }) => {
      const p = orbitDisplayPoint(item) || screenPoint(item);
      if (!p) return;
      const isStar = item.kind === "star" || item.type === "star" || stars.some((starItem) => starItem.id === item.id);
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
      const objectName = item.name || item.id;
      world.appendChild(element("title", {}, objectName));
      addDeclutteredLabel(world, objectName, p.x, p.y, "space-map-label", systemLabelBoxes, { fontSize: isStar ? 12 : 11, gap: 8 });
    });

    // Craft use the same coordinate frame as every other spatial object.
    craftWithLocalPositions.forEach((craft) => {
      const p = screenPoint(craft);
      if (!p) return;
      const marker = element("g", { class: `space-map-node ${craft.id === selectedCraft?.id ? "is-selected" : ""}`, tabindex: "0", role: "button", "aria-label": `Select ${craft.name}` });
      marker.appendChild(element("circle", { cx: p.x, cy: p.y, r: 13, class: "node-halo" }));
      marker.appendChild(element("path", { d: `M ${p.x} ${p.y - 8} L ${p.x + 7} ${p.y + 7} L ${p.x - 7} ${p.y + 7} Z`, fill: craft.id === selectedCraft?.id ? "#ffbf66" : "#d48e42", stroke: "#ffe1b8", "stroke-width": "1" }));
      marker.appendChild(element("title", {}, craft.name));
      if (craft.id === selectedCraft?.id) addDeclutteredLabel(world, craft.name, p.x, p.y, "space-map-label space-map-label-selected", systemLabelBoxes, { fontSize: 11, gap: 9 });
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
      const px = hasSpatialFrame ? offsetX + (x - originX) * scale : x * 10 + displayOffsetX;
      const py = hasSpatialFrame ? offsetY - (y - originY) * scale : y * 5 + displayOffsetY;
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
    selectedGalaxySystemId = selectedSystem;
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
    const focusLabel = document.getElementById("space-focus-label");
    const focusMode = document.getElementById("space-focus-mode");
    const craftSystemName = systemNames[selectedCraft.location_system_id] || selectedCraft.location;
    const systemMatchesCraft = selectedCraft.location_system_id === selectedSystem;
    if (focusMode) focusMode.textContent = systemMatchesCraft ? "ACTIVE CRAFT FOCUS" : "SYSTEM INSPECTION";
    if (focusLabel) focusLabel.textContent = systemMatchesCraft
      ? `${selectedCraft.name} · ${craftSystemName}`
      : `${systemNames[selectedSystem] || data.system.name} · selected asset: ${selectedCraft.name}`;
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
  root.querySelector("[data-toggle-orbit-references]")?.addEventListener("click", (event) => {
    showOrbitReferences = !showOrbitReferences;
    event.currentTarget.setAttribute("aria-pressed", String(showOrbitReferences));
    event.currentTarget.textContent = showOrbitReferences ? "Hide orbits" : "Show orbits";
    renderSystem();
  });
  renderGalaxy();
  renderNetwork();
  renderSystem();
  updateInspector();
})();