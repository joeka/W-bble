local game = {}

function game:init()

end

function game:enter()

end

function game:update(dt)

end

function game:keypressed( key )
	if key == "escape" then
		gamestate.pop(states.title)
	end
end

function game:draw()

end

return game
