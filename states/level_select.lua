local level_select = {}

local LIST_PADDING_LEFT = 100
local LIST_PADDING_TOP = 100
local LIST_WIDTH = 300
local LIST_ITEM_HEIGHT = 15
local LIST_ITEM_COUNT = 10

local list_min_index = 0

function level_select:init()
	self.sel_index = 0
	self.sel_key = nil
end

function level_select:enter()
	
end

function level_select:resume()
	love.graphics.setBackgroundColor(0, 0, 0)
	love.graphics.setColor(255, 255, 255)
end

function level_select:update(dt)

end

function level_select:keypressed( key )
	if key == "down" then
		if self.sel_index < #levels - 1 then
			self.sel_index = self.sel_index + 1
			if (self.sel_index - list_min_index >= LIST_ITEM_COUNT) then
				list_min_index = list_min_index + 1
			end
		end
	elseif key == "up" then
		if self.sel_index > 0 then
			self.sel_index = self.sel_index - 1
			if (self.sel_index < list_min_index) then
				list_min_index = self.sel_index
			end
		end
	elseif key == "return" then
		states.game:load_level(self.sel_key)
		gamestate.push (states.game)
	elseif key == "escape" then
		gamestate.pop()
	end
end

function level_select:draw()
	love.graphics.print("SELECT LEVEL", LIST_PADDING_LEFT, LIST_PADDING_TOP - 40)

	local item_count = #levels
	local item_vis = LIST_ITEM_COUNT
	local item_start = list_min_index

	local din_start_percent = item_start / item_count
	local din_end_percent = (item_start + item_vis) / item_count

	local bar_height = LIST_ITEM_HEIGHT * LIST_ITEM_COUNT
	local din_start = din_start_percent * bar_height
	local din_end = din_end_percent * bar_height

	love.graphics.rectangle("fill", LIST_PADDING_LEFT + LIST_WIDTH + 10, LIST_PADDING_TOP + din_start, 8, din_end - din_start)

	i = 0
	for k, v in ipairs(levels) do
		if i >= list_min_index and i < list_min_index + LIST_ITEM_COUNT then
			if i == self.sel_index then
				love.graphics.rectangle("fill", LIST_PADDING_LEFT, LIST_PADDING_TOP + (i - list_min_index) * LIST_ITEM_HEIGHT, LIST_WIDTH, LIST_ITEM_HEIGHT)
				self.sel_key = k
			end
			love.graphics.print(v.title, LIST_PADDING_LEFT, LIST_PADDING_TOP + (i - list_min_index) * LIST_ITEM_HEIGHT)
		end
		i = i + 1
	end
end

return level_select