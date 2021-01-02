--***********************************************************
--**                      AQUATSAR       	               **
--***********************************************************

require 'Boats/Init'
require "TimedActions/ISBaseTimedAction"

ISSwimAction = ISBaseTimedAction:derive("ISSwimAction")

function ISSwimAction:isValid()
	return true
end

local function compare(a,b)
    return a:getWeight() > b:getWeight()
end

local function dropItems(playerObj)
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

local function wetItems(playerObj)
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

function ISSwimAction:update()
    self.character:setX( self.x + self.dx*self:getJobDelta())
    self.character:setY( self.y + self.dy*self:getJobDelta())

    local sq = self.character:getSquare()
    if sq and sq:Is(IsoFlagType.water) then
        self.character:getSprite():getProperties():Set(IsoFlagType.invisible)
    else
        self.character:getSprite():getProperties():UnSet(IsoFlagType.invisible)
    end

    if self.enduranceFirst - self:getJobDelta()*self.enduranceValue < 0 then
        self:stop()
    end
    self.character:getStats():setEndurance(self.enduranceFirst - self:getJobDelta()*self.enduranceValue)

    if self.character:getStats():getEndurance() < 0.3 and self.isFail then
        if self.damageCount < 6 and ZombRand(100) < 15 then
            if self.damageCount == 0 then
                self.character:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):AddDamage(ZombRand(30))
                AquatsarYachts.Swim.Say("damage", 15)
            elseif self.damageCount == 1 then
                self.character:getBodyDamage():getBodyPart(BodyPartType.Torso_Lower):AddDamage(ZombRand(30))
                AquatsarYachts.Swim.Say("damage", 15)
            elseif self.damageCount == 2 then
                self.character:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):AddDamage(ZombRand(30))
                AquatsarYachts.Swim.Say("damage", 15)
            elseif self.damageCount == 3 then
                self.character:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):AddDamage(ZombRand(30))
                AquatsarYachts.Swim.Say("damage", 15)
            elseif self.damageCount == 4 then
                self.character:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):AddDamage(ZombRand(30))
                AquatsarYachts.Swim.Say("damage", 15)
            elseif self.damageCount == 5 then
                self.character:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):AddDamage(ZombRand(30))    
                AquatsarYachts.Swim.Say("damage", 15)
            end
            self.damageCount = self.damageCount + 1
        end
    end

    if self.isFail and (self.dropCount == 1 and self:getJobDelta() > self.dropTime2) or (self.dropCount == 2 and self:getJobDelta() > self.dropTime1) then
        dropItems(self.character)
        self.dropCount = self.dropCount - 1
        self.isLostItems = true
    end
end

function ISSwimAction:start()
    self.sound = getSoundManager():PlayWorldSound("swim", self.character:getSquare(), 0, 10, 1, true);
    self.character:getBodyDamage():setWetness(100);
    wetItems(self.character)
end

function ISSwimAction:stop()
    if self.sound then
        getSoundManager():StopSound(self.sound)
    end

	ISBaseTimedAction.stop(self)
end

function ISSwimAction:perform()
    if self.sound then
        getSoundManager():StopSound(self.sound)
    end

    self.character:setX( self.x2)
    self.character:setY( self.y2)

    if self.func ~= nil then
        self.func(self.arg1, self.arg2)
    end

    if self.isFail then
        AquatsarYachts.Swim.Say("fail", 30)
    else
        AquatsarYachts.Swim.Say("success", 20)
    end

    if self.isLostItems then
        AquatsarYachts.Swim.Say("lostItems", 100)
    end

	ISBaseTimedAction.perform(self)
end

function ISSwimAction:new(character, chance, x2, y2, func, arg1, arg2)
	local o = {}
	setmetatable(o, self)
	self.__index = self
    o.character = character    
	
    o.x = character:getX()
    o.y = character:getY()
    o.x2 = x2 + 0.5
    o.y2 = y2 + 0.5
    o.dx = o.x2 - o.x
    o.dy = o.y2 - o.y
    o.len = math.sqrt(o.dx*o.dx + o.dy*o.dy)

    o.func = func
    o.arg1 = arg1
    o.arg2 = arg2

    o.maxTime = 60 * math.floor(o.len)

    o.chance = chance
    o.isFail = ZombRand(100) > chance
    o.enduranceFirst = character:getStats():getEndurance()
    o.enduranceValue = o.len/50

    o.damageCount = 0

    local eqWeight = round(character:getInventory():getCapacityWeight(), 2)

    if eqWeight > 20 then
        o.dropCount = 2
    elseif eqWeight > 10 then
        o.dropCount = 1
    else
        o.dropCount = ZombRand(1)
    end

    o.dropTime1 = ZombRand(50)/100
    o.dropTime2 = o.dropTime1 + ZombRand(100 - 100*o.dropTime1)/100

	return o
end

