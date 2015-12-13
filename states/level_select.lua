local level_select = {}
local LIST_PADDING_LEFT = 100
local LIST_PADDING_TOP = 100
local LIST_ITEM_HEIGHT = 15

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
		end
	elseif key == "up" then
		if self.sel_index > 0 then
			self.sel_index = self.sel_index - 1
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

	i = 0
	for k, v in ipairs(levels) do
		if i == self.sel_index then
			love.graphics.rectangle("fill", LIST_PADDING_LEFT, LIST_PADDING_TOP + i * LIST_ITEM_HEIGHT, 100, LIST_ITEM_HEIGHT)
			self.sel_key = k
		end
		love.graphics.print(v.title, LIST_PADDING_LEFT, LIST_PADDING_TOP + i * LIST_ITEM_HEIGHT)
		i = i + 1
	end
end

return level_select