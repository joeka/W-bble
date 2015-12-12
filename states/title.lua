local title = {}

function title:draw()
	love.graphics.print( "press any key" , 100, 100 )
end

function title:keypressed( key )
	if key == "escape" then
		love.event.push('quit')
	elseif key == "return" then
		gamestate.switch( states.game )
	end
end

return title
