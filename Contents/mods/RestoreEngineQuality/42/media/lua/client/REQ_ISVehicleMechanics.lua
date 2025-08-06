-- ===================================================================================================== --
-- VEHICLE MECHANICS MENU EXTENSION
-- ===================================================================================================== --

local REQ_ISRestoreEngineQuality = require "REQ_ISRestoreEngineQuality"
local REQ_Tooltips = require "REQ_Tooltips"
local REQ_Requirements = require "REQ_Requirements"
local REQ_ModOptions = require "REQ_ModOptions"

-- Create our override class for better mod compatibility
local REQ_ISVehicleMechanics = {}

-- ===================================================================================================== --
-- HELPER FUNCTIONS
-- ===================================================================================================== --

---Generate context menu text with optional quality change preview
---@param restorationDetails table
---@return string menuText
function REQ_ISVehicleMechanics.generateMenuText(restorationDetails)
    local restoreText = getText("IGUI_REQ_Restore")
    local engineQualityText = getText("IGUI_Vehicle_EngineQuality")
    local menuText = restoreText .. " " .. engineQualityText .. " (" .. restorationDetails.currentQuality
    if restorationDetails.newQuality > restorationDetails.currentQuality then
        menuText = menuText .. " > " .. restorationDetails.newQuality
    end
    menuText = menuText .. ")"
    return menuText
end

-- ===================================================================================================== --
-- MAIN OVERRIDE FUNCTIONS  
-- ===================================================================================================== --

-- Store original method reference
REQ_ISVehicleMechanics.originalDoPartContextMenu = nil

-- Initialize or reinitialize our override
function REQ_ISVehicleMechanics.initialize()
    -- Store original if not already stored or if it's been overridden by another mod
    if not REQ_ISVehicleMechanics.originalDoPartContextMenu or 
       ISVehicleMechanics.doPartContextMenu ~= REQ_ISVehicleMechanics.extendedDoPartContextMenu then
        REQ_ISVehicleMechanics.originalDoPartContextMenu = ISVehicleMechanics.doPartContextMenu
    end
    
    -- Apply our override
    ISVehicleMechanics.doPartContextMenu = REQ_ISVehicleMechanics.extendedDoPartContextMenu
    
    -- Add our custom callback method to the ISVehicleMechanics class if not already present
    if not ISVehicleMechanics.onRestoreEngineQuality then
        ISVehicleMechanics.onRestoreEngineQuality = REQ_ISVehicleMechanics.onRestoreEngineQuality
    end
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
        
        if engineQuality < 100 then
            -- Validate all requirements
            local requirementResults = REQ_Requirements.validateAllRequirements(self.chr, part)
            
            -- Calculate restoration details for tooltip preview
            local restorationDetails = REQ_ISRestoreEngineQuality.calculateRestorationDetails(self.chr, part)
            
            -- Create context menu text with quality change preview (only show new value if it's bigger)
            local menuText = REQ_ISVehicleMechanics.generateMenuText(restorationDetails)
            local option = self.context:addOption(menuText, getPlayer(), ISVehicleMechanics.onRestoreEngineQuality, part)
            
            -- Add comprehensive tooltip with requirement checking and restoration preview
            REQ_Tooltips.createRestoreEngineTooltip(option, requirementResults, restorationDetails)

            if not requirementResults:areAllRequirementsMet() then
                option.notAvailable = true
            end
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
    end
end

return REQ_ISVehicleMechanics