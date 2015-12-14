local highscores = {}

function highscores:load()
	if love.filesystem.exists("highscore_lists.lua") then
		self.lists = love.filesystem.load("highscore_lists.lua")()
	else
		self.lists = {}
	end
end

function highscores:good_enough( level, time )
	local list = self:get(level)
	return #list < 10 or list[#list].time > time
end

function highscores:get( level )
	for i, list in ipairs(self.lists) do
		if list.level == level then
			return list
		end
	end
	return {}
end

function highscores:add( level, time, name )
	local level_found = false
	for i, list in ipairs(self.lists) do
		if list.level == level then
			table.insert(list, {time=time, name=name})
			table.sort(list, self.highsort)
			while #list > 10 do
				table.remove(list, #list)
			end
			level_found = true
			break
		end
	end
	if not level_found then
		table.insert(self.lists, {level=level, {time=time, name=name}})
	end

	self:save()
end

function highscores.highsort( e1, e2 )
	return e1.time < e2.time
end

function highscores:save()
	love.filesystem.write("highscore_lists.lua", self:create_file())
end

function highscores:create_file()
	local txt = "return {\n"

	for i, list in ipairs( self.lists ) do
		txt = txt .. "{ level = \"" .. list.level .. "\",\n"
		for j, entry in ipairs( list ) do
			txt = txt .. "{time=" .. entry.time .. ", name=\""..entry.name.."\"},\n"
		end
		txt = txt .. " },\n"
	end

	txt = txt .. "}"
	return txt
end

return highscores
