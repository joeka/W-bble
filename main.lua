gamestate = require "libs.hump.gamestate"

anim8 = require "libs.anim8"

states = {}

function love.load()

	states.title = require "states.title"
	states.game = require "states.game"

	gamestate.registerEvents()
	gamestate.switch( states.title )
end
