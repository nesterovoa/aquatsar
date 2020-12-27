require("Boats/Init")
AquatsarYachts.Swim = {}



function AquatsarYachts.Swim.chanceSuccess(playerObj, square)
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
    local isFail = ZombRand(100) > chance

    if equipWeight > 20 then
        playerObj:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):AddDamage(ZombRand(30))
        playerObj:getBodyDamage():getBodyPart(BodyPartType.Torso_Lower):AddDamage(ZombRand(30))
        playerObj:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):AddDamage(ZombRand(30))
        playerObj:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):AddDamage(ZombRand(30))
        playerObj:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):AddDamage(ZombRand(30))
        playerObj:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):AddDamage(ZombRand(30))    
        AquatsarYachts.Swim.dropItems(playerObj)

        local endurance = playerObj:getStats():getEndurance() - 0.5
        if endurance < 0 then endurance = 0 end
        playerObj:getStats():setEndurance(endurance);
        playerObj:getBodyDamage():setWetness(100);

        playerObj:Say(getText("IGUI_almostDieFail"))
        playerObj:Say(getText("IGUI_andDropItems"))
    else
        if isFail then
            playerObj:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):AddDamage(ZombRand(30))
            playerObj:getBodyDamage():getBodyPart(BodyPartType.Torso_Lower):AddDamage(ZombRand(30))
            playerObj:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):AddDamage(ZombRand(30))
            playerObj:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):AddDamage(ZombRand(30))
            playerObj:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):AddDamage(ZombRand(30))
            playerObj:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):AddDamage(ZombRand(30))    
            AquatsarYachts.Swim.dropItems(playerObj)   
            
            playerObj:Say(getText("IGUI_almostDie"))
            playerObj:Say(getText("IGUI_andDropItems"))
        end

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
        for j = -i, i do
            local sq = cell:getGridSquare(x-i, y+j, 0)
            
            if not WaterNWindPhysics.isWater(sq) and sq:isNotBlocked(true) then
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
            
            if not WaterNWindPhysics.isWater(sq) and sq:isNotBlocked(true) then
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
            
            if not WaterNWindPhysics.isWater(sq) and sq:isNotBlocked(true) then
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

--------------------------
local function startSwimToBoat(playerObj, boat, chance)
    local equipWeight = round(playerObj:getInventory():getCapacityWeight(), 2)
    local isFail = ZombRand(100) > chance

    if equipWeight > 20 then
        playerObj:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):AddDamage(ZombRand(30))
        playerObj:getBodyDamage():getBodyPart(BodyPartType.Torso_Lower):AddDamage(ZombRand(30))
        playerObj:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):AddDamage(ZombRand(30))
        playerObj:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):AddDamage(ZombRand(30))
        playerObj:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):AddDamage(ZombRand(30))
        playerObj:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):AddDamage(ZombRand(30))    
        AquatsarYachts.Swim.dropItems(playerObj)

        local endurance = playerObj:getStats():getEndurance() - 0.5
        if endurance < 0 then endurance = 0 end
        playerObj:getStats():setEndurance(endurance);
        playerObj:getBodyDamage():setWetness(100);

        playerObj:Say(getText("IGUI_almostDieFail"))
        playerObj:Say(getText("IGUI_andDropItems"))
    else
        if isFail then
            playerObj:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):AddDamage(ZombRand(30))
            playerObj:getBodyDamage():getBodyPart(BodyPartType.Torso_Lower):AddDamage(ZombRand(30))
            playerObj:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):AddDamage(ZombRand(30))
            playerObj:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):AddDamage(ZombRand(30))
            playerObj:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):AddDamage(ZombRand(30))
            playerObj:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):AddDamage(ZombRand(30))    
            AquatsarYachts.Swim.dropItems(playerObj)

            playerObj:Say(getText("IGUI_almostDie"))
            playerObj:Say(getText("IGUI_andDropItems"))
        end

        boat:enter(0, playerObj)
        boat:setCharacterPosition(playerObj, 0, "inside")
        boat:transmitCharacterPosition(0, "inside")
        boat:playPassengerAnim(0, "idle")
        triggerEvent("OnEnterVehicle", playerObj)

        local endurance = playerObj:getStats():getEndurance() - 0.5
        if endurance < 0 then endurance = 0 end
        playerObj:getStats():setEndurance(endurance);
        playerObj:getBodyDamage():setWetness(100);
    end
end

local function getBoatsForSwimTo(square)
    local cell = getCell()
    local x = square:getX()
    local y = square:getY()
    
    local boats = {}

    for i=-50, 50 do
        for j =-50, 50 do
            local sq = cell:getGridSquare(x+i, y+j, 0)
            
            if WaterNWindPhysics.isWater(sq) then
                for i=1, sq:getMovingObjects():size() do
					local obj = sq:getMovingObjects():get(i-1)
					if obj~= nil and instanceof(obj, "BaseVehicle") and AquaTsarConfig.isBoat(obj) then
						boats[obj] = true
					end
				end
            end
        end 
    end

    local answer = {}
    for key, value in pairs(boats) do
        table.insert( answer, key)
    end

    return answer
end

local function swimToBoat(player, context, worldobjects, test)
    local waterSquare = nil
    local playerObj = getSpecificPlayer(player)

    if playerObj:getVehicle() then return end

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

        local consolidateOption = context:addOption(getText("IGUI_SwimTo"), nil, nil)
        local subMenuConsolidate = context:getNew(context)
        context:addSubMenu(consolidateOption, subMenuConsolidate)
        
        local boats = getBoatsForSwimTo(waterSquare)
        for i=1, #boats do
            local name = getText("IGUI_BoatName" .. boats[i]:getScript():getName())
            local chance = AquatsarYachts.Swim.chanceSuccess(playerObj, boats[i]:getSquare())
            subMenuConsolidate:addOption(name .. " (" .. getText("IGUI_chance") .. ": " .. chance .. "%)", playerObj, startSwimToBoat, boats[i], chance)
        end



        --[[
        
        if boat ~= nil then
            local chance = AquatsarYachts.Swim.chanceSuccess(playerObj, boat:getSquare())
            context:addOption(getText("IGUI_SwimTo") .. " " .. getText("IGUI_chance") .. ": " .. chance .. "%" , worldobjects[1], startSwimToBoat, playerObj, boat, chance)
        end
        ]]
    end

end

Events.OnFillWorldObjectContextMenu.Add(swimToBoat);