# dps-rotations

Deterministic rotating-location engine for Del Perro Sands: moves drug
dealers, harvest spots, and other configurable point pools around the map on
a schedule, so grinders can't camp a wiki-known coordinate forever.

## Concepts
- **Pool**: a named set of candidate locations (e.g. dealer spots).
- **Rotation**: on a deterministic schedule, the active subset changes -
  server-computed so every player sees the same active locations.
- Consumers query the active set via exports rather than hardcoding coords.

## Integration
Other DPS resources ask this engine where things currently are. Adding a new
rotating system means adding a pool and pointing the consumer at the export -
no new timers or sync logic.

Database-backed state survives restarts. See `config.lua` for pools and
schedule tuning.
