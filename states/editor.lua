local editor = {}
local editor_save = {}

local utf8 = require("utf8")

local min_dist = 5

local objects = require ("objects")

local keys_text = "LMB: draw line / move object    RMB: move screen     DEL: delete object     +: zoom in     -:zoom out"

function editor:init()
	self.backgroundImage = love.graphics.newImage("img/background.png")

	love.filesystem.createDirectory( "levels" )

	objects:load_images()
	local w, h = love.window.getDimensions()
	local y = 40
	for i, object in ipairs(objects) do
		object.x = w - 80
		object.y = y
		y = y + object.h + 20
	end
end

function editor:enter()
	editor.lines = {}
	editor.objects = {}
	self.current_point = nil
	self.current_line = {}
	self.drawing = false

	self.current_pos = nil
	self.moving = false

	self.cam = camera()

	self.level_id = nil
end

function editor:resume()

end

function editor:update(dt)
	if self.moving then
		self.cam:move(self.current_pos.x - love.mouse.getX(), self.current_pos.y - love.mouse.getY())
		self.current_pos = vector(love.mouse.getX(), love.mouse.getY())
	elseif self.drawing then
		local wx, wy = self.cam:mousePosition()
		if self.current_point:dist(vector(wx,wy)) > min_dist then
			table.insert(self.current_line, wx)
			table.insert(self.current_line, wy)
			self.current_point = vector(wx,wy)
		end
	elseif self.moving_line then
		local wx, wy = self.cam:mousePosition()
		local dx, dy = wx - self.line_move_current_pt.x, wy - self.line_move_current_pt.y
		local line = self.lines[self.line_highlight]
		for i, pt in ipairs(line) do
			if i % 2 == 0 then line[i] = pt + dy end
			if i % 2 == 1 then line[i] = pt + dx end
		end
		self.line_move_current_pt = vector(wx,wy)
	elseif self.moving_object then
		local wx, wy = self.cam:mousePosition()
		self.moving_object.x = self.moving_object.x + (wx - self.current_point.x)
		self.moving_object.y = self.moving_object.y + (wy - self.current_point.y)
		self.current_point = vector(wx, wy)
	end
end

function editor:keypressed( key )
	if key == "escape" then
		gamestate.pop()
	elseif key == "return" then
		self:preview()
	elseif key == "s" then
		gamestate.push( editor_save )
	elseif key == "backspace" then
		if #self.lines > 0 then
			table.remove(self.lines)
		end
	elseif key == "+" then
		self.cam:zoom(1.2)
	elseif key == "-" then
		self.cam:zoom(1 / 1.2)
	elseif key == "delete" then
		if self.line_highlight ~= nil then
			table.remove(self.lines, self.line_highlight)
		end

		local x, y = love.mouse.getPosition()
		local _, i = self:object_clicked(x, y, false)
		if i then
			table.remove(self.objects, i)
		end 
	end
end

function editor:preview()
	if not self.level_id then
		table.insert(levels, {title = "preview", lines = self.lines, objects = self.objects})
		self.level_id = #levels
	else
		levels[self.level_id] = {title = "preview", lines = self.lines, objects = self.objects}
	end
	states.game:load_level(self.level_id)
	gamestate.push(states.game)
end

function editor:move_object(obj)
	self.moving_object = obj
end

function editor:line_clicked(x, y)
	p = vector(x, y)
	for i, line in pairs(self.lines) do
		p1x = 0
		p1y = 0
		for j, pt in ipairs(line) do
			if (j % 2) == 0 then p1y = pt end
			if (j % 2) == 1 then p1x = pt end

			if (j % 2) == 1 then
				dist = PointDistance(p, vector(p1x, p1y))
				if dist < 60 then
					return i
				end
			end
		end
	end
	return nil
end

function PointDistance(A, B)
	return math.sqrt((A.x - B.x) * (A.x - B.x) + (A.y - B.y) * (A.y - B.y))
end

function editor:object_clicked(x, y, create)
	if create == nil then
		create = true
	end

	if create then
		for i, object in ipairs(objects) do
			if x >= object.x and x <= object.x + object.w
					and y >= object.y and y <= object.y + object.h then
				local ox, oy = self.cam:worldCoords(object.x, object.y)
				local obj = {type = i, x = ox, y = oy, w = object.w, h = object.h}
				table.insert( self.objects, obj)
				return obj, i
			end
		end
	end

	local gx, gy = self.cam:worldCoords(x, y)
	for i, object in ipairs(self.objects) do
		if gx >= object.x and gx <= object.x + object.w
				and gy >= object.y and gy <= object.y + object.h then
			return object, i
		end
	end
end

function editor:mousepressed(x, y, button)
	if button == "l" then
		local wx, wy = self.cam:worldCoords(x,y)
		local obj = self:object_clicked(x, y)
		local line = self:line_clicked(wx, wy)

		if obj then
			self.current_point = vector(wx,wy)
			self:move_object(obj)
		else
			if line ~= nil then
				self.line_highlight = line
				self.line_move_current_pt = vector(x,y)
				self.moving_line = true
			else
				self.line_highlight = nil
				table.insert(self.current_line, wx)
				table.insert(self.current_line, wy)
				self.current_point = vector(wx, wy)
				self.drawing = true
			end
		end
	elseif button == "r" then
		self.current_pos = vector(x,y)
		self.moving = true
	end
end

function editor:mousereleased(x, y, button)
	if button == "l" then
		local wx, wy = self.cam:worldCoords(x,y)

		if self.moving_line then
			self.moving_line = false
			self.line_move_current_pt = nil

		elseif self.moving_object then
			self.moving_object.x = self.moving_object.x + (wx - self.current_point.x)
			self.moving_object.y = self.moving_object.y + (wy - self.current_point.y)
			self.moving_object = nil
			current_point = nil

		elseif self.drawing then
			if self.current_point:dist(vector(wx,wy)) > min_dist then
				table.insert(self.current_line, wx)
				table.insert(self.current_line, wy)
			end
			
			self.current_point = nil
			self.drawing = false
			if #self.current_line >= 4 then
				table.insert( self.lines, self.current_line )
			end
			self.current_line = {}
		end

	elseif button == "r" then
		self.moving = false
		self.cam:move(self.current_pos.x - x, self.current_pos.y - y)
	end
end

function editor:draw()
	self.cam:attach()

	local bg_scale_x = love.graphics.getWidth() / self.backgroundImage:getWidth()
	local bg_scale_y = love.graphics.getHeight() / self.backgroundImage:getHeight()

	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.backgroundImage, 0, 0, 0, bg_scale_x, bg_scale_y, 0, 0, 0)

	love.graphics.setColor(255, 255, 255)
	love.graphics.setLineStyle( "smooth" )
	love.graphics.setLineWidth( 10 )

	if (self.line_highlight ~= nil) then
		love.graphics.print("Line highlight", 10, 10)
	end

	for i,line in pairs(self.lines) do
		if (self.line_highlight ~= nil and self.line_highlight == i) then
			love.graphics.setColor(255, 0, 255)
		else
			love.graphics.setColor(255, 255, 255)
		end
		love.graphics.line(line)
	end
	if #self.current_line >= 4 then
		love.graphics.line(self.current_line)
	end

	love.graphics.setColor(255, 255, 255)
	for i, object in ipairs(self.objects) do
		love.graphics.draw(objects[object.type].image, object.x, object.y )
	end

	love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("fill", 500, 50, 10, 10)

	self.cam:detach()

	-- GUI --
	love.graphics.setColor( 255, 255, 255, 50 )
	local w, h = love.window.getDimensions()
	love.graphics.rectangle( "fill", w - 100,  0, 100, h )
	love.graphics.setColor( 255, 255, 255, 100 )
	for i, object in ipairs(objects) do
		love.graphics.draw(object.image, object.x, object.y )
	end
	love.graphics.setColor( 255, 255, 255, 50 )
	love.graphics.rectangle( "fill", 0,  h - 20, w - 100, 20 )

	love.graphics.setColor( 255, 255, 255 )
	love.graphics.print(keys_text, 40, h - 16)
end


------------------------


function editor_save:init()
	local w, h = love.window.getDimensions()
	self.box = { w=400, h=200 }
	self.box.x = w/2 - self.box.w/2
	self.box.y = h/2 - self.box.h/2

	self.title = ""
end

function editor_save:enter()
	love.keyboard.setTextInput( true )
end

function editor_save:leave()
	love.keyboard.setTextInput( false )
end

function editor_save:update(dt)
	
end

function love.textinput(t)
    editor_save.title = editor_save.title .. t
end

function editor_save:keypressed( key )
	if key == "escape" then
		gamestate.pop()
	elseif key == "return" then
		self:save()
	elseif key == "backspace" then
		local byteoffset = utf8.offset(self.title, -1)
		if byteoffset then
			self.title = string.sub(self.title, 1, byteoffset - 1)
		end
	end
end

function editor_save:draw()
	states.editor:draw()

	love.graphics.setColor( 255, 255, 255, 50 )
	
	love.graphics.rectangle( "fill", self.box.x,  self.box.y, self.box.w, self.box.h )
	love.graphics.setColor( 0, 0, 0)

	local text = "Filename:\n\n" .. self.title .. ".lvl"
	love.graphics.printf( text, self.box.x + 20, self.box.y + 20, self.box.w - 40, "center")
end

function editor_save:save()
	love.filesystem.write( "levels/" .. self.title .. ".lvl", self:create_level() )
	if not states.editor.level_id then
		table.insert(levels, {title = self.title, lines = states.editor.lines, objects = states.editor.objects})
		states.editor.level_id = #levels
	else
		levels[states.editor.level_id] = {title = self.title, lines = states.editor.lines, objects = states.editor.objects}
	end
	gamestate.pop()
end

function editor_save:create_level()
	local level_txt = "return {\n"
					.."title = \"" .. self.title .. "\",\n"
					.."lines = { \n"

	for i, line in ipairs( states.editor.lines ) do
		level_txt = level_txt .. "{ "
		for j, value in pairs( line ) do
			level_txt = level_txt .. value .. ", "
		end
		level_txt = level_txt .. " },\n"
	end

	level_txt = level_txt .. "},\nobjects = {"

	for i, object in ipairs( states.editor.objects ) do
		level_txt = level_txt .. " {type = " .. object.type .. ", "
		level_txt = level_txt .. "x = " .. object.x .. ", "
		level_txt = level_txt .. "y = " .. object.y .. ", "
		level_txt = level_txt .. "w = " .. object.w .. ", " 
		level_txt = level_txt .. "h = " .. object.h .. "}, "
	end

	level_txt = level_txt .. "}\n}"
	return level_txt
end

return editor
