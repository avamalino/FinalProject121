-- src/theme.lua

-- Single shared table; we alias it as both `theme` and `Theme`
local theme = {
    mode        = "light",  -- "light" or "dark"
    night_alpha = 0.18,     -- how strong the night tint is (0.10–0.25 is nice)
    button      = nil,      -- UI toggle button rect
}

local Theme = theme -- alias so code can use either `theme` or `Theme`

---------------------------------------------------------------------
-- Mode helpers
---------------------------------------------------------------------

function theme.isDark()
    return theme.mode == "dark"
end

function theme.setLight()
    theme.mode = "light"
end

function theme.setDark()
    theme.mode = "dark"
end

function theme.toggle()
    if theme.isDark() then
        theme.setLight()
    else
        theme.setDark()
    end
end

---------------------------------------------------------------------
-- Room tint (applied over 3D scene, *not* over UI)
---------------------------------------------------------------------

function theme.applyRoomTint()
    if not theme.isDark() then
        -- day: no tint, just ensure color is reset
        love.graphics.setColor(1, 1, 1, 1)
        return
    end

    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    -- very soft purple overlay, fairly transparent
    love.graphics.setColor(0.10, 0.03, 0.22, theme.night_alpha)
    love.graphics.rectangle("fill", 0, 0, w, h)
    love.graphics.setColor(1, 1, 1, 1)
end

-- Backwards-compat for main.lua: it calls Theme.drawOverlay()
function theme.drawOverlay()
    theme.applyRoomTint()
end

---------------------------------------------------------------------
-- Text color (UI labels, inventory text, etc.)
---------------------------------------------------------------------

function theme.getTextColor()
    if theme.isDark() then
        return 1, 1, 1, 0.95  -- almost-white text for dark mode
    else
        return 0, 0, 0, 0.95  -- almost-black text for light mode
    end
end

---------------------------------------------------------------------
-- Toggle button UI (sun / moon switch in top-right)
---------------------------------------------------------------------

-- Compute button rect based on window size
function theme.init()
    local margin = 24
    local w, h   = 96, 32
    local sw     = love.graphics.getWidth()

    theme.button = {
        x      = sw - w - margin,
        y      = margin,
        w      = w,
        h      = h,
        radius = h / 2,
    }
end

local function ensureButton()
    if not theme.button then
        theme.init()
    end
    return theme.button
end

-- Draw the sun/moon toggle pill
function theme.drawToggle()
    local btn = ensureButton()
    local x, y, w, h, r = btn.x, btn.y, btn.w, btn.h, btn.radius

    -- Track background
    if theme.isDark() then
        love.graphics.setColor(0.16, 0.16, 0.24, 0.9)
    else
        love.graphics.setColor(0.92, 0.88, 0.70, 0.9)
    end
    love.graphics.rectangle("fill", x, y, w, h, r, r)

    -- Border
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("line", x, y, w, h, r, r)

    -- Knob
    local knob_margin = 4
    local knob_r      = h / 2 - knob_margin
    local knob_y      = y + h / 2
    local knob_x

    if theme.isDark() then
        knob_x = x + w - knob_r - knob_margin
    else
        knob_x = x + knob_r + knob_margin
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle("fill", knob_x, knob_y, knob_r)

    -- Simple sun icon on the left
    local sun_x = x + h / 2
    love.graphics.setColor(1, 0.85, 0.25, 1)
    love.graphics.circle("fill", sun_x, knob_y, 5)

    -- Simple moon icon on the right
    local moon_x = x + w - h / 2
    love.graphics.setColor(0.7, 0.8, 1.0, 1)
    love.graphics.circle("fill", moon_x, knob_y, 5)
end

-- Handle clicks on the toggle
function theme.mousepressed(mx, my, button)
    if button ~= 1 then return end
    local btn = ensureButton()
    if mx >= btn.x and mx <= btn.x + btn.w and
       my >= btn.y and my <= btn.y + btn.h then
        theme.toggle()
    end
end

-- If you resize the window, re-anchor the toggle
function theme.resize(w, h)
    theme.init()
end

---------------------------------------------------------------------
return theme
