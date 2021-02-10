Entity = {

	tileX = 4,
	tileY = 4,
	x = 40, -- displayed x and y on screen
	y = 40,
	moving = false, -- just a useless bool iunno
	dead = false,
}

function Entity:update()
	self.x = self.x + (((self.tileX * 32) - self.x) / 5);
	self.y = self.y + (((self.tileY * 32) - self.y) / 5);

	if math.floor(self.y + 0.5) == ( self.tileY * 32 ) and math.floor(self.x + 0.5) == ( self.tileX * 32 ) and self.moving then
	
		self.moving = false;
		
		love.audio.stop(SND_ENEMY)
		SND_ENEMY:setVolume(2);
		
		tile = map[self.tileX][self.tileY];
		note = tile.note;
		
		
		SND_ENEMY:setPitch(note.num / note.den);
		
		love.audio.play(SND_ENEMY)
	end
end

function Entity:nextTurn()
	
	self.moving = true;
	
	-- randomtile = nil;
	-- while randomtile == nil or randomtile.tiletype ~= 1 or (randoffX == 0 and randoffY == 0)  do
		
		-- randoffX = love.math.random(-1, 1); randoffY = love.math.random(-1, 1); 
		-- print(randoffX)
		-- if map[self.tileX + randoffX] ~= nil then
			-- randomtile = map[self.tileX + randoffX][self.tileY + randoffY]
			
			-- self.tileX = self.tileX + randoffX; self.tileY = self.tileY + randoffY
		-- end
	-- end
	randoffX = {  0, 0, -1, 1 } 
	randoffY = { -1, 1,  0, 0 }
	
	randomtile = nil;
	while randomtile == nil or randomtile.tiletype ~= 1 do
	
		randindex = love.math.random(1,4)
	
		if map[self.tileX + randoffX[randindex]] ~= nil then
			randomtile = map[self.tileX + randoffX[randindex]][self.tileY + randoffY[randindex]]
		end
	end
	self.tileX = randomtile.x ; self.tileY = randomtile.y ;
	
	-- bounds
	self.tileX = math.min(self.tileX, room.width)
	self.tileX = math.max(self.tileX, 0)
	self.tileY = math.min(self.tileY, room.height)
	self.tileY = math.max(self.tileY, 0)
	
end

function Entity:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end