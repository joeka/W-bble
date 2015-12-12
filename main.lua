gamestate = require "libs.hump.gamestate"
anim8 = require "libs.anim8"

levels = require "levels.levels"

states = {}

function love.load()

	states.title = require "states.title"
	states.game = require "states.game"

	levels:load()

	gamestate.registerEvents()
	gamestate.switch( states.title )
end
