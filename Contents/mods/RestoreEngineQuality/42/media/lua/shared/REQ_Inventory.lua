-- ===================================================================================================== --
-- INVENTORY HELPERS (TRANSFER / CONSUMPTION)
-- ===================================================================================================== --

local REQ_Inventory = {}

---Count all items of a type across carried containers (recursive)
---@param playerObj IsoPlayer
---@param itemType string
---@return integer count
function REQ_Inventory.countTypeRecurse(playerObj, itemType)
    return playerObj:getInventory():getNumberOfItem(itemType, false, true)
end

---Check if any item of a type exists across carried containers (recursive)
---@param playerObj IsoPlayer
---@param itemType string
---@return boolean hasIt
function REQ_Inventory.hasTypeRecurse(playerObj, itemType)
    return playerObj:getInventory():containsTypeRecurse(itemType)
end

---@param playerObj IsoPlayer
---@param itemType string
---@param count integer
---@return integer removed
function REQ_Inventory.consumeItemsByTypeRecurse(playerObj, itemType, count)
    if count <= 0 then return 0 end
    local removed = 0
    local inv = playerObj:getInventory()
    while removed < count do
        local item = inv:getFirstTypeRecurse(itemType)
        if not item then break end
        local container = item:getContainer()
        if not container then break end
        container:DoRemoveItem(item)
        sendRemoveItemFromContainer(container, item)
        removed = removed + 1
    end
    return removed
end

return REQ_Inventory
