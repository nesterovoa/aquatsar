--***********************************************************
--**                      AQUATSAR       	               **
--***********************************************************

require 'Boats/Init'
require "TimedActions/ISBaseTimedAction"

ISSwimAction = ISBaseTimedAction:derive("ISSwimAction")

function ISSwimAction:isValid()
	return true
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

end

function ISSwimAction:start()
    self.sound = getSoundManager():PlayWorldSound("swim", self.character:getSquare(), 0, 10, 1, true);
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

	return o
end

