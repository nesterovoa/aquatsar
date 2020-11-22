WaterVehicles = {}

local waterVehicleMode = false

function WaterVehicles.moveFunction(vehicle, a, b)
   local field = getClassField(vehicle, 157)
   print(field)
   local tmpTransform = field:get(vehicle)
   print(tmpTransform)

   local wTranform = vehicle:getWorldTransform(tmpTransform)

   print(wTranform)
   local originField = getClassField(wTranform, 1)
   local origin = originField:get(wTranform)

   print(origin:x() .. " " .. origin:y() .. " " .. origin:z())

   origin:set(origin:x() + a, 0.8, origin:z() + b)

   vehicle:setWorldTransform(wTranform)
end





local function waterVehicleControl(key)
   local player = getSpecificPlayer(0)
   if player == nil then return end

   if key == Keyboard.KEY_6 then
      waterVehicleMode = not waterVehicleMode
   end

   local veh = player:getVehicle()
   if player and veh and waterVehicleMode then
      if key == Keyboard.KEY_W then
         WaterVehicles.moveFunction(veh, 1, 0)
      elseif key == Keyboard.KEY_S then
         WaterVehicles.moveFunction(veh, -1, 0)
      elseif key == Keyboard.KEY_A then
         WaterVehicles.moveFunction(veh, 0, 1)
      elseif key == Keyboard.KEY_D then
         WaterVehicles.moveFunction(veh, 0, -1)
      end
   end  
end


Events.OnKeyKeepPressed.Add(waterVehicleControl)
