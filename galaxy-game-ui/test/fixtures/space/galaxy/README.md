# Sol neighborhood astronomy fixtures

These files are presentation fixtures for the separate GalaxyGame UI prototype. They are not authoritative game state, StarSim input, or a finalized main-application catalog.

## Files

- `sol_neighborhood.min.json` joins the current curated real-system seed selection to nearby-star astrometry and derived equatorial Cartesian positions.
- `constellations.sol.min.json` contains the subset of IAU constellation metadata and boundary polygons intersected by the current seed selection.
- `THIRD_PARTY_NOTICES.md` carries the BSD-3-Clause notice for the redistributed D3-Celestial boundary geometry.

## Data rules

- Preserve each curated seed's filename and exact `identifier`; do not silently rename or rewrite the source seed.
- The nearby-star source used for the current positions does not state a coordinate epoch. Keep that limitation visible. Constellation matches are therefore marked provisional rather than represented as precision astrometry.
- `position.cartesian_ly` is derived from the source right ascension, declination, and distance. Axes are equatorial: X toward RA 0h/Dec 0°, Y toward RA 6h/Dec 0°, and Z toward the north celestial pole.
- Preserve both the reference distance and any distance already present in the seed. Differences are intentionally recorded for later review.
- Alpha Centauri is one game system seed containing Alpha Centauri A, Alpha Centauri B, and Proxima Centauri. Its neighborhood node uses Alpha Centauri AB as the reference position; Proxima is retained as a separate component position.
- Constellation boundaries are angular sky regions. They must never be rendered as physical 3D boundaries or used as a substitute for Local Bubble geometry.
- The Local Bubble is recorded as a physical-neighborhood concept, but no boundary is drawn because this fixture does not contain a sourced 3D boundary model.
- A real system with incomplete astrometry may remain unplotted until a position is available. A system with no supported constellation assignment may use `null` / `unknown`. Procedurally generated systems must not receive invented real-world constellation membership.

## Expansion

When the curated real-system seed library expands, add only systems that actually exist in that seed collection, join them to a cited astrometric source, and extend the constellation subset to include any newly intersected IAU regions. Record source epoch, reference frame, uncertainty, and proper motion whenever available. Do not assume that a system needs a complete planetary inventory to appear in Galaxy View.

The eventual main-application catalog and persistence model remain open. These UI fixtures may be replaced or migrated after that design is reviewed.
