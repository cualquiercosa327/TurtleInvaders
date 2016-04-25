local ability = {}

ability.name = "portal"
ability.description = "Shoots portals to travel long distances quickly."

local portalImage = love.graphics.newImage("characters/hugo/portal.png")
local portalGradientImage = love.graphics.newImage("characters/hugo/portalgrad.png")
local shootingImage = love.graphics.newImage("characters/hugo/shooting.png")
local gunImage = love.graphics.newImage("characters/hugo/guns.png")

local gunQuads = {}
for i = 1, 8 do
	table.insert(gunQuads, love.graphics.newQuad(0, (i - 1) * 28, gunImage:getWidth(), gunImage:getHeight(), gunImage:getWidth(), gunImage:getHeight()))
end

local shootingQuads = {}
for y = 1, 2 do
	table.insert(shootingQuads, love.graphics.newQuad(0, (y - 1) * 16, 32, 16, shootingImage:getWidth(), shootingImage:getHeight()))
end

local portalQuads = {}
for x = 1, 2 do
	portalQuads[x] = love.graphics.newQuad((x - 1) * 8, 0, 7, 64, portalImage:getWidth(), portalImage:getHeight())
end

local gradientQuads = {}
for x = 1, 2 do
	gradientQuads[x] = love.graphics.newQuad((x - 1) * 8, 0, 8, 64, portalGradientImage:getWidth(), portalGradientImage:getHeight())
end

function ability:init(turtle)
	self.parent = turtle

	self.timer = 0

	self.gunQuadi = 1

	self.oldDraw = self.parent.draw
	self.parent.draw = function()
		love.graphics.draw(gunImage, gunQuads[self.gunQuadi], self.parent.x + (self.parent.width / 2) - 28, self.parent.y)
	end

	self.parent.mask["barrier"] = false

	self.timer = 0

	self.reverse = false

	self.portals = {}
end

function ability:update(dt)
	for k, v in pairs(self.portals) do
		v:update(dt)
	end

	if self.parent.x < 8 then
		self.parent.x = self.parent.x + 393
	elseif self.parent.x > 393 then
		self.parent.x = self.parent.x - 393
	end

	if self.gunQuadi == 8 then
		if not self.finishAbility then
			self.parent.draw = self.oldDraw
			self.finishAbility = true
		end
		return
	end

	self.timer = self.timer + 8 * dt
	self.gunQuadi = math.floor(self.timer % 8) + 1

	if self.gunQuadi == 6 then
		self.portals[1] = newPortalShot(self.parent.x - 32, self.parent.y + (self.parent.height / 2), 1, self)

		self.portals[2] = newPortalShot(self.parent.x + self.parent.width, self.parent.y + (self.parent.height / 2), 2, self)
	end
end

function ability:createPortals(x, y, i)
	self.portals[i] = newPortal(x, y, i)
end

function ability:draw()
	if self.parent.shouldDraw and objects["player"][1] then
		if self.parent.x < 8 then
			love.graphics.draw(self.parent.graphic, self.parent.animationQuads[self.parent.animationQuadi], self.parent.x + 393, self.parent.y)
		elseif self.parent.x + self.parent.width > 393 then
			love.graphics.draw(self.parent.graphic, self.parent.animationQuads[self.parent.animationQuadi], self.parent.x - 393, self.parent.y)
		end
	end

	for k, v in pairs(self.portals) do
		v:draw()
	end
end

function ability:reset()
	self.parent.mask["barrier"] = true
	self.parent.draw = self.oldDraw
end

function newPortalShot(x, y, i, abilityData)
	local shot = {}
	shot.colors = {{0, 128, 255, 255}, {255, 128, 0, 255}}

	shot.x = x
	shot.y = y

	shot.graphic = shootingImage
	shot.quadi = i

	local speed = -180
	if i == 2 then
		speed = 180
	end

	shot.speedx = speed
	shot.speedy = 0

	shot.parent = abilityData

	shot.width = 32
	shot.height = 16

	function shot:update(dt)
		if not self.remove then
			self.x = self.x + self.speedx * dt

			if self.x < 0 then
				self.parent:createPortals(0, util.getHeight() - 64, self.quadi)
				self.remove = true
			elseif self.x > 400 then
				self.parent:createPortals(393, util.getHeight() - 64, self.quadi)
				self.remove = true
			end
		end
	end

	function shot:draw()
		love.graphics.setColor(unpack(self.colors[self.quadi]))
		love.graphics.draw(self.graphic, shootingQuads[self.quadi], self.x, self.y)
		love.graphics.setColor(255, 255, 255)
	end

	return shot
end

function newPortal(x, y, i)
	local portal = {}

	portal.x = x
	portal.y = y

	portal.i = i

	portal.colors = {{0, 128, 255, 0}, {255, 128, 0, 0}}

	function portal:update(dt)
		self.colors[self.i][4] = math.min(self.colors[self.i][4] + 160 * dt, 255)
	end

	local offset = 1
	if i == 2 then
		offset = -1
	end
	portal.offset = offset

	function portal:draw()
		love.graphics.push()

		love.graphics.setColor(255, 255, 255, self.colors[self.i][4])
		love.graphics.draw(portalGradientImage, gradientQuads[self.i], self.x + self.offset, self.y)

		love.graphics.setColor(unpack(self.colors[self.i]))
		love.graphics.draw(portalImage, portalQuads[self.i], self.x, self.y)

		love.graphics.setColor(255, 255, 255, 255)

		love.graphics.pop()
	end

	return portal
end

return ability