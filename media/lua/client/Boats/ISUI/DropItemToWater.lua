

local dropItem = function(item, player)
    local playerObj = getSpecificPlayer(player)
    if item == nil then return end
    ISTimedActionQueue.add(ISDropItemToWaterAction:new(playerObj, item))
end


local function dropItems(items, player)
	items = ISInventoryPane.getActualItems(items)

	for _,item in ipairs(items) do
		if not item:isFavorite() then
			dropItem(item, player)
		end
	end
end

local function dropItemToWater( player, context, items)
    local playerObj = getSpecificPlayer(player)

    if playerObj:getVehicle() ~= nil and AquaConfig.isBoat(playerObj:getVehicle()) then
        context:addOption(getText("IGUI_DropToWater"), items, dropItems, player);
    end
end



Events.OnFillInventoryObjectContextMenu.Add(dropItemToWater);