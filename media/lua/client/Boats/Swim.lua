require("Boats/Init")
AquatsarYachts.Swim = {}

function AquatsarYachts.Swim.swimChanceSuccess(playerObj, square)
    local x = playerObj:getX() - square:getX()
    local y = playerObj:getY() - square:getY()    
    local dist = math.sqrt(x*x + y*y)
    local canSwim = playerObj:isRecipeKnown("Swimming")
    local haveLifebouy = playerObj:getInventory():containsType("Lifebuoy")

    local chance
    if dist < 10 then
        if canSwim or haveLifebouy then 
            chance = 100
        else
            chance = 80
        end
    elseif dist < 30 then
        if canSwim or haveLifebouy then 
            chance = 95
        else
            chance = 60
        end
    else
        if canSwim or haveLifebouy then 
            chance = 80
        else
            chance = 20
        end
    end

    local haveDivingMask = playerObj:getInventory():containsType("DivingMask")
    if haveDivingMask then 
        chance = chance * 1.1
    end

    local equipWeight = round(playerObj:getInventory():getCapacityWeight(), 2)    
    chance = chance * (1 - (equipWeight/40))
    
    local Unlucky = playerObj:HasTrait("Unlucky")
    if Unlucky then 
        chance = chance * 0.8
    end

    local Lucky = playerObj:HasTrait("Lucky")
    if Lucky then 
        chance = chance * 1.2
    end
    
    local Overweight = playerObj:HasTrait("Overweight")
    if Overweight then 
        chance = chance * 0.9
    end
    
    local Obese = playerObj:HasTrait("Obese")
    if Obese then 
        chance = chance * 0.8
    end
    
    local panic = playerObj:getMoodles():getMoodleLevel(MoodleType.Panic)
    chance = chance * (1 - panic/20)

    local drunk = playerObj:getMoodles():getMoodleLevel(MoodleType.Drunk)
    chance = chance * (1 - drunk/20)

    local endurance = playerObj:getMoodles():getMoodleLevel(MoodleType.Endurance)
    chance = chance * (1 - endurance/20)

    local tired = playerObj:getMoodles():getMoodleLevel(MoodleType.Tired)
    chance = chance * (1 - tired/20)

    local pain = playerObj:getMoodles():getMoodleLevel(MoodleType.Pain)
    chance = chance * (1 - pain/20)

    local Fitness = playerObj:getPerkLevel(Perks.Fitness)
    chance = chance * (Fitness/10 + 0.5)

    if chance > 100 then 
        chance = 100
    elseif chance < 0 then
        chance = 0
    end

    return math.floor(chance)
end


local function swimToBoatPerform(playerObj, boat, chance)
    local func = function(pl, vehicle)
        vehicle:enter(0, pl)
        vehicle:setCharacterPosition(pl, 0, "inside")
        vehicle:transmitCharacterPosition(0, "inside")
        vehicle:playPassengerAnim(0, "idle")
        triggerEvent("OnEnterVehicle", pl)
    end

    local square = boat:getAreaCenter("SeatFrontLeft")

    ISTimedActionQueue.clear(playerObj)
    ISTimedActionQueue.add(ISSwimAction:new(playerObj, chance, square:getX(), square:getY(), func, playerObj, boat));
end

local function swimToPointPerform(playerObj, square, chance)
    ISTimedActionQueue.clear(playerObj)
    ISTimedActionQueue.add(ISSwimAction:new(playerObj, chance, square:getX(), square:getY()));
end

local function swimToLandPerform(playerObj, square, chance)
    local func = function(pl) 
        pl:getSprite():getProperties():UnSet(IsoFlagType.invisible)
    end

    ISTimedActionQueue.clear(playerObj)
    ISTimedActionQueue.add(ISSwimAction:new(playerObj, chance, square:getX(), square:getY(), func, playerObj ));
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
        local chance = AquatsarYachts.Swim.swimChanceSuccess(playerObj, boat:getSquare())
        local name = getText("IGUI_BoatName" .. boat:getScript():getName())
        context:addOption(getText("IGUI_SwimTo", name).. " (" .. getText("IGUI_chance") .. ": " .. chance .. "%)", playerObj, swimToBoatPerform, boat, chance)
    
    elseif pointSquare and isWaterLine(playerObj:getX(), playerObj:getY(), pointSquare:getX(), pointSquare:getY()) then
        local chance = AquatsarYachts.Swim.swimChanceSuccess(playerObj, pointSquare)
        context:addOption(getText("IGUI_SwimToPoint").. " (" .. getText("IGUI_chance") .. ": " .. chance .. "%)", playerObj, swimToPointPerform, pointSquare, chance)

    elseif pointSquare and playerSquare and playerSquare:Is(IsoFlagType.water) then
        if not pointSquare:Is(IsoFlagType.water) then
            local sq = getLineNearestLand(playerObj:getX(), playerObj:getY(), pointSquare:getX(), pointSquare:getY())
            if sq then 
                local chance = AquatsarYachts.Swim.swimChanceSuccess(playerObj, sq)
                context:addOption(getText("IGUI_SwimToLand").. " (" .. getText("IGUI_chance") .. ": " .. chance .. "%)", playerObj, swimToLandPerform, sq, chance)
            end
        end        
    end
end

Events.OnFillWorldObjectContextMenu.Add(swimToPoint)