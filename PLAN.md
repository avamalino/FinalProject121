# F2 Project Plan

This actionable todo list is based on the F2 requirements and our existing code.

## Goals

- Implement scene navigation (rooms)
- Allow object selection and interaction
- Maintain an inventory that affects other scenes
- Include a skill/reasoning-based physics puzzle
- Provide at least one conclusive ending

## Todo List

1. Implement Scene Manager [x]
   - Description: create a small scene lifecycle API (`load`, `update`, `draw`, `onEnter`, `onExit`) and a central manager to switch scenes.
   - Acceptance: can switch between at least two scenes via code and via player input (keyboard or UI).

   - Implementation: `src/rooms/room1.lua` is an exmaple scene Scenes can be switched by using `toolkit:switch(RoomName)` initial room is `room1` set by `gamestate.init(Room1)` in `src/main.lua`

2. Create Scene Templates [x]
   - Description: implement two scenes/rooms with distinct layout, objects and background.
   - Acceptance: both scenes load and render without errors and are reachable through the scene manager.

   - Implementation: `src/scenes/room1.lua` is an example scene it can be referenced for creating new scenes.

3. Object Selection & Interaction [ ]
   - Description: implement pointer/touch selection (raycast or bounding-box), visual feedback (highlight), and an action menu (Pick up / Examine).
   - Acceptance: clicking/tapping an in-scene object selects it, highlights it and shows available actions.

4. Inventory System [ ]
   - Description: implement add/remove/list for items, simple UI overlay showing collected items. Keep inventory in global game state.
   - Acceptance: picking up an object adds it to inventory; inventory persists across scene changes.

5. Pick-Up & Examine Actions [ ]
   - Description: implement concrete actions: picking up removes object from scene and adds it to inventory; examining shows a description panel.
   - Acceptance: items disappear from scene when picked and appear in inventory UI; examine displays details.

6. Physics-Based Puzzle [ ]
   - Description: build a puzzle that uses physics (forces/collisions/momentum). Example: use weighted boxes to tip a platform to open a door.
   - Acceptance: puzzle uses physics computations and is required to progress to a new scene or trigger an important state change.

7. Skill/Reasoning-Based Mechanics [ ]
   - Description: ensure puzzle success depends on player input/skill or reasoning (timing, placement, aiming), not randomness. Provide clear success/failure conditions and allow retries.
   - Acceptance: players can fail the puzzle through incorrect actions; success must be reproducible through skillful play.

8. Cross-Scene Dependency [ ]
   - Description: at least one inventory item changes puzzle possibilities (e.g., a crowbar from room1 opens a crate in room2). Use flags to gate interactions.
   - Acceptance: using the inventory item in the target scene changes possible actions and is necessary for a conclusive solution path.

9. Endings & Outcome States [ ]
   - Description: implement at least one conclusive ending and an end screen summarizing outcome.
   - Acceptance: a playthrough can reach an ending screen and gameplay halts or shows replay options.

10. Game State Persistence [ ]
    - Description: maintain in-memory game state across scenes
    - Acceptance: scene switches retain puzzle state, inventory and flags within a play session. (This should be inherently supported by lua and not require much work by us)

11. UI & UX Polishing [ ]
    - Description: add minimal HUD for inventory, current objective, selected object info, and puzzle feedback (success/failure messages).
    - Acceptance: player can see inventory and selection feedback clearly during play.

---

Next steps: work the items in order. Start by implementing the Scene Manager (`1`) and Scene Templates (`2`), then add interaction and inventory systems (`3`–`5`), followed by the physics puzzle and cross-scene dependencies (`6`–`8`), and finish with endings, persistence and testing (`9`–`11`).
