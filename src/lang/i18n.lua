local i18n = {
    current = "en",
    languages = {}
}

-- Load a language file dynamically
function i18n.load(langCode)
    local ok, lang = pcall(require, "lang." .. langCode)
    if ok then
        i18n.languages[langCode] = lang
    else
        error("Language not found: " .. langCode)
    end
end

-- Set active language
function i18n.setLanguage(langCode)
    if not i18n.languages[langCode] then
        i18n.load(langCode)
    end
    i18n.current = langCode
end

-- Helper: traverse nested tables
local function getNested(tbl, key)
    local current = tbl
    for part in string.gmatch(key, "[^%.]+") do
        if current[part] then
            current = current[part]
        else
            return nil
        end
    end
    return current
end

-- Translate a key
function i18n.t(key)
    local lang = i18n.languages[i18n.current]
    local value = getNested(lang, key)
    if value then
        return value
    else
        return "<missing:" .. key .. ">"
    end
end

return i18n