-- ===================================================================================================== --
-- TOOLTIP SYSTEM FOR ENGINE QUALITY RESTORATION
-- ===================================================================================================== --

local REQ_Tooltips = {}

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
    local color = hasRequirement and ISVehicleMechanics.ghs or ISVehicleMechanics.bhs
    return " " .. color .. skillName .. " " .. currentLevel .. "/" .. requiredLevel .. " <LINE>"
end

---Build item requirement line for tooltip (hides counts when met)
---@param hasRequirement boolean
---@param itemName string
---@param currentCount number
---@param requiredCount number
---@return string requirementLine
function REQ_Tooltips.buildItemRequirementLine(hasRequirement, itemName, currentCount, requiredCount)
    local color = hasRequirement and ISVehicleMechanics.ghs or ISVehicleMechanics.bhs
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
        lines[#lines + 1] = " " .. ISVehicleMechanics.bhs .. keyReq.name .. " <LINE>"
    end
    
    return lines
end



-- ===================================================================================================== --
-- MAIN TOOLTIP CREATION FUNCTION
-- ===================================================================================================== --

---Create comprehensive tooltip for engine quality restoration
---@param option table
---@param requirementResults REQ_RequirementResults
function REQ_Tooltips.createRestoreEngineTooltip(option, requirementResults)
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
    
    tooltip.description = table.concat(parts)
    option.toolTip = tooltip
end

return REQ_Tooltips
