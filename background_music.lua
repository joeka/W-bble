require "libs.TESound"

local bg_music = {}

function bg_music:init()
	self.musics = { "snd/music1_long.ogg", "snd/music2_long.ogg" }
	math.randomseed(os.time())
end

function bg_music:play()
	self.channels = TEsound.playLooping(self.musics)
end

function bg_music:update()
	TEsound.cleanup()
end	

function bg_music:stop()
	if (self.channels ~= nil) then
		TEsound.stopAll()
		self.channels = nil
	end
end

return bg_music