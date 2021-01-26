Player = { 

	tileX = 4,
	tileY = 4,
	x = 40, -- displayed x and y on screen
	y = 40,
	moving = false, -- just a useless bool iunno

	currentnum = 1,
	currentden = 1
}

function Player:update()
	self.x = self.x + (((self.tileX * 32) - self.x) / 5);
	self.y = self.y + (((self.tileY * 32) - self.y) / 5);
	
	if math.floor(self.y + 0.5) == ( self.tileY * 32 ) and math.floor(self.x + 0.5) == ( self.tileX * 32 ) and self.moving then
	
		self.moving = false;
		
		love.audio.stop(SND_PLAYER)
		
		tile = map[self.tileX][self.tileY];
		note = tile.note;
		
		SND_PLAYER:setPitch(note.num / note.den);
		
		self.currentnum = note.num; self.currentden = note.den;
		
		love.audio.play(SND_PLAYER)
	end
end

function Player:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end