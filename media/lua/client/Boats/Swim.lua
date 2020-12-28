
local function swimToBoatPerform(playerObj, boat)
    local func = function(pl, vehicle)
        vehicle:enter(0, pl)
        vehicle:setCharacterPosition(pl, 0, "inside")
        vehicle:transmitCharacterPosition(0, "inside")
        vehicle:playPassengerAnim(0, "idle")
        triggerEvent("OnEnterVehicle", pl)
    end

    ISTimedActionQueue.clear(playerObj)
    ISTimedActionQueue.add(ISSwimAction:new(playerObj, 100, square:getX(), square:getY(), func, playerObj, boat));
end

local function swimToPointPerform(playerObj, square)
    ISTimedActionQueue.clear(playerObj)
    ISTimedActionQueue.add(ISSwimAction:new(playerObj, 100, square:getX(), square:getY()));
end

local function swimToLandPerform(playerObj, square)
    local func = function(pl) 
        pl:getSprite():getProperties():UnSet(IsoFlagType.invisible)
    end

    ISTimedActionQueue.clear(playerObj)
    ISTimedActionQueue.add(ISSwimAction:new(playerObj, 100, square:getX(), square:getY(), func, playerObj ));
end

local function isWaterLine(x, y, x2, y2)  
    local tmpX = x2 - x
    local tmpY = y2 - y    
    local len = math.sqrt(tmpX*tmpX + tmpY*tmpY)
    local dx = tmpX / len
    local dy = tmpY / len

    local cell = getCell()
    for i=2, math.floor(len) do
        local sq = cell:getGridSquare(x + dx*i, y + dy*i, 0)
        if not sq or not sq:Is(IsoFlagType.water) then 
            return false
        end    
    end

    return true
end

local function getLineNearestLand(x, y, x2, y2)  
    local tmpX = x2 - x
    local tmpY = y2 - y    
    local len = math.sqrt(tmpX*tmpX + tmpY*tmpY)
    local dx = tmpX / len
    local dy = tmpY / len

    local cell = getCell()
    for i=1, math.floor(len) do
        local sq = cell:getGridSquare(x + dx*i, y + dy*i, 0)
        if not sq or not sq:Is(IsoFlagType.water) then 
            return sq
        end    
    end
end

local function swimToPoint(player, context, worldobjects, test)
    local playerObj = getSpecificPlayer(player)
    local playerSquare = playerObj:getSquare()
    local pointSquare
    local boat
    
    if playerObj:getVehicle() then return end

	for i,v in ipairs(worldobjects) do
		local square = v:getSquare();
        
        if square then
            pointSquare = square

            local vehicle = square:getVehicleContainer()
            if vehicle and AquaConfig.isBoat(vehicle) then
                boat = vehicle
            end
        end
    end
    
    if boat then
        local name = getText("IGUI_BoatName" .. boat:getScript():getName())
        context:addOption(getText("IGUI_SwimTo", name), playerObj, swimToBoatPerform, boat)
    
    elseif pointSquare and isWaterLine(playerObj:getX(), playerObj:getY(), pointSquare:getX(), pointSquare:getY()) then
        context:addOption(getText("IGUI_SwimToPoint"), playerObj, swimToPointPerform, pointSquare)

    elseif pointSquare and playerSquare and playerSquare:Is(IsoFlagType.water) then
        if not pointSquare:Is(IsoFlagType.water) then
            local sq = getLineNearestLand(playerObj:getX(), playerObj:getY(), pointSquare:getX(), pointSquare:getY())
            if sq then 
                context:addOption(getText("IGUI_SwimToLand"), playerObj, swimToLandPerform, sq)
            end
        end        
    end
end

Events.OnFillWorldObjectContextMenu.Add(swimToPoint)