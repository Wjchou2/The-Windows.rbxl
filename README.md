# The Windows

**The Windows** is a short, narrative-driven Roblox game about Miles, a convenience-store worker trying to get through an ordinary shift while deciding what—and who—deserves his time.

Play Here: https://www.roblox.com/games/133701951494104


Players restock the store, help customers at the register, and take part in small conversations that reveal pieces of the people around them. A phone call from home and a request from a coworker eventually force Miles to make a choice, leading to different closing scenes.

## Gameplay

- Complete guided store tasks such as opening the stock closet, filling the fridges, and scanning groceries.
- Meet procedurally selected customers with varied dialogue and response choices.
- Follow cinematic camera sequences, environmental transitions, objectives, and spatial sound cues.
- Make story choices through phone and face-to-face conversations.
- Reach one of multiple narrative outcomes based on the final decision.

## Project Structure

- `ServerScriptService/Main.legacy.luau` — main story sequence, objectives, interactions, dialogue, and endings.
- `ServerScriptService/NPCs.legacy.luau` — customer spawning, movement paths, and store behavior.
- `ServerScriptService/CollisionGroups.legacy.luau` — collision setup for characters and the environment.
- `ReplicatedStorage/` — shared helpers for sound, typewriter text, clock control, and model vibration.
- `ServerStorage/Animate.legacy.luau` — character animation handling.

## Built With

- Roblox Studio
- Luau
- Roblox services including TweenService, ProximityPrompt, RemoteEvents, and TeleportService

This repository contains the game’s Luau source. The scripts rely on the corresponding Roblox place hierarchy, models, UI, sounds, and RemoteEvents configured in Studio.
