require("Boats/Init")
AquatsarYachts.Swim = {}



function AquatsarYachts.Swim.chanceSuccess(playerObj, square)
    local x = playerObj:getX() - square:getX()
    local y = playerObj:getY() - square:getY()    
    local dist = math.sqrt(x*x + y*y)
    local canSwim = playerObj:isRecipeKnown("Swimming")
    local equipWeight = round(playerObj:getInventory():getCapacityWeight(), 2)
    local haveDivingMask = playerObj:getInventory():containsType("Wrench")
    local haveLifebouy = playerObj:getInventory():containsType("Screwdriver")
    
    local panic = playerObj:getMoodles():getMoodleLevel(MoodleType.Panic)
    local drunk = playerObj:getMoodles():getMoodleLevel(MoodleType.Drunk)
    local endurance = playerObj:getMoodles():getMoodleLevel(MoodleType.Endurance)
    local tired = playerObj:getMoodles():getMoodleLevel(MoodleType.Tired)
    local pain = playerObj:getMoodles():getMoodleLevel(MoodleType.Pain)

    local Fitness = playerObj:getPerkLevel(Perks.Fitness)

    local Unlucky = playerObj:HasTrait("Unlucky")
    local Lucky = playerObj:HasTrait("Lucky")
    local Overweight = playerObj:HasTrait("Overweight")
    local Obese = playerObj:HasTrait("Obese")

    local chance = 99
    if haveLifebouy then  
        chance = chance * ((50 - dist)/50) * 1.8
    else
        chance = chance * ((50 - dist)/50) * 1.4

        if not canSwim then
            chance = chance * 0.5
        end
    end

    chance = chance * ((30 - equipWeight)/30) * 1.6

    if haveDivingMask then 
        chance = chance * 1.2
    end

    if panic then 
        chance = chance * 0.9
    end

    if drunk then 
        chance = chance * 0.9
    end

    if endurance then 
        chance = chance * 0.9
    end

    if tired then 
        chance = chance * 0.9
    end

    if pain then 
        chance = chance * 0.9
    end

    if Unlucky then 
        chance = chance * 0.9
    end

    if Lucky then 
        chance = chance * 1.2
    end

    if Overweight then 
        chance = chance * 0.9
    end

    if Obese then 
        chance = chance * 0.9
    end

    chance = chance * Fitness / 5

    if chance > 100 then 
        chance = 100
    end

    return 11-- math.floor(chance)
end

local function compare(a,b)
    return a:getWeight() > b:getWeight()
end

function AquatsarYachts.Swim.dropItems(playerObj)
    local inv = playerObj:getInventory()    
    local items = {}

    for j=1, inv:getItems():size() do
        local item = inv:getItems():get(j-1);
        table.insert(items, item)
    end

    local dropNum = ZombRand(#items * 0.6)
    table.sort(items, compare)

    for i=1, dropNum do
        inv:DoRemoveItem(items[i])
    end
end

function AquatsarYachts.Swim.swimToLand(playerObj, square, chance)
    local equipWeight = round(playerObj:getInventory():getCapacityWeight(), 2)
    
    if equipWeight > 20 then
        local coeff = (ZombRand(80) + 10)/100
        playerObj:setHealth(0.2)
        playerObj:Say(getText("IGUI_almostDieFail"))
        AquatsarYachts.Swim.dropItems(playerObj)
    else
        local vehicle = playerObj:getVehicle()
        local seat = vehicle:getSeat(playerObj)
        vehicle:exit(playerObj)
        playerObj:PlayAnim("Idle")
        triggerEvent("OnExitVehicle", playerObj)
        vehicle:updateHasExtendOffsetForExitEnd(playerObj)
        playerObj:setX(square:getX())
        playerObj:setY(square:getY())
    
        local endurance = playerObj:getStats():getEndurance() - 0.5
        if endurance < 0 then endurance = 0 end
        playerObj:getStats():setEndurance(endurance);
        playerObj:getBodyDamage():setWetness(100);
        
        if ZombRand(100) <= chance then
      
        else
            local coeff = (ZombRand(80) + 10)/100
            playerObj:setHealth(0.2)
            playerObj:Say(getText("IGUI_almostDie"))
            AquatsarYachts.Swim.dropItems(playerObj)
        end
    end
end

function AquatsarYachts.Swim.getSwimSquares(x, y)
    local squares = {}
    local cell = getCell()

    local NminDist = 50
    local SminDist = 50
    local EminDist = 50
    local WminDist = 50


    for i=-50, 0 do
        for j=-50, 0 do
            local sq = cell:getGridSquare(x+i, y+j, 0)
            
            if not WaterNWindPhysics.isWater(sq) and sq:isNotBlocked(true) then
                local dist = math.sqrt((i*i + j*j))

                if dist < NminDist then 
                    NminDist = dist
                    squares["NORTH"] = sq
                end
            end
        end
    end

    for i=1, 50 do
        for j = -50, 0 do
            local sq = cell:getGridSquare(x+i, y+j, 0)
            if not WaterNWindPhysics.isWater(sq) and sq:isNotBlocked(true) then
                local dist = math.sqrt((i*i + j*j))

                if dist < EminDist then 
                    EminDist = dist
                    squares["EAST"] = sq
                end
            end
            
        end 
    end

    for i=-50, 0 do
        for j = 1, 50 do
            local sq = cell:getGridSquare(x+i, y+j, 0)

            if not WaterNWindPhysics.isWater(sq) and sq:isNotBlocked(true) then
                local dist = math.sqrt((i*i + j*j))

                if dist < WminDist then 
                    WminDist = dist
                    squares["WEST"] = sq
                end
            end
            
        end 
    end

    for i=1, 50 do
        for j = 1, 50 do
            local sq = cell:getGridSquare(x+i, y+j, 0)

            if not WaterNWindPhysics.isWater(sq) and sq:isNotBlocked(true) then
                local dist = math.sqrt((i*i + j*j))

                if dist < SminDist then 
                    SminDist = dist
                    squares["SOUTH"] = sq
                end
            end
        end 
    end

    return squares
end

--------------------------
local function startSwimToBoat(_, playerObj, boat, chance)
    local equipWeight = round(playerObj:getInventory():getCapacityWeight(), 2)
    
    if equipWeight > 20 then
        local coeff = (ZombRand(80) + 10)/100
        playerObj:setHealth(0.2)
        playerObj:Say(getText("IGUI_almostDieFail"))
        AquatsarYachts.Swim.dropItems(playerObj)
    else
        boat:enter(0, playerObj)

        boat:setCharacterPosition(playerObj, 0, "inside")
        boat:transmitCharacterPosition(0, "inside")
        boat:playPassengerAnim(0, "idle")
        triggerEvent("OnEnterVehicle", playerObj)
        
        local endurance = playerObj:getStats():getEndurance() - 0.5
        if endurance < 0 then endurance = 0 end
        playerObj:getStats():setEndurance(endurance);
        playerObj:getBodyDamage():setWetness(100);
        
        if ZombRand(100) < chance then

        else
            local coeff = (ZombRand(80) + 10)/100
            playerObj:setHealth(0.2)
            playerObj:Say(getText("IGUI_almostDie"))
            AquatsarYachts.Swim.dropItems(playerObj)
        end
    end
end

local function getBoatForSwimTo(square)
    local cell = getCell()
    local x = square:getX()
    local y = square:getY()
    
    for i=-50, 50 do
        for j =-50, 50 do
            local sq = cell:getGridSquare(x+i, y+j, 0)
            
            if WaterNWindPhysics.isWater(sq) then
                for i=1, sq:getMovingObjects():size() do
					local obj = sq:getMovingObjects():get(i-1)
					if obj~= nil and instanceof(obj, "BaseVehicle") and AquaTsarConfig.isBoat(obj) then
						return obj
					end
				end
            end
        end 
    end

end

local function swimToBoat(player, context, worldobjects, test)
    local waterSquare = nil
    local playerObj = getSpecificPlayer(player)

	for i,v in ipairs(worldobjects) do
		square = v:getSquare();
        if square and square:Is(IsoFlagType.water) then
            waterSquare = square
            break
        end
    end
    
    if waterSquare then
        local x = waterSquare:getX() - playerObj:getX()
        local y = waterSquare:getY() - playerObj:getY()

        local boat = getBoatForSwimTo(waterSquare)
        if boat ~= nil then
            local chance = AquatsarYachts.Swim.chanceSuccess(playerObj, boat:getSquare())
            context:addOption(getText("IGUI_SwimTo") .. " " .. getText("IGUI_chance") .. ": " .. chance .. "%" , worldobjects[1], startSwimToBoat, playerObj, boat, chance)
        end
    end

end

Events.OnFillWorldObjectContextMenu.Add(swimToBoat);