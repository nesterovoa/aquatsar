require("Boats/Init")
AquatsarYachts.Tutorial = {}


function AquatsarYachts.Tutorial.initTutorialWindow()
    tut = ISRichTextPanel:new(0, 0, 500, 500);
    tut:initialise();
    tut:setAnchorBottom(true);
    tut:setAnchorRight(true);
    AquatsarYachts.Tutorial.moreinfo = tut:wrapInCollapsableWindow();
    AquatsarYachts.Tutorial.moreinfo:setX((getCore():getScreenWidth() / 2) - (tut.width / 2));
    AquatsarYachts.Tutorial.moreinfo:setY((getCore():getScreenHeight() / 2) - (tut.height / 2));
    AquatsarYachts.Tutorial.moreinfo:addToUIManager();

    tut:setWidth(AquatsarYachts.Tutorial.moreinfo:getWidth());
    tut:setHeight(AquatsarYachts.Tutorial.moreinfo:getHeight()-16);
    tut:setY(AquatsarYachts.Tutorial.moreinfo:titleBarHeight());
    local scrollBarWid = 0
    tut.marginRight = tut.marginLeft + scrollBarWid
    tut.autosetheight = false;
    tut.clip = true
    tut:addScrollBars();

    tut.textDirty = true;
	tut.text = getText("IGUI_Tutorial")
	tut:paginate();
	tut:setYScroll(0);
end


function AquatsarYachts.Tutorial.onLoad()
    local player = getPlayer()
    if player == nil then return end

    if player:getModData()["aqua_isTutorialShowed"] == nil then
        AquatsarYachts.Tutorial.initTutorialWindow()
        player:getModData()["aqua_isTutorialShowed"] = true
    end
end


AquatsarYachts.Tutorial.onKeyPressed = function(key)
	if key == getCore():getKey("Toggle Survival Guide") and not SurvivalGuideManager.blockSurvivalGuide then
        if AquatsarYachts.Tutorial.moreinfo == nil then
            AquatsarYachts.Tutorial.initTutorialWindow()
        else
            if AquatsarYachts.Tutorial.moreinfo:getIsVisible() then
                AquatsarYachts.Tutorial.moreinfo:setVisible(false)
            else
                AquatsarYachts.Tutorial.moreinfo:setVisible(true)
            end
        end
	end
end

Events.OnLoad.Add(AquatsarYachts.Tutorial.onLoad)
Events.OnKeyPressed.Add(AquatsarYachts.Tutorial.onKeyPressed);