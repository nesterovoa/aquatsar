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

    return math.floor(chance)
end


function AquatsarYachts.Swim.swimToLand(playerObj, square, chance)
    if ZombRand(100) <= chance then
        local vehicle = playerObj:getVehicle()
        local seat = vehicle:getSeat(playerObj)
        vehicle:exit(playerObj)
        playerObj:PlayAnim("Idle")
        triggerEvent("OnExitVehicle", playerObj)
        vehicle:updateHasExtendOffsetForExitEnd(playerObj)
        playerObj:setX(square:getX())
        playerObj:setY(square:getY())

        playerObj:getBodyDamage():setWetness(100);
    else
        playerObj:Say("I DIED")
    end
end

function AquatsarYachts.Swim.getSwimSquares(x, y)
    local squares = {}
    local cell = getCell()

    local NminDist = 50
    local SminDist = 50
    local EminDist = 50
    local WminDist = 50

    for i=1, 50 do
        for j = -i, i do
            local sq = cell:getGridSquare(x+i, y+j, 0)
            
            if not WaterBorders.isWater(sq) and sq:isNotBlocked(true) then
                local dist = math.sqrt((i*i + j*j))

                if dist < WminDist then 
                    WminDist = dist
                    squares["WEST"] = sq
                end
            end
        end 
    end

    for i=1, 50 do
        for j = -i, i do
            local sq = cell:getGridSquare(x-i, y+j, 0)
            
            if not WaterBorders.isWater(sq) and sq:isNotBlocked(true) then
                local dist = math.sqrt((i*i + j*j))

                if dist < EminDist then 
                    EminDist = dist
                    squares["EAST"] = sq
                end
            end
        end 
    end

    for i=1, 50 do
        for j = -i, i do
            local sq = cell:getGridSquare(x+j, y+i, 0)
            
            if not WaterBorders.isWater(sq) and sq:isNotBlocked(true) then
                local dist = math.sqrt((i*i + j*j))

                if dist < SminDist then 
                    SminDist = dist
                    squares["SOUTH"] = sq
                end
            end
        end 
    end

    for i=1, 50 do
        for j = -i, i do
            local sq = cell:getGridSquare(x+j, y-i, 0)
            
            if not WaterBorders.isWater(sq) and sq:isNotBlocked(true) then
                local dist = math.sqrt((i*i + j*j))

                if dist < NminDist then 
                    NminDist = dist
                    squares["NORTH"] = sq
                end
            end
        end 
    end

    return squares
end