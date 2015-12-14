local title = {}
local figur = require("dancer")
local music = require("background_music")
title.text = "press any key"

function title:init()
	self.imgTitle = love.graphics.newImage("img/title.png")
	figur:init()
	music:init()
	music:play()
	figur:reset()
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
	love.graphics.print(self.text, 100, 100)
	love.graphics.draw(self.imgTitle, 50, 200, 0, 0.3, 0.3)
	figur:draw()
end

function title:update(dt)
	figur:update(dt)
	music:update()
end

local fail_counter = 0
function title:keypressed( key )
	if key == "escape" then
		love.event.push('quit')
	elseif key == "e" then
		gamestate.push (states.editor)
	-- elseif key == "l" then
	-- 	gamestate.push (states.level_select)
	elseif key == "return" then
		--gamestate.push (states.game)
		gamestate.push (states.level_select)
	else
		fail_counter = fail_counter + 1

		if fail_counter > 5 then
			self.text = "maybe try enter"
		end
	end
end

return title
