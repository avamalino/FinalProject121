-- Global undo stack system
UndoStack = {
    stack = {}
}

-- Push a new action onto the undo stack
function UndoStack:push(action)
    table.insert(self.stack, action)
end

-- Pop and execute the most recent action from the stack
function UndoStack:undo()
    if #self.stack == 0 then
        return false
    end
    
    local action = table.remove(self.stack) -- LIFO - removes last element
    
    if action.type == 'room_transition' then
        self:undo_room_transition(action)
    elseif action.type == 'item_pickup' then
        self:undo_item_pickup(action)
    end
    
    return true
end

-- Undo a room transition by switching back to the previous room
function UndoStack:undo_room_transition(action)
    -- Switch back to previous room
    toolkit:switch(action.from_room)
end

-- Undo an item pickup by restoring the item to its original position
function UndoStack:undo_item_pickup(action)
    local current_room = gamestate.current()
    
    if action.item_type == 'key' then
        -- Remove from inventory (key doesn't use inventory system)
        -- Restore key to its original position and state
        if current_room.key then
            current_room.key.picked = false
            current_room.key.translation:set(action.position.x, action.position.y, action.position.z)
            current_room.key.rotation.angle = action.rotation.angle
            current_room.key.rotation.axis:set(
                action.rotation.axis.x,
                action.rotation.axis.y,
                action.rotation.axis.z
            )
            
            -- Add back to solid array
            table.insert(current_room.solid, current_room.key)
        end
    elseif action.item_type == 'suitcase' then
        -- Remove from inventory
        Inventory:remove('suitcase')
        
        -- Restore suitcase to its original position
        if current_room.suitcase then
            current_room.suitcase.collected = false
            current_room.suitcase.translation:set(action.position.x, action.position.y, action.position.z)
            current_room.suitcase.rotation.angle = action.rotation.angle
            current_room.suitcase.rotation.axis:set(
                action.rotation.axis.x,
                action.rotation.axis.y,
                action.rotation.axis.z
            )
            
            -- Add back to solid array
            table.insert(current_room.solid, current_room.suitcase)
        end
    end
end

-- Check if the stack has any actions
function UndoStack:has_actions()
    return #self.stack > 0
end

-- Clear the entire stack
function UndoStack:clear()
    self.stack = {}
end

-- Get the number of actions in the stack
function UndoStack:size()
    return #self.stack
end

return UndoStack
