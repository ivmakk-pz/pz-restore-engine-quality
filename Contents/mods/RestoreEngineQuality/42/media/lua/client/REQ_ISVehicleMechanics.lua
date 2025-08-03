-- ===================================================================================================== --
-- VEHICLE MECHANICS MENU EXTENSION
-- ===================================================================================================== --

local REQ_ISRestoreEngineQuality = require "REQ_ISRestoreEngineQuality"

-- Create our override class for better mod compatibility
local REQ_ISVehicleMechanics = {}

-- Store original method reference
REQ_ISVehicleMechanics.originalDoPartContextMenu = nil

-- Initialize or reinitialize our override
function REQ_ISVehicleMechanics.initialize()
    -- Store original if not already stored or if it's been overridden by another mod
    if not REQ_ISVehicleMechanics.originalDoPartContextMenu or 
       ISVehicleMechanics.doPartContextMenu ~= REQ_ISVehicleMechanics.extendedDoPartContextMenu then
        REQ_ISVehicleMechanics.originalDoPartContextMenu = ISVehicleMechanics.doPartContextMenu
        print("[REQ] Stored reference to current doPartContextMenu method")
    end
    
    -- Apply our override
    ISVehicleMechanics.doPartContextMenu = REQ_ISVehicleMechanics.extendedDoPartContextMenu
    
    -- Add our custom callback method to the ISVehicleMechanics class if not already present
    if not ISVehicleMechanics.onRestoreEngineQuality then
        ISVehicleMechanics.onRestoreEngineQuality = REQ_ISVehicleMechanics.onRestoreEngineQuality
    end
    
    print("[REQ] Vehicle mechanics menu override applied successfully")
end

-- Our extended doPartContextMenu method
function REQ_ISVehicleMechanics.extendedDoPartContextMenu(self, part, x, y)
    -- Call the current original method (handles other mod compatibility)
    if REQ_ISVehicleMechanics.originalDoPartContextMenu then
        REQ_ISVehicleMechanics.originalDoPartContextMenu(self, part, x, y)
    end
    
    -- Add our custom option for engine quality restoration
    if part:getId() == "Engine" and not VehicleUtils.RequiredKeyNotFound(part, self.chr) then
        local engineQuality = part:getVehicle():getEngineQuality()
        
        -- Calculate maximum quality based on mechanic skill level using our helper function
        local mechanicLevel = self.chr:getPerkLevel(Perks.Mechanics)
        local maxQuality = REQ_ISRestoreEngineQuality.calculateMaxQuality(mechanicLevel)

        -- Debug logging
        print("[REQ] Engine quality: " .. engineQuality)
        print("[REQ] Max quality for skill level " .. mechanicLevel .. ": " .. maxQuality .. "%")
        print("[REQ] EngineParts: " .. self.chr:getInventory():getNumberOfItem("EngineParts", false, true))
        print("[REQ] Wrench: " .. tostring(self.chr:getInventory():containsTypeRecurse("Wrench")))
        print("[REQ] Engine power: " .. part:getVehicle():getScript():getEngineForce() *  math.max(0.6, (engineQuality * 1.6 / 100)))
        
        -- Check if restoration is possible (engine quality below skill cap and has requirements)
        if engineQuality < maxQuality and 
           self.chr:getInventory():getNumberOfItem("EngineParts", false, true) >= 2 and
           self.chr:getPerkLevel(Perks.Mechanics) >= part:getVehicle():getScript():getEngineRepairLevel() and
           self.chr:getInventory():containsTypeRecurse("Wrench") then
            
           local option = self.context:addOption("Restore Engine Quality (" .. engineQuality .. "% -> " .. maxQuality .. "%)", 
                getPlayer(), ISVehicleMechanics.onRestoreEngineQuality, part)
        end
    end
end

-- Custom callback method for engine quality restoration
function REQ_ISVehicleMechanics.onRestoreEngineQuality(playerObj, part)
    local typeToItem = VehicleUtils.getItems(playerObj:getPlayerNum())
    local item = typeToItem["Base.Wrench"] and typeToItem["Base.Wrench"][1]
    
    if item then
        ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, part:getVehicle(), part:getArea()))
        ISTimedActionQueue.add(REQ_ISRestoreEngineQuality:new(playerObj, part, item, 400))
    else
        print("[REQ] Warning: No wrench found for engine quality restoration")
    end
end

return REQ_ISVehicleMechanics