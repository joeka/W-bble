local title = {}

function title:init()
	-- music = love.audio.newSource( 'snd/music.wav', 'static' )
	-- music:setLooping( true ) --so it doesnt stop
	-- music:play()
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
	love.graphics.print( "press any key" , 100, 100 )
end

function title:keypressed( key )
	if key == "escape" then
		love.event.push('quit')
	elseif key == "e" then
		gamestate.push (states.editor)
	elseif key == "l" then
		gamestate.push (states.level_select)
	elseif key == "return" then
		gamestate.push (states.game)
	end
end

return title
