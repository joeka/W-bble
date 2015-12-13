local figur = {}

function figur:init()
	self.body = love.graphics.newImage("img/figur/body.png")
	self.eye_l = love.graphics.newImage("img/figur/eye_left.png")
	self.eye_r = love.graphics.newImage("img/figur/eye_right.png")
	self.foot_l = love.graphics.newImage("img/figur/fuss_left.png")
	self.foot_r = love.graphics.newImage("img/figur/fuss_right.png")
	self.up = false
	self.time = 0
end

function figur:reset()
	self.time = 0
	self.up = false
end

function figur:update(dt)
	self.time = self.time + dt
	if (self.time > 0.35) then
		self.time = 0
		self.up = not self.up
	end
end

function figur:draw()
	if (self.up) then
		dy = 10
	else
		dy = 0
	end

	love.graphics.draw(self.body, 600, 200 - dy)
	love.graphics.draw(self.foot_l, 600, 200 + self.body:getHeight() - self.foot_l:getHeight() / 2)
	love.graphics.draw(self.foot_r, 600 + self.body:getWidth() - self.foot_r:getWidth() / 2, 200 + self.body:getHeight() - self.foot_r:getHeight() / 2)
	love.graphics.draw(self.eye_l, 600, 200 - self.eye_l:getHeight() - dy)
	love.graphics.draw(self.eye_r, 600 + self.body:getWidth() - self.eye_r:getWidth() / 2, 200 - self.eye_r:getHeight() - dy)
end

return figur