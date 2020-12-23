if AIDebug == nil then AIDebug = {} end
AIDebugValuesInspector = {}

-- ИСПОЛЬЗОВАНИЕ
-- AIDebug.setInsp(name, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)


AIDebugValuesInspector.tabData = {}
AIDebugValuesInspector.tabPanels = {}


AIDebugValuesInspector.hideWindow = function(self) -- {{{
	ISCollapsableWindow.close(self);
	AIDebugValuesInspector.toolbarButton:setImage(getTexture("media/textures/AIDebug/Icon_Inspector_Off.png"));
end

local function renderText(self)
    --self.values
    
    local step = 1
    for _, values in pairs(self.values) do
        local text = ""
        text = text .. values[1] .. "  "
        
        for i=2, #values do
            if i == #values then
                text = text .. values[i]
            else
                text = text .. values[i] .. " | "            
            end
        end

        self:drawText(text, 1, step, 1, 1, 1, 1, UIFont.Small);
        step = step + 15
    end
end


AIDebugValuesInspector.addTab = function(name) -- {{{
    AIDebugValuesInspector.tabPanels[name] = ISPanelJoypad:new(0, 48, AIDebugValuesInspector.window:getWidth(), AIDebugValuesInspector.window:getHeight() - AIDebugValuesInspector.window.nested.tabHeight)
    AIDebugValuesInspector.tabPanels[name]:initialise()
    AIDebugValuesInspector.tabPanels[name]:instantiate()
    AIDebugValuesInspector.tabPanels[name]:setAnchorRight(true)
    AIDebugValuesInspector.tabPanels[name]:setAnchorLeft(true)
    AIDebugValuesInspector.tabPanels[name]:setAnchorTop(true)
    AIDebugValuesInspector.tabPanels[name]:setAnchorBottom(true)
    AIDebugValuesInspector.tabPanels[name]:noBackground()
    AIDebugValuesInspector.tabPanels[name].borderColor = {r=0, g=0, b=0, a=0};
    AIDebugValuesInspector.tabPanels[name]:setScrollChildren(true)

    AIDebugValuesInspector.tabPanels[name].values = AIDebugValuesInspector.tabData[name]
    AIDebugValuesInspector.tabPanels[name].render = renderText
  
    AIDebugValuesInspector.tabPanels[name]:addScrollBars();
    AIDebugValuesInspector.window.nested:addView(name, AIDebugValuesInspector.tabPanels[name])
end



AIDebugValuesInspector.showWindow = function(player, useSprayCan)--{{{
    -- Set tab window
    local InspectorPanel = ISTabPanel:new(Core:getInstance():getScreenWidth() - 680, Core:getInstance():getScreenHeight() - 285, 640, 248);
    InspectorPanel:initialise();
    InspectorPanel:setAnchorBottom(true);
    InspectorPanel:setAnchorRight(true);
    InspectorPanel.target = self;
    InspectorPanel:setEqualTabWidth(true)
    InspectorPanel:setCenterTabs(true)
    AIDebugValuesInspector.window = InspectorPanel:wrapInCollapsableWindow("Values inspector");
    AIDebugValuesInspector.window.close = AIDebugValuesInspector.hideWindow;
    AIDebugValuesInspector.window.closeButton.onmousedown = AIDebugValuesInspector.hideWindow;
    AIDebugValuesInspector.window:setResizable(true);

    for name, values in pairs(AIDebugValuesInspector.tabData) do
        AIDebugValuesInspector.addTab(name)
    end

    AIDebugValuesInspector.window:addToUIManager();
	AIDebugValuesInspector.toolbarButton:setImage(getTexture("media/textures/AIDebug/Icon_Inspector_On.png"));
end



function AIDebugValuesInspector.showInspector()
    if AIDebugValuesInspector.window and AIDebugValuesInspector.window:getIsVisible() then
		AIDebugValuesInspector.window:close();
	else
		AIDebugValuesInspector.showWindow(getPlayer():getPlayerNum(), nil);
	end
end


function AIDebugValuesInspector.addToolbarButton()
    if AIDebugValuesInspector.toolBarButton then return end

    local movableBtn = ISEquippedItem.instance.movableBtn;
	AIDebugValuesInspector.toolbarButton = ISButton:new(0, movableBtn:getY() + movableBtn:getHeight() + 100, 64, 64, "", nil, AIDebugValuesInspector.showInspector);
	AIDebugValuesInspector.toolbarButton:setImage(getTexture("media/textures/AIDebug/Icon_Inspector_Off.png"))
	AIDebugValuesInspector.toolbarButton:setDisplayBackground(false);
	AIDebugValuesInspector.toolbarButton.borderColor = {r=1, g=1, b=1, a=0.1};

	ISEquippedItem.instance:addChild(AIDebugValuesInspector.toolbarButton);
    ISEquippedItem.instance:setHeight(math.max(ISEquippedItem.instance:getHeight(), AIDebugValuesInspector.toolbarButton:getY() + 64));
    
    AIDebugValuesInspector.showInspector()
end

Events.OnCreatePlayer.Add(AIDebugValuesInspector.addToolbarButton);

-----------------------

function AIDebugValuesInspector.set(name, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    local needRestart = false
    
    if AIDebugValuesInspector.tabData[name] == nil then
        AIDebugValuesInspector.tabData[name] = {}
        needRestart = true
    end
    
    local t = {}
    if arg1 ~= nil then table.insert(t, arg1) end
    if arg2 ~= nil then table.insert(t, arg2) end
    if arg3 ~= nil then table.insert(t, arg3) end
    if arg4 ~= nil then table.insert(t, arg4) end
    if arg5 ~= nil then table.insert(t, arg5) end
    if arg6 ~= nil then table.insert(t, arg6) end
    if arg7 ~= nil then table.insert(t, arg7) end
    if arg8 ~= nil then table.insert(t, arg8) end
    if arg9 ~= nil then table.insert(t, arg9) end

    if #t == 0 then return end

    if AIDebugValuesInspector.tabData[name][t[1]] == nil then
        needRestart = true
    end
    AIDebugValuesInspector.tabData[name][t[1]] = t

    if needRestart then
        AIDebugValuesInspector.showInspector()
    end
end

function AIDebug.setInsp(name, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    AIDebugValuesInspector.set(name, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
end

-- Default player data

local function showPlayerStats()
    local player = getPlayer()

    AIDebug.setInsp("Player", "Player position:", math.floor(player:getX()*10)/10, math.floor(player:getY()*10)/10)

    local vehicle = player:getVehicle()

    local x = "None"
    local y = "None"
    local vehName = "None"

    if vehicle then
        x = math.floor(vehicle:getX()*10)/10
        y = math.floor(vehicle:getY()*10)/10
        vehName = vehicle:getScript():getName()
    end

    AIDebug.setInsp("Player", "Vehicle:", vehName)
    AIDebug.setInsp("Player", "Vehicle position:", x, y)
end


Events.OnTick.Add(showPlayerStats)