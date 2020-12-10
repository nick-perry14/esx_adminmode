# esx_adminmode
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/nick-perry14/esx_adminmode)](#)
[![Maintenance](https://img.shields.io/maintenance/yes/2020)](#)
[![GitHub all releases](https://img.shields.io/github/downloads/nick-perry14/esx_adminmode/total)](https://github.com/nick-perry14/esx_adminmode/releases)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/nick-perry14/esx_adminmode)](https://github.com/nick-perry14/esx_adminmode/releases/latest)
[![GitHub issues](https://img.shields.io/github/issues/nick-perry14/esx_adminmode)](https://github.com/nick-perry14/esx_adminmode/issues)

## About
### Admin On Duty Mode
This is a simple admin-mode project that allows users of a specific group to change into a special "on duty mode".  This mode automatically:
- Gods the player
- Changes their ESX job to an on-duty version
- Heals the player
- Spawns in an admin vehicle (if specified)
- Changes the player's ped automatically (if specified)

Upon Disabling admin mode, the resource:
- Ungods the player
- Returns their ESX Job back to where it was before
- Removes the admin vehicle (unreliable at the current point)
- Resets the player's ped to the ESX skin (looking to change to last ped to work with EUP)

### Admin Panel (View Credit Below)
- Ability to warn, kick, and ban players
- Warns and Kicks can be executed anonymously
- Bans can be executed offline
- Bans ban ALL identifiers (IP, Steam, Rockstar, Discord, etc)



## Commands
- /accassist \[ID\] - Accepts the assist from the specified player and teleports to them
- /adminmode - Toggles the player into admin mode.
- /assist \[reason\] - Requests assistance from admins
- /ban - Opens Ban Window
- /banlist - Opens Ban List
- /cassist - Cancels your active assist.
- /decassist - Declines the pending assist (the assist will still be open for other admins).
- /finassist - Finished the active assist and teleports the admin back to where they were.
- /kick - Opens Kick Window
- /warn - Opens Warn window
- /warnlist - Opens Warn List

## Download
- [Download Latest Release](https://github.com/nick-perry14/esx_adminmode/releases/latest)
- [See All Releases](https://github.com/nick-perry14/esx_adminmode/releases)
- [Download Source Code](https://github.com/nick-perry14/esx_adminmode/archive/main.zip)

## Help
Before asking me for help, or creating an issue, please check out the Wiki, located [here](https://github.com/nick-perry14/esx_adminmode/wiki)

## API
The simplest way to check if a user is in Admin Mode is to check their job.  If their job is one of the specified admin mode jobs, it can be assumed the user is in admin mode.

### Admin Panel API
The following events can ONLY be executed by the server.
```
-- banning
-- 1st parameter -> ESX user object of the sender
-- 2nd parameter -> ESX user object of the receiver OR if the player is offline, their steam identifier
-- 3rd parameter -> reason
-- 4th parameter -> length (exp. date of ban) in this format YYYY/MM/DD HH:SS, other formats won't work
-- 5th parameter -> if the player is offline, set to true, otherwise leave false or nil
TriggerEvent("esx_adminmode:ban", ESX.GetPlayerFromId(sender), ESX.GetPlayerFromId(target), reason, length, offline)
```
```
-- warning
-- 1st parameter -> ESX user object of the sender
-- 2nd parameter -> ESX user object of the receiver
-- 3rd parameter -> message of warn
-- 4th parameter -> boolean, if set to true the sender name will not show for the player
TriggerEvent("esx_adminmode:warn", ESX.GetPlayerFromId(sender), ESX.GetPlayerFromId(target), message, anonymous)
```
## Credit

- [Elipse458/el_bwh](https://github.com/Elipse458/el_bwh) - Main admin panel and UI

## Future Features
- Add toggles for car spawn, ped spawn, etc.
