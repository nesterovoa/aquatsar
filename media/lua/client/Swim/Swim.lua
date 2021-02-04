require("Boats/Init")
AquatsarYachts.Swim = {}

function AquatsarYachts.Swim.swimChanceSuccess(playerObj)
    local canSwim = playerObj:isRecipeKnown("Swimming")
    
    local item = playerObj:getInventory():getItemFromType("Lifebuoy")
    local haveLifebouy = item and item:isEquipped()

    local chance
    if canSwim or haveLifebouy then 
        chance = 95
    else
        chance = 60
    end

    local haveDivingMask = playerObj:getInventory():getItemFromType("DivingMask")
    if haveDivingMask and haveDivingMask:isEquipped() then 
        chance = chance * 1.15
    end

    local haveSwimGlasses = playerObj:getInventory():getItemFromType("Glasses_SwimmingGoggles")
    if haveSwimGlasses and haveSwimGlasses:isEquipped() then 
        chance = chance * 1.1
    end

    ------
    local haveSwimTrunks_Y = playerObj:getInventory():getItemFromType("SwimTrunks_Yellow")
    local haveSwimTrunks_R = playerObj:getInventory():getItemFromType("SwimTrunks_Red")
    local haveSwimTrunks_B = playerObj:getInventory():getItemFromType("SwimTrunks_Blue")
    local haveSwimTrunks_G = playerObj:getInventory():getItemFromType("SwimTrunks_Green")
    local haveSwimSuit = playerObj:getInventory():getItemFromType("Swimsuit_TINT")
    if haveSwimTrunks_Y and haveSwimTrunks_Y:isEquipped() 
        or haveSwimTrunks_R and haveSwimTrunks_R:isEquipped() 
        or haveSwimTrunks_B and haveSwimTrunks_B:isEquipped() 
        or haveSwimTrunks_G and haveSwimTrunks_G:isEquipped() 
        or haveSwimSuit and haveSwimSuit:isEquipped() then 
        chance = chance * 1.1
    end

    -----

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

Events.OnKeyStartPressed.Add(fastSwim)
Events.OnFillWorldObjectContextMenu.Add(swimToPoint)



function AquatsarYachts.Swim.onTick()
    local playerObj = getPlayer()
    if playerObj == nil then return end

    if playerObj:getSquare():Is(IsoFlagType.water) then

        local chanceCoeff = (100 - AquatsarYachts.Swim.swimChanceSuccess(playerObj))/50 + 0.4
        

        playerObj:getStats():setEndurance(playerObj:getStats():getEndurance() - (0.0025 - playerObj:getPerkLevel(Perks.Fitness)/10000)*chanceCoeff)
        playerObj:getXp():AddXP(Perks.Fitness, 0.05)

        local eqWeight = round(playerObj:getInventory():getCapacityWeight(), 2)
        if eqWeight > 20 and ZombRand(1000) < 5 then
            AquatsarYachts.Swim.dropItems(playerObj)
        elseif eqWeight > 10 and ZombRand(1000) < 5 then
            AquatsarYachts.Swim.dropItems(playerObj)
        end

        if playerObj:getStats():getEndurance() < 0.5 then
            if ZombRand(1000) < 5 then
                local part = ZombRand(6)
                if part == 0 then
                    playerObj:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):AddDamage(ZombRand(30))
                    AquatsarYachts.Swim.Say("damage", 15)
                elseif part == 1 then
                    playerObj:getBodyDamage():getBodyPart(BodyPartType.Torso_Lower):AddDamage(ZombRand(30))
                    AquatsarYachts.Swim.Say("damage", 15)
                elseif part == 2 then
                    playerObj:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):AddDamage(ZombRand(30))
                    AquatsarYachts.Swim.Say("damage", 15)
                elseif part == 3 then
                    playerObj:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):AddDamage(ZombRand(30))
                    AquatsarYachts.Swim.Say("damage", 15)
                elseif part == 4 then
                    playerObj:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):AddDamage(ZombRand(30))
                    AquatsarYachts.Swim.Say("damage", 15)
                elseif part == 5 then
                    playerObj:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):AddDamage(ZombRand(30))    
                    AquatsarYachts.Swim.Say("damage", 15)
                end
            end
        end
    end
end


Events.OnTick.Add(AquatsarYachts.Swim.onTick)