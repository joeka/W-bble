local utf8 = require("utf8")

local win = {}
local music = require("background_music")

local highscores = require("highscores")

local win_input = {}

win.highscores_text = ""
win_input.name = ""
win.name = nil

function win:init()
	self.armsImage = love.graphics.newImage("img/kreide_figur_arme.png")
	highscores:load()
end

function win:enter()
	music:stop()
	music:play()

	self.level = levels[states.game.current_level].title
	self.time = states.game.timer
	if highscores:good_enough(level, time) then
		gamestate.push(win_input)
	else
		win:update_highscore()
	end
end

function win:update_highscore()
	local highscore_list = highscores:get(self.level)
	for i, entry in ipairs(highscore_list) do
		self.highscores_text = self.highscores_text .. i .. ":		" .. entry.name .. " (" .. entry.time .. ")\n" 
	end
end

function win:resume()
	love.graphics.setBackgroundColor(0, 0, 0)
	love.graphics.setColor(255, 255, 255)
end

function win:update(dt)
	music.update()
end

function win:keypressed( key )
	if (key == "return") or key == "escape" then
		gamestate.pop()
	end
end

function win:draw()
	love.graphics.draw(self.armsImage, 600, 20)
	love.graphics.print("YOU WIN", 20, 20)
	love.graphics.print("PRESS RETURN", 60, 50)

	love.graphics.print(self.highscores_text, 20, 100)
end

------------------------


function win_input:init()
	local w, h = love.window.getDimensions()
	self.box = { w=400, h=200 }
	self.box.x = 200
	self.box.y = 400
end

function win_input:enter()
	love.keyboard.setTextInput( true )
	love.textinput = self.textinput
end

function win_input:leave()
	love.keyboard.setTextInput( false )
end

function win_input.textinput(t)
    win_input.name = win_input.name .. t
end

function win_input:keypressed( key )
	if key == "escape" then
		states.win.name = nil
		gamestate.pop()
	elseif key == "return" then
		states.win.name = self.win
		highscores:add(states.win.level, states.win.time, self.name)
		states.win:update_highscore()
		gamestate.pop()
	elseif key == "backspace" then
		local byteoffset = utf8.offset(self.name, -1)
		if byteoffset then
			self.name = string.sub(self.name, 1, byteoffset - 1)
		end
	end
end

function win_input:draw()
	states.win:draw()

	love.graphics.setColor( 255, 255, 255, 50 )
	
	love.graphics.rectangle( "fill", self.box.x,  self.box.y, self.box.w, self.box.h )
	love.graphics.setColor( 255, 255, 255)

	local text = "Please enter your name:\n\n" .. self.name
	love.graphics.printf( text, self.box.x + 20, self.box.y + 20, self.box.w - 40, "center")
end


return win