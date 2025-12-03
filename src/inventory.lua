-- Global inventory system
Inventory = {
    items = {}
}

function Inventory:add(item_name)
    table.insert(self.items, item_name)
end

function Inventory:has(item_name)
    for _, item in ipairs(self.items) do
        if item == item_name then
            return true
        end
    end
    return false
end

function Inventory:remove(item_name)
    for i, item in ipairs(self.items) do
        if item == item_name then
            table.remove(self.items, i)
            return true
        end
    end
    return false
end

function Inventory:clear()
    self.items = {}
end

return Inventory
