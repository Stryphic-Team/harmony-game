Entity = {

	tileX = 4,
	tileY = 4,
	x = 40, -- displayed x and y on screen
	y = 40,
	moving = false, -- just a useless bool iunno
}

function Entity:update()
	self.x = self.x + (((self.tileX * 32) - self.x) / 5);
	self.y = self.y + (((self.tileY * 32) - self.y) / 5);
	
	if math.floor(self.y + 0.5) == ( self.tileY * 32 ) and math.floor(self.x + 0.5) == ( self.tileX * 32 ) and self.moving then
	
		self.moving = false;
		
	end
end

function Entity:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end