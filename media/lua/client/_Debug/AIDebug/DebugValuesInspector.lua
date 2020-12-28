if AIDebug == nil then AIDebug = {} end
AIDebugValuesInspector = {}

-- ИСПОЛЬЗОВАНИЕ
-- AIDebug.setInsp(name, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)


AIDebugValuesInspector.tabData = {}
AIDebugValuesInspector.tabPanels = {}
AIDebugValuesInspector.paramView = 1

AIDebugValuesInspector.hideWindow = function(self) -- {{{
	ISCollapsableWindow.close(self);
	AIDebugValuesInspector.toolbarButton:setImage(getTexture("media/textures/AIDebug/Icon_Inspector_Off.png"));
end

local function renderTextParamsView(self)
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

        self:drawText(text, 3, step, 1, 1, 1, 1, UIFont.Small);
        step = step + 15
    end
end

local function renderTextTableDynamicView(self)
    local columnSize = {}

    for _, values in pairs(self.values) do
        for i=1, #values do
            local str = tostring(values[i])
            if columnSize[i] == nil then
                columnSize[i] = string.len(str)
            else
                if string.len(str) > columnSize[i] then
                    columnSize[i] = string.len(str)
                end
            end
        end
    end

    local xSteps = {}
    xSteps[0] = 0
    for i=1, 9 do
        if columnSize[i] ~= nil then
            xSteps[i] = xSteps[i-1] + columnSize[i]
        end
    end


    local yStep = 1
    for _, values in pairs(self.values) do
        local text = ""

        for i=1, #values do
            self:drawText(tostring(values[i]), xSteps[i-1]*8 + 3, yStep, 1, 1, 1, 1, UIFont.Small);    
        end

        yStep = yStep + 15
    end
end

local function renderTextTableStaticView(self)
    local xSteps = {}
    xSteps[0] = 0
    for i=1, 9 do
        xSteps[i] = xSteps[i-1] + 20
    end


    local yStep = 1
    for _, values in pairs(self.values) do
        local text = ""

        for i=1, #values do
            self:drawText(tostring(values[i]), xSteps[i-1]*8 + 3, yStep, 1, 1, 1, 1, UIFont.Small);    
        end

        yStep = yStep + 15
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

    if AIDebugValuesInspector.paramView == 1 then
        AIDebugValuesInspector.tabPanels[name].render = renderTextParamsView
    elseif AIDebugValuesInspector.paramView == 2 then
        AIDebugValuesInspector.tabPanels[name].render = renderTextTableStaticView
    else
        AIDebugValuesInspector.tabPanels[name].render = renderTextTableDynamicView
    end
  
    AIDebugValuesInspector.tabPanels[name]:addScrollBars();
    AIDebugValuesInspector.window.nested:addView(name, AIDebugValuesInspector.tabPanels[name])
end



local function repairVehicle()
    local veh = getPlayer():getVehicle()
    if veh ~= nil then
        veh:repair()
    end
end

local function noclip()
    local pl = getPlayer()
    if pl:isNoClip() then
        pl:setNoClip(false)
    else
        pl:setNoClip(true)
    end

    AIDebugValuesInspector.showInspector(); 
    AIDebugValuesInspector.showInspector()
    AIDebugValuesInspector.InspectorPanel:activateView("Cheats")
end


local function godMode()
    local pl = getPlayer()
    if pl:isGodMod() then
        pl:setGodMod(false)
    else
        pl:setGodMod(true)
    end

    AIDebugValuesInspector.showInspector(); 
    AIDebugValuesInspector.showInspector()
    AIDebugValuesInspector.InspectorPanel:activateView("Cheats")
end

local function ghostMode()
    local pl = getPlayer()
    if pl:isGhostMode() then
        pl:setGhostMode(false)
    else
        pl:setGhostMode(true)
    end

    AIDebugValuesInspector.showInspector(); 
    AIDebugValuesInspector.showInspector()
    AIDebugValuesInspector.InspectorPanel:activateView("Cheats")
end

AIDebugValuesInspector.showWindow = function(player, useSprayCan)--{{{
    -- Set tab window
    AIDebugValuesInspector.InspectorPanel = ISTabPanel:new(Core:getInstance():getScreenWidth() - 680, Core:getInstance():getScreenHeight() - 285, 640, 248);
    AIDebugValuesInspector.InspectorPanel:initialise();
    AIDebugValuesInspector.InspectorPanel:setAnchorBottom(true);
    AIDebugValuesInspector.InspectorPanel:setAnchorRight(true);
    AIDebugValuesInspector.InspectorPanel.target = self;
    AIDebugValuesInspector.InspectorPanel:setEqualTabWidth(true)
    AIDebugValuesInspector.InspectorPanel:setCenterTabs(true)
    AIDebugValuesInspector.window = AIDebugValuesInspector.InspectorPanel:wrapInCollapsableWindow("Values inspector");
    AIDebugValuesInspector.window.close = AIDebugValuesInspector.hideWindow;
    AIDebugValuesInspector.window.closeButton.onmousedown = AIDebugValuesInspector.hideWindow;
    AIDebugValuesInspector.window:setResizable(true);

    for name, values in pairs(AIDebugValuesInspector.tabData) do
        AIDebugValuesInspector.addTab(name)
    end

    -- Settings
    local name = "Settings"
    AIDebugValuesInspector.settingsTab = ISPanelJoypad:new(0, 48, AIDebugValuesInspector.window:getWidth(), AIDebugValuesInspector.window:getHeight() - AIDebugValuesInspector.window.nested.tabHeight)
    AIDebugValuesInspector.settingsTab:initialise()
    AIDebugValuesInspector.settingsTab:instantiate()
    AIDebugValuesInspector.settingsTab:setAnchorRight(true)
    AIDebugValuesInspector.settingsTab:setAnchorLeft(true)
    AIDebugValuesInspector.settingsTab:setAnchorTop(true)
    AIDebugValuesInspector.settingsTab:setAnchorBottom(true)
    AIDebugValuesInspector.settingsTab:noBackground()
    AIDebugValuesInspector.settingsTab.borderColor = {r=0, g=0, b=0, a=0};
    AIDebugValuesInspector.settingsTab:setScrollChildren(true)
    AIDebugValuesInspector.settingsTab:addScrollBars();
    AIDebugValuesInspector.window.nested:addView(name, AIDebugValuesInspector.settingsTab)

    local btn = ISButton:new(10, 10, 100, 20, "Params view", nil, function() AIDebugValuesInspector.paramView = 1; AIDebugValuesInspector.showInspector(); AIDebugValuesInspector.showInspector() end); 
    AIDebugValuesInspector.settingsTab:addChild(btn);

    btn = ISButton:new(10, btn:getBottom() + 10, 100, 20, "Table static view", nil, function() AIDebugValuesInspector.paramView = 2; AIDebugValuesInspector.showInspector(); AIDebugValuesInspector.showInspector() end); 
    AIDebugValuesInspector.settingsTab:addChild(btn);

    btn = ISButton:new(10, btn:getBottom() + 10, 100, 20, "Table dynamic view", nil, function() AIDebugValuesInspector.paramView = 3; AIDebugValuesInspector.showInspector(); AIDebugValuesInspector.showInspector() end); 
    AIDebugValuesInspector.settingsTab:addChild(btn);

    btn = ISButton:new(10, btn:getBottom() + 10, 100, 20, "Clear", nil, AIDebugValuesInspector.clear); 
    AIDebugValuesInspector.settingsTab:addChild(btn);

    btn = ISButton:new(10, btn:getBottom() + 10, 100, 20, "Reload", nil, function() AIDebugValuesInspector.showInspector(); AIDebugValuesInspector.showInspector() end); 
    AIDebugValuesInspector.settingsTab:addChild(btn);


    -- Cheats
    local name = "Cheats"
    AIDebugValuesInspector.cheatsTab = ISPanelJoypad:new(0, 48, AIDebugValuesInspector.window:getWidth(), AIDebugValuesInspector.window:getHeight() - AIDebugValuesInspector.window.nested.tabHeight)
    AIDebugValuesInspector.cheatsTab:initialise()
    AIDebugValuesInspector.cheatsTab:instantiate()
    AIDebugValuesInspector.cheatsTab:setAnchorRight(true)
    AIDebugValuesInspector.cheatsTab:setAnchorLeft(true)
    AIDebugValuesInspector.cheatsTab:setAnchorTop(true)
    AIDebugValuesInspector.cheatsTab:setAnchorBottom(true)
    AIDebugValuesInspector.cheatsTab:noBackground()
    AIDebugValuesInspector.cheatsTab.borderColor = {r=0, g=0, b=0, a=0};
    AIDebugValuesInspector.cheatsTab:setScrollChildren(true)
    AIDebugValuesInspector.cheatsTab:addScrollBars();
    AIDebugValuesInspector.window.nested:addView(name, AIDebugValuesInspector.cheatsTab)

    local btn = ISButton:new(10, 10, 100, 20, "Repair vehicle", nil, repairVehicle); 
    AIDebugValuesInspector.cheatsTab:addChild(btn);

    btn = ISButton:new(10, btn:getBottom() + 10, 100, 20, "NoClip", nil, noclip); 
    AIDebugValuesInspector.cheatsTab:addChild(btn);
    local pl = getPlayer()
    if pl:isNoClip() then
        btn.textColor = {r=0.0, g=1.0, b=0.0, a=1.0};
    else
        btn.textColor = {r=1.0, g=0.0, b=0.0, a=1.0};
    end

    btn = ISButton:new(10, btn:getBottom() + 10, 100, 20, "God Mode", nil, godMode); 
    AIDebugValuesInspector.cheatsTab:addChild(btn);
    if pl:isGodMod() then
        btn.textColor = {r=0.0, g=1.0, b=0.0, a=1.0};
    else
        btn.textColor = {r=1.0, g=0.0, b=0.0, a=1.0};
    end

    btn = ISButton:new(10, btn:getBottom() + 10, 100, 20, "Ghost Mode", nil, ghostMode); 
    AIDebugValuesInspector.cheatsTab:addChild(btn);
    if pl:isGhostMode() then
        btn.textColor = {r=0.0, g=1.0, b=0.0, a=1.0};
    else
        btn.textColor = {r=1.0, g=0.0, b=0.0, a=1.0};
    end


    AIDebugValuesInspector.window:addToUIManager();
	AIDebugValuesInspector.toolbarButton:setImage(getTexture("media/textures/AIDebug/Icon_Inspector_On.png"));
end

function AIDebugValuesInspector.clear()
    AIDebugValuesInspector.tabData = {}
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