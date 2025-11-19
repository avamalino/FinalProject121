# CMPM 121 FINAL PROJECT

## SUMMARY OF PROJECT

our tentative project is a small browser game called campus cat express.

you play as a cat courier delivering care packages to different buildings through a stylized campus. each level gives you a time limit and a set of delivery locations; you have to plan a route, navigate around simple obstacles, and reach all destinations before time runs out. as you progress, more buildings unlock, routes get trickier, and you can earn small upgrades (like extra time or slightly faster movement) for completing optional challenges.

core goals:

- **simple movement + routing:** Easy-to-learn controls with clear feedback about where to go next.
- **readable map UI:** Buildings and delivery spots are visually distinct with icons and color-coding.
- **gentle difficulty curve:** Early levels are forgiving; later levels add more decisions, not just more punishment.

---

## TEAM

- **Tools Lead:** Ava Malinowski, Nayanika Bhattacharya
- **Engine Lead:** Kaitlyn Eng  
- **Design Lead:** Arti Gnanasekar  
- **Testing Lead:** Sonny Trucco

---

## TOOLS + MATERIALS

### Engine

- **custom TypeScript + HTML5 canvas setup** (no third-party game engine; we manage our own loop, rendering, and input)

### Language

- **TypeScript** – core game logic, state management, and rendering

### Tools

- **Deno + Vite** – Development server and bundling  
- **GitHub** – Version control and collaboration  
- **GitHub Pages** – Deployment via GitHub Actions  
- **Figma / Excalidraw (optional)** – Quick layout and UI sketches

### Generative AI

we plan to use generative AI tools **only during development**, not at runtime in the game:

- brainstorming level ideas, challenge variations, and building names  
- getting help debugging TypeScript and build issues  
- drafting and revising documentation text (e.g., this project summary)

no AI-generated content is required for players to run the game.

---

## OUTLOOK

we expect to deliver:

- a **playable core loop** where players:
  - move the courier around the campus map
  - deliver packages to highlighted locations
  - beat a visible timer to complete the level
- a **small level set** (e.g., 3–5 levels) with escalating complexity:
  - more delivery points
  - slightly tighter timers
  - optional bonus objectives (like “no collisions” or “perfect route”)
- at least one **round of informal playtesting**, using feedback to:
  - adjust timer difficulty
  - improve clarity of the HUD and delivery markers
  - tune movement feel (speed, acceleration, etc.)

**stretch goals (nice-to-have):**

- simple animations (e.g., cat drone bobbing, delivery “poof” effect)  
- basic sound effects for movement, successful delivery, and timer warnings  
- a final **summary screen** showing total deliveries, stars, or best time

---

## DEVELOPMENT SETUP

```bash
# Clone repo
git clone https://github.com/avamalino/FinalProject121
cd FinalProject121

# Install dependencies
npm install

# Run dev server (Deno + Vite)
npm run dev

# Build for production
npm run build
