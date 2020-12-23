


ISSalingBoatDashboard = ISPanel:derive("ISSalingBoatDashboard")

function ISSalingBoatDashboard:createChildren()
	self.backgroundTex = ISImage:new(1000,350, self.dashboardBG:getWidth(), self.dashboardBG:getHeight(), self.dashboardBG);
	self.backgroundTex:initialise();
	self.backgroundTex:instantiate();
	self:addChild(self.backgroundTex);

	x = 947
	y = 67
	self.speedGauge = ISVehicleGauge:new(x, y, self.speedGaugeTex, 73, 71, -225, 0) -- красная полоска скорости
	self.speedGauge:initialise()
	self.speedGauge:instantiate()
	self:addChild(self.speedGauge)
	
	x = 90
	y = 80
	self.windGauge = ISVehicleGauge:new(x, y, self.windGaugeTex, 100, 100, -270, 90) -- красная полоска (x, y, angle start, angle finish)
	self.windGauge:initialise()
	self.windGauge:instantiate()
	self.windGauge:setNeedleWidth(80)
	self:addChild(self.windGauge)
	
	self:onResolutionChange()
end

function ISSalingBoatDashboard:getAlphaFlick(default)
	if self.flickingTimer > 0 then
		self.flickingTimer = self.flickingTimer - 1;
		
		if self.flickAlphaUp then
			self.flickAlpha = self.flickAlpha + 0.2;
			if self.flickAlpha >= 1 then
				self.flickAlpha = 0.8;
				self.flickAlphaUp = false;
			end
		else
			self.flickAlpha = self.flickAlpha - 0.2;
			if self.flickAlpha <= 0 then
				self.flickAlpha = 0.2;
				self.flickAlphaUp = true;
			end
		end
		
		return self.flickAlpha;
	else
		return default;
	end
end

function ISSalingBoatDashboard:setVehicle(boat)
print("ISSalingBoatDashboard:setBoat")
	self.boat = boat
	for _,gauge in ipairs(self.gauges) do
		gauge:setVisible(false)
	end
	self.gauges = {}
	if not boat then
		self:removeFromUIManager()
		return
	end
	
	self.speedGauge:setVisible(true)
	table.insert(self.gauges, self.speedGauge)
	self.windGauge:setVisible(true)
	table.insert(self.gauges, self.windGauge)
	if #self.gauges > 0 then
		self:setVisible(true)
		self:addToUIManager()
		self:onResolutionChange()
	else
		self:removeFromUIManager()
	end
	if not ISUIHandler.allUIVisible then
		self:removeFromUIManager()
	end
end

function ISSalingBoatDashboard:prerender()
	if not self.boat or not ISUIHandler.allUIVisible then return end
	local alpha = self:getAlphaFlick(0.65);
	local greyBg = {r=0.5, g=0.5, b=0.5, a=alpha};
	local engineSpeedValue = 0;
	local speedValue = 0;
	if self.boat:isEngineRunning() then
		engineSpeedValue = math.max(0,math.min(1,(self.boat:getEngineSpeed())/6000));
		speedValue = math.max(0,math.min(1,math.abs(self.boat:getCurrentSpeedKmHour())/138));
	end
	-- self.engineGauge:setValue(engineSpeedValue)
	-- RJ: Fake the speedometer a tad
	self.speedGauge:setValue(speedValue * BaseVehicle.getFakeSpeedModifier())
	-- print("X: ", self.boat:getAngleX())
	-- print("Y: ", self.boat:getAngleY())
	local frontVector = Vector3f.new()
	local rearVector = Vector3f.new()
	self.boat:getAttachmentWorldPos("trailer", frontVector)
	self.boat:getAttachmentWorldPos("trailerfront", rearVector)
	local x = frontVector:x() - rearVector:x()
	local y = frontVector:y() - rearVector:y()
	local wind = math.fmod(getClimateManager():getWindAngleDegrees(), 360)
	wind = getClimateManager():getWindAngleDegrees()
	print(ClimateManager.getWindAngleString(getClimateManager():getWindAngleDegrees()))
	--local boatDirection = math.atan2(math.sqrt(2)/2*(x-y), math.sqrt(2)/2*(x+y)) * 57.2958 + 180
	local boatDirection = math.atan2(x,y) * 57.2958 + 180
	print("Wind angle ", wind)	
	--local directionVector = Vector3f.new(x,y, 0)
	print("boatDirection ", boatDirection)
	local newwind = 0
	if wind >= 180 then
		newwind = wind - 180
	else 
		newwind = wind + 180
	end
	print("newwind: ", newwind)
	local windOnBoat = 0
	if newwind > boatDirection then
		windOnBoat = newwind - boatDirection
		print("1windOnBoat ", windOnBoat)
	else
		windOnBoat = 360 - (boatDirection - newwind)
		print("2windOnBoat ", windOnBoat)
	end
	if windOnBoat <= 180 then
		self.windGauge:setValue((180 - windOnBoat)/360)
	else
		self.windGauge:setValue((540 - windOnBoat)/360)
	end
	
end
		
function ISSalingBoatDashboard:render()

end

function ISSalingBoatDashboard:ISSalingBoatDashboard()
	return true
end

function ISSalingBoatDashboard:onResolutionChange()

	local screenLeft = getPlayerScreenLeft(self.playerNum)
	local screenTop = getPlayerScreenTop(self.playerNum)
	local screenWidth = getPlayerScreenWidth(self.playerNum)
	local screenHeight = getPlayerScreenHeight(self.playerNum)

	if self.backgroundTex == nil then
		return;
	end
	
	self:setHeight(self.backgroundTex:getHeight());
	self:setX(screenLeft + (screenWidth - self.backgroundTex:getWidth()) / 2);
	self:setY(screenTop + screenHeight);

	if self.backgroundTex then
		self.backgroundTex:setX(0)
		self.backgroundTex:setY(0)
	end
end

function ISSalingBoatDashboard:new(playerNum, chr)
	local o = ISPanel:new(1000, 1000, 2000, 2000)
	setmetatable(o, self)
	self.__index = self
	o.playerNum = playerNum
	o.character = chr;
	o.gauges = {}
	o.dashboardBG = getTexture("media/ui/boats/salingdashboard/boat_dashboard.png");
	o.speedGaugeTex = getTexture("media/ui/boats/salingdashboard/boat_spedometer.png")
	o.windGaugeTex = getTexture("media/ui/boats/salingdashboard/boat_wind.png")
	o.flickingTimer = 0;
	o:setWidth(o.dashboardBG:getWidth());
	return o
end