(() => {
  const root = document.querySelector("[data-space-root]");
  const payloadNode = document.getElementById("space-view-data");
  const svg = root?.querySelector("#space-planetary-system-map");
  if (!root || !payloadNode || !svg) return;

  let data;
  try { data = JSON.parse(payloadNode.textContent); }
  catch (error) { console.error("Unable to read Planetary System payload", error); return; }

  const ns = "http://www.w3.org/2000/svg";
  const make = (tag, attrs = {}, text = null) => {
    const node = document.createElementNS(ns, tag);
    Object.entries(attrs).forEach(([key, value]) => node.setAttribute(key, String(value)));
    if (text !== null) node.textContent = text;
    return node;
  };
  const bodies = data.system.bodies || [];
  const stations = data.system.stations || [];
  const craft = (data.craft || []).find((item) => item.id === data.selected_craft_id);
  let showOrbits = true;

  const idOf = (item) => item?.id || item?.identifier || item?.name;
  const isMoon = (body) => body?.is_moon === true ||
    String(body?.kind || body?.type || body?.source_category || "").toLowerCase().includes("moon") ||
    Boolean(body?.parent_id || body?.parent_body);
  const parentOf = (body) => {
    const reference = body?.parent_id || body?.parent_body;
    return bodies.find((item) => idOf(item) === reference || item.name === reference) || null;
  };
  const byLocation = (id) => bodies.find((item) => idOf(item) === id) || stations.find((item) => idOf(item) === id) || null;
  const currentRef = craft?.current_position_ref || craft?.position_reference;
  const currentObject = currentRef ? byLocation(currentRef) : null;
  const currentBody = currentObject && stations.includes(currentObject)
    ? bodies.find((body) => body.name === currentObject.near || idOf(body) === currentObject.near)
    : currentObject;
  const currentPlanet = currentBody && isMoon(currentBody) ? parentOf(currentBody) : currentBody;
  const currentStop = (craft?.route_stops || []).find((stop) => stop.status === "current");
  const stopObject = currentStop ? byLocation(currentStop.location_id) : null;
  const stopBody = stopObject && stations.includes(stopObject)
    ? bodies.find((body) => body.name === stopObject.near || idOf(body) === stopObject.near)
    : stopObject;
  const stopPlanet = stopBody && isMoon(stopBody) ? parentOf(stopBody) : stopBody;
  const focus = currentPlanet || stopPlanet || null;

  function positionOf(item) {
    const point = item?.map_position || item?.display_position;
    if (!point) return null;
    const x = Number(point.x), y = Number(point.y);
    return Number.isFinite(x) && Number.isFinite(y) ? { x, y } : null;
  }

  function draw() {
    svg.replaceChildren();
    svg.setAttribute("viewBox", "0 0 1000 500");
    svg.setAttribute("preserveAspectRatio", "xMidYMid meet");
    const world = make("g", { class: "planetary-local-world" });
    svg.appendChild(world);

    if (!focus) {
      world.appendChild(make("text", { x: 500, y: 235, "text-anchor": "middle", class: "space-map-label" }, "No planetary focus is available for this craft."));
      world.appendChild(make("text", { x: 500, y: 262, "text-anchor": "middle", class: "space-map-subtitle" }, "A reported current body or an active planetary route stop is required."));
      return;
    }

    const center = { x: 500, y: 250 };
    const moons = bodies.filter((body) => isMoon(body) && parentOf(body) === focus);
    const localStations = stations.filter((station) =>
      station.near === focus.name || station.near === idOf(focus) ||
      moons.some((moon) => station.near === moon.name || station.near === idOf(moon)));

    world.appendChild(make("circle", { cx: center.x, cy: center.y, r: 76, fill: "rgba(65,151,194,.08)", stroke: "rgba(65,151,194,.25)", "stroke-width": 1.5 }));
    world.appendChild(make("circle", { cx: center.x, cy: center.y, r: 24, fill: "#4b8fb7", stroke: "#d8f1ff", "stroke-width": 1.6 }));
    world.appendChild(make("text", { x: center.x, y: center.y + 48, "text-anchor": "middle", class: "space-map-label space-map-label-selected" }, focus.name || idOf(focus)));
    world.appendChild(make("text", { x: center.x, y: 28, "text-anchor": "middle", class: "space-map-subtitle" }, "LOCAL PLANETARY NAVIGATION · " + (focus.name || idOf(focus)).toUpperCase()));

    if (showOrbits) {
      moons.forEach((moon, index) => {
        const orbit = (moon.orbits || []).find((entry) => {
          const around = entry.around;
          return around === focus.name || around === idOf(focus);
        }) || moon.orbit || null;
        let radius = null;
        const semiMajorAxis = Number(orbit?.semi_major_axis_au);
        if (Number.isFinite(semiMajorAxis) && semiMajorAxis > 0) radius = Math.max(48, Math.min(205, semiMajorAxis * 20000));
        if (!radius) {
          const parentPosition = positionOf(focus), moonPosition = positionOf(moon);
          if (parentPosition && moonPosition) {
            const dx = moonPosition.x - parentPosition.x, dy = moonPosition.y - parentPosition.y;
            radius = Math.max(48, Math.min(205, Math.hypot(dx, dy) * 10));
          }
        }
        if (!radius) return;
        const angle = Number.isFinite(Number(moon.display_phase_deg))
          ? Number(moon.display_phase_deg) * Math.PI / 180
          : (index / Math.max(1, moons.length)) * Math.PI * 2;
        const p = { x: center.x + Math.cos(angle) * radius, y: center.y + Math.sin(angle) * radius };
        world.appendChild(make("circle", { cx: center.x, cy: center.y, r: radius, fill: "none", stroke: "#8199aa", "stroke-width": 1.2, "stroke-dasharray": "4 5", opacity: .8 }));
        world.appendChild(make("circle", { cx: p.x, cy: p.y, r: 7, fill: "#b9c8d2", stroke: "#f0f5f8", "stroke-width": 1 }));
        world.appendChild(make("text", { x: p.x, y: p.y - 13, "text-anchor": "middle", class: "space-map-label" }, moon.name || idOf(moon)));
      });
    }

    localStations.forEach((station, index) => {
      const nearMoon = moons.find((moon) => station.near === moon.name || station.near === idOf(moon));
      const parentPoint = nearMoon ? (() => {
        const moonIndex = moons.indexOf(nearMoon);
        const angle = (moonIndex / Math.max(1, moons.length)) * Math.PI * 2;
        return { x: center.x + Math.cos(angle) * 100, y: center.y + Math.sin(angle) * 100 };
      })() : center;
      const p = positionOf(station);
      const x = p ? center.x + (p.x - (positionOf(focus)?.x || 0)) * 10 : parentPoint.x + 36 + index * 12;
      const y = p ? center.y - (p.y - (positionOf(focus)?.y || 0)) * 5 : parentPoint.y - 30 - index * 10;
      world.appendChild(make("rect", { x: x - 5, y: y - 5, width: 10, height: 10, rx: 2, fill: "#43d39a", stroke: "#d6fff0", "stroke-width": 1 }));
      world.appendChild(make("text", { x: x + 10, y: y + 4, class: "space-map-label" }, station.name || idOf(station)));
    });

    if (currentBody && (currentBody === focus || moons.includes(currentBody))) {
      const marker = { x: center.x + 42, y: center.y - 42 };
      world.appendChild(make("path", {
        d: "M " + marker.x + " " + (marker.y - 9) + " l 8 8 l -8 8 l -8 -8 Z",
        fill: "#ffbf66", stroke: "#fff0c1", "stroke-width": 1.3, class: "space-current-craft-marker"
      }));
      world.appendChild(make("text", { x: marker.x + 13, y: marker.y - 5, class: "space-map-label space-map-label-selected" }, craft.name));
      world.appendChild(make("text", { x: center.x, y: 465, "text-anchor": "middle", class: "space-map-subtitle" }, craft.current_position_label || craft.location));
    }

    if (!moons.length) {
      world.appendChild(make("text", { x: 500, y: 420, "text-anchor": "middle", class: "space-map-subtitle" }, "No moon records are present for this planetary system in the loaded JSON."));
    } else {
      world.appendChild(make("text", { x: 500, y: 465, "text-anchor": "middle", class: "space-map-subtitle" },
        moons.length + " moon record(s) · parent-centered orbital context · spacing may be schematic where source elements are incomplete"));
    }
  }

  root.querySelector("[data-toggle-planetary-orbits]")?.addEventListener("click", (event) => {
    showOrbits = !showOrbits;
    event.currentTarget.setAttribute("aria-pressed", String(showOrbits));
    event.currentTarget.textContent = showOrbits ? "Hide moon orbits" : "Show moon orbits";
    draw();
  });
  root.querySelector('[data-map-reset="planetary-system"]')?.addEventListener("click", draw);
  draw();
})();
