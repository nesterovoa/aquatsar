local KEY_9 = 10
local KEY_0 = 11

if not AquatsarYachts then AquatsarYachts = {} end
if not AquatsarYachts.Physics then AquatsarYachts.Physics = {} end

local tempVector1 = Vector3f.new()
local tempVector2 = Vector3f.new()
AquatsarYachts.frontLeftVector = Vector3f.new()
AquatsarYachts.frontRightVector = Vector3f.new()
AquatsarYachts.rearLeftVector = Vector3f.new()
AquatsarYachts.rearRightVector = Vector3f.new()

function AquatsarYachts.Physics.stopVehicleMove(vehicle, force)   
   local linearVel = vehicle:getLinearVelocity(tempVector1)
    tempVector2:set(linearVel:x(), linearVel:z(), linearVel:y())   

    tempVector1:set(tempVector2:x(), 0, tempVector2:y())
    if tempVector1:length() > 1 then 
        tempVector1:normalize()
    end

    tempVector1:mul(-force)
    tempVector2:set(0, 0, 0)
    vehicle:addImpulse(tempVector1, tempVector2) 
end

local function OpenDebug(key)
	if key == KEY_0 then
		print(Go_To:Debug())
	elseif key == KEY_9 then
		vehicleDB:applyImpulseFromHitZombies()
		--AquatsarYachts.Physics.stopVehicleMove(vehicleDB, 3500)
	end
end
	
Events.OnKeyKeepPressed.Add(OpenDebug)  

local textManager = getTextManager();

local screenX = 350;
local screenY = 1;

local r = 0.1
local g = 0.8
local b = 1

local function round(_num)
	local number = _num;
	return number <= 0 and floor(number) or floor(number + 0.5);
end

local function getCoords()
	local player = getSpecificPlayer(0)
	if player then

		local playerX = player:getX();
		local playerY = player:getY();
		local playerZ = player:getZ();
		
		local txt = "POS PLAYER: " .. playerX .. " x " .. playerY .. " x " .. playerZ .. "\n"
		
		vehicleDB = player:getVehicle()
		if not vehicleDB then
			--textManager:DrawString(UIFont.Large, screenX, screenY + 7, txt, r, g, b, 1);
			return
		end
	
		if vehicleDB:getScriptName() == "Base.BoatZeroPatient" then  
			-- squareDB = getSquare(vehicleDB:getX(), vehicleDB:getY(), 0)
			-- floorR = squareDB:getFloor()
			-- vehicleDB:getAttachmentWorldPos("frontLeft", AquatsarYachts.frontLeftVector)
			-- vehicleDB:getAttachmentWorldPos("frontRight", AquatsarYachts.frontRightVector)
			-- vehicleDB:getAttachmentWorldPos("rearLeft", AquatsarYachts.rearLeftVector)
			-- vehicleDB:getAttachmentWorldPos("rearRight", AquatsarYachts.rearRightVector)
			-- local x = squareDB:getX()
			-- local y = squareDB:getY()
			-- local z = squareDB:getZ()
			-- txt = txt .. "squareDB coordinats: ".. tonumber(x) .. " Y:" .. tonumber(y) .. "\n"
			
			-- local tile = floorR:getTextureName()

			
			-- x = AquatsarYachts.frontLeftVector:x()
			-- y = AquatsarYachts.frontLeftVector:y()
			-- txt = txt .. "FrontLeftTile: " .. tonumber(x) .. " Y:" .. tonumber(y) .. "\n"
			-- tile = getSquare(x, y, 0):getFloor():getTextureName()
			-- txt = txt  .. tile .. "\n"
			-- if not string.match(string.lower(tile), "blends_natural_02") then
				--print("ACHTUNG! FrontLeftTile")
			-- end
			-- x = AquatsarYachts.frontRightVector:x()
			-- y = AquatsarYachts.frontRightVector:y()
			-- txt = txt .. "FrontRightTile: " .. tonumber(x) .. " Y:" .. tonumber(y) .. "\n"
			
			-- tile = getSquare(x, y, 0):getFloor():getTextureName()
			-- txt = txt .. tile .. "\n"
			-- if not string.match(string.lower(tile), "blends_natural_02") then
				--print("ACHTUNG! FrontRightTile")
			-- end
			-- x = AquatsarYachts.rearLeftVector:x()
			-- y = AquatsarYachts.rearLeftVector:y()
			-- txt = txt .. "RearLeftTile: " .. tonumber(x) .. " Y:" .. tonumber(y) .. "\n"
			
			-- tile = getSquare(x, y, 0):getFloor():getTextureName()
			-- txt = txt .. tile .. "\n"
			-- if not string.match(string.lower(tile), "blends_natural_02") then
				--print("ACHTUNG! RearLeftTile")
			-- end
			-- x = AquatsarYachts.rearRightVector:x()
			-- y = AquatsarYachts.rearRightVector:y()
			-- txt = txt .. "RearRightTile: " .. tonumber(x) .. " Y:" .. tonumber(y) .. "\n"
			
			-- tile = getSquare(x, y, 0):getFloor():getTextureName()
			-- txt = txt .. tile
			-- if not string.match(string.lower(tile), "blends_natural_02") then
				--print("ACHTUNG! RearRightTile")
			-- end
			
			vehicleDB:getLinearVelocity(tempVector1)
			txt = txt .. "\n" .. "getZ: " .. tonumber(vehicleDB:getDebugZ()) .. "\n"
			
			vehicleDB:getLinearVelocity(tempVector1)
			txt = txt .. "\n" .. "getLinearVelocity: " .. tonumber(tempVector1:x()) .. " Y:" .. tonumber(tempVector1:y()) .. "\n"
			
			vehicleDB:getForwardVector(tempVector1)
			txt = txt .. "\n" .. "getForwardVector: " .. tonumber(tempVector1:x()) .. " Y:" .. tonumber(tempVector1:y()) .. "\n"
			--textManager:DrawString(UIFont.Large, screenX, screenY + 7, txt, r, g, b, 1);
			
			
			
			-- for y=square:getY() - 6, square:getY() + 6 do
			-- for x=square:getX() - 6, square:getX() + 6 do
				-- local square2 = getCell():getGridSquare(x, y, 0)
				-- if square2 then
					-- for i=1, square2:getMovingObjects():size() do
						-- local obj = square2:getMovingObjects():get(i-1)
						-- if obj~= nil 
								-- and instanceof(obj, "BaseVehicle") 
								-- and obj ~= mainVehicle
								-- and #(TowCarMod.Utils.getHookTypeVariants(mainVehicle, obj, hasTowBar)) ~= 0 then
							-- table.insert(vehicles, obj)
						-- end
					-- end
				-- end
			-- end
		end				 
		
		
	end
end

local function round(_num)
	local number = _num;
	return number <= 0 and floor(number) or floor(number + 0.5);
end

local function init()
	if ibrrusDEBUG then
		Events.OnPostUIDraw.Add(getCoords)
	end
end

Events.OnGameStart.Add(init)