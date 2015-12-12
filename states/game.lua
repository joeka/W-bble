local game = {}
local player = {}
local world = {}
local debug = true


function game:init()
	font = love.graphics.newImageFont("img/font.png",
								      " abcdefghijklmnopqrstuvwxyz" ..
								      "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
								      "123456789.,!?-+/():;%&`'*#=[]\"")

	love.graphics.setFont(font)

	self.backgroundImage = love.graphics.newImage("img/background.png", format)
	world = love.physics.newWorld(0, 200, true)
	player:init()
	self:load_level(1)
end

function game:load_level(lvl)
	self.static = {}
	self.static.b = love.physics.newBody(world, 400, 400, "static")
	self.static.s = love.physics.newRectangleShape(200, 50)
	self.static.f = love.physics.newFixture(self.static.b, self.static.s)
	self.static.f:setUserData("Block")

	self.lines = {}
	for i, polygon in pairs(levels[lvl].lines) do
		local line = {}
		line.points = polygon
		line.shape = love.physics.newChainShape(true, polygon)
		line.body = love.physics.newBody(world, 0, 0, "static")
		line.fixture = love.physics.newFixture(line.body, line.shape, 1)
		table.insert(self.lines, line)
	end
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

	world:update(dt)
	player:update(dt)
end

function game:keypressed( key )
	if key == "escape" then
		gamestate.pop(states.title)
	end
end

function game:draw()
	local bg_scale_x = love.graphics.getWidth() / self.backgroundImage:getWidth()
	local bg_scale_y = love.graphics.getHeight() / self.backgroundImage:getHeight()

	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.backgroundImage, 0, 0, 0, bg_scale_x, bg_scale_y, 0, 0, 0)
	player:render()

	love.graphics.setColor(0, 0, 0)
	love.graphics.polygon("line", self.static.b:getWorldPoints(self.static.s:getPoints()))

	--debug stuff
	for i,line in pairs(self.lines) do
		love.graphics.polygon("line", line.points)
	end
end

function player:init()
	self.image = love.graphics.newImage('img/kreide_figur.png')
	self.posX = 0
	self.posY = 0

	self.physObj = {}
	self.physObj.body = love.physics.newBody(world, 500, 50, "dynamic")
	self.physObj.body:setMass(1)
	self:setSize(30)

	--self.image = love.graphics.newImage('img/sprite_test.png')
	--local g = anim8.newGrid(150, 150, self.image:getWidth(), self.image:getHeight())
	--self.animation = anim8.newAnimation(g('1-6',1), 0.2)
end

function player:update()
	-- nix
end

function player:getSize()
	return self.physObj.shape:getRadius()
end

function player:setSize(size)
	if self.physObj.fixture ~= nil then
		self.physObj.fixture:destroy()
	end

	self.physObj.shape = love.physics.newCircleShape(size)
	self.physObj.fixture = love.physics.newFixture(self.physObj.body, self.physObj.shape)
	self.physObj.fixture:setRestitution(0.1)
	self.physObj.fixture:setFriction(1)
	self.physObj.fixture:setUserData("Ball")
end

function player:render()
	local figure_scale_x = 2 * self.physObj.shape:getRadius() / self.image:getWidth()
	local figure_scale_y = 2 * self.physObj.shape:getRadius() / self.image:getHeight()

	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.image,
					   self.physObj.body:getX() - self.physObj.shape:getRadius(), 
					   self.physObj.body:getY() - self.physObj.shape:getRadius(),
					   0,
					   figure_scale_x,
					   figure_scale_y)

	if (debug) then
		love.graphics.circle("line", self.physObj.body:getX(), self.physObj.body:getY(), self.physObj.shape:getRadius())
	end

	--animation:draw(self.image, self.physObj.body:getX() - 150 / 2, self.physObj.body:getY()  - (150 - self.physObj.shape:getRadius()), 0, 1, 1, 0, 0)
end

return game
