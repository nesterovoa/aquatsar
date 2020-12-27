


ISNewSalingBoatDashboard = ISPanel:derive("ISNewSalingBoatDashboard")

function ISNewSalingBoatDashboard:createChildren()
	self.backgroundTex = ISImage:new(1000,350, self.dashboardBG:getWidth(), self.dashboardBG:getHeight(), self.dashboardBG);
	self.backgroundTex:initialise();
	self.backgroundTex:instantiate();
	self:addChild(self.backgroundTex);
	

	
	
	-- self.speedTex = ISImage:new(x, y, self.speedGaugeTex:getWidthOrig(), self.speedGaugeTex:getHeightOrig(), self.speedGaugeTex);
	-- self.speedTex:initialise();
	-- self.speedTex:instantiate();
	-- -- self.ignitionTex.onclick = ISBoatDashboard.onClickKeys; -- TODO переключение режима отображения срокости
	-- -- self.ignitionTex.target = self;
	-- -- self.ignitionTex.mouseovertext = getText("Tooltip_Dashboard_KeysIgnition")
	-- self:addChild(self.speedTex);
	
	local x = 133
	local y = 192
	self.speedTexOnes = ISImage:new(x, y, self.speedGaugeNull:getWidthOrig(), self.speedGaugeNull:getHeightOrig(), self.speedGaugeNull);
	self.speedTexOnes:initialise();
	self.speedTexOnes:instantiate();
	self:addChild(self.speedTexOnes);
	
	x = 143
	y = 192
	self.speedTexTens = ISImage:new(x, y, self.speedGaugeNull:getWidthOrig(), self.speedGaugeNull:getHeightOrig(), self.speedGaugeNull);
	self.speedTexTens:initialise();
	self.speedTexTens:instantiate();
	self:addChild(self.speedTexTens);
	
	x = 152
	y = 192
	self.speedTexPoint = ISImage:new(x, y, self.speedGaugePoint:getWidthOrig(), self.speedGaugePoint:getHeightOrig(), self.speedGaugePoint);
	self.speedTexPoint:initialise();
	self.speedTexPoint:instantiate();
	self:addChild(self.speedTexPoint);
	
	x = 156
	y = 192
	self.speedTexFraction = ISImage:new(x, y, self.speedGaugeNull:getWidthOrig(), self.speedGaugeNull:getHeightOrig(), self.speedGaugeNull);
	self.speedTexFraction:initialise();
	self.speedTexFraction:instantiate();
	self:addChild(self.speedTexFraction);
	
	x = 133
	y = 211
	self.speedWindTexOnes = ISImage:new(x, y, self.speedGaugeNull:getWidthOrig(), self.speedGaugeNull:getHeightOrig(), self.speedGaugeNull);
	self.speedWindTexOnes:initialise();
	self.speedWindTexOnes:instantiate();
	self:addChild(self.speedWindTexOnes);
	
	x = 143
	y = 211
	self.speedWindTexTens = ISImage:new(x, y, self.speedGaugeNull:getWidthOrig(), self.speedGaugeNull:getHeightOrig(), self.speedGaugeNull);
	self.speedWindTexTens:initialise();
	self.speedWindTexTens:instantiate();
	self:addChild(self.speedWindTexTens);
	
	x = 152
	y = 211
	self.speedWindTexPoint = ISImage:new(x, y, self.speedGaugePoint:getWidthOrig(), self.speedGaugePoint:getHeightOrig(), self.speedGaugePoint);
	self.speedWindTexPoint:initialise();
	self.speedWindTexPoint:instantiate();
	self:addChild(self.speedWindTexPoint);
	
	x = 156
	y = 211
	self.speedWindTexFraction = ISImage:new(x, y, self.speedGaugeNull:getWidthOrig(), self.speedGaugeNull:getHeightOrig(), self.speedGaugeNull);
	self.speedWindTexFraction:initialise();
	self.speedWindTexFraction:instantiate();
	self:addChild(self.speedWindTexFraction);
	
	
	
	-- x = 947
	-- y = 67
	-- self.speedGauge = ISVehicleGauge:new(x, y, self.speedGaugeTex, 73, 71, -225, 0) -- красная полоска скорости
	-- self.speedGauge:initialise()
	-- self.speedGauge:instantiate()
	-- self:addChild(self.speedGauge)
	
	x = 145
	y = 145
	self.windGauge = ISVehicleGauge:new(x, y, self.windGaugeTex, 5, 5, -270, 90) -- красная полоска (x, y, angle start, angle finish)
	self.windGauge:initialise()
	self.windGauge:instantiate()
	self.windGauge:setNeedleWidth(100)
	self:addChild(self.windGauge)
	
	-- self.windSpeedGauge = ISVehicleGauge:new(x, y, self.sailGaugeTex, 125, 125, -138, -42) -- красная полоска (x, y, angle start, angle finish)
	-- self.windSpeedGauge:initialise()
	-- self.windSpeedGauge:instantiate()
	-- self.windSpeedGauge:setNeedleWidth(50)
	-- self:addChild(self.windSpeedGauge)
	
	-- self.sailGauge = ISVehicleGauge:new(x, y, self.sailGaugeTex, 125, 125, 0, 180) -- красная полоска (x, y, angle start, angle finish)
	-- self.sailGauge:initialise()
	-- self.sailGauge:instantiate()
	-- self.sailGauge:setNeedleWidth(50)
	-- self:addChild(self.sailGauge)
	self:onResolutionChange()
end

function ISNewSalingBoatDashboard:getAlphaFlick(default)
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

function ISNewSalingBoatDashboard:setVehicle(boat)
print("ISNewSalingBoatDashboard:setBoat")
	self.boat = boat
	for _,gauge in ipairs(self.gauges) do
		gauge:setVisible(false)
	end
	self.gauges = {}
	if not boat then
		self:removeFromUIManager()
		return
	end
	
	-- self.speedGauge:setVisible(true)
	-- table.insert(self.gauges, self.speedGauge)
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

function ISNewSalingBoatDashboard:setBoatSpeedValue(speed)
	print("Speed: ", speed)
	if not speed == 0 then
		speed = math.abs(speed)	
		local tens = math.floor(speed / 10)
		local ones = math.floor(speed % 10)
		local fraction = math.floor(a * 10 % 10)
		self.speedTexOnes.texture = self.speedGaugesTex[ones+1]
		self.speedTexTens.texture = self.speedGaugesTex[tens+1]
		self.speedTexFraction.texture = self.speedGaugesTex[fraction+1]
	else 
		print(self.speedGaugesTex)
		print(self.speedGaugesTex[1])
		self.speedTexOnes.texture = self.speedGaugesTex[1]
		self.speedTexTens.texture = self.speedGaugesTex[1]
		self.speedTexFraction.texture = self.speedGaugesTex[1]
	end
		
end

function ISNewSalingBoatDashboard:prerender()
	if not self.boat or not ISUIHandler.allUIVisible then return end
	local alpha = self:getAlphaFlick(0.65)
	local greyBg = {r=0.5, g=0.5, b=0.5, a=alpha}
	local speedValue = self.boat:getCurrentSpeedKmHour()/1.60934
	self.setBoatSpeedValue(speedValue)

	local frontVector = Vector3f.new()
	local rearVector = Vector3f.new()
	self.boat:getAttachmentWorldPos("trailerfront", frontVector)
	self.boat:getAttachmentWorldPos("trailer", rearVector)
	local x = frontVector:x() - rearVector:x()
	local y = frontVector:y() - rearVector:y()
	local wind = getClimateManager():getWindAngleDegrees()
	local boatDirection = math.atan2(x,y) * 57.2958 + 180
	local newwind = 0
	local windOnBoat = 0
	if wind > boatDirection then
		windOnBoat = wind - boatDirection
	else
		windOnBoat = 360 - (boatDirection - wind)
	end
	
	if windOnBoat <= 180 then
		self.windGauge:setValue((180 - windOnBoat)/360)
	else
		self.windGauge:setValue((540 - windOnBoat)/360)
	end
	
	-- local sailAngle = self.boat:getModData()["sailAngle"]
	-- if sailAngle == nil then
		-- sailAngle = 15
	-- end
	-- sailAngle = (sailAngle + 90)/180
	-- self.sailGauge:setValue(sailAngle)
	
	-- local windSpeed = getClimateManager():getWindIntensity()*getClimateManager():getMaxWindspeedKph()
	-- if windSpeed > 100 then windSpeed = 100 end
	-- self.windSpeedGauge:setValue(windSpeed/100)
	
end
		
function ISNewSalingBoatDashboard:render()

end

function ISNewSalingBoatDashboard:ISNewSalingBoatDashboard()
	return true
end

function ISNewSalingBoatDashboard:onResolutionChange()

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

function ISNewSalingBoatDashboard:new(playerNum, chr)
	local o = ISPanel:new(0, 0, 300, 300)
	setmetatable(o, self)
	self.__index = self
	o.playerNum = playerNum
	o.character = chr;
	o.gauges = {}
	o.dashboardBG = getTexture("media/ui/boats/newsalingdashboard/boat_dashboard.png")
	o.windGaugeTex = getTexture("media/ui/boats/newsalingdashboard/boat_wind.png")
	o.wind = getTexture("media/ui/boats/newsalingdashboard/boat_dashboard.png")
	o.speedGaugeTex = getTexture("media/ui/boats/newsalingdashboard/boat_speed_panel.png")
	o.speedGaugeNull = getTexture("media/ui/boats/newsalingdashboard/boat_8.png")
	o.speedGaugePoint = getTexture("media/ui/boats/newsalingdashboard/boat_point.png")
	o.speedGauge0 = getTexture("media/ui/boats/newsalingdashboard/boat_0.png")
	o.speedGauge1 = getTexture("media/ui/boats/newsalingdashboard/boat_1.png")
	o.speedGauge2 = getTexture("media/ui/boats/newsalingdashboard/boat_2.png")
	o.speedGauge3 = getTexture("media/ui/boats/newsalingdashboard/boat_3.png")
	o.speedGauge4 = getTexture("media/ui/boats/newsalingdashboard/boat_4.png")
	o.speedGauge5 = getTexture("media/ui/boats/newsalingdashboard/boat_5.png")
	o.speedGauge6 = getTexture("media/ui/boats/newsalingdashboard/boat_6.png")
	o.speedGauge7 = getTexture("media/ui/boats/newsalingdashboard/boat_7.png")
	o.speedGauge8 = getTexture("media/ui/boats/newsalingdashboard/boat_8.png")
	o.speedGauge9 = getTexture("media/ui/boats/newsalingdashboard/boat_9.png")
	o.speedGaugesTex = {getTexture("media/ui/boats/newsalingdashboard/boat_0.png"), getTexture("media/ui/boats/newsalingdashboard/boat_1.png"),getTexture("media/ui/boats/newsalingdashboard/boat_2.png"),getTexture("media/ui/boats/newsalingdashboard/boat_3.png"),getTexture("media/ui/boats/newsalingdashboard/boat_4.png"),getTexture("media/ui/boats/newsalingdashboard/boat_5.png"),getTexture("media/ui/boats/newsalingdashboard/boat_6.png"),getTexture("media/ui/boats/newsalingdashboard/boat_7.png"),getTexture("media/ui/boats/newsalingdashboard/boat_8.png"),getTexture("media/ui/boats/newsalingdashboard/boat_9.png")}
	o.flickingTimer = 0;
	o:setWidth(o.dashboardBG:getWidth());
	return o
end