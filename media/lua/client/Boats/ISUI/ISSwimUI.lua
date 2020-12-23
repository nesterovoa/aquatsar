ISSwimUI = ISPanelJoypad:derive("ISSwimUI");
ISSwimUI.messages = {};
ISSwimUI.windows = {}

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

--************************************************************************--
--** ISSwimUI:initialise
--**
--************************************************************************--

function ISSwimUI:initialise()
    ISPanelJoypad.initialise(self);
    local btnWid = 100
    local btnHgt = math.max(FONT_HGT_SMALL + 3 * 2, 25)
    local padBottom = 10

    self.options = ISTickBox:new(10, self.titleY + FONT_HGT_MEDIUM + 10, 150, 20, "")
    self.options.choicesColor = {r=1, g=1, b=1, a=1}
    self.options:initialise()
    self.options.autoWidth = true;

    local option = self.options:addOption(getText("IGUI_WithMask"), "Mask")
    option = self.options:addOption(getText("IGUI_WithLifeBouy"), "LifeBouy")

    --[[
    if not self.player:isRecipeKnown("Herbalist") then
        self.options:disableOption(getText("IGUI_ScavengeUI_MedicinalPlants"), true);
        self.options:setSelected(option, false);
    end
    ]]--
    self:addChild(self.options)

    -- Tick box to put items inside equipped bag directly
    self.ItemsOptions = ISRadioButtons:new(self.options:getRight(), self.options.y, 100, 20)
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
    self.barY = self.options:getBottom() + self.barPadY
    self:setHeight(self.barY + self.barHgt + self.barPadY + self.barHgt + self.barPadY + btnHgt + padBottom)

	self:insertNewLineOfButtons(self.options, self.ItemsOptions)
	self:insertNewLineOfButtons(self.ok, self.cancel, self.close)
end


function ISSwimUI:render()
	ISPanelJoypad.render(self);
end

function ISSwimUI:prerender()
    local splitPoint = 100;
    local x = 10;
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
        local savedOptions = {};
        for i=1,#self.options.options do
            if self.options:isSelected(i) then
                savedOptions[self.options.optionData[i]] = true;
            end
        end

        if savedOptions["Mask"] then end

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

    self.ItemsOptions:setSelected(1, true);
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
    o.itemsScavenged = {};
    o.maxItem = 4
--    o.itemScavenged = nil;
--    o.itemScavengedAlpha = 1;
--    o.itemScavengedTimer = 0;
    o.zoneProgress = 100;
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

