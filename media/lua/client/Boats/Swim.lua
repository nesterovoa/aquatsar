require("Boats/Init")
AquatsarYachts.Swim = {}

function AquatsarYachts.Swim.swimChanceSuccess(playerObj, square)
    local x = playerObj:getX() - square:getX()
    local y = playerObj:getY() - square:getY()    
    local dist = math.sqrt(x*x + y*y)
    local canSwim = playerObj:isRecipeKnown("Swimming")
    
    local item = playerObj:getInventory():getItemFromType("Lifebuoy")
    local haveLifebouy = item and item:isEquipped()

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

    local haveDivingMask = playerObj:getInventory():getItemFromType("DivingMask")
    if haveDivingMask and haveDivingMask:isEquipped() then 
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
    -- local func = function(pl, vehicle)
        -- vehicle:enter(0, pl)
        -- vehicle:setCharacterPosition(pl, 0, "inside")
        -- vehicle:transmitCharacterPosition(0, "inside")
        -- vehicle:playPassengerAnim(0, "idle")
        -- triggerEvent("OnEnterVehicle", pl)
    -- end
	
	local seat = ISBoatMenu.getBestSeatEnter(playerObj, boat)
    local areaVec = boat:getAreaCenter(boat:getPassengerArea(seat))

    ISTimedActionQueue.clear(playerObj)
    ISTimedActionQueue.add(ISSwimAction:new(playerObj, chance, areaVec:getX(), areaVec:getY(), ISBoatMenu.onEnter, playerObj, boat));
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
    local len = math.abs(math.sqrt(tmpX*tmpX + tmpY*tmpY))
    local dx = tmpX / len
    local dy = tmpY / len

    if len < 2 then return false end

    local cell = getCell()
    for i=2, math.floor(len) do
        local sq = cell:getGridSquare(x + dx*i, y + dy*i, 0)
        if not sq or not sq:getFloor():getSprite():getProperties():Is(IsoFlagType.water) then 
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
        -- if square:Is(IsoFlagType.water) then
            -- print("ISWATER")
        -- end
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
    
    elseif pointSquare and pointSquare ~= playerSquare and isWaterLine(playerObj:getX(), playerObj:getY(), pointSquare:getX(), pointSquare:getY()) then
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
        if not items[i]:isEquipped() then
            inv:DoRemoveItem(items[i])
        end
    end
end

function AquatsarYachts.Swim.wetItems(playerObj)
    local inv = playerObj:getInventory()    
    local items = {}

    for j=1, inv:getItems():size() do
        local item = inv:getItems():get(j-1);
        table.insert(items, item)
    end

    for i=1, #items do
        if items[i]:IsClothing() then
            items[i]:setWetness(80 + ZombRand(20))
        elseif items[i]:IsLiterature() then
            local item = InventoryItemFactory.CreateItem("Aqua.TaintedLiterature");
            inv:AddItem(item)
            inv:DoRemoveItem(items[i])
        end
    end
end


------
-- Fast swim

local function fastSwim(key)
    if key == Keyboard.KEY_SPACE and (isShiftKeyDown() or isKeyDown(Keyboard.KEY_LMENU))then
        local pl = getPlayer()
        local dir = pl:getForwardDirection()
        local x = pl:getX() + dir:getX()
        local y = pl:getY() + dir:getY()

        local sq = getCell():getGridSquare(x, y, pl:getZ())

        if sq and sq:Is(IsoFlagType.water) then 
            pl:setX(x)
            pl:setY(y)
            pl:getBodyDamage():setWetness(100);
            AquatsarYachts.Swim.wetItems(pl)
        end 
    end
end

Events.OnKeyStartPressed.Add(fastSwim)


------
--- Say when swim

local SwimSayWords = {}
SwimSayWords.damage = {}
SwimSayWords.damage["IGUI_SwimWord_Damage1"] = 20
SwimSayWords.damage["IGUI_SwimWord_Damage2"] = 20
SwimSayWords.damage["IGUI_SwimWord_Damage3"] = 15
SwimSayWords.damage["IGUI_SwimWord_Damage4"] = 15
SwimSayWords.damage["IGUI_SwimWord_Damage5"] = 15
SwimSayWords.damage["IGUI_SwimWord_Damage6"] = 15

SwimSayWords.lostItems = {}
SwimSayWords.lostItems["IGUI_SwimWord_LostItems1"] = 33
SwimSayWords.lostItems["IGUI_SwimWord_LostItems2"] = 33
SwimSayWords.lostItems["IGUI_SwimWord_LostItems3"] = 34

SwimSayWords.success = {}
SwimSayWords.success["IGUI_SwimWord_Success1"] = 33
SwimSayWords.success["IGUI_SwimWord_Success2"] = 33
SwimSayWords.success["IGUI_SwimWord_Success3"] = 34

SwimSayWords.fail = {}
SwimSayWords.fail["IGUI_SwimWord_Fail1"] = 33
SwimSayWords.fail["IGUI_SwimWord_Fail2"] = 33
SwimSayWords.fail["IGUI_SwimWord_Fail3"] = 34




function AquatsarYachts.Swim.Say(situation, chaceToSay)
    if ZombRand(100) <= chaceToSay then
        local currentChance = ZombRand(100)
        local count = 0
        for word, chance in pairs(SwimSayWords[situation]) do
            if currentChance >= count and currentChance < (count + chance) then
                getPlayer():Say(getText(word))
                break
            end
            count = count + chance
        end
    end
end

