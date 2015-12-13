local levels = {}

function levels:load()
	local files = love.filesystem.getDirectoryItems("levels")
	for k, file in ipairs(files) do
		if file:match "%.lvl$" then
			local lvl_txt = love.filesystem.load("levels/" .. file)
			local lvl = lvl_txt()
			table.insert(levels, lvl)
		end
	end
end

return levels
