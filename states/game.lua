local game = {}
local player = {}
local objects = require ("objects")
local world = nil
local debug = false
local music = require("background_music")

local PLAYER_MAX_SIZE = 100
local PLAYER_MIN_SIZE = 20

local initial_position = { 500, 50}

-- ###########################################################################################
-- ###########################################################################################
-- GAME

local linewidth = 20

local default_lvl = 1

function game:init()
	music:init()

	self.backgroundImage = love.graphics.newImage("img/background.png")
	self.particleImage = love.graphics.newImage('img/particle.png')
	self.ps = love.graphics.newParticleSystem(self.particleImage, 400)
	self.ps:setParticleLifetime(1, 4) -- Particles live at least 2s and at most 5s.
	self.ps:setEmissionRate(20)
	self.ps:setSizeVariation(1)
	self.ps:setLinearAcceleration(-20, 20, 20, 30) -- Random movement in all directions.
	self.ps:setColors(255, 255, 255, 255, 255, 255, 255, 0) -- Fade to transparency.
	
	self.sounds = {  }
	self.sounds["bip"] = love.audio.newSource("snd/bip.wav", "static")
	self.sounds["yippi"] = love.audio.newSource("snd/yippi.wav", "static")

	objects:load_images()

	if not world then
		self:load_level(default_lvl)
	end

	local ass_pos = vector(player.physObj.body:getX(), player.physObj.body:getY()) + vector(0, 1):rotated(player.physObj.body:getAngle()) * player.physObj.shapeBody:getRadius()
	self.ps:setPosition(ass_pos.x, ass_pos.y)

	self.timer = 0
end

function game:reset()
	player.physObj.body:setPosition(unpack(initial_position))
	player.physObj.body:setAngle(0)
	player.physObj.body:setLinearVelocity(0,0)
	player.physObj.body:setAngularVelocity(0)
	self.cam:lookAt(unpack(initial_position))

	self.timer = 0
end

function game:load_level(lvl, preview)
	self.preview = preview

	self.current_level = lvl
	world = love.physics.newWorld(0, 200, true)
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)

	self.lines = {}
	for i, polygon in pairs(levels[lvl].lines) do
		local line = {}
		line.points = polygon
		line.shape = love.physics.newChainShape(false, polygon)
		line.body = love.physics.newBody(world, 0, 0, "static")
		line.fixture = love.physics.newFixture(line.body, line.shape, 1)
		
		table.insert(self.lines, line)
	end

	self.physicalObjects = {}

	for i, k in pairs(levels[lvl].objects) do
		local obj = {}
		obj.body = love.physics.newBody(world, k.x, k.y, "static")
		obj.shape = love.physics.newRectangleShape(k.w, k.h)
		obj.fixture = love.physics.newFixture(obj.body, obj.shape, 1)
		obj.type = k.type
		table.insert(self.physicalObjects, obj)
	end

	music:stop()
	music:play()

	player:init()
	self:init_camera()
end

function game:init_camera()
	self.cam = camera()
	self.cam.smoother = camera.smooth.damped(20)
	self.cam:lookAt(player.physObj.body:getX(), player.physObj.body:getY())
end

function game:init_color()
	love.graphics.setColor(255,255,255)
end

function game:enter()
	self:reset()
	self.init_color()
end

function game:resume()
	self.init_color()
end

function game:update(dt)
	self.timer = self.timer + dt

	if debug then
	    if love.keyboard.isDown("l") then
	        player.physObj.body:applyForce(10000, 0)
	    elseif love.keyboard.isDown("j") then
	        player.physObj.body:applyForce(-10000, 0) 
	    end

	    if love.keyboard.isDown("i") then
	        player.physObj.body:applyForce(0, -10000)
	    elseif love.keyboard.isDown("k") then
	        player.physObj.body:applyForce(0, 10000)
	    end
	end

    if love.keyboard.isDown("+") or love.keyboard.isDown("up")then
    	player:setSize(player:getSize() + 1)
    elseif love.keyboard.isDown("-") or love.keyboard.isDown("down")then
    	player:setSize(player:getSize() - 1)
    end

    vx, vy = player.physObj.body:getLinearVelocity()

    player.accel_x = (player.vx_l - vx) / dt
    player.accel_y = (player.vy_l - vy) / dt
    player.vx_l = vx
    player.vy_l = vy

	self.ps:setLinearAcceleration(-vx, -vy, -vx + 10, -vy + 10)
	self.ps:update(dt)

	world:update(dt)
	player:update(dt)
	music:update()

	local ass_pos = vector(player.physObj.body:getX(), player.physObj.body:getY()) + vector(0, 1):rotated(player.physObj.body:getAngle()) * player.physObj.shapeBody:getRadius()
	self.ps:setPosition(ass_pos.x, ass_pos.y) 

	local w = love.window.getWidth()
	local h = love.window.getHeight()
	self.cam:lockWindow(player.physObj.body:getX(), player.physObj.body:getY(), w*2/5, w*3/5, h*2/5, h*3/5 )
end

function game:keypressed( key )
	if key == "escape" then
		gamestate.pop()
	elseif key == "r" then
		self:reset()
	end
end

function game:draw()
	self.cam:attach()

	local bg_scale_x = love.graphics.getWidth() / self.backgroundImage:getWidth()
	local bg_scale_y = love.graphics.getHeight() / self.backgroundImage:getHeight()
	
	love.graphics.setColor(255, 255, 255)

	local x,y = self.cam:position()
	local xm = x % 1280
	local ym = y % 720
	love.graphics.draw(self.backgroundImage, x - xm, y - ym, 0, bg_scale_x, bg_scale_y, 0, 0, 0)

	if xm < 1280 / 2 then
		love.graphics.draw(self.backgroundImage, x - xm - 1280, y - ym, 0, bg_scale_x, bg_scale_y, 0, 0, 0)

		if ym < 720 / 2 then
			love.graphics.draw(self.backgroundImage, x - xm - 1280, y - ym - 720, 0, bg_scale_x, bg_scale_y, 0, 0, 0)
		elseif ym > 720 / 2 then
			love.graphics.draw(self.backgroundImage, x - xm - 1280, y - ym + 720, 0, bg_scale_x, bg_scale_y, 0, 0, 0)
		end
	elseif xm > 1280 / 2 then
		love.graphics.draw(self.backgroundImage, x - xm + 1280, y - ym, 0, bg_scale_x, bg_scale_y, 0, 0, 0)

		if ym < 720 / 2 then
			love.graphics.draw(self.backgroundImage, x - xm + 1280, y - ym - 720, 0, bg_scale_x, bg_scale_y, 0, 0, 0)
		elseif ym > 720 / 2 then
			love.graphics.draw(self.backgroundImage, x - xm + 1280, y - ym + 720, 0, bg_scale_x, bg_scale_y, 0, 0, 0)
		end
	end
	if ym < 720 / 2 then
		love.graphics.draw(self.backgroundImage, x - xm, y - ym - 720, 0, bg_scale_x, bg_scale_y, 0, 0, 0)
	elseif ym > 720 / 2 then
		love.graphics.draw(self.backgroundImage, x - xm, y - ym + 720, 0, bg_scale_x, bg_scale_y, 0, 0, 0)
	end
	
	player:render()

	love.graphics.setColor(255, 255, 255)
	love.graphics.setLineStyle( "smooth" )
	love.graphics.setLineWidth( linewidth )

	for i,line in pairs(self.lines) do
		love.graphics.line(line.points)
	end

	for i,k in pairs(self.physicalObjects) do
		love.graphics.draw(objects[k.type].image, k.body:getX(), k.body:getY(), 0, 1, 1)
	end

	love.graphics.draw(
		self.ps, 0, 0
	)

	self.cam:detach()
	local w, h = love.window.getDimensions()
	love.graphics.print(self.timer, w - 190, 20 )
end

function objectForFixture(fix)
	for i, k in pairs(states.game.physicalObjects) do
		if (fix == k.fixture) then
			return k
		end
	end
	return nil
end

function beginContact(a, b, coll)
 	obj = objectForFixture(a)
 	if obj == nil then
 		obj = objectForFixture(b)
 		if obj == nil then
 			return
 		end
 	end

 	if objects[obj.type].name == "flagge" then
 		love.audio.play(states.game.sounds["yippi"])
 		gamestate.pop()
 		if not game.preview then
 			gamestate.push(states.win)
 		end
 	else
	 	love.audio.play(states.game.sounds["bip"])
 	end

end
 
function endContact(a, b, coll)
 
end
 
function preSolve(a, b, coll)
 
end
 
function postSolve(a, b, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2)
 
end


-- ###########################################################################################
-- ###########################################################################################
-- PLAYER

function player:init()
	self.imgBody      = love.graphics.newImage('img/figur/body.png')
	self.imgEyeLeft   = love.graphics.newImage('img/figur/eye_left.png')
	self.imgEyeRight  = love.graphics.newImage('img/figur/eye_right.png')
	self.imgFootLeft  = love.graphics.newImage('img/figur/fuss_left.png')
	self.imgFootRight = love.graphics.newImage('img/figur/fuss_right.png')

	self.physObj = {}
	self.physObj.body = love.physics.newBody(world, 500, 50, "dynamic")
	self.physObj.body:setMass(1)

	self:setSize(30)

	player.accel_x = 0
	player.accel_y = 0
	player.vx_l = 0
	player.vy_l = 0

	--self.imgBody = love.graphics.newImage('img/sprite_test.png')
	--local g = anim8.newGrid(150, 150, self.imgBody:getWidth(), self.imgBody:getHeight())
	--self.animation = anim8.newAnimation(g('1-6',1), 0.2)
end

function player:update()
	-- nix
end

function player:getSize()
	return self.physObj.shapeBody:getRadius()
end

function player:setSize(size)
	if self.physObj.fixtureBody ~= nil then
		self.physObj.fixtureBody:destroy()
	end

	if (size < PLAYER_MIN_SIZE) then
		size = PLAYER_MIN_SIZE
	elseif (size > PLAYER_MAX_SIZE) then
		size = PLAYER_MAX_SIZE
	end

	self.physObj.shapeBody = love.physics.newCircleShape(size)
	self.physObj.fixtureBody = love.physics.newFixture(self.physObj.body, self.physObj.shapeBody)
	self.physObj.fixtureBody:setRestitution(0.1)
	self.physObj.fixtureBody:setFriction(1)
	self.physObj.fixtureBody:setUserData("body")
end

function player:render()
	local EYE_ROTATE_FACTOR = 10
	local EYE_SCALE_X_FACTOR = 20
	local EYE_SCALE_Y_FACTOR = 40
	local FOOT_ROTATE_FACTOR = 40

	local body_scale_x = 2 * self.physObj.shapeBody:getRadius() / self.imgBody:getWidth()
	local body_scale_y = 2 * self.physObj.shapeBody:getRadius() / self.imgBody:getHeight()

	love.graphics.setColor(255, 255, 255)

	x, y = self.physObj.body:getLinearVelocity()
	r = self.physObj.body:getAngularVelocity()

	eye_scale_x = body_scale_x * (1 - math.abs(r) / EYE_SCALE_X_FACTOR)
	eye_scale_y = body_scale_y * (1 + math.abs(r) / EYE_SCALE_Y_FACTOR)

	love.graphics.draw(self.imgBody, 
					   self.physObj.body:getX(), 
					   self.physObj.body:getY(),
					   self.physObj.body:getAngle(), 
					   body_scale_x, body_scale_y,
					   self.imgBody:getWidth() / 2,
					   self.imgBody:getHeight() / 2)

	love.graphics.draw(self.imgEyeLeft,
					   self.physObj.body:getX(),
					   self.physObj.body:getY(),
					   self.physObj.body:getAngle() - r / EYE_ROTATE_FACTOR,
					   eye_scale_x, eye_scale_y,
					   self.imgBody:getWidth() / 2 + self.imgEyeLeft:getWidth() * 0.3,
					   self.imgBody:getHeight() / 2  + self.imgEyeLeft:getHeight())

	love.graphics.draw(self.imgEyeRight,
					   self.physObj.body:getX(),
					   self.physObj.body:getY(),
					   self.physObj.body:getAngle() - r / EYE_ROTATE_FACTOR,
					   eye_scale_x, eye_scale_y,
					   self.imgBody:getWidth() / 2 - self.imgEyeLeft:getWidth() * 1.6,
					   self.imgBody:getHeight() / 2  + self.imgEyeLeft:getHeight() * 0.9)

	love.graphics.draw(self.imgFootLeft,
					   self.physObj.body:getX(),
					   self.physObj.body:getY(),
					   self.physObj.body:getAngle() + r / FOOT_ROTATE_FACTOR,
					   body_scale_x, body_scale_y,
					   self.imgBody:getWidth() / 2 + self.imgEyeLeft:getWidth() * 0.3,
					   self.imgBody:getHeight() / 2  - self.imgEyeLeft:getHeight() * 2.4)

	love.graphics.draw(self.imgFootRight,
					   self.physObj.body:getX(),
					   self.physObj.body:getY(),
					   self.physObj.body:getAngle() + r / FOOT_ROTATE_FACTOR,
					   body_scale_x, body_scale_y,
					   self.imgBody:getWidth() / 2 - self.imgEyeLeft:getWidth() * 1.7,
					   self.imgBody:getHeight() / 2  - self.imgEyeLeft:getHeight() * 2.4)

	if (debug) then
		love.graphics.print("a_x: "..self.accel_x, 10, 10)
		love.graphics.print("a_y: "..self.accel_y, 10, 25)
		love.graphics.print("mass: "..self.physObj.body:getMass(), 10, 40)
		love.graphics.print("theta: "..r, 10, 55)

		love.graphics.circle("line", self.physObj.body:getX(), self.physObj.body:getY(), self.physObj.shapeBody:getRadius())
	end
end


--
-- ###########################################################################################
-- ###########################################################################################

return game

