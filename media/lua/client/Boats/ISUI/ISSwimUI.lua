ISSwimUI = ISPanelJoypad:derive("ISSwimUI");
ISSwimUI.messages = {};
ISSwimUI.windows = {}

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

local function isWater(square)
	return square ~= nil and square:Is(IsoFlagType.water)
end


local function getSwimSquares(x, y)
    local squares = {}
    local cell = getCell()

    local NminDist = 50
    local SminDist = 50
    local EminDist = 50
    local WminDist = 50


    for i=1, 50 do
        for j = -i, i do
            local sq = cell:getGridSquare(x+i, y+j, 0)
            if not isWater(sq) and sq:isNotBlocked(true) then
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
            local sq = cell:getGridSquare(x-i, y+j, 0)
            if not isWater(sq) and sq:isNotBlocked(true) then
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
            local sq = cell:getGridSquare(x+j, y+i, 0)
            
            if not isWater(sq) and sq:isNotBlocked(true) then
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
            
            if not isWater(sq) and sq:isNotBlocked(true) then
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


--************************************************************************--
--** ISSwimUI:initialise
--**
--************************************************************************--

function ISSwimUI:initialise()
    ISPanelJoypad.initialise(self);
    local btnWid = 100
    local btnHgt = math.max(FONT_HGT_SMALL + 3 * 2, 25)
    local padBottom = 10

    -- Tick box to put items inside equipped bag directly
    self.ItemsOptions = ISRadioButtons:new(10, self.titleY + FONT_HGT_MEDIUM + 10, 100, 20)
    self.ItemsOptions.choicesColor = {r=1, g=1, b=1, a=1}
    self.ItemsOptions:initialise()
    self.ItemsOptions.autoWidth = true;
    self:addChild(self.ItemsOptions)
    self:doItemsOptions();

    self.ok = ISButton:new(10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("UI_Ok"), self, ISSwimUI.onClick);
    self.ok.internal = "OK";
    self.ok.anchorTop = false
    self.ok.anchorBottom = true
    self.ok:initialise();
    self.ok:instantiate();
    self.ok.borderColor = self.buttonBorderColor;
    self:addChild(self.ok);
    
    self.close = ISButton:new(self:getWidth() - btnWid - 10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("UI_Close"), self, ISSwimUI.onClick);
    self.close.internal = "CLOSE";
    self.close.anchorTop = false
    self.close.anchorBottom = true
    self.close:initialise();
    self.close:instantiate();
    self.close.borderColor = self.buttonBorderColor;
    self:addChild(self.close);

    self.barPadY = 4
    self.barY = self.ItemsOptions:getBottom() + self.barPadY
    self:setHeight(self.barY + self.barHgt + self.barPadY + self.barPadY + btnHgt + padBottom)

	self:insertNewLineOfButtons(self.ItemsOptions)
	self:insertNewLineOfButtons(self.ok, self.cancel, self.close)
end


function ISSwimUI:render()
    ISPanelJoypad.render(self);

    local yStep = 20

    local x = self.player:getX() - self.searchX
    local y = self.player:getY() - self.searchY
    if math.sqrt(x*x + y*y) > 1 then
        self:setVisible(false);
        self:removeFromUIManager();
        local playerNum = self.player:getPlayerNum()
        if JoypadState.players[playerNum+1] then
            setJoypadFocus(playerNum, nil)
        end
        return
    end

    if self.swimSquares["EAST"] then 
        if not self.ItemsOptions:isOptionEnabled(1) then
            self.ItemsOptions:setOptionEnabled(1, true)
        end    
        
        local chance = AquatsarYachts.Swim.swimChanceSuccess(self.player, self.swimSquares["EAST"])
        self.chances["EAST"] = chance
        self:drawText(getText("IGUI_chance") .. ": " .. chance .. "%", self.ItemsOptions:getRight()+10, self.ItemsOptions.y + 2, 1, 1, 1, 1, UIFont.Small);
    else
        if self.ItemsOptions:isOptionEnabled(1) then
            self.ItemsOptions:setOptionEnabled(1, false)
        end    
    end

    if self.swimSquares["SOUTH"] then 
        if not self.ItemsOptions:isOptionEnabled(2) then
            self.ItemsOptions:setOptionEnabled(2, true)
        end    
        
        local chance = AquatsarYachts.Swim.swimChanceSuccess(self.player, self.swimSquares["SOUTH"])
        self.chances["SOUTH"] = chance
        self:drawText(getText("IGUI_chance") .. ": " .. chance .. "%", self.ItemsOptions:getRight()+10, self.ItemsOptions.y + 2 + yStep, 1, 1, 1, 1, UIFont.Small);
    else
        if self.ItemsOptions:isOptionEnabled(2) then
            self.ItemsOptions:setOptionEnabled(2, false)
        end    
    end

    if self.swimSquares["WEST"] then 
        if not self.ItemsOptions:isOptionEnabled(3) then
            self.ItemsOptions:setOptionEnabled(3, true)
        end    
        
        local chance = AquatsarYachts.Swim.swimChanceSuccess(self.player, self.swimSquares["WEST"])
        self.chances["WEST"] = chance
        self:drawText(getText("IGUI_chance") .. ": " .. chance .. "%", self.ItemsOptions:getRight()+10, self.ItemsOptions.y + 2 + yStep*2, 1, 1, 1, 1, UIFont.Small);
    else
        if self.ItemsOptions:isOptionEnabled(3) then
            self.ItemsOptions:setOptionEnabled(3, false)
        end    
    end

    if self.swimSquares["NORTH"] then 
        if not self.ItemsOptions:isOptionEnabled(4) then
            self.ItemsOptions:setOptionEnabled(4, true)
        end    
        
        local chance = AquatsarYachts.Swim.swimChanceSuccess(self.player, self.swimSquares["NORTH"])
        self.chances["NORTH"] = chance
        self:drawText(getText("IGUI_chance") .. ": " .. chance .. "%", self.ItemsOptions:getRight()+10, self.ItemsOptions.y + 2 + yStep*3, 1, 1, 1, 1, UIFont.Small);
    else
        if self.ItemsOptions:isOptionEnabled(4) then
            self.ItemsOptions:setOptionEnabled(4, false)
        end    
    end

    self.ok:setEnable(false)
    for i=1, 4 do    
        if self.ItemsOptions:isOptionEnabled(i) and self.ItemsOptions:isSelected(i) then
            self.ok:setEnable(true)
        end
    end
end

function ISSwimUI:prerender()
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:drawTextCentre(getText("IGUI_SwimUI_Title"), self.width/2, self.titleY, 1,1,1,1, UIFont.Medium);
    if self.joyfocus and self:getJoypadFocus() == self.ok then
        self:setISButtonForA(self.ok)
    else
        self.ISButtonA = nil
        self.ok.isJoypad = false
    end
end

function ISSwimUI:onClick(button)
    if button.internal == "OK" then

        local dir = "SOUTH"
        if self.ItemsOptions:isSelected(1) then
            dir = "EAST"
        elseif self.ItemsOptions:isSelected(2) then
            dir = "SOUTH"
        elseif self.ItemsOptions:isSelected(3) then
            dir = "WEST"
        elseif self.ItemsOptions:isSelected(4) then
            dir = "NORTH"
        end

        local vehicle = self.player:getVehicle()
        local seat = vehicle:getSeat(self.player)
        vehicle:exit(self.player)
        self.player:PlayAnim("Idle")
        triggerEvent("OnExitVehicle", self.player)
        vehicle:updateHasExtendOffsetForExitEnd(self.player)

        local func = function(pl) 
            pl:getSprite():getProperties():UnSet(IsoFlagType.invisible)
        end
    
        ISTimedActionQueue.clear(self.player)
        ISTimedActionQueue.add(ISSwimAction:new(self.player, self.chances[dir], self.swimSquares[dir]:getX(), self.swimSquares[dir]:getY(), func, self.player ));

        self:setVisible(false);
        self:removeFromUIManager();
        local playerNum = self.player:getPlayerNum()
        if JoypadState.players[playerNum+1] then
            setJoypadFocus(playerNum, nil)
        end

    elseif button.internal == "CLOSE" then
        self:setVisible(false);
        self:removeFromUIManager();
        local playerNum = self.player:getPlayerNum()
        if JoypadState.players[playerNum+1] then
            setJoypadFocus(playerNum, nil)
        end
    end
end

function ISSwimUI:onGainJoypadFocus(joypadData)
    ISPanelJoypad.onGainJoypadFocus(self, joypadData)
    self.joypadIndexY = 2
    self.joypadIndex = 1
    self.joypadButtons = self.joypadButtonsY[self.joypadIndexY]
    self.joypadButtons[self.joypadIndex]:setJoypadFocused(true)
    self:setISButtonForB(self.cancel)
    self:setISButtonForY(self.close)
end

function ISSwimUI:onJoypadDown(button)
    ISPanelJoypad.onJoypadDown(self, button)
    if button == Joypad.BButton then
        self:onClick(self.cancel)
    end
end


function ISSwimUI:doItemsOptions()
    self.ItemsOptions:clear();

    self.ItemsOptions:addOption(getText("IGUI_EAST"), "EAST");
    self.ItemsOptions:addOption(getText("IGUI_SOUTH"), "SOUTH");
    self.ItemsOptions:addOption(getText("IGUI_WEST"), "WEST");
    self.ItemsOptions:addOption(getText("IGUI_NORTH"), "NORTH");
end

function ISSwimUI:findLand()
    

end


--************************************************************************--
--** ISSwimUI:new
--**
--************************************************************************--
function ISSwimUI:new(x, y, width, height, player, square)
    local o = {}
    if y == 0 then
        y = getPlayerScreenTop(player) + (getPlayerScreenHeight(player) - height) / 2
        y = y + 200;
    end
    if x == 0 then
        x = getPlayerScreenLeft(player) + (getPlayerScreenWidth(player) - width) / 2
    end
    o = ISPanelJoypad:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.backgroundColor = {r=0, g=0, b=0, a=0.6};
    o.width = width;
    o.titleY = 10
    o.barHgt = FONT_HGT_SMALL;
    o.height = height;
    o.player = getSpecificPlayer(player);
    o.fgBar = {r=0, g=0.6, b=0, a=0.7 }
    o.fgBarOrange = {r=1, g=0.3, b=0, a=0.7 }
    o.fgBarRed = {r=1, g=0, b=0, a=0.7 }
    o.zone = zone;
    o.square = square;
    o.moveWithMouse = true;
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5};

    o.searchX = o.player:getX()
    o.searchY = o.player:getY()
    o.swimSquares = getSwimSquares(o.searchX, o.searchY)
    o.chances = {}

    return o;
end

function ISSwimUI.OnPlayerDeath(playerObj)
	local ui = ISSwimUI.windows[playerObj:getPlayerNum()+1]
	if ui then
		ui:removeFromUIManager()
		ISSwimUI.windows[playerObj:getPlayerNum()+1] = nil
	end
end

Events.OnPlayerDeath.Add(ISSwimUI.OnPlayerDeath)

