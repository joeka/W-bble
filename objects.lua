local objects = {
	{ name = "testbox", file = "img/testobject.png", w = 32, h = 32},
	{ name = "flagge", file = "img/flagge.png", w = 32, h = 32}
}

function objects:load_images()
	for i, object in ipairs(objects) do
		object.image = love.graphics.newImage(object.file)
	end
end

return objects