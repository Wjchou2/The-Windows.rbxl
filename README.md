# The Windows

**The Windows** is a short Roblox story game, currently it involves one story of a convenience-store worker trying to get through an ordinary shift.

Play Here: https://www.roblox.com/games/133701951494104
<br>
Short Demo video here: https://www.youtube.com/watch?v=xBJAlXhZvNY


Players play through the story by doing small actions such as restocking the store, helping customers at the register, and talking with NPCs. At the end, the player has to make a choice, leading to different closing scenes.
## Running LOCALLY
You can play on Roblox, Play Here: https://www.roblox.com/games/133701951494104
However, running locally can also be done. 
1. Install Roblox Studio from the [Roblox website](https://create.roblox.com/docs/studio/setup)
2. Follow login/signup
3. Download the TheWindowsV2.rbxl from this repo.
4. Double click/open the file with Roblox studio.
5. Click the playtest button at the top left of screen.

## Gameplay

- Entering store, completing small tasks like filling the fridges, and scanning groceries and talking to NPCs.
- Talk to NPCs and choose dialoge choices
- Cutscenes, camera transitions 
- Reach one of 2 story endings based on the final decision.

## Project Structure

- `ServerScriptService/Main.legacy.luau` Main code for story handling on server
- `ServerScriptService/NPCs.legacy.luau` — Spawns npc's their movement and dialouge
- `ServerScriptService/CollisionGroups.legacy.luau` — Sets up different collision groups for npcs/player
- `ReplicatedStorage/` — Contains many modules used on server and client such as dialouge, datasaving, etc.
- `ServerStorage/Animate.legacy.luau` — handles NPC animations

The project was built using Roblox Studio Lua, exported to github using Rojo, So the scripts rely on the corresponding Roblox place hierarchy with models, UI, sounds, and RemoteEvents in the rbxl file
