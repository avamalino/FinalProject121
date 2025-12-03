-- src/theme.lua
-- Simple light/dark theme manager + toggle button for Cat Game

local Theme = {}

-- Theme definitions
Theme.modes = {
  light = {
    name = "light",
    -- soft warm wash so it still feels bright
    overlay = {1.0, 0.98, 0.9, 0.12},
  },
  dark = {
    name = "dark",
    -- dark purple transparent overlay for night mode
    overlay = {0.16, 0.05, 0.27, 0.30},
  },
}

Theme.currentName = "light"
Theme.current     = Theme.modes.light

-- Button layout (we keep it in the top-right)
Theme.button = {
  x = 0,
  y = 0,
  w = 84,
  h = 34,
  margin = 16,
}

-- --- host environment detection -----------------------------------------
-- We treat an environment variable called DARK_MODE as the host preference.
-- If your shell / OS launcher exports DARK_MODE=dark, the game starts in dark.
local function detectHostPreference()
  local env = os.getenv("DARK_MODE")
  if not env then
    return "light"
  end
  env = env:lower()
  if env == "1" or env == "true" or env == "dark" then
    return "dark"
  end
  return "light"
end

function Theme.init()
  local initial = detectHostPreference()
  Theme.setMode(initial)
  Theme.onResize(love.graphics.getWidth(), love.graphics.getHeight())
end

function Theme.setMode(name)
  if Theme.modes[name] then
    Theme.currentName = name
    Theme.current     = Theme.modes[name]
  end
end

function Theme.toggle()
  if Theme.currentName == "light" then
    Theme.setMode("dark")
  else
    Theme.setMode("light")
  end
end

function Theme.isDark()
  return Theme.currentName == "dark"
end

-- keep the button snug in the top-right when window size changes
function Theme.onResize(w, h)
  local b = Theme.button
  b.x = w - b.w - b.margin
  b.y = b.margin
end

-- ---- global day/night tint ---------------------------------------------

-- Call this AFTER drawing the game / UI, but BEFORE drawing the toggle button,
-- so the rooms+inventory get tinted but the button stays crisp.
function Theme.drawOverlay()
  local overlay = Theme.current.overlay
  if not overlay or overlay[4] <= 0 then return end

  local w, h = love.graphics.getWidth(), love.graphics.getHeight()

  love.graphics.push("all")
  love.graphics.setBlendMode("multiply", "premultiplied")
  love.graphics.setColor(overlay)
  love.graphics.rectangle("fill", 0, 0, w, h)
  love.graphics.pop()
end

-- ---- button helpers ----------------------------------------------------

local function pointInRect(px, py, x, y, w, h)
  return px >= x and px <= x + w and py >= y and py <= y + h
end

-- Returns true if this click was used by the theme button
function Theme.mousepressed(mx, my, button)
  if button ~= 1 then return false end

  local b = Theme.button
  if not pointInRect(mx, my, b.x, b.y, b.w, b.h) then
    return false
  end

  local midX = b.x + b.w / 2
  if mx < midX then
    Theme.setMode("light")
  else
    Theme.setMode("dark")
  end
  return true
end

-- Draw the sun/moon toggle in the corner
function Theme.drawToggle()
  local b     = Theme.button
  local midX  = b.x + b.w / 2
  local cY    = b.y + b.h / 2

  love.graphics.push("all")

  -- card background
  love.graphics.setColor(0, 0, 0, 0.55)
  love.graphics.rectangle("fill", b.x, b.y, b.w, b.h, 8, 8)

  -- highlight active half
  love.graphics.setColor(1, 1, 1, 0.18)
  if Theme.currentName == "light" then
    love.graphics.rectangle("fill", b.x + 2, b.y + 2, b.w / 2 - 4, b.h - 4, 6, 6)
  else
    love.graphics.rectangle("fill", midX + 2, b.y + 2, b.w / 2 - 4, b.h - 4, 6, 6)
  end

  -- divider
  love.graphics.setColor(1, 1, 1, 0.35)
  love.graphics.setLineWidth(1)
  love.graphics.line(midX, b.y + 4, midX, b.y + b.h - 4)

  -- SUN (left)
  local sunX = b.x + b.w * 0.25
  love.graphics.setColor(1.0, 0.9, 0.2, 1)
  love.graphics.circle("fill", sunX, cY, 7)
  love.graphics.setLineWidth(1)
  for i = 1, 8 do
    local a = i * (math.pi / 4)
    local cx, cy = math.cos(a), math.sin(a)
    love.graphics.line(
      sunX + cx * 10, cY + cy * 10,
      sunX + cx * 13, cY + cy * 13
    )
  end

  -- MOON (right)
  local moonX = b.x + b.w * 0.75
  love.graphics.setColor(0.8, 0.8, 1.0, 1)
  love.graphics.circle("fill", moonX, cY, 7)
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.circle("fill", moonX + 3, cY - 2, 7)

  love.graphics.pop()
end

return Theme
