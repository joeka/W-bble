gamestate = require "libs.hump.gamestate"
vector = require "libs.hump.vector"
camera = require "libs.hump.camera"
levels = require "levels.levels"

shine = require "libs.shine"

states = {}

post_effect = nil

function love.load()
	states.title = require "states.title"
	states.game = require "states.game"
	states.editor = require "states.editor"
	states.level_select = require "states.level_select"
	states.win = require "states.win"

	love.graphics.setBackgroundColor(0,0,0)

	love.keyboard.setTextInput( false )	--used later in editor_save state

	levels:load()

	font = love.graphics.newImageFont("img/font.png",
								      " abcdefghijklmnopqrstuvwxyz" ..
								      "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
								      "123456789.,!?-+/():;%&`'*#=[]\"")

	local grain = shine.filmgrain()
    grain.opacity = 0.1
    local vignette = shine.vignette()
    vignette.parameters = {radius = 0.7, opacity = 0.5}
    local desaturate = shine.desaturate{strength = 0.3, tint = {200,250,200}}
    post_effect = desaturate:chain(grain):chain(vignette)
    post_effect.opacity = 0.5

	love.graphics.setFont(font)

	gamestate.registerEvents()
	gamestate.push(states.title)
end
