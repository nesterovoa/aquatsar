
local function blockOptions(player, context, worldobjects, test)
	local playerObj = getSpecificPlayer(player)
	if not playerObj:getVehicle() and playerObj:getSquare() and playerObj:getSquare():Is(IsoFlagType.water) then
		context:removeOption(context:getOptionFromName(getText("ContextMenu_Fishing")))
		context:removeOption(context:getOptionFromName(getText("ContextMenu_Build")))
		context:removeOption(context:getOptionFromName(getText("ContextMenu_SitGround")))
		context:removeOption(context:getOptionFromName(getText("ContextMenu_Walk_to")))
		context:removeOption(context:getOptionFromName(getText("ContextMenu_Wash")))
		context:removeOption(context:getOptionFromName(getText("ContextMenu_SleepOnGround")))
	end
end


Events.OnFillWorldObjectContextMenu.Add(blockOptions)