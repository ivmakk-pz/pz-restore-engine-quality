-- ===================================================================================================== --
-- TOOLTIP SYSTEM FOR ENGINE QUALITY RESTORATION
-- ===================================================================================================== --

local REQ_Tooltips = {}
local REQ_Utils = require "REQ_Utils"

-- ===================================================================================================== --
-- TOOLTIP BUILDING FUNCTIONS
-- ===================================================================================================== --

---Build skill requirement line for tooltip (always shows counts)
---@param hasRequirement boolean
---@param skillName string
---@param currentLevel number
---@param requiredLevel number
---@return string requirementLine
function REQ_Tooltips.buildSkillRequirementLine(hasRequirement, skillName, currentLevel, requiredLevel)
    local color = REQ_Utils.getRequirementColor(hasRequirement)
    return " " .. color .. skillName .. " " .. currentLevel .. "/" .. requiredLevel .. " <LINE>"
end

---Build item requirement line for tooltip (hides counts when met)
---@param hasRequirement boolean
---@param itemName string
---@param currentCount number
---@param requiredCount number
---@return string requirementLine
function REQ_Tooltips.buildItemRequirementLine(hasRequirement, itemName, currentCount, requiredCount)
    local color = REQ_Utils.getRequirementColor(hasRequirement)
    if hasRequirement then
        return " " .. color .. itemName .. " <LINE>"
    else
        return " " .. color .. itemName .. " " .. currentCount .. "/" .. requiredCount .. " <LINE>"
    end
end



---Build requirements section for tooltip using pre-validated requirement results
---@param requirementResults table
---@return table requirementLines
function REQ_Tooltips.buildRequirementsSection(requirementResults)
    local lines = {}
    
    -- Header
    lines[#lines + 1] = getText("Tooltip_craft_Needs") .. " : <LINE>"
    
    -- Add mechanic skill requirement
    local skillReq = requirementResults.mechanicSkill
    lines[#lines + 1] = REQ_Tooltips.buildSkillRequirementLine(skillReq.met, skillReq.name, skillReq.current, skillReq.required)
    
    -- Add wrench requirement  
    local wrenchReq = requirementResults.wrench
    lines[#lines + 1] = REQ_Tooltips.buildItemRequirementLine(wrenchReq.met, wrenchReq.name, wrenchReq.current, wrenchReq.required)
    
    -- Add engine parts requirement
    local partsReq = requirementResults.engineParts
    lines[#lines + 1] = REQ_Tooltips.buildItemRequirementLine(partsReq.met, partsReq.name, partsReq.current, partsReq.required)
    
    -- Add key requirement if needed
    local keyReq = requirementResults.vehicleKey
    if not keyReq.met then
        lines[#lines + 1] = " " .. REQ_Utils.getRequirementColor(false) .. keyReq.name .. " <LINE>"
    end
    
    return lines
end

---Build restoration details section for tooltip
---@param restorationDetails table
---@return table detailLines
function REQ_Tooltips.buildRestorationDetailsSection(restorationDetails)
    local lines = {}

    local color = REQ_Utils.Colors.NEUTRAL
    local enginePartsText = ScriptManager.instance:getItem("Base.EngineParts"):getDisplayName()
    local engineQualityText = getText("IGUI_Vehicle_EngineQuality")
    local enginePowerText = getText("IGUI_EnginePower")
    local efficiencyText = getText("IGUI_REQ_Efficiency")

    
    -- Only show details if restoration will improve quality
    if restorationDetails.qualityIncrease > 0 then

        lines[#lines + 1] = "<LINE>"
        lines[#lines + 1] = color .. getText("IGUI_REQ_RestorationPreview") .. ":" .. " <LINE>"
        
        -- Quality improvement
        lines[#lines + 1] = color .. engineQualityText .. restorationDetails.currentQuality .. " > " .. restorationDetails.newQuality .. " (+" .. restorationDetails.qualityIncrease .. "%)" .. " <LINE>"
        
        -- Engine power improvement (only show if it would increase)
        if restorationDetails.newEnginePower and restorationDetails.currentEnginePower and 
           restorationDetails.newEnginePower > restorationDetails.currentEnginePower then
            -- Divide by 10 for consistency with game UI display (like vanilla ISVehicleMechanics)
            local currentPowerDisplay = math.floor(restorationDetails.currentEnginePower / 10)
            local newPowerDisplay = math.floor(restorationDetails.newEnginePower / 10)
            local powerIncrease = newPowerDisplay - currentPowerDisplay
            lines[#lines + 1] = color .. enginePowerText .. ": " .. currentPowerDisplay .. " > " .. newPowerDisplay .. " (+" .. powerIncrease .. ") hp" .. " <LINE>"
        end
        
        -- Parts consumption
        lines[#lines + 1] = color .. enginePartsText .. ": " .. restorationDetails.usedParts .. " / " .. restorationDetails.availableParts .. " used" .. " <LINE>"

        -- Efficiency
        lines[#lines + 1] = color .. efficiencyText .. ": +" .. restorationDetails.qualityPerIteration .. "% / " .. restorationDetails.partsPerIteration .. " " .. enginePartsText .. " <LINE>"
    end
    
    return lines
end



-- ===================================================================================================== --
-- MAIN TOOLTIP CREATION FUNCTION
-- ===================================================================================================== --

---Create comprehensive tooltip for engine quality restoration
---@param option table
---@param requirementResults REQ_RequirementResults
---@param restorationDetails table?
function REQ_Tooltips.createRestoreEngineTooltip(option, requirementResults, restorationDetails)
    local tooltip = ISToolTip:new()
    tooltip:initialise()
    tooltip:setVisible(false)
    
    -- Build tooltip description using table.concat for performance
    local parts = {}
    
    -- Requirements section
    local requirementLines = REQ_Tooltips.buildRequirementsSection(requirementResults)
    for i = 1, #requirementLines do
        parts[#parts + 1] = requirementLines[i]
    end
    
    -- Restoration details section (if provided)
    if restorationDetails then
        local detailLines = REQ_Tooltips.buildRestorationDetailsSection(restorationDetails)
        for i = 1, #detailLines do
            parts[#parts + 1] = detailLines[i]
        end
    end
    
    tooltip.description = table.concat(parts)
    option.toolTip = tooltip
end

return REQ_Tooltips
