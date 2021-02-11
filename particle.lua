Particle = {

	x = 40, -- displayed x and y on screen
	y = 40,
	dead = false,
	color = {1.0, 1.0, 1.0},
	life = 50,
}

function Particle:update()
	self.y = self.y - 1;
	self.life = self.life - 1;
	
	if self.life <= 0 then
		self.dead = true;
	end
}

function Particle:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end