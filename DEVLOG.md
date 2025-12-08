# F1 DEVLOG

## How we satisfied the software requirements

1. We used LOVE2D Engine as the platform that does not already provide support for 3D rendering and physics simulation.
2. We used G3D graphics for the third=party 3D rendering library.
3. We used CPML math library for the third-party physics simulation library.
4. We have a moveable cat (uses WASD/arrow keys) that can move around and interact with objects.
5. The player must interact with a button using the space key in order to unlock a door.
6. The player cannot advance into the next stage if the button is not pressed.
7. We have "Blocking commits for code that does not pass typechecking or other build tests"
8. We have packaging and deployment to GitHub Pages.

## Reflection

Learning LOVE2D has been rough, especially with setting up the engine and figuring out the environment. We wish we used a different engine because LUA was a whole different language we had to learn. We had some roles originally assigned to other members but we found it easier to swap based on who already was ahead.

# F2 DEVLOG

## How we satisfied the software requirements

1. Game renders 3D objects.
2. Player can interact (press space) with doors to move between screens (rooms).
3. Player can select objects in a scene by pressing the interact key (space).
4. When objects are picked up, the object disappears from the room and is placed in their inventory (appears top left in text). The inventory is carried throughout rooms.
5. The player must press a button in order to unlock the ability to open the door into the next room.
6. The player is not able to end the game unless the button is pressed.
7. There is an ending upon reaching the final door that tells you that you had completed the game.

## Reflection

We realized how compliciated the features of the game can become without constant communication. The learning curve on how LOVE2D works was difficult at first. We need to get better at documenting our changes but with Thanksgiving break and finals coming up, everyone's schedules have been different. We started using the LiveShare feature more but we discovered that only the host can run the server. We need to meet up in person more in order to have direct communication about which steps we are doing first.

# F3 DEVLOG

## Selected Requirements

1. [continuous inventory] The game must involve one inventory item for which the continuous quantity matters in an interesting way (e.g. a bucket holds some continuously variable number of liters of water, but the bucket can't put out the fire unless it has enough water). 2.[offline mobile] Support offline play on some smartphone-class mobile device (i.e. some way of installing the app so that it can be played by players who don't have live internet access).
2. [visual themes] Support light and dark modes visual styles that respond to the user's preferences set in the host environment (e.g. operating system or browser, not in-game settings), and these visual styles are integrated deeply into the game's display (e.g. day/night lighting of the fictional rooms, not just changing the border color of the game window)
3. [touchscreen] Support touchscreen-only gameplay (no requirement of mouse and keyboard).
4. [i18n + l10n] Support three different natural languages including English, a language with a logographic script (e.g. 中文), and a language with a right-to-left script (e.g. العربية).
5. [unlimited undo] Support unlimited levels of undo of the major play actions (such as moving to a scene or interacting with a specific object, but don't worry about undo within a physics interaction)

## Features Implemented

1. Inventory menu implemented --> shows all objects picked up
2. Game works if offline
3. Light and dark mode background option was implemented.
4. A joystick was added as movement control on mobile devices, no keyboard and mouse is required.
5. Players can click "1" to change the language to English and click "2" to change the language to Chinese
6. Players can click an undo button to undo their previous action.

## Reflection

Our team tweaked a few goals but we still kept the game as basic as possible. We realized how difficult it is to maintain a clean commit log. With everyone working on the project, it was hard to keep the code clean. Towards the end of the project, we plan to refractor a lot of our code and clean it up. We realize that there are a lot of issues in coding styles when we try to merge all of our code together. We thought need to get all the requirements and basics down first before cleaning up our code. We realize that we should started with planning in PLAN.MD first to prevent these issues where everyone's tasks collide with each other.

## Todo List

1. Implement Inventory Popup Menu
   - [x] when "I" is pressed, a popup appears
   - [x] clicking "I" or "ESC" hides the popup
   - [x] displays inventory title
   - [x] displays items when it gets picked up in the popup
   - [] displays 3d image of the item
   - [] displays item name under the item image
   - [x] displays item count at the bottom right
   - [] on hover, show description of item

2. Implement Offline Mode
   - [x] save game
   - [x] load game

3. Implement Light/Dark Mode
   - [x] light mode
   - [x] dark mode

4. Touchscreen mode for phone and optional controls for computer
   - [x] joystick to move the cat around
   - [x] undo button
   - [x] pickup button
   - [x] inventory button

5. Implement Language Switching
   - [x] English
   - [x] Chinese
   - [] Arabic

6. Implement Undo Button
   - [x] physical undo button
   - [x] undo button deletes previous action
