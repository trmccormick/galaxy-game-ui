/**
 * Player Planetary - Self-contained visualization module
 *
 * Ported from Admin Monitor (galaxyGame/galaxy_game/app/javascript/admin/monitor.js).
 * Stripped: data polling, admin-specific logic.
 * Retained: canvas rendering, layer overlays, viewport pan/zoom, color schemes.
 * Data source: inline #monitor-data JSON (mock Earth data).
 */

window.PlayerPlanetary = (function() {
  'use strict';

  // ============================================
  // Module state
  // ============================================

  let planetId        = null;
  let planetName      = '';
  let planetType      = '';
  let climate         = null;
  let planetData      = null;
  let terrainData     = null;
  let monitorData     = null;
  let layers          = {};
  let visibleLayers   = new Set(['terrain']);
  let initialized     = false;
  let hasBiosphere    = false;

  // Viewport state for pan/zoom
  let viewport = {
    offsetX: 0,
    offsetY: 0,
    scale: 1.0,
    isDragging: false,
    dragStartX: 0,
    dragStartY: 0,
    dragStartOffsetX: 0,
    dragStartOffsetY: 0,
    initialized: false
  };

  // ============================================
  // Layer overlay colors (temperature, rainfall, features)
  // ============================================

  const layerOverlays = {
    liquid: {
      terrainColors: {
        coast: '#87CEEB',
        ocean: '#1e3a8a',
        deep_sea: '#000080'
      }
    },
    biomes: {
      terrainColors: {
        forest:   '#228B22',
        jungle:   '#006400',
        grasslands: '#32CD32',
        plains:   '#FFFF00',
        swamp:    '#808000',
        boreal:   '#228B22',
        arctic:   '#ffffff',
        desert:   '#DAA520'
      }
    },
    features: {
      terrainColors: {
        mountains:         '#505050',
        mountain:          '#505050',
        polar_mountains:   '#a0a0a0',
        tropical_mountains:'#606060',
        hills:             '#707050',
        peaks:             '#c0c0c0',
        rock:              '#696969',
        volcanic:          '#8b0000',
        lava:              '#ff4400'
      },
      isFeature: function(biome) {
        if (!biome) return false;
        return (
          biome.includes('mountain') ||
          biome.includes('hill')     ||
          biome.includes('peak')     ||
          biome.includes('volcanic') ||
          biome === 'rock'           ||
          biome === 'lava'
        );
      }
    },
    temperature: {
      getOverlayColor: function(latitude, elevation, globalTemp, pressure) {
        const absLat = Math.abs(latitude);
        let baseTemp;

        if (absLat < 30) {
          baseTemp = globalTemp - 273.15 + 20 - (absLat / 30) * 10;
        } else if (absLat < 60) {
          baseTemp = globalTemp - 273.15 - ((absLat - 30) / 30) * 20;
        } else {
          baseTemp = globalTemp - 273.15 - 20 - ((absLat - 60) / 30) * 30;
        }

        const elevationMeters  = elevation * 8000;
        const elevationCooling = (elevationMeters / 1000) * 6.5;
        const elevationTemp    = baseTemp - elevationCooling;
        const pressureTemp     = elevationTemp * (0.5 + Math.min(pressure, 1.0) * 0.5);

        if (pressureTemp > 35)    return '#ff0000';
        if (pressureTemp > 25)    return '#ff4400';
        if (pressureTemp > 15)    return '#ff8800';
        if (pressureTemp > 5)     return '#ffcc00';
        if (pressureTemp > -5)    return '#88cc44';
        if (pressureTemp > -15)   return '#44aaff';
        if (pressureTemp > -30)   return '#2288ff';
        return '#0066cc';
      },
      terrainColors: {}
    },
    rainfall: {
      terrainColors: {
        tropical_rainforest:      '#0033ff',
        jungle:                   '#0044ff',
        swamp:                    '#0055ff',
        tropical_seasonal_forest: '#0066ff',
        temperate_forest:         '#2288ff',
        temperate_rainforest:     '#1166ff',
        boreal_forest:            '#4499ff',
        forest:                   '#3388ff',
        boreal:                   '#55aaff',
        temperate_grassland:      '#66bbff',
        grassland:                '#77ccff',
        grasslands:               '#77ccff',
        tropical_grassland:       '#88ddff',
        plains:                   '#99eeff',
        tundra:                   '#aaddcc',
        polar_desert:             '#ffee88',
        desert:                   '#ffcc00',
        ocean:                    '#004488',
        coast:                    '#006699'
      }
    },
    resources: {
      terrainColors: {
        rock:   '#ffd700',
        desert: '#daa520'
      }
    }
  };

  // ============================================
  // Utilities
  // ============================================

  function hexToRgb(hex) {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? {
      r: parseInt(result[1], 16),
      g: parseInt(result[2], 16),
      b: parseInt(result[3], 16)
    } : null;
  }

  function blendColors(baseColor, overlayColor, alpha) {
    const base    = hexToRgb(baseColor);
    const overlay = hexToRgb(overlayColor);
    if (!base || !overlay) return baseColor;
    const r = Math.round(base.r * (1 - alpha) + overlay.r * alpha);
    const g = Math.round(base.g * (1 - alpha) + overlay.g * alpha);
    const b = Math.round(base.b * (1 - alpha) + overlay.b * alpha);
    return '#' + r.toString(16).padStart(2, '0') +
                 g.toString(16).padStart(2, '0') +
                 b.toString(16).padStart(2, '0');
  }

  function formatMass(mass) {
    if (mass > 1e18) return (mass / 1e18).toFixed(2) + ' Eg';
    if (mass > 1e15) return (mass / 1e15).toFixed(2) + ' Pg';
    if (mass > 1e12) return (mass / 1e12).toFixed(2) + ' Tg';
    if (mass > 1e9)  return (mass / 1e9).toFixed(2)  + ' Gg';
    return mass.toFixed(2) + ' kg';
  }

  // ============================================
  // Climate / color classification
  // ============================================

  function calculateClimateZones(tempK, pressureBar) {
    const Ts = tempK;
    const Tp = Ts - 75 / (1 + 5 * pressureBar);
    const Tt = Ts * 1.1;

    let iceLat  = 0;
    let habRatio = 0;

    if (Tt > 273 && Tp < 273) {
      habRatio = Math.pow((Tt - 273) / (Tt - Tp), 0.666667);
      iceLat   = Math.asin(habRatio) * 180 / Math.PI;
    } else if (Tt < 273) {
      habRatio = 0;
      iceLat   = 90;
    } else {
      habRatio = 1;
      iceLat   = 0;
    }

    return {
      surfaceTemp:   Ts,
      polarTemp:     Tp,
      tropicalTemp:  Tt,
      iceLatitude:   iceLat,
      habitableRatio: habRatio,
      polarZone:     iceLat,
      temperateZone: Math.max(iceLat + 30, 45),
      tropicalZone:  Math.max(iceLat + 60, 75)
    };
  }

  function getTerrainColorScheme(pData) {
    const type       = pData.type;
    const atmosphere = pData.atmosphere;
    const surfaceTemp = pData.surface_temperature || pData.temperature || 288;
    const geologicalActivity =
      pData.geological_activity || pData.geosphere_attributes?.geological_activity || 50;
    const gravity = pData.gravity || 1.0;
    const name    = (pData.name || '').toLowerCase();

    const geosphere = pData.geosphere_attributes || pData.geosphere || {};
    const crust = geosphere.crust_composition || {};
    const surface_color_hint = geosphere.surface_color_hint ||
                               pData.properties?.surface_color_hint;

    const ironOxide = crust.iron_oxide || crust.Fe2O3 || 0;
    const isRusty = ironOxide > 10 || surface_color_hint === '#cd5c3c';

    if (surfaceTemp > 700 && geologicalActivity > 80) {
      return { low: '#1a0000', high: '#ff4500' };
    }

    if (atmosphere && atmosphere.pressure > 10 && surfaceTemp > 400) {
      return { low: '#8b4513', high: '#ffa500' };
    }

    if ((atmosphere && atmosphere.pressure > 0.001 && atmosphere.pressure < 0.1 &&
         surfaceTemp < 280 && surfaceTemp > 150 && gravity > 2 && gravity < 5)) {
      return { low: '#4a2810', high: '#cd5c3c' };
    }

    if ((atmosphere && atmosphere.pressure < 0.001) ||
        !atmosphere ||
        gravity < 0.3 ||
        type?.includes('moon')     ||
        type?.includes('asteroid') ||
        type?.includes('dwarf_planet') ||
        name === 'luna' || name === 'moon' || name === 'mercury') {
      return { low: '#4a4a4a', high: '#d0d0d0' };
    }

    if (type?.includes('carbon') || crust.elements?.C > 25 || (crust.C && crust.C > 25)) {
      return { low: '#2f2f2f', high: '#696969' };
    }

    return { low: '#2d1810', high: '#d2b48c' };
  }

  function getElevationColor(normalizedElevation, pData) {
    if (normalizedElevation == null) return '#000000';
    const scheme  = getTerrainColorScheme(pData);
    const lowRgb  = hexToRgb(scheme.low);
    const highRgb = hexToRgb(scheme.high);
    if (!lowRgb || !highRgb) return '#808080';
    const r = Math.round(lowRgb.r + (highRgb.r - lowRgb.r) * normalizedElevation);
    const g = Math.round(lowRgb.g + (highRgb.g - lowRgb.g) * normalizedElevation);
    const b = Math.round(lowRgb.b + (highRgb.b - lowRgb.b) * normalizedElevation);
    return `rgb(${r}, ${g}, ${b})`;
  }

  function getBiomeColor(biome, latitude) {
    const biomeColors = {
      desert:          '#DAA520',
      polar_desert:    '#E8DCC8',
      hot_desert:      '#F4A460',
      grassland:       '#7CCD7C',
      grasslands:      '#7CCD7C',
      temperate_grassland: '#90EE90',
      tropical_grassland:  '#98FB98',
      savanna:         '#9ACD32',
      forest:          '#228B22',
      temperate_forest:'#228B22',
      tropical_seasonal_forest: '#006400',
      tropical_rainforest:      '#004000',
      boreal_forest:   '#2E8B57',
      boreal:          '#2E8B57',
      jungle:          '#004400',
      temperate_rainforest: '#006633',
      tundra:          '#B8C4C8',
      arctic:          '#E8E8E8',
      ice:             '#E0FFFF',
      polar_ice:       '#F0FFFF',
      snow:            '#FFFAFA',
      swamp:           '#556B2F',
      marsh:           '#6B8E23',
      wetland:         '#698B69',
      wetlands:        '#698B69',
      plains:          '#C4B454',
      steppe:          '#BDB76B',
      lowlands:        '#8FBC8F',
      highlands:       '#BC8F8F',
      mountains:       '#808080',
      mountain:        '#808080',
      polar_mountains: '#A9A9A9',
      tropical_mountains: '#696969',
      hills:           '#8B7765',
      peaks:           '#DCDCDC',
      volcanic:        '#8B0000',
      lava:            '#FF4500',
      maria:           '#3C3C3C',
      ocean:           '#0066cc',
      coast:           '#4682B4',
      deep_sea:        '#003366'
    };

    if (biome && biomeColors[biome]) return biomeColors[biome];

    if (biome) {
      const lower = biome.toLowerCase();
      if (lower.includes('desert')) {
        if (latitude != null) {
          const absLat = Math.abs(latitude);
          if (absLat > 60) return '#ffeedd';
          if (absLat > 30) return '#f4d89e';
        }
        return '#DAA520';
      }
      if (lower.includes('forest'))   return '#228B22';
      if (lower.includes('grass'))    return '#7CCD7C';
      if (lower.includes('tundra'))   return '#B8C4C8';
      if (lower.includes('mountain')) return '#808080';
      if (lower.includes('peak'))     return '#DCDCDC';
      if (lower.includes('hill'))     return '#8B7765';
      if (lower.includes('ice') || lower.includes('snow')) return '#E0FFFF';
      if (lower.includes('jungle') || lower.includes('rain')) return '#004400';
      if (lower.includes('savanna'))  return '#9ACD32';
      if (lower.includes('plain'))    return '#C4B454';
    }

    return '#8B4513';
  }

  // ============================================
  // Hydrosphere color – composition aware
  // ============================================

  function getHydrosphereColor(waterDepth, pData) {
    const name   = (pData.name || '').toLowerCase();
    const liquid = (pData.liquid_name || 'H2O').toUpperCase();
    const temp   = pData.surface_temperature || pData.temperature || 288;

    const shallowThreshold = 200;
    const deepThreshold    = 4000;

    if (liquid === 'ICE' || liquid.includes('FROZEN') ||
        (liquid === 'H2O' && temp < 273)) {
      if (waterDepth < shallowThreshold) {
        const t = waterDepth / shallowThreshold;
        const v = Math.round(240 - t * 20);
        return `rgba(${v}, ${v}, 255, 0.8)`;
      } else if (waterDepth < deepThreshold) {
        const t = (waterDepth - shallowThreshold) / (deepThreshold - shallowThreshold);
        const v = Math.round(220 - t * 40);
        return `rgba(${v}, ${v}, 255, 0.85)`;
      } else {
        const t = Math.min(1, (waterDepth - deepThreshold) / 4000);
        const v = Math.round(180 - t * 40);
        return `rgba(${v}, ${v}, 255, 0.9)`;
      }
    }

    if (liquid === 'CH4' || liquid === 'C2H6' ||
        liquid.includes('METHANE') || liquid.includes('ETHANE')) {
      if (waterDepth < shallowThreshold) {
        const t = waterDepth / shallowThreshold;
        const r = Math.round(255 - t * 30);
        const g = Math.round(180 - t * 40);
        const b = Math.round(50  - t * 20);
        return `rgba(${r}, ${g}, ${b}, 0.8)`;
      } else if (waterDepth < deepThreshold) {
        const t = (waterDepth - shallowThreshold) / (deepThreshold - shallowThreshold);
        const r = Math.round(225 - t * 75);
        const g = Math.round(140 - t * 60);
        const b = Math.round(30  - t * 30);
        return `rgba(${r}, ${g}, ${b}, 0.85)`;
      } else {
        const t = Math.min(1, (waterDepth - deepThreshold) / 4000);
        const r = Math.round(150 - t * 50);
        const g = Math.round(80  - t * 40);
        const b = 0;
        return `rgba(${r}, ${g}, ${b}, 0.9)`;
      }
    }

    if (liquid === 'N2' || liquid.includes('NITROGEN')) {
      if (waterDepth < shallowThreshold) {
        const t = waterDepth / shallowThreshold;
        const r = Math.round(240 - t * 10);
        const g = Math.round(240 - t * 20);
        const b = Math.round(250 - t * 20);
        return `rgba(${r}, ${g}, ${b}, 0.7)`;
      } else if (waterDepth < deepThreshold) {
        const t = (waterDepth - shallowThreshold) / (deepThreshold - shallowThreshold);
        const r = Math.round(230 - t * 30);
        const g = Math.round(220 - t * 40);
        const b = Math.round(230 - t * 50);
        return `rgba(${r}, ${g}, ${b}, 0.75)`;
      } else {
        const t = Math.min(1, (waterDepth - deepThreshold) / 4000);
        const r = Math.round(200 - t * 30);
        const g = Math.round(180 - t * 40);
        const b = Math.round(180 - t * 40);
        return `rgba(${r}, ${g}, ${b}, 0.8)`;
      }
    }

    if (liquid === 'NH3' || liquid.includes('AMMONIA')) {
      if (waterDepth < shallowThreshold) {
        const t = waterDepth / shallowThreshold;
        const r = Math.round(200 - t * 30);
        const g = Math.round(150 - t * 50);
        const b = Math.round(255 - t * 30);
        return `rgba(${r}, ${g}, ${b}, 0.75)`;
      } else if (waterDepth < deepThreshold) {
        const t = (waterDepth - shallowThreshold) / (deepThreshold - shallowThreshold);
        const r = Math.round(170 - t * 50);
        const g = Math.round(100 - t * 50);
        const b = Math.round(225 - t * 75);
        return `rgba(${r}, ${g}, ${b}, 0.8)`;
      } else {
        const t = Math.min(1, (waterDepth - deepThreshold) / 4000);
        const r = Math.round(120 - t * 30);
        const g = Math.round(50  - t * 20);
        const b = Math.round(150 - t * 50);
        return `rgba(${r}, ${g}, ${b}, 0.85)`;
      }
    }

    // Default: H2O-like water
    if (waterDepth < shallowThreshold) {
      const t = waterDepth / shallowThreshold;
      const r = Math.round(100 - t * 50);
      const g = Math.round(200 - t * 50);
      const b = Math.round(255 - t * 35);
      return `rgba(${r}, ${g}, ${b}, 0.85)`;
    } else if (waterDepth < deepThreshold) {
      const t = (waterDepth - shallowThreshold) / (deepThreshold - shallowThreshold);
      const r = Math.round(50  - t * 50);
      const g = Math.round(150 - t * 100);
      const b = Math.round(220 - t * 70);
      return `rgba(${r}, ${g}, ${b}, 0.9)`;
    } else {
      const t = Math.min(1, (waterDepth - deepThreshold) / 4000);
      const g = Math.round(20 - t * 10);
      const b = Math.round(100 - t * 20);
      return `rgba(0, ${g}, ${b}, 0.95)`;
    }
  }

  // ============================================
  // Hydrosphere: Bathtub algorithm
  // ============================================

  function calculateWaterLayerFromHydrosphere(elevationLayer) {
    if (!elevationLayer || !elevationLayer.grid) return null;

    const width  = elevationLayer.width;
    const height = elevationLayer.height;
    const elevationGrid = elevationLayer.grid;

    let coverage = 0;

    if (planetData.surface_liquid_coverage != null) {
      coverage = planetData.surface_liquid_coverage;
    } else if (planetData.hydrosphere && planetData.hydrosphere.state_distribution &&
               planetData.hydrosphere.state_distribution.liquid != null) {
      coverage = planetData.hydrosphere.state_distribution.liquid;
    } else if (planetData.water_coverage != null) {
      coverage = planetData.water_coverage;
    }

    if (coverage > 1) coverage /= 100.0;
    coverage = Math.max(0, Math.min(1, coverage));
    if (coverage <= 0) return null;

    const allElevations = [];
    let hasNegative = false;

    for (let y = 0; y < height; y++) {
      for (let x = 0; x < width; x++) {
        const elev = elevationGrid[y][x];
        if (elev != null && elev !== undefined) {
          allElevations.push(elev);
          if (elev < 0) hasNegative = true;
        }
      }
    }

    if (allElevations.length === 0) return null;

    let seaLevel = 0;

    if (hasNegative) {
      seaLevel = 0;
    } else {
      allElevations.sort((a, b) => a - b);
      const seaLevelIndex = Math.floor(allElevations.length * coverage);
      seaLevel = allElevations[Math.min(seaLevelIndex, allElevations.length - 1)];
    }

    const waterGrid = [];
    for (let y = 0; y < height; y++) {
      waterGrid[y] = [];
      for (let x = 0; x < width; x++) {
        const elevation = elevationGrid[y][x];
        if (elevation != null && elevation < seaLevel) {
          waterGrid[y][x] = seaLevel - elevation;
        } else {
          waterGrid[y][x] = 0;
        }
      }
    }

    return {
      grid:          waterGrid,
      width:         width,
      height:        height,
      layer_type:    'liquid',
      sea_level:     seaLevel,
      water_coverage: coverage
    };
  }

  // ============================================
  // Adaptive grid (pixelation fix)
  // ============================================

  function calculateAdaptiveGrid(planetData, terrainData) {
    if (!planetData || !terrainData) {
      return {
        width: 80,
        height: 50,
        tileSize: 8,
        totalWidth: 640,
        totalHeight: 400,
        adaptive: false
      };
    }

    const diameterKm = planetData.diameter || planetData.radius * 2 || 12742;
    const bodyType   = planetData.type || planetData.body_category || 'planet';
    const name       = (planetData.name || '').toLowerCase();

    const earthDiameter = 12742;
    const diameterRatio = Math.max(0.01, diameterKm / earthDiameter);

    let baseGridSize;
    if (diameterKm < 100) {
      baseGridSize = Math.max(40, Math.min(120, 80 * Math.sqrt(1 / diameterRatio)));
    } else if (diameterKm < 1000) {
      baseGridSize = Math.max(50, Math.min(100, 80 * Math.sqrt(1 / diameterRatio)));
    } else if (diameterKm < 5000) {
      baseGridSize = Math.max(60, Math.min(120, 80 * Math.sqrt(diameterRatio)));
    } else {
      baseGridSize = Math.max(70, Math.min(150, 80 * diameterRatio));
    }

    if (name === 'luna' || name === 'moon' || bodyType.includes('moon')) {
      baseGridSize = 60;
    } else if (name === 'mars' || bodyType.includes('terrestrial')) {
      baseGridSize = 90;
    } else if (bodyType.includes('gas_giant') || bodyType.includes('ice_giant')) {
      baseGridSize = Math.min(120, baseGridSize);
    }

    const targetMinResolution = 800;
    let tileSize = Math.max(4, Math.min(24, targetMinResolution / baseGridSize));

    return {
      width:        baseGridSize,
      height:       Math.floor(baseGridSize * 0.5),
      tileSize:     tileSize,
      totalWidth:   baseGridSize * tileSize,
      totalHeight:  Math.floor(baseGridSize * 0.5) * tileSize,
      adaptive:     true
    };
  }

  // ============================================
  // Extract layers from terrain data
  // ============================================

  function extractLayers(terrainData) {
    const canvas = document.getElementById('planetCanvas');
    if (!canvas) return;
    const ctx = canvas.getContext('2d');

    layers = {
      terrain:   null,
      liquid:    null,
      biomes:    null,
      resources: null,
      elevation: null
    };

    // NASA-first: elevation
    if (terrainData && terrainData.elevation) {
      layers.elevation = {
        grid:   terrainData.elevation,
        width:  terrainData.elevation[0]?.length || 0,
        height: terrainData.elevation.length,
        layer_type: 'elevation',
        quality: terrainData.quality_score || 'mock',
        method:  terrainData.generation_method || 'prototype_placeholder'
      };
    }

    // Biomes
    if (terrainData && terrainData.biomes &&
        Array.isArray(terrainData.biomes) &&
        terrainData.biomes.length > 0 &&
        Array.isArray(terrainData.biomes[0]) &&
        layers.elevation &&
        terrainData.biomes.length === layers.elevation.height &&
        terrainData.biomes[0].length === layers.elevation.width) {

      layers.biomes = {
        grid:   terrainData.biomes,
        width:  terrainData.biomes[0].length,
        height: terrainData.biomes.length,
        layer_type: 'biomes'
      };
    }

    // Resources
    if (terrainData && terrainData.resource_grid &&
        Array.isArray(terrainData.resource_grid) &&
        terrainData.resource_grid.length > 0) {
      layers.resources = {
        grid:   terrainData.resource_grid,
        width:  terrainData.resource_grid[0]?.length || 0,
        height: terrainData.resource_grid.length,
        layer_type: 'resources'
      };
    }

    // Hydrosphere layer (always named "liquid" internally)
    if (layers.elevation && planetData) {
      layers.liquid = calculateWaterLayerFromHydrosphere(layers.elevation);
    }

    if (terrainData && terrainData.decomposed_layers) {
      terrainData = terrainData.decomposed_layers;
    }

    if (!layers.terrain && terrainData) {
      layers.terrain = terrainData;
    }

    if (!layers.elevation) {
      ctx.fillStyle = '#000000';
      ctx.fillRect(0, 0, canvas.width, canvas.height);
      ctx.fillStyle = '#ffffff';
      ctx.font = '16px monospace';
      ctx.textAlign = 'center';
      ctx.fillText('NO TERRAIN DATA', canvas.width / 2, canvas.height / 2 - 20);
      ctx.fillText('AVAILABLE', canvas.width / 2, canvas.height / 2 + 10);
      return;
    }

    const width         = layers.elevation.width;
    const height        = layers.elevation.height;
    const elevationData = layers.elevation.grid;

    if (width === 0 || height === 0) return;

    // Scale tile size so the terrain fills the available canvas area.
    // The adaptive-grid tileSize is ignored for rendering; it was designed
    // for grids that match its expected dimensions.  Our mock data has a
    // different grid size, so we compute a fitting tile size here.
    const margin = 80; // px padding around the map
    const availW = canvas.width  - margin * 2;
    const availH = canvas.height - margin * 2;
    const tileByW = Math.floor(availW / width);
    const tileByH = Math.floor(availH / height);
    const tileSize = Math.max(4, Math.min(tileByW, tileByH));

    canvas.width   = width  * tileSize;
    canvas.height  = height * tileSize;

    // Center the map only once per body
    if (!viewport.initialized) {
      viewport.offsetX = 0;
      viewport.offsetY = 0;
      viewport.initialized = true;
    }

    const canvasContainer = document.getElementById('canvasContainer');
    if (canvasContainer) {
      canvasContainer.style.width  = (width  * tileSize) + 'px';
      canvasContainer.style.height = (height * tileSize) + 'px';
    }
  }

  // ============================================
  // Render terrain map
  // ============================================

  function renderTerrainMap() {
    const canvas = document.getElementById('planetCanvas');
    if (!canvas) return;
    const ctx = canvas.getContext('2d');

    if (!layers.elevation) {
      ctx.fillStyle = '#000000';
      ctx.fillRect(0, 0, canvas.width, canvas.height);
      ctx.fillStyle = '#ffffff';
      ctx.font = '14px monospace';
      ctx.textAlign = 'center';
      ctx.fillText('Terrain data not available.', canvas.width / 2, canvas.height / 2);
      ctx.font = '11px monospace';
      ctx.fillStyle = '#888888';
      ctx.fillText('(Mock Earth — terrain map from main app pending)', canvas.width / 2, canvas.height / 2 + 20);
      return;
    }

    const width         = layers.elevation.width;
    const height        = layers.elevation.height;
    const elevationData = layers.elevation.grid;

    if (width === 0 || height === 0) return;

    // Min/max elevation
    let minElevation = Infinity;
    let maxElevation = -Infinity;
    for (let y = 0; y < height; y++) {
      for (let x = 0; x < width; x++) {
        const elev = elevationData[y][x];
        if (elev != null) {
          minElevation = Math.min(minElevation, elev);
          maxElevation = Math.max(maxElevation, elev);
        }
      }
    }
    if (minElevation === Infinity)  minElevation = 0;
    if (maxElevation === -Infinity) maxElevation = 1000;

    ctx.fillStyle = '#000000';
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    const hasBiosphere = planetData?.has_biosphere || false;

    // Draw terrain base layer
    for (let y = 0; y < height; y++) {
      for (let x = 0; x < width; x++) {
        const rawElevation = elevationData[y][x];
        const elevationRange = maxElevation - minElevation;
        const normalizedElevation = elevationRange > 0
          ? (rawElevation - minElevation) / elevationRange
          : 0.5;

        let color = getElevationColor(normalizedElevation, planetData);

        // LAYER 1: liquid (hydrosphere)
        if (visibleLayers.has('liquid') &&
            layers.liquid && layers.liquid.grid &&
            layers.liquid.grid[y] && layers.liquid.grid[y][x] > 0) {

          const waterDepth = layers.liquid.grid[y][x];
          let primaryLiquid = 'H2O';

          if (planetData.hydrosphere && planetData.hydrosphere.composition) {
            const comp = planetData.hydrosphere.composition;
            primaryLiquid = Object.keys(comp).reduce(
              (a, b) => comp[a] > comp[b] ? a : b,
              'H2O'
            );
          } else if (planetData.liquid_name) {
            primaryLiquid = planetData.liquid_name;
          }

          const hydroData = Object.assign({}, planetData, { liquid_name: primaryLiquid });
          color = getHydrosphereColor(waterDepth, hydroData);
        }

        // LAYER 2: biomes
        if (visibleLayers.has('biomes') && hasBiosphere && layers.biomes) {
          if (layers.biomes.grid && layers.biomes.grid[y] && layers.biomes.grid[y][x]) {
            const biome = layers.biomes.grid[y][x];
            if (biome && biome !== 'ocean' && biome !== 'none') {
              const isUnderwater =
                layers.liquid && layers.liquid.grid &&
                layers.liquid.grid[y] && layers.liquid.grid[y][x] > 0;

              if (!isUnderwater) {
                const latitude = (y / height - 0.5) * 180;
                const biomeColor = getBiomeColor(biome, latitude);
                color = biomeColor;
              }
            }
          }
        }

        // LAYER 3: resources
        if (visibleLayers.has('resources') &&
            layers.resources &&
            layers.resources.grid[y] &&
            layers.resources.grid[y][x]) {
          const resource = layers.resources.grid[y][x];
          if (resource && resource !== 'none') {
            color = blendColors(color, '#FFFF00', 0.4);
          }
        }

        // LAYER 4: Temperature overlay
        if (visibleLayers.has('temperature') &&
            !(visibleLayers.has('liquid') && layers.liquid?.grid?.[y]?.[x] > 0)) {
          const latitude = (y / height - 0.5) * 180;
          const absLat = Math.abs(latitude);
          let tempC = (planetData.surface_temperature || 288) - 273.15;
          tempC -= absLat * 0.4;
          const elevationKm = normalizedElevation * 8;
          tempC -= elevationKm * 6.5;
          const pressureMod = planetData.atmosphere?.pressure || 1.0;
          tempC *= (0.6 + pressureMod * 0.4);
          const hue = Math.max(0, Math.min(240, 40 - tempC * 3));
          const saturation = Math.min(90, 50 + Math.abs(tempC) * 0.8);
          const lightness = Math.max(30, 60 - Math.abs(tempC) * 0.4);
          color = `hsl(${hue}, ${saturation}%, ${lightness}%)`;
        }

        // LAYER 5: Rainfall overlay
        if (visibleLayers.has('rainfall') && planetData.has_hydrosphere) {
          const latitude = (y / height - 0.5) * 180;
          const absLat = Math.abs(latitude);
          let primaryLiquid = 'H2O';
          if (planetData.hydrosphere && planetData.hydrosphere.composition) {
            const comp = planetData.hydrosphere.composition;
            primaryLiquid = Object.keys(comp).reduce(
              (a, b) => comp[a] > comp[b] ? a : b, 'H2O'
            );
          } else if (planetData.liquid_name) {
            primaryLiquid = planetData.liquid_name;
          }
          const liquidUpper = (primaryLiquid || '').toUpperCase();
          const surfaceTemp = planetData.surface_temperature || planetData.temperature || 288;

          if (planetData.has_atmosphere) {
            let wetness = Math.sin((90 - absLat) * Math.PI / 180) ** 1.2;
            wetness = Math.max(0.1, wetness);
            const elevationDryness = Math.min(1.0, normalizedElevation * 0.6);
            wetness *= (1.0 - elevationDryness * 0.5);
            let coastalBoost = 1.0;
            if (layers.liquid?.grid) {
              for (let dy = -1; dy <= 1; dy++) {
                for (let dx = -1; dx <= 1; dx++) {
                  if (dx === 0 && dy === 0) continue;
                  const ny = Math.max(0, Math.min(height-1, y + dy));
                  const nx = Math.max(0, Math.min(width-1, x + dx));
                  if (layers.liquid.grid[ny]?.[nx] > 0) {
                    coastalBoost = 1.4;
                    break;
                  }
                }
                if (coastalBoost > 1.0) break;
              }
            }
            wetness *= coastalBoost;
            wetness = Math.max(0.0, Math.min(1.0, wetness));
            if (wetness >= 0.75) {
              const intensity = 30 + (wetness - 0.75) * 40;
              color = `hsl(220, 80%, ${intensity}%)`;
            } else if (wetness >= 0.50) {
              const intensity = 45 + (wetness - 0.50) * 20;
              color = `hsl(200, 70%, ${intensity}%)`;
            } else if (wetness >= 0.30) {
              const intensity = 60 + (wetness - 0.30) * 15;
              color = `hsl(180, 60%, ${intensity}%)`;
            } else if (wetness >= 0.15) {
              const intensity = 70 - (wetness - 0.15) * 20;
              color = `hsl(60, 75%, ${intensity}%)`;
            } else {
              const intensity = 55 - wetness * 15;
              color = `hsl(30, 70%, ${intensity}%)`;
            }
          }
        }

        // LAYER 6: features
        if (visibleLayers.has('features') && hasBiosphere) {
          const biome = layers.biomes?.grid[y]?.[x];
          if (biome && layerOverlays.features.isFeature(biome)) {
            color = layerOverlays.features.terrainColors[biome] || '#696969';
          } else if (normalizedElevation > 0.85) {
            color = '#808080';
          }
        }

        if (color) {
          ctx.fillStyle = color;
          const screenX = x * viewport.scale + viewport.offsetX;
          const screenY = y * viewport.scale + viewport.offsetY;
          const screenSize = Math.max(1, viewport.scale);
          ctx.fillRect(screenX, screenY, screenSize, screenSize);
        }
      }
    }

    setTimeout(centerMapView, 50);
  }

  // ============================================
  // UI helpers
  // ============================================

  function logConsole(message, type) {
    type = type || 'info';
    const consoleEl = document.getElementById('console');
    if (!consoleEl) return;
    const line = document.createElement('div');
    line.className = `console-line ${type}`;
    const timestamp = new Date().toLocaleTimeString();
    line.textContent = `[${timestamp}] > ${message}`;
    consoleEl.appendChild(line);
    consoleEl.scrollTop = consoleEl.scrollHeight;
    while (consoleEl.children.length > 50) {
      consoleEl.removeChild(consoleEl.firstChild);
    }
  }

  function centerMapView() {
    const scroller = document.getElementById('canvasScroller');
    const canvas   = document.getElementById('planetCanvas');
    if (!scroller || !canvas) return;
    const dx = (canvas.width  - scroller.clientWidth)  / 2;
    const dy = (canvas.height - scroller.clientHeight) / 2;
    scroller.scrollLeft = Math.max(0, dx);
    scroller.scrollTop  = Math.max(0, dy);
  }

  function updateElement(id, value) {
    const el = document.getElementById(id);
    if (el) el.textContent = value;
  }

  function updateProgressBar(id, percentage) {
    const el = document.getElementById(id);
    if (el) el.style.width = `${percentage}%`;
  }

  // ============================================
  // Layer toggles
  // ============================================

  function toggleLayer(layerName) {
    if (layerName === 'terrain') {
      logConsole('Terrain is the base layer and cannot be disabled', 'warning');
      return;
    }

    let internalLayer = layerName;
    if (layerName === 'water') internalLayer = 'liquid';

    if (visibleLayers.has(internalLayer)) {
      visibleLayers.delete(internalLayer);
      logConsole(`${internalLayer} overlay hidden`, 'info');
    } else {
      visibleLayers.add(internalLayer);
      logConsole(`${internalLayer} overlay shown`, 'info');
    }

    renderTerrainMap();
    updateLayerButtons();
  }

  function updateLayerButtons() {
    document.querySelectorAll('.layer-btn').forEach(btn => {
      const layer = btn.dataset.layer;
      let internalLayer = layer;
      if (layer === 'water') internalLayer = 'liquid';

      if (visibleLayers.has(internalLayer)) {
        btn.classList.add('active');
      } else {
        btn.classList.remove('active');
      }
    });
  }

  // ============================================
  // Populate data panel from mock/real planet data
  // ============================================

  function populateDataPanel() {
    if (!planetData) return;

    const p = planetData;

    // Atmosphere section
    updateElement('atmo-pressure', (p.atmosphere?.pressure || p.atmosphere_pressure || 1.0).toFixed(2) + ' atm');
    updateElement('atmo-temp', (p.surface_temperature || p.temperature || p.atmosphere?.temperature || 288) + ' K');
    updateElement('atmo-mass', formatMass(p.atmosphere?.total_mass || 5.15e19));

    // Atmosphere composition
    const compEl = document.getElementById('atmo-composition');
    if (compEl && p.atmosphere?.composition) {
      const comp = p.atmosphere.composition;
      compEl.innerHTML = Object.entries(comp).map(([gas, pct]) =>
        `<div class="data-row mb-1 flex justify-between">
           <span class="data-label" style="color: var(--gg-text-secondary);">${gas}:</span>
           <span class="data-value text-[var(--gg-primary)]">${pct.toFixed(1)}%</span>
         </div>`
      ).join('');
    }

    // Biosphere section
    if (p.has_biosphere) {
      const bioDiv = document.getElementById('bio-diversity');
      const bioHab = document.getElementById('bio-habitability');
      const bioLife = document.getElementById('bio-lifeforms');
      const bioDivBar = document.getElementById('bio-diversity-bar');
      const bioHabBar = document.getElementById('bio-habitability-bar');

      if (p.biosphere_attributes) {
        const ba = p.biosphere_attributes;
        const biodiv = (ba.biodiversity_index || 0.65) * 100;
        const habrat = (ba.habitable_ratio || 0.92) * 100;
        if (bioDiv) bioDiv.textContent = biodiv.toFixed(1) + '%';
        if (bioHab) bioHab.textContent = habrat.toFixed(1) + '%';
        if (bioDivBar) bioDivBar.style.width = biodiv + '%';
        if (bioHabBar) bioHabBar.style.width = habrat + '%';
      }
      if (bioLife) bioLife.textContent = p.biosphere_attributes?.life_forms || 'Extensive';
    }

    // Geosphere section
    const geoCore = document.getElementById('geo-core');
    if (p.geosphere_attributes) {
      updateElement('geo-activity', (p.geosphere_attributes.geological_activity || 50) + '/100');
      updateElement('geo-tectonic', p.geosphere_attributes.tectonic_active ? 'Yes' : 'No');
      if (geoCore) geoCore.textContent = formatMass(p.geosphere_attributes.core_mass || 1.33e23);
    }

    // Hydrosphere section
    updateElement('hydro-coverage', ((p.water_coverage || p.surface_liquid_coverage || 71.0)).toFixed(1) + '%');
    const hydroOcean = document.getElementById('hydro-ocean');
    if (hydroOcean && p.liquid_name) {
      hydroOcean.textContent = p.liquid_name;
    }
    updateElement('hydro-ice', formatMass(p.hydrosphere?.total_water_mass || 1.4e21));
  }

  function setupLayerToggles() {
    document.querySelectorAll('.layer-btn').forEach(btn => {
      const layer = btn.dataset.layer;
      btn.addEventListener('click', function() {
        toggleLayer(layer);
      });
    });
  }

  // ============================================
  // Zoom / pan / scroll
  // ============================================

  function setupZoomControl() {
    const zoomInput   = document.getElementById('zoom');
    const zoomValue   = document.getElementById('zoomValue');
    const canvas      = document.getElementById('planetCanvas');
    if (!zoomInput || !canvas) return;

    zoomInput.addEventListener('input', function() {
      viewport.scale = parseFloat(this.value);
      if (zoomValue) zoomValue.textContent = viewport.scale.toFixed(1) + 'x';
      renderTerrainMap();
    });

    if (zoomValue) zoomValue.textContent = viewport.scale.toFixed(1) + 'x';
  }

  function setupScrollableMap() {
    const wrapper  = document.getElementById('canvasWrapper');
    const scroller = document.getElementById('canvasScroller');
    if (!wrapper || !scroller) return;

    const rect          = wrapper.getBoundingClientRect();
    const overlayHeight = 50;

    scroller.style.width     = rect.width + 'px';
    scroller.style.height    = (rect.height - overlayHeight) + 'px';
    scroller.style.position  = 'absolute';
    scroller.style.top       = overlayHeight + 'px';
    scroller.style.left      = '0';
    scroller.style.overflow  = 'auto';
  }

  function setupPanControl() {
    const canvas = document.getElementById('planetCanvas');
    if (!canvas) return;

    canvas.style.cursor = 'grab';

    canvas.addEventListener('wheel', (e) => {
      e.preventDefault();

      const rect = canvas.getBoundingClientRect();
      const mouseX = e.clientX - rect.left;
      const mouseY = e.clientY - rect.top;

      const worldXBefore = (mouseX - viewport.offsetX) / viewport.scale;
      const worldYBefore = (mouseY - viewport.offsetY) / viewport.scale;

      const zoomDelta = e.deltaY > 0 ? 0.9 : 1.1;
      viewport.scale = Math.max(0.5, Math.min(4.0, viewport.scale * zoomDelta));

      const worldXAfter = (mouseX - viewport.offsetX) / viewport.scale;
      const worldYAfter = (mouseY - viewport.offsetY) / viewport.scale;

      viewport.offsetX += (worldXAfter - worldXBefore) * viewport.scale;
      viewport.offsetY += (worldYAfter - worldYBefore) * viewport.scale;

      const zoomInput = document.getElementById('zoom');
      const zoomValue = document.getElementById('zoomValue');
      if (zoomInput) zoomInput.value = viewport.scale;
      if (zoomValue) zoomValue.textContent = viewport.scale.toFixed(1) + 'x';

      renderTerrainMap();
    }, { passive: false });

    canvas.addEventListener('mousedown', e => {
      viewport.isDragging = true;
      viewport.dragStartX = e.clientX;
      viewport.dragStartY = e.clientY;
      viewport.dragStartOffsetX = viewport.offsetX;
      viewport.dragStartOffsetY = viewport.offsetY;
      canvas.style.cursor = 'grabbing';
    });

    canvas.addEventListener('mousemove', e => {
      if (!viewport.isDragging) return;
      e.preventDefault();

      const dx = e.clientX - viewport.dragStartX;
      const dy = e.clientY - viewport.dragStartY;

      viewport.offsetX = viewport.dragStartOffsetX + dx;
      viewport.offsetY = viewport.dragStartOffsetY + dy;

      renderTerrainMap();
    });

    canvas.addEventListener('mouseup', () => {
      viewport.isDragging = false;
      canvas.style.cursor = 'grab';
    });

    canvas.addEventListener('mouseleave', () => {
      viewport.isDragging = false;
      canvas.style.cursor = 'grab';
    });

    const resetBtn = document.getElementById('resetViewBtn');
    if (resetBtn) {
      resetBtn.addEventListener('click', resetMapView);
    }
  }

  function resetMapView() {
    viewport.offsetX = 0;
    viewport.offsetY = 0;
    viewport.scale = 1.0;
    viewport.initialized = false;

    const zoomInput = document.getElementById('zoom');
    const zoomValue = document.getElementById('zoomValue');
    if (zoomInput) zoomInput.value = 1.0;
    if (zoomValue) zoomValue.textContent = '1.0x';

    renderTerrainMap();
  }

  // ============================================
  // Init (NO polling — uses inline JSON data only)
  // ============================================

  function init() {
    const dataElement    = document.getElementById('monitor-data');
    const canvas         = document.getElementById('planetCanvas');
    const canvasWrapper  = document.getElementById('canvasWrapper');

    if (!dataElement || !canvas || !canvasWrapper) {
      console.log('Player Planetary: DOM not found; skipping init');
      return;
    }

    if (initialized) {
      console.log('Player Planetary already initialized; skipping duplicate init');
      return;
    }
    initialized = true;

    try {
      const data = JSON.parse(dataElement.textContent);
      monitorData = data;
      planetId    = data.planet_id;
      planetName  = data.planet_name;
      planetType  = data.planet_type;
      terrainData = data.terrain_data;
      planetData  = data.planet_data;
      hasBiosphere = !!planetData?.has_biosphere;

      // Update page title
      const mapTitle = document.getElementById('mapTitle');
      if (mapTitle) mapTitle.textContent = `${planetName} - PLANETARY MAP`;

      // Set up layer availability based on planet data
      const availableLayers = monitorData.available_layers || {
        biomes:     true,
        water:      true,
        resources:  true,
        temperature:true,
        rainfall:   true,
        features:   true
      };

      // Default visible layers
      visibleLayers = new Set(['terrain']);

      // Add default layers for this planet
      if (planetData.has_hydrosphere && availableLayers.water) {
        visibleLayers.add('liquid');
      }
      if (availableLayers.biomes && hasBiosphere) {
        visibleLayers.add('biomes');
      }
      if (availableLayers.temperature) {
        visibleLayers.add('temperature');
      }

      const planetTemp    = data.atmosphere_temperature || data.surface_temperature || 288;
      const planetPressure = data.atmosphere_pressure || 1.0;
      climate = calculateClimateZones(planetTemp, planetPressure);

      // Populate the right-side data panel from mock data
      populateDataPanel();

      console.log(`Player Planetary initialized for: ${planetName}`);
    } catch (e) {
      console.error('Player Planetary: Error parsing monitor data:', e);
      return;
    }

    setupLayerToggles();
    updateLayerButtons();
    setupZoomControl();
    setupPanControl();
    setupScrollableMap();

    // Schedule render after DOM is stable
    function scheduleRender() {
      const canvas = document.getElementById('planetCanvas');
      if (!canvas || canvas.width === 0 || canvas.height === 0) {
        setTimeout(scheduleRender, 100);
        return;
      }
      extractLayers(terrainData);
      renderTerrainMap();
      logConsole('System initialized', 'info');
    }

    if (typeof Turbo !== 'undefined') {
      document.addEventListener('turbo:load', function onFirstLoad() {
        document.removeEventListener('turbo:load', onFirstLoad);
        setTimeout(scheduleRender, 200);
      });
    } else {
      setTimeout(scheduleRender, 100);
    }
  }

  // ============================================
  // Public API
  // ============================================

  return {
    init: init
  };

})();

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', function() {
  if (window.PlayerPlanetary) {
    window.PlayerPlanetary.init();
  }
});
