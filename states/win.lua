local win = {}
local music = require("background_music")

function win:init()
	self.armsImage = love.graphics.newImage("img/kreide_figur_arme.png")
end

function win:enter()
	music:stop()
	music:play()
end

function win:resume()
	love.graphics.setBackgroundColor(0, 0, 0)
	love.graphics.setColor(255, 255, 255)
end

function win:update(dt)
	music.update()
end

function win:keypressed( key )
	if (key == "return") then
		gamestate.pop()
	end
end

function win:draw()
	love.graphics.draw(self.armsImage, 600, 20)
	love.graphics.print("YOU WIN", 20, 20)
	love.graphics.print("PRESS RETURN", 60, 50)
end

return win