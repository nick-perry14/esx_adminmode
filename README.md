# esx_adminmode
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/nick-perry14/esx_adminmode)](#)
[![Maintenance](https://img.shields.io/maintenance/yes/2020)](#)
[![GitHub all releases](https://img.shields.io/github/downloads/nick-perry14/esx_adminmode/total)](https://github.com/nick-perry14/esx_adminmode/releases)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/nick-perry14/esx_adminmode)](https://github.com/nick-perry14/esx_adminmode/releases/latest)
[![GitHub issues](https://img.shields.io/github/issues/nick-perry14/esx_adminmode)](https://github.com/nick-perry14/esx_adminmode/issues)

## About
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

## Commands
- /adminmode - Toggles the player into admin mode.

## Download
- [Download Latest Release](https://github.com/nick-perry14/esx_adminmode/releases/latest)
- [See All Releases](https://github.com/nick-perry14/esx_adminmode/releases)
- [Download Source Code](https://github.com/nick-perry14/esx_adminmode/archive/main.zip)

## Help
Before asking me for help, or creating an issue, please check out the Wiki, located [here](https://github.com/nick-perry14/esx_adminmode/wiki)

## API
The simplest way to check if a user is in Admin Mode is to check their job.  If their job is one of the specified admin mode jobs, it can be assumed the user is in admin mode.

## Future Features
- Config File with different groups
- Add toggles for car spawn, ped spawn, etc.
- Option to NOT spawn car with admin
