local game = {}
local player = {}
local world = nil
local debug = false

-- ###########################################################################################
-- ###########################################################################################
-- GAME

local linewidth = 20

local default_lvl = 1

function game:init()
	self.backgroundImage = love.graphics.newImage("img/background.png")
	
	if not world then
		self:load_level(default_lvl)
	end
end

function game:load_level(lvl)
	world = love.physics.newWorld(0, 200, true)

	self.lines = {}
	for i, polygon in pairs(levels[lvl].lines) do
		local line = {}
		line.points = polygon
		line.shape = love.physics.newChainShape(false, polygon)
		line.body = love.physics.newBody(world, 0, 0, "static")
		line.fixture = love.physics.newFixture(line.body, line.shape, 1)
		
		table.insert(self.lines, line)
	end

	player:init()
end

function game:init_color()
	love.graphics.setColor(255,255,255)
	love.graphics.setBackgroundColor( 255, 255, 255 )	
end

function game:enter()
	self.init_color()
end

function game:resume()
	self.init_color()
end

function game:update(dt)
    if love.keyboard.isDown("right") then
        player.physObj.body:applyForce(10000, 0)
    elseif love.keyboard.isDown("left") then
        player.physObj.body:applyForce(-10000, 0) 
    end

    if love.keyboard.isDown("up") then
        player.physObj.body:applyForce(0, -10000)
    elseif love.keyboard.isDown("down") then
        player.physObj.body:applyForce(0, 10000)
    end

    if love.keyboard.isDown("+") then
    	player:setSize(player:getSize() + 1)
    elseif love.keyboard.isDown("-") then
    	player:setSize(player:getSize() - 1)
    end


    vx, vy = player.physObj.body:getLinearVelocity()

    player.accel_x = (player.vx_l - vx) / dt
    player.accel_y = (player.vy_l - vy) / dt
    player.vx_l = vx
    player.vy_l = vy

	world:update(dt)
	player:update(dt)
end

function game:keypressed( key )
	if key == "escape" then
		gamestate.pop()
	end
end

function game:draw()
	local bg_scale_x = love.graphics.getWidth() / self.backgroundImage:getWidth()
	local bg_scale_y = love.graphics.getHeight() / self.backgroundImage:getHeight()

	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.backgroundImage, 0, 0, 0, bg_scale_x, bg_scale_y, 0, 0, 0)
	player:render()
	
	love.graphics.setColor(255, 255, 255)
	love.graphics.setLineStyle( "smooth" )
	love.graphics.setLineWidth( linewidth )

	for i,line in pairs(self.lines) do
		print(#line)
		love.graphics.line(line.points)
	end
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

