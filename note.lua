Note = {
	num = 1,
	den = 1
}

function Note:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end