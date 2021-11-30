# FFXIV-Crafting-Helper
AHK script for automating crafting tasks in FFXIV

![Example Crafting Helper Screenshot](https://user-images.githubusercontent.com/2283362/143943992-7d27c13d-18df-478e-bdbc-7dd46c828ddf.jpg)

## Quick Start
**Requires AutoHotKey installed. Run 'FFXIV Crafting.ahk' then press ctrl+f12 to open the script's UI. After selecting options in the script UI, starting a craft requires Crafting Log UI to be open. Pop consumab**

## Instructions
Script assumes you've already created your crafting macros in-game and setup crafts.json with the waits and hotkeys.

Strongly recommend using https://ffxivteamcraft.com/ to create your macros/rotations

Script does not handle consumables. Pop those yourself before crafting.

Do not have any other UI open

Do not be close to any interactables in-game

Script relies on Keybind > System > Confirm to be bound to NUM0 (this is the games default)

Click on the recipe in the Crafting Log recipe list to ensure proper UI panel focus. This is the scripts asssumed start point.

FFXIV does not need to be in focus for this script to work.

For multi macro crafts it is recommended to not use your keyboard while the script is running.

## Functionality
Select the craft from the drop down, insert how many iterations you would like it to run for (0 means run until stopped), and click Craft

Pause - Pauses execution of the script immediately. Click again to unpause

Stop - Returns the script to an idle state after finishing the current craft

Run Simulation - Simulates the selected craft for testing. Will popup a message box with the craft data. Will also output hotkeys to Notepad.exe if it is running instead of the FFXIV client.

Reload Crafts - Reloads the crafts.json file. Useful for changing data without having to reload the script

## Files
### FFXIV Crafting.ahk
The main script.

### crafts.json
JSON file which contains crafting data.

Example JSON:
This will add an item to the scripts dropdown named "3.5* 70D". When executed it will press hotkey 7 in FFXIV, wait 39s, then press 8 in FFXIV and wait 11s.
```
{
  "3.5* 70D": {
    "macros": [
    {
      "hotkey": "7",
      "duration": 39
    },
    {
      "hotkey": "8",
      "duration": 11
    }]
  }
}
```

### JSON.ahk
lib file required by main script.

## FAQ/Help
### Script seesm to be stuck in HQ UI panel
Make sure the script has window focus in the Crafting Log's recipe list area. Click on the recipe in the Crafting Log recipe list to ensure proper UI panel focus. This is the scripts asssumed start point.

### I'm getting 'out of range' errors
Make sure your character is not next to any interactables in the world. The script sends 'Confirm' keyboard commands which the game may interpret as interact with nearby interactables.

### Script seems to be getting stuck during execution
You're likely using your keyboard/mouse at the same time the script is running. While theoretically this should work fine, in practice FFXIV sometimes misses inputs from the script. Single macro crafts are safe even if FFXIV misses an input and will not get stuck. Multi macro crafts it is recommended to AFK.
