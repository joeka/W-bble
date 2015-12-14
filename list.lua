Class = require 'libs/hump.class'

List = Class {
	init = function(self)
		self.items = {}
		self.index = 0
		self.visible_items = 10
		self.item_height = 15
		self.min_visible_index = 0
	end
}

function List:setVisibleItems(count)
	self.visible_items = count
end

function List:setItemHeight(height)
	self.item_height = height
end

function List:addItem(text, tag)
	table.insert(self.items, { text = text, tag = tag })
end

function List:getIndex()
	return self.index
end

function List:getSelectedItemTag()
	return self.items[self.index + 1].tag
end

function List:getSelectedItemText()
	return self.items[self.index + 1].text
end

function List:setIndex(index)
	self.index = index

	if self.min_visible_index > index then
		self.min_visible_index = index
	elseif self.min_visible_index + self.visible_items < index then
		self.min_visible_index = index - self.visible_items
	end

	if self.min_visible_index < 0 then
		self.min_visible_index = 0
	end
end

function List:keypressed(key)
	if key == "up" then
		if self.index > 0 then
			self.index = self.index - 1
			if (self.index < self.min_visible_index) then
				self.min_visible_index = self.index
			end
		end
	end

	if key == "down" then
		if self.index < #self.items - 1 then
			self.index = self.index + 1
			if (self.index - self.min_visible_index >= self.visible_items) then
				self.min_visible_index = self.min_visible_index + 1
			end
		end
	end
end

function List:draw(x, y, width)
	local item_count = #self.items
	local item_vis = self.visible_items
	local item_start = self.min_visible_index

	local din_start_percent = item_start / item_count
	local din_end_percent = (item_start + item_vis) / item_count

	local bar_height = self.item_height * self.visible_items
	local din_start = din_start_percent * bar_height
	local din_end = din_end_percent * bar_height

	love.graphics.rectangle("fill", x + width + 10, y + din_start, 8, din_end - din_start)

	i = 0
	for k, v in ipairs(self.items) do
		if i >= self.min_visible_index and i < self.min_visible_index + self.visible_items then
			if i == self.index then
				love.graphics.rectangle("fill", x, y + (i - self.min_visible_index) * self.item_height, width, self.item_height)
			end
			love.graphics.print(v.text, x, y + (i - self.min_visible_index) * self.item_height)
		end
		i = i + 1
	end
end