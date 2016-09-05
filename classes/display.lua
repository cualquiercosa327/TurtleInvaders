display = class("display")

function display:init()
	self.x = 2
	self.y = 0

	self.width = util.getWidth() / scale
	self.height = util.getHeight() - self.y

	self.powerupTime = 8

	self.drainPowerup = false

	self.player = nil

	self.powerupFade = 1

	self.abilityFade = 1
	self.abilitySine = 0

	self.rouletteInit = false
	self.rouletteTime = 0
	self.rouletteIndex = 0
	self.rouletteTotalTime = 0
	self.rouletteMaxTime = 0.1
end

function display:update(dt)
	if self.drainPowerup then
		self.powerupTime = math.max(0, self.powerupTime - dt)
		self.powerupFade = (self.powerupTime / 8)

		if self.powerupTime <= 0 then
			self.drainPowerup = false

			if self.player then
				self.player:setPowerup("none")
			end
			self.powerupTime = 8
			self.powerupFade = 1
		end
	end

	if abilityKills > 0 then
		self.abilitySine = self.abilitySine + 0.5 * dt

		self.abilityFade = math.abs( math.sin( self.abilitySine * math.pi ) / 2 ) + 0.5
	else
		self.abilitySine = 0
	end

	if self.rouletteInit then
		if self.rouletteTotalTime < 5 then
			if self.rouletteTime < self.rouletteMaxTime then
				self.rouletteTime = self.rouletteTime + dt
			else
				local rand = love.math.random(#powerupList)
				self.rouletteIndex = rand
				self.rouletteTime = 0

				if self.rouletteTotalTime > 1 then
					self.rouletteMaxTime = self.rouletteMaxTime + 6 * dt
				end
			end
			self.rouletteTotalTime = self.rouletteTotalTime + dt
		else
			self.rouletteInit = false
			self.rouletteTotalTime = 0
			self.rouletteTime = 0
			self.rouletteMaxTime = 0.1

			objects["player"][1]:setPowerup(powerupList[self.rouletteIndex])
		end
	end
end

function display:setEnemyData(enemy)
	self.enemyData = enemy
end

function display:getEnemyData()
	return self.enemyData
end

function display:startRoulette()
	if love.math.random() > .05 then
		return
	end

	self.rouletteInit = true
end

function display:draw()
	love.graphics.setColor(255, 255, 255, 160)
	
	if objects["player"][1] then
		self.player = objects["player"][1]
	end
	local player = self.player

	if mobileMode then
		love.graphics.draw(pauseImage, util.getWidth() * 0.005, util.getHeight() - pauseImage:getHeight() * scale  - 2 * scale)
	end
	
	--Player info
	love.graphics.print("Player", self.x * scale, self.y * scale)

	for x = 1, player:getMaxHealth() do
		love.graphics.setColor(255, 255, 255, 160)

		local quadi, color = 1, 1
		if x > player:getHealth() then
			quadi = 2
		end

		if abilityKills / 2 >= x then
			love.graphics.setColor(255, 255, 255, 160 * self.abilityFade)

			color = 2
		end
		
		love.graphics.draw(healthImage, healthQuads[quadi][color], self.x + 2 * scale + math.mod((x - 1), 6) * 9 * scale, self.y + 26 * scale + math.floor((x - 1) / 6) * 9 * scale)
	end
	love.graphics.setColor(255, 255, 255, 160)

	--Score
	love.graphics.print("Score", love.graphics.getWidth() / 2 - hudFont:getWidth("Score") / 2, self.y * scale)

	love.graphics.print(score, love.graphics.getWidth() / 2 - hudFont:getWidth(score) / 2, self.y + 18 * scale)

	--Enemy info
	love.graphics.print("Enemy", (self.x + self.width) * scale - hudFont:getWidth("Enemy") - 4 * scale, self.y)

	if self.enemyData then
		local enemy = self.enemyData
		for x = 1, enemy:getMaxHealth() do
			local quadi = 1
			if x > enemy:getHealth() then
				quadi = 2
			end
			love.graphics.draw(healthImage, healthQuads[quadi][1], ( (self.x + self.width) * scale - hudFont:getWidth("Enemy") / 2 - 27 * scale ) + math.mod((x - 1), 6) * 9 * scale, self.y + 26 * scale + math.floor((x - 1) / 6) * 9 * scale)
		end
	end

	--Powerup info
	local powerupValue = player:getPowerup()
	if powerupValue ~= "none" then
		local powerup, powerupTimeValue = self:getDisplayInfo(powerupValue)

		--display current powerup
		love.graphics.setColor(255, 255, 255, 160 * self.powerupFade)
		love.graphics.draw(powerupImage, powerupQuads[powerup], self.x * scale + hudFont:getWidth("Player") + 8 * scale, self.y * scale + hudFont:getHeight() / 2 - powerupImage:getHeight() / 2)
			
		if not self.drainPowerup then
			self.powerupTime = powerupTimeValue
			self.drainPowerup = true
		end
	else
		if not self.rouletteInit or not powerupQuads[self.rouletteIndex] then
			return
		end

		local powerup = self:getDisplayInfo(powerupList[self.rouletteIndex])

		love.graphics.setColor(255, 255, 255, 160)
		love.graphics.draw(powerupImage, powerupQuads[powerup], self.x * scale + hudFont:getWidth("Player") + 8 * scale, self.y * scale + hudFont:getHeight() / 2 - powerupImage:getHeight() / 2)
	end

	love.graphics.setColor(255, 255, 255, 255)
end

function display:getDisplayInfo(powerupValue)
	local i, time = 1, 8

	if powerupValue == "shield" then
		i = 2
	elseif powerupValue == "laser" then
		i = 3
	elseif powerupValue == "freeze" then
		i = 4
	elseif powerupValue == "anti" then
		i = 5
	elseif powerupValue == "nobullets" then
		i = 6
	elseif powerupValue == "mega" then
		i, time = 7, 5
	elseif powerupValue == "blindness" then
		i = 8
	elseif powerupValue == "bomb" then
		i = 9
	elseif powerupValue == "deflect" then
		i = 10
	elseif powerupValue == "confusion" then
		i = 11
	end

	return i, time
end