function init_gui()

	WINDOW_MAIN = {};

	topbar = TextBox_TopBar:new{ x=0, y=0, height=150 }
	table.insert(WINDOW_MAIN, topbar);

	window = WINDOW_MAIN;
end

TextBox = {

	x = -1, -- displayed x and y on screen
	y = -1,
	-- if not manually assigned, (-1, -1) is the "auto" setting to fill up the parent box
	
	width = 100, height = 100,
	color = {1.0, 1.0, 1.0, 0.5},
	
	parent = nil,  -- the text box above it in the hierarchy
	children = {}, -- other text boxes displayed within it
	
	text = "",
}

function TextBox:appendElement(e)

	e.parent = self;
	table.insert(self.children, e);

end

function TextBox:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function TextBox:update()
end

TextBox_TopBar = TextBox:new{

};

function TextBox_TopBar:update()
	self.width = love.graphics.getWidth();
end