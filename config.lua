-- dps-rotations config
-- Pools are hand-placed candidate locations. Rotation is DETERMINISTIC from the
-- calendar (daily = date, weekly = ISO week), so every restart in the same
-- period lands on the same spot — no RNG, no drift.
-- COORD NOTE (wave: streets placement v1): all coords below are first-pass and
-- get walk-tuned in-game per the map-test protocol. Fix a bad spot by editing
-- its pool entry; the schedule math never changes.

Config = {}

-- Resource whose caches must reload after a rotation is applied.
Config.RestartResource = 'rcore_drugs'
Config.RestartDelayMs  = 8000  -- let the boot settle before bouncing it

-- Ace for the /rotate admin command (add_ace group.admin dps.rotations allow)
Config.RotateAce = 'dps.rotations'

-- target = 'dealer'  -> UPDATE rcore_drugs_dealer_locations WHERE dealer_type = key
-- target = 'harvest' -> UPDATE rcore_drugs_harvests WHERE id = row_id
Config.Rotations = {

    { id = 'supplier', cadence = 'daily', target = 'dealer', dealer_type = 'supplier',
      pool = {
        { label = 'Supplier — Grove St cul-de-sac',   x = -115.3,  y = -1602.1, z = 32.5,  h = 140.0 },
        { label = 'Supplier — Forum Dr corner',       x = -167.0,  y = -1608.2, z = 33.7,  h = 230.0 },
        { label = 'Supplier — Strawberry underpass',  x = 275.4,   y = -1902.6, z = 26.2,  h = 320.0 },
        { label = 'Supplier — Davis Ave lot',         x = 89.6,    y = -1959.3, z = 20.8,  h = 50.0  },
        { label = 'Supplier — Rancho blvd back',      x = 470.1,   y = -1834.7, z = 28.3,  h = 190.0 },
        { label = 'Supplier — El Burro yard',         x = 1332.5,  y = -1499.5, z = 53.5,  h = 270.0 },
        { label = 'Supplier — Cypress Flats dock',    x = 812.9,   y = -2158.4, z = 29.6,  h = 90.0  },
        { label = 'Supplier — Skid Row alley',        x = 471.3,   y = -1312.2, z = 29.2,  h = 10.0  },
        { label = 'Supplier — La Mesa rail side',     x = 748.6,   y = -982.4,  z = 24.9,  h = 180.0 },
        { label = 'Supplier — Vespucci canal walk',   x = -1181.8, y = -1391.2, z = 4.6,   h = 120.0 },
        { label = 'Supplier — Sandy rear lot',        x = 1932.4,  y = 3709.3,  z = 32.3,  h = 300.0 },
        { label = 'Supplier — Paleto back street',    x = -163.9,  y = 6320.6,  z = 31.3,  h = 45.0  },
      } },

    { id = 'lab_dealer', cadence = 'daily', target = 'dealer', dealer_type = 'lab_dealer',
      pool = {
        { label = 'Dealer — Sandy under bridge',      x = -182.6,  y = 4230.0,  z = 32.7,  h = 230.0 },
        { label = 'Dealer — Grapeseed barn side',     x = 2432.8,  y = 4968.5,  z = 42.3,  h = 135.0 },
        { label = 'Dealer — Harmony gas back',        x = 546.2,   y = 2662.8,  z = 42.1,  h = 10.0  },
        { label = 'Dealer — Stab City edge',          x = 84.7,    y = 3743.6,  z = 39.7,  h = 200.0 },
        { label = 'Dealer — Chumash pier lot',        x = -3244.3, y = 997.5,   z = 12.5,  h = 90.0  },
        { label = 'Dealer — Paleto forest turnout',   x = -710.2,  y = 5791.1,  z = 17.5,  h = 69.0  },
      } },

    { id = 'weed_harvest', cadence = 'weekly', target = 'harvest', row_id = 1,
      pool = {
        { label = 'Weed — Chiliad foothills',   x = 1708.9,  y = 2246.6,  z = 79.9 },
        { label = 'Weed — Raton Canyon shelf',  x = -1552.8, y = 4448.3,  z = 19.7 },
        { label = 'Weed — Grapeseed treeline',  x = 2216.4,  y = 5577.9,  z = 53.8 },
      } },

    { id = 'coca_harvest', cadence = 'weekly', target = 'harvest', row_id = 2,
      pool = {
        { label = 'Coca — Gordo slope',         x = 2939.0,  y = 802.2,   z = 24.8 },
        { label = 'Coca — Cassidy Creek bend',  x = -430.6,  y = 4433.2,  z = 57.6 },
        { label = 'Coca — Palomino ridge',      x = 2795.4,  y = 1530.7,  z = 32.4 },
      } },

    { id = 'meth_harvest', cadence = 'weekly', target = 'harvest', row_id = 3,
      pool = {
        { label = 'Solvent — Ron Alt refinery', x = 2794.0,  y = 1409.8,  z = 24.4 },
        { label = 'Solvent — El Burro chem lot',x = 1391.4,  y = -2075.6, z = 51.9 },
        { label = 'Solvent — Sandy scrapyard',  x = 2396.3,  y = 3049.5,  z = 60.1 },
      } },
}
