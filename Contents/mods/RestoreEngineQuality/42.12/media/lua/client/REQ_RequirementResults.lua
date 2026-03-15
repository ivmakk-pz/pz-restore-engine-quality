-- ===================================================================================================== --
-- REQUIREMENT RESULTS CLASS
-- ===================================================================================================== --

---@class REQ_RequirementResults
---@field mechanicSkill table
---@field wrench table  
---@field engineParts table
---@field vehicleKey table
---@field qualityRestorable table
local REQ_RequirementResults = {}
REQ_RequirementResults.__index = REQ_RequirementResults

---Create new requirement results instance
---@param mechanicSkill table
---@param wrench table
---@param engineParts table
---@param vehicleKey table
---@param qualityRestorable table
---@return REQ_RequirementResults
function REQ_RequirementResults:new(mechanicSkill, wrench, engineParts, vehicleKey, qualityRestorable)
    local instance = {
        mechanicSkill = mechanicSkill,
        wrench = wrench,
        engineParts = engineParts,
        vehicleKey = vehicleKey,
        qualityRestorable = qualityRestorable
    }
    setmetatable(instance, self)
    return instance
end

---Check if all requirements are met
---@return boolean allRequirementsMet
function REQ_RequirementResults:areAllRequirementsMet()
    return self.mechanicSkill.met and 
           self.wrench.met and 
           self.engineParts.met and 
           self.vehicleKey.met and
           self.qualityRestorable.met
end

---Get list of unmet requirements
---@return table unmetRequirements
function REQ_RequirementResults:getUnmetRequirements()
    local unmet = {}
    
    if not self.mechanicSkill.met then
        unmet[#unmet + 1] = self.mechanicSkill
    end
    if not self.wrench.met then
        unmet[#unmet + 1] = self.wrench
    end
    if not self.engineParts.met then
        unmet[#unmet + 1] = self.engineParts
    end
    if not self.vehicleKey.met then
        unmet[#unmet + 1] = self.vehicleKey
    end
    if not self.qualityRestorable.met then
        unmet[#unmet + 1] = self.qualityRestorable
    end
    
    return unmet
end

return REQ_RequirementResults
