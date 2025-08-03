require "TimedActions/ISBaseTimedAction"

---@class REQ_ISRestoreEngineQuality : ISBaseTimedAction
---@field vehicle BaseVehicle
---@field part VehiclePart
---@field item InventoryItem
---@field jobType string
local REQ_ISRestoreEngineQuality = ISBaseTimedAction:derive("ISRestoreEngineQuality")


function REQ_ISRestoreEngineQuality:isValid()
	--	return self.vehicle:isInArea(self.part:getArea(), self.character)
	return true;
end

function REQ_ISRestoreEngineQuality:waitToStart()
	self.character:faceThisObject(self.vehicle)
	return self.character:shouldBeTurning()
end

function REQ_ISRestoreEngineQuality:update()
	self.character:faceThisObject(self.vehicle)
	self.item:setJobDelta(self:getJobDelta())

	self.character:setMetabolicTarget(Metabolics.MediumWork);
end

function REQ_ISRestoreEngineQuality:start()
	self.item:setJobType(getText("IGUI_RepairEngine"))
	self:setActionAnim("VehicleWorkOnMid")
end

function REQ_ISRestoreEngineQuality:stop()
	self.item:setJobDelta(0)
	ISBaseTimedAction.stop(self)
end

function REQ_ISRestoreEngineQuality:perform()
	self.item:setJobDelta(0)
	ISBaseTimedAction.perform(self)
end

function REQ_ISRestoreEngineQuality:getEngineQuality(part)
    if part:getId() == "Engine" and part:getVehicle() then
        return part:getVehicle():getEngineQuality()
    end
    return 100
end

---Complete the engine quality restoration action
---@return boolean success
function REQ_ISRestoreEngineQuality:complete()
     local skill = self.character:getPerkLevel(Perks.Mechanics) - self.vehicle:getScript():getEngineRepairLevel()
    local numberOfParts = self.character:getInventory():getNumberOfItem("EngineParts", false, true)
    
    if self.vehicle then
        if not self.part then
            print("[REQ] Error: Engine part not found")
            return false
        end
        
        local currentQuality = self:getEngineQuality(self.part)
        
        -- Calculate quality improvement per part based on skill
        local qualityPerPart = 3 + (skill / 2)
        if qualityPerPart > 10 then qualityPerPart = 10 end
        
        local done = 0
        local newQuality = currentQuality
        
        for i=1,numberOfParts do
            newQuality = newQuality + qualityPerPart
            done = done + 1
            
            if newQuality >= 100 then
                newQuality = 100
                break
            end
        end
        
        if done > 0 and newQuality > currentQuality then
            -- Get current engine parameters
            local engineLoudness = self.vehicle:getScript():getEngineLoudness()
            local baseEnginePower = self.vehicle:getScript():getEngineForce()
            
            -- Calculate new engine power based on quality
            local qualityBoosted = newQuality * 1.6
            if qualityBoosted > 100 then qualityBoosted = 100 end
            local qualityModifier = math.max(0.6, (qualityBoosted / 100))
            local newEnginePower = baseEnginePower * qualityModifier
            
            -- Update engine with new quality
            self.vehicle:setEngineFeature(newQuality, engineLoudness, newEnginePower)
            
            -- Remove used engine parts
            local items = self.character:getInventory():RemoveAll('EngineParts', tonumber(done))
            sendRemoveItemsFromContainer(self.character:getInventory(), items)
            
            -- Grant XP (more than regular repair)
            addXp(self.character, Perks.Mechanics, done * 3)
            
            -- Transmit changes to other players
            self.vehicle:transmitEngine()
            
            self.character:sendObjectChange('mechanicActionDone', { success = true })
        end
    end
    
    return true
end

---Create new engine quality restoration action
---@param character IsoPlayer
---@param part VehiclePart
---@param item InventoryItem
---@param maxTime number?
---@return any
function REQ_ISRestoreEngineQuality:new(character, part, item, maxTime)
    local o = ISBaseTimedAction.new(self, character)
    ---@diagnostic disable-next-line: inject-field
    o.vehicle = part:getVehicle()
    ---@diagnostic disable-next-line: inject-field
    o.part = part
    ---@diagnostic disable-next-line: inject-field
    o.item = item
    o.maxTime = maxTime or 400  -- Longer than regular repair
    ---@diagnostic disable-next-line: inject-field
    o.jobType = "Restore Engine Quality"
    return o
end

return REQ_ISRestoreEngineQuality