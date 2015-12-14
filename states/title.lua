local title = {}
local figur = require("dancer")
local music = require("background_music")
title.text = "press any key"

require "list"

function title:init()
	self.imgTitle = love.graphics.newImage("img/title.png")
	figur:init()
	music:init()
	music:play()
	figur:reset()

	self.options = List()
	self.options:setVisibleItems(4)
	self.options:addItem("Select Level", 0)
	self.options:addItem("Create Level", 1)
	self.options:addItem("Exit", 2)
end

function title:enter()
	love.graphics.setColor(255,255,255)
	love.graphics.setBackgroundColor(0, 0, 0)
end

function title:resume()
	love.graphics.setColor(255,255,255)
	love.graphics.setBackgroundColor(0, 0, 0)
end

function title:draw()
	love.graphics.draw(self.imgTitle, 50, 100, 0, 0.3, 0.3)
	figur:draw()
	self.options:draw(100, 400, 200)
end

function title:update(dt)
	figur:update(dt)
	music:update()
end

local fail_counter = 0
function title:keypressed( key )
	if key == "up" or key == "down" then
		self.options:keypressed(key)

	elseif key == "escape" then
		love.event.push('quit')

	elseif key == "return" then
		opt = self.options:getSelectedItemTag()
		if opt == 0 then gamestate.push (states.level_select) end
		if opt == 1 then gamestate.push (states.editor) end
		if opt == 2 then love.event.push('quit') end

	end
end

return title
