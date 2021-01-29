Tile = {
	x = 0,
	y = 0,
	note = nil,
	tiletype = 1
}

function Tile:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end