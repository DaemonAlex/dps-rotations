<p align="center"><img src=".github/dps-logo.svg" alt="DelPerroSands" width="360"></p>

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
| [dps-insurance](https://github.com/DaemonAlex/dps-insurance) | Ties m-Insurance into the MDT, impound, hospital and medical chart, and raises premiums for incidents other scripts report. Pairs with dps-medical and dps-fuel. |
| [dps-studio](https://github.com/DaemonAlex/dps-studio) | Build rooms, doors and portals in game from one panel (`/studio`), with owners and managers so staff do not have to support them. |
| [dps-shops](https://github.com/DaemonAlex/dps-shops) | Shop clerks who greet, react to robberies, talk back through dps-ainpcs and remember trouble, plus player-owned stores with delivery runs. Pairs with dps-ainpcs. |
| [dps-fleet](https://github.com/DaemonAlex/dps-fleet) | Vehicle browser and workshop on one panel: extras, liveries and mods for emergency vehicles. |
| [dps-parking](https://github.com/DaemonAlex/dps-parking) | Parking with valet, impound, violations and reserved spots. |
| [dps-vehiclepersistence](https://github.com/DaemonAlex/dps-vehiclepersistence) | Vehicles stay where they were parked. Pairs with dps-parking. |
| [dps-towjob](https://github.com/DaemonAlex/dps-towjob) | Queue-based tow job with jg-mechanic integration. |
| [dps-services](https://github.com/DaemonAlex/dps-services) | Request a tow and follow it live on the lb-phone and lb-tablet. Pairs with dps-towjob. |
| [dps-autoshops](https://github.com/DaemonAlex/dps-autoshops) | Self-service repair shops when no mechanic is on duty. |
| [dps-cityworker](https://github.com/DaemonAlex/dps-cityworker) | City infrastructure job and career. |
| [dps-ainpcs](https://github.com/DaemonAlex/dps-ainpcs) | NPCs you can talk to, with trust, quests and intel. Other scripts can make their own NPCs talk (dps-shops clerks). |
| [dps-badpeds](https://github.com/DaemonAlex/dps-badpeds) | Police interaction with NPCs: stops, arrests, intel and jail records. |
| [dps-gangwars](https://github.com/DaemonAlex/dps-gangwars) | Ambient gang NPCs, territory population and war reinforcements. |
| [dps-trains](https://github.com/DaemonAlex/dps-trains) | The train system. Pairs with dps-trains-stock, dps-traintools and dps-transitapp. |
| [dps-transitapp](https://github.com/DaemonAlex/dps-transitapp) | Live train arrival boards on the lb-phone. |
| [dps-faceplant](https://github.com/DaemonAlex/dps-faceplant) | City help, reports and staff tools on the lb-phone and lb-tablet. |
| [dps-chat](https://github.com/DaemonAlex/dps-chat) | A command box for voice-only servers. No chat feed. |
| [dps-filmmode](https://github.com/DaemonAlex/dps-filmmode) | One key hides every HUD layer and gives a smooth free camera for recording. |
| [dps-fuel](https://github.com/DaemonAlex/dps-fuel) | Gas station drive-offs for the ox_fuel nozzle: ripped hose, pump fire, station camera and a police call, by odds. Pairs with dps-insurance. |
| [dps-voice](https://github.com/DaemonAlex/dps-voice) | Spoken lines for NPCs, station announcements, dispatch and shops, from local voice models first. Pairs with dps-ainpcs. |
| [dps-bags](https://github.com/DaemonAlex/dps-bags) | Real bags for ox_inventory: the bag you carry shows on your character. |
| [dps-items](https://github.com/DaemonAlex/dps-items) | Item rules for ox_inventory: locked items, glovebox seats and an exploit watch. |
| [dps-furniture](https://github.com/DaemonAlex/dps-furniture) | Puts streamed furniture packs into the qs-housing furniture shop. |
| [dps-shellbrowser](https://github.com/DaemonAlex/dps-shellbrowser) | Staff tool to look at every qs-housing shell and set its door. |
| [dps-signs](https://github.com/DaemonAlex/dps-signs) | Rotates city messages across the SmartSigns road boards. |
| [dps-stationclear](https://github.com/DaemonAlex/dps-stationclear) | Hides map props that are in the way and keeps stray game peds off chosen spots. |
| [dps-citymap](https://github.com/DaemonAlex/dps-citymap) | A ready-made map of the whole city, cut into tiles for in-game screens. |
| [dps-cayo](https://github.com/DaemonAlex/dps-cayo) | Switches on the game's own Cayo Perico island, and nothing else. |
| [dps-aviation](https://github.com/DaemonAlex/dps-aviation) | Flight behaviour: aircraft idle instead of cutting out, sane taxi speed, a real start sequence. |
| [dps-airlines](https://github.com/DaemonAlex/dps-airlines) | Airlines job: passenger flights, cargo, charters, flight school and maintenance. |
| [dps-traintools](https://github.com/DaemonAlex/dps-traintools) | Rider tools for trains: board, sit, get off at a stop, ambient passengers. Pairs with dps-trains. |
| [dps-trains-stock](https://github.com/DaemonAlex/dps-trains-stock) | Train models and carriage sets for the train system. No scripts. Pairs with dps-trains. |
| [dps-traintracks](https://github.com/DaemonAlex/dps-traintracks) | Extra train track data. No scripts. Pairs with dps-trains. |
| [dps-crossings](https://github.com/DaemonAlex/dps-crossings) | Level crossings that close when a train comes. Pairs with dps-trains. |
| [dps-transit](https://github.com/DaemonAlex/dps-transit) | Passenger rail planning and scheduling (older system; dps-trains runs today). |
| [dps-maritime](https://github.com/DaemonAlex/dps-maritime) | Dock work and boat deliveries with progression. |
| [dps-maritime-maps](https://github.com/DaemonAlex/dps-maritime-maps) | Map files for the Jetsam docks, the map half of dps-maritime. |
| [dps-proracing](https://github.com/DaemonAlex/dps-proracing) | Circuit racing with lobbies, an AI practice grid and lap times. |
| [dps-carmenu](https://github.com/DaemonAlex/dps-carmenu) | Staff vehicle browser and spawner over the live Qbox vehicle list. |
| [dps-clothingbrowser](https://github.com/DaemonAlex/dps-clothingbrowser) | Staff tool to browse, identify and export clothing and uniforms. |
| [dps-lootpeds](https://github.com/DaemonAlex/dps-lootpeds) | Loot dead NPCs, with loot tables per model. |
| [dps-hookers](https://github.com/DaemonAlex/dps-hookers) | Adults-only RP (18+), adapted from MH Hookers by MaDHouSe. |
| [dps-weatherbridge](https://github.com/DaemonAlex/dps-weatherbridge) | Lets qb-weathersync and Renewed-Weathersync scripts work with night_natural_disasters. |
| [dps-fixes](https://github.com/DaemonAlex/dps-fixes) | Small server fixes kept in one resource. |
| [dps-bucketfix](https://github.com/DaemonAlex/dps-bucketfix) | Puts players back in the main world after spawning. |
| [dps-unfocus](https://github.com/DaemonAlex/dps-unfocus) | One key that frees a player stuck in a menu. |
| [dps-welcomecam](https://github.com/DaemonAlex/dps-welcomecam) | Aims the first camera a new player sees. |
| [dps-handlingdump](https://github.com/DaemonAlex/dps-handlingdump) | Developer tool: saves the stock handling of every vanilla vehicle. |
| [dps-weaponsounds](https://github.com/DaemonAlex/dps-weaponsounds) | Custom weapon sounds (planning; no code yet). |
| [dps-events](https://github.com/DaemonAlex/dps-events) | Playtime reward events (planning; no code yet). |
