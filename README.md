# dps-rotations

Deterministic rotating-location engine for Del Perro Sands: moves drug
dealers, harvest spots, and other configurable point pools around the map on
a schedule, so grinders can't camp a wiki-known coordinate forever.

## What it is for

Players learn where a dealer or a harvest field is, then farm that one spot
forever. Staff then have to move things by hand. This script moves them for
you. Each day or week it picks the next spot from a list you wrote, so the
drug trade keeps moving and players have to ask around to find it.

## Concepts
- **Pool**: a named set of candidate locations (e.g. dealer spots). You write
  each pool by hand in `config.lua`.
- **Rotation**: each pool has a cadence, `daily` or `weekly`. The script works
  out the active entry from the calendar date (or the ISO week) and the pool
  id. There is no random roll, so every restart in the same period lands on
  the same spot, and every player sees the same location.
- **Target**: where the chosen entry is written. `dealer` and `harvest` write
  to the rcore_drugs tables. `podium` writes the casino podium car into the
  rcore_casino settings.
- **State**: the table `dps_rotations_state` records the last period applied
  for each pool. It is created on first start and survives restarts.

## How it runs

The script has no client side and no exports. It runs once when the resource
starts, which on a live server means at each server boot.

1. For each pool it checks if the period (day or week) has changed.
2. If it has, it writes the new location into the target script's database
   table.
3. After `Config.RestartDelayMs` (8 seconds by default) it restarts the
   resources named in `Config.RestartResource`, so they load the new spot.
4. If nothing changed, it does nothing and restarts nothing.

A daily pool only moves if the server restarts at least once that day.

## Admin command

| Command | What it does |
|---|---|
| `/rotate <id>` | Moves one pool to its next spot now. The id is the pool's `id` in `config.lua`, for example `supplier`. |
| `/rotate all` | Moves every pool now. |

The command needs the ace `dps.rotations`
(`add_ace group.admin dps.rotations allow`). It also works from the server
console.

## On its own, and with other scripts

**On its own.** With only oxmysql the script starts, creates its state table
and logs a warning for each pool, because there is nothing to move. It needs
at least one of the scripts below to be useful.

**With a paid drugs script (rcore_drugs).** The supplier and the lab dealer
move to a new street corner each day. The weed, coca and solvent harvest
fields move each week. Each dealer gets a small table prop placed behind them.
Players who memorised a spot find it empty and have to look for the new one.
The script writes straight into two rcore_drugs tables
(`rcore_drugs_dealer_locations` and `rcore_drugs_harvests`). It does not call
any rcore_drugs code. If an rcore_drugs update renames those tables or
columns, the rotation will stop and log a warning until the queries in
`server.lua` are updated.

**With a paid casino (rcore_casino).** The car on the casino podium changes
each week, picked from the `casino_podium` pool. The script edits one key
(`PodiumPriceProps.podiumName`) inside the casino's saved settings and leaves
the rest as it found it. The casino must have started once so that the
settings row exists. If the row is missing or unreadable, the script leaves
it alone and logs a line.

## Requirements

- [oxmysql](https://github.com/overextended/oxmysql)
- rcore_drugs for the `dealer` and `harvest` targets
- rcore_casino for the `podium` target

## Installation

1. Put the folder in your resources and add `ensure dps-rotations` to
   `server.cfg`, after oxmysql, rcore_drugs and rcore_casino.
2. Edit the pools in `config.lua`. Each dealer or harvest entry needs a
   `label` and coordinates. Each podium entry needs a `label` and a vehicle
   `model`.
3. Give your admin group the ace: `add_ace group.admin dps.rotations allow`.

## Integration

Adding a new rotating spot of a kind the script already knows means adding a
pool to `Config.Rotations` in `config.lua`. No new timers or sync logic are
needed. A new kind of target needs a small write function in `server.lua`.

Database-backed state survives restarts. See `config.lua` for pools and
schedule tuning.

## Recent changes

- **12 November 2026.** README: what it is for, how it works alone and with paid scripts, other DPS scripts.
- **27 October 2026.** Eight cars that were removed from the server were taken out of the casino podium pool. Four cars remain in the pool.

## Author

Made by [DaemonAlex](https://github.com/DaemonAlex) for DelPerroSands.

## Other DPS scripts

All of these are made for DelPerroSands and run together on one Qbox server. Each one works on
its own. The ones marked "pairs with" do more when both are running.

| Script | What it does |
|---|---|
| [dps-inventory](https://github.com/DaemonAlex/dps-inventory) | The inventory: ox_inventory with equipment slots, backpacks, armour plates and a self status panel, in the DelPerroSands colours. |
| [dps-medical](https://github.com/DaemonAlex/dps-medical) | Patient records, illness and diagnostic tests. A companion to wasabi_ambulance. Pairs with dps-inventory: symptoms and diagnoses show on the status panel. |
| [dps-insurance](https://github.com/DaemonAlex/dps-insurance) | Ties m-Insurance into the MDT, impound, hospital and medical chart. Pairs with dps-medical. |
| [dps-studio](https://github.com/DaemonAlex/dps-studio) | Build rooms, doors and portals in game from one panel (`/studio`), with owners and managers so staff do not have to support them. |
| [dps-shops](https://github.com/DaemonAlex/dps-shops) | Shop clerks who greet and react to a robbery, then player-owned shops. |
| [dps-fleet](https://github.com/DaemonAlex/dps-fleet) | Vehicle browser and workshop on one panel: extras, liveries and mods for emergency vehicles. |
| [dps-parking](https://github.com/DaemonAlex/dps-parking) | Parking with valet, impound, violations and reserved spots. |
| [dps-vehiclepersistence](https://github.com/DaemonAlex/dps-vehiclepersistence) | Vehicles stay where they were parked. Pairs with dps-parking. |
| [dps-towjob](https://github.com/DaemonAlex/dps-towjob) | Queue-based tow job with jg-mechanic integration. |
| [dps-services](https://github.com/DaemonAlex/dps-services) | Request a tow and follow it live on the lb-phone and lb-tablet. Pairs with dps-towjob. |
| [dps-autoshops](https://github.com/DaemonAlex/dps-autoshops) | Self-service repair shops when no mechanic is on duty. |
| [dps-cityworker](https://github.com/DaemonAlex/dps-cityworker) | City infrastructure job and career. |
| [dps-ainpcs](https://github.com/DaemonAlex/dps-ainpcs) | NPCs you can talk to, with trust, quests and intel. |
| [dps-badpeds](https://github.com/DaemonAlex/dps-badpeds) | Police interaction with NPCs: stops, arrests, intel and jail records. |
| [dps-gangwars](https://github.com/DaemonAlex/dps-gangwars) | Ambient gang NPCs, territory population and war reinforcements. |
| [dps-trains](https://github.com/DaemonAlex/dps-trains) | The train system. Pairs with dps-trains-stock, dps-traintools and dps-transitapp. |
| [dps-transitapp](https://github.com/DaemonAlex/dps-transitapp) | Live train arrival boards on the lb-phone. |
| [dps-faceplant](https://github.com/DaemonAlex/dps-faceplant) | City help, reports and staff tools on the lb-phone and lb-tablet. |
| [dps-chat](https://github.com/DaemonAlex/dps-chat) | A command box for voice-only servers. No chat feed. |
| [dps-filmmode](https://github.com/DaemonAlex/dps-filmmode) | One key hides every HUD layer and gives a smooth free camera for recording. |
