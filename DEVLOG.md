# F3 DEVLOG

## Selected Requirements

1. [continuous inventory] The game must involve one inventory item for which the continuous quantity matters in an interesting way (e.g. a bucket holds some continuously variable number of liters of water, but the bucket can't put out the fire unless it has enough water).
2. [visual themes] Support light and dark modes visual styles that respond to the user's preferences set in the host environment (e.g. operating system or browser, not in-game settings), and these visual styles are integrated deeply into the game's display (e.g. day/night lighting of the fictional rooms, not just changing the border color of the game window)
3. [unlimited undo] Support unlimited levels of undo of the major play actions (such as moving to a scene or interacting with a specific object, but don't worry about undo within a physics interaction)
4. [touchscreen] Support touchscreen-only gameplay (no requirement of mouse and keyboard).
5. [offline mobile] Support offline play on some smartphone-class mobile device (i.e. some way of installing the app so that it can be played by players who don't have live internet access).

## Features Implemented

1.
2. Light and dark mode background option was implemented.
3.
4. A joystick was added as movement control on mobile devices, no keyboard and mouse is required.

## Reflection

Looking back on how you achieved the F3 requirements, how has your team’s plan changed since your F3 devlog? There’s learning value in you documenting how your team’s thinking has changed over time.

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

2. Implement a Save Game Button
   - [] display save button
   - [] multiple manual save slots
   - [] confirm save popup when button is clicked "would you like to save the game y/n"
   - [] "your game has been saved" popup
   - [] autosaves after a minute of gameplay
   - [] load and delete functions

3. Implement Offline Mode
   - [] save game
   - [] load game
