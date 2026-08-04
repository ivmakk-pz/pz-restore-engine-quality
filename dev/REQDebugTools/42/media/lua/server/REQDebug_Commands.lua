-- Local testing helper. Engine state is server-authoritative and BaseVehicle.transmitEngine()
-- is a no-op unless GameServer.server, so a client cannot change engine quality itself.
-- This runs the change on the server and lets the normal sync push it back to clients.

local Commands = {}

---Set the engine quality of the vehicle nearest the calling player
---@param player IsoPlayer
---@param args table quality (0-100), optional power override
function Commands.setEngineQuality(player, args)
    local vehicle = player:getNearVehicle()
    if not vehicle then
        print("[REQDebug] no vehicle near player")
        return
    end

    local quality = args.quality or 30

    -- Mirrors Vehicles.Create.Engine so power stays consistent with a naturally created engine
    local qualityBoosted = math.min(100, quality * 1.6)
    local qualityModifier = math.max(0.6, qualityBoosted / 100)
    local power = args.power or (vehicle:getScript():getEngineForce() * qualityModifier)

    -- setEngineFeature divides loudness by 2.7 internally, so scale up to keep it stable
    vehicle:setEngineFeature(quality, vehicle:getEngineLoudness() * 2.7, power)
    vehicle:transmitEngine()

    print(table.concat({
        "[REQDebug] engine set: quality ", tostring(vehicle:getEngineQuality()),
        ", power ", tostring(vehicle:getEnginePower()),
        ", loudness ", tostring(vehicle:getEngineLoudness())
    }))
end

local function onClientCommand(module, command, player, args)
    if module == "REQDebug" and Commands[command] then
        Commands[command](player, args or {})
    end
end

Events.OnClientCommand.Add(onClientCommand)
