
local function repairSailPerform(playerObj, sail, item, thread, needle, addCondition)
    ISTimedActionQueue.add(ISRepairSailAction:new(playerObj, sail, item, thread, needle, addCondition));
end

local function showRepairSailMenu(playerObj, sail, context) 
    -- you need thread and needle
    local thread = playerObj:getInventory():getItemFromType("Thread", true, true);
    local needle = playerObj:getInventory():getItemFromType("Needle", true, true);
    local fabric1 = playerObj:getInventory():getItemFromType("RippedSheets", true, true);
    local fabric2 = playerObj:getInventory():getItemFromType("DenimStrips", true, true);
    local fabric3 = playerObj:getInventory():getItemFromType("LeatherStrips", true, true);
    if not thread or not needle or (not fabric1 and not fabric2 and not fabric3) then
        local patchOption = context:addOption(getText("IGUI_RepairSail"));
        patchOption.notAvailable = true;
        local tooltip = ISInventoryPaneContextMenu.addToolTip();
        tooltip.description = getText("ContextMenu_CantRepair");
        patchOption.toolTip = tooltip;
        return;
    end

    local repairOption = context:addOption(getText("IGUI_RepairSail"));
    local subRepairMenu = context:getNew(context)
    context:addSubMenu(repairOption, subRepairMenu)
    
    if fabric1 ~= nil then
        subRepairMenu:addOption(getItemNameFromFullType(fabric1:getFullType()) .. " (3%)", playerObj, repairSailPerform, sail, fabric1, thread, needle, 3)
    end

    if fabric2 ~= nil then
        subRepairMenu:addOption(getItemNameFromFullType(fabric2:getFullType()) .. " (7%)", playerObj, repairSailPerform, sail, fabric2, thread, needle, 7)
    end

    if fabric3 ~= nil then
        subRepairMenu:addOption(getItemNameFromFullType(fabric3:getFullType()) .. " (12%)", playerObj, repairSailPerform, sail, fabric3, thread, needle, 12)
    end
end


local function sayWindInfo(playerObj)
    local speed = AquaPhysics.Wind.getWindSpeed()
    local force = ""

    if speed < 1 then 
        force = getText("IGUI_Wind_NoWind")
    elseif speed < 10 then
        force = getText("IGUI_Wind_WeakWind")
    elseif speed < 30 then
        force = getText("IGUI_Wind_StrongWind")
    else
        force = getText("IGUI_Wind_StormWind")
    end

    playerObj:Say(getText("IGUI_Wind") .. force .. ", " .. AquaPhysics.Wind.getWindDirection())
end

local function sayWindInfoContext( player, context, items)
    local playerObj = getSpecificPlayer(player)

    items = ISInventoryPane.getActualItems(items)

    for _, item in ipairs(items) do
        if item:getType() == "Compass" then
            if playerObj:isOutside() then
                context:addOption(getText("IGUI_sayWindInfo"), playerObj, sayWindInfo);   
            else
                context:addOption(getText("IGUI_needBeOutside_tosayWindInfo"));   
            end
        end
        if item:getType() == "Sail" and item:getCondition() < 100 then
            showRepairSailMenu(playerObj, item, context)
        end
	end
end



Events.OnFillInventoryObjectContextMenu.Add(sayWindInfoContext);