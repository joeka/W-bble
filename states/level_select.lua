local level_select = {}

local LIST_PADDING_LEFT = 100
local LIST_PADDING_TOP = 100
local LIST_WIDTH = 300
local LIST_ITEM_COUNT = 10

require "list"

local dancer = require("dancer")
local music = require("background_music")

function level_select:init()
	self.sel_index = 0
	self.sel_key = nil
	dancer:init()
end

function level_select:enter()
	self.list = List()
	self.list:setVisibleItems(LIST_ITEM_COUNT)
	for k, v in ipairs(levels) do
		self.list:addItem(v.title, k)
	end
end

function level_select:resume()
	love.graphics.setBackgroundColor(0, 0, 0)
	love.graphics.setColor(255, 255, 255)
end

function level_select:update(dt)
	dancer:update(dt)
	music:update()
end

function level_select:keypressed( key )
	if key == "down" then
		self.list:keypressed(key)
	elseif key == "up" then
		self.list:keypressed(key)
	elseif key == "return" then
		states.game:load_level(self.list:getSelectedItemTag())
		gamestate.push (states.game)
	elseif key == "escape" then
		gamestate.pop()
	elseif key == "e" then
		states.editor:load(self.list:getSelectedItemTag())
		gamestate.push(states.editor)
	end
end

function level_select:draw()
	love.graphics.print("SELECT LEVEL", LIST_PADDING_LEFT, LIST_PADDING_TOP - 40)
	self.list:draw(LIST_PADDING_LEFT, LIST_PADDING_TOP, LIST_WIDTH)
	dancer:draw()
end

return level_select