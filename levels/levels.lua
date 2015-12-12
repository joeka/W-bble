local levels = {}

local json = require ("libs.lunajson.lunajson")

function levels:load()
	local files = love.filesystem.getDirectoryItems("levels")
	for k, file in ipairs(files) do
		if file:match "%.lvl$" then
			local jsonstr, size = love.filesystem.read( "levels/"..file )

			if size > 0 then
				local lvl = json.decode(jsonstr)
				table.insert(levels, lvl)
			end
		end
	end
end

return levels
