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
		
		tile = map[self.tileX][self.tileY];
		note = tile.note;
		
		self.sound = love.audio.newSource(self.soundpath, "static");
		self.sound:setVolume(2);
		self.sound:setPitch(note.num / note.den);
		
		love.audio.play(self.sound)
	end
end

function Entity:draw()
	love.graphics.draw(SPR_ENEMY, tra_x(self.x), tra_y(self.y), 0, cam_zoom, cam_zoom);
end

function Entity:nextTurn()
	
	--self.moving = true;
	
	-- randoffX = {  0, 0, -1, 1 } 
	-- randoffY = { -1, 1,  0, 0 }
	
	-- randomtile = nil;
	-- while randomtile == nil or randomtile.tiletype ~= 1 do
	
		-- randindex = love.math.random(1,4)
	
		-- if map[self.tileX + randoffX[randindex]] ~= nil then
			-- randomtile = map[self.tileX + randoffX[randindex]][self.tileY + randoffY[randindex]]
		-- end
	-- end
	-- self.tileX = randomtile.x ; self.tileY = randomtile.y ;

	currentile = map[self.tileX][self.tileY];
	if isSafeTile(currentile) then
		self.dead = true;
	end
	
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

EntityAnt = Entity:new{
	movstep = 1,
	soundpath = "snd/snd_enemy.wav",
};

function EntityAnt:nextTurn()
	Entity.nextTurn(self);
	
	for i = 1, 2 do
		if map[self.tileX + self.movstep] ~= nil then
			
			newtile = map[self.tileX + self.movstep][self.tileY];
			
			if newtile.tiletype == 1 and not isSafeTile(newtile) then
			
				self.tileX = self.tileX + self.movstep;
				self.moving = true;
				break;
			else
				self.movstep = 0 - self.movstep
			end
		end
	end
end