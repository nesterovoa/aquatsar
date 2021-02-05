require("Boats/Init")
AquatsarYachts.Swim = {}

function AquatsarYachts.Swim.swimDifficultCoeff(playerObj)
    local canSwim = playerObj:isRecipeKnown("Swimming")
    
    local item = playerObj:getInventory():getItemFromType("Lifebuoy")
    local haveLifebouy = item and item:isEquipped()

    local coeff = 5

    if canSwim or haveLifebouy then
        coeff = 1.0
    end

    local haveDivingMask = playerObj:getInventory():getItemFromType("DivingMask")
    if haveDivingMask and haveDivingMask:isEquipped() then 
        coeff = coeff * 0.9
    end

    local haveSwimGlasses = playerObj:getInventory():getItemFromType("Glasses_SwimmingGoggles")
    if haveSwimGlasses and haveSwimGlasses:isEquipped() then 
        coeff = coeff * 0.9
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
            coeff = coeff * 0.9
    end

    -----

    local equipWeight = round(playerObj:getInventory():getCapacityWeight(), 2)
    if equipWeight > 10 then
        coeff = coeff * (equipWeight/10)
    end
    
    local Unlucky = playerObj:HasTrait("Unlucky")
    if Unlucky then 
        coeff = coeff * 1.2
    end

    local Lucky = playerObj:HasTrait("Lucky")
    if Lucky then 
        coeff = coeff * 0.8
    end
    
    local Overweight = playerObj:HasTrait("Overweight")
    if Overweight then 
        coeff = coeff * 1.1
    end
    
    local Obese = playerObj:HasTrait("Obese")
    if Obese then 
        coeff = coeff * 1.2
    end
    
    local panic = playerObj:getMoodles():getMoodleLevel(MoodleType.Panic)
    coeff = coeff + panic*0.2

    local drunk = playerObj:getMoodles():getMoodleLevel(MoodleType.Drunk)
    coeff = coeff + drunk*0.2

    local endurance = playerObj:getMoodles():getMoodleLevel(MoodleType.Endurance)
    coeff = coeff + endurance*0.2

    local tired = playerObj:getMoodles():getMoodleLevel(MoodleType.Tired)
    coeff = coeff + tired*0.2

    local pain = playerObj:getMoodles():getMoodleLevel(MoodleType.Pain)
    coeff = coeff + pain*0.2

    local Fitness = playerObj:getPerkLevel(Perks.Fitness)
    coeff = coeff * (1.5 - Fitness/10)

    return coeff
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

    local dropNum = ZombRand(#items * 0.4)
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

        local coeff = AquatsarYachts.Swim.swimDifficultCoeff(playerObj)
        print(coeff)

        playerObj:getStats():setEndurance(playerObj:getStats():getEndurance() - 0.0025*coeff)
        playerObj:getXp():AddXP(Perks.Fitness, 0.05)

        local eqWeight = round(playerObj:getInventory():getCapacityWeight(), 2)
        if eqWeight > 20 and ZombRand(100) < 20 and playerObj:getStats():getEndurance() < 0.4 then
            AquatsarYachts.Swim.dropItems(playerObj)
        elseif eqWeight > 10 and ZombRand(100) < 5 and playerObj:getStats():getEndurance() < 0.4 then
            AquatsarYachts.Swim.dropItems(playerObj)
        end

        if playerObj:getStats():getEndurance() < 0.1 then
            if ZombRand(100) < 5 then
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