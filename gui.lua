function init_gui()

	WINDOW_MAIN = {};

	topbar = TextBox_TopBar:new{ x=0, y=0, height=150 }
	table.insert(WINDOW_MAIN, topbar);

	window = WINDOW_MAIN;
end

TextBox = {

	x = -1, -- physical x and y of the dom element
	y = -1,
	-- if not manually assigned, (-1, -1) is the "auto" setting to fill up the parent box
	
	width = 100, height = 100, padding = 50,
	
	-- x and y as they appear on the screen and to the children divs
	dispx = -1, dispy = -1,
	dispwidth = 100, dispheight = 100,
	
	color        = {0.0, 0.0, 0.0, 0.5},
	outlinecolor = {1.0, 1.0, 1.0, 1.0},
	
	parent = nil,  -- the text box above it in the hierarchy
	children = {}, -- other text boxes displayed within it
	
	text = "Deez Nuts Ha Got Eem Deez Nuts Ha Got Eem Deez Nuts Ha Got Eem Deez Nuts Ha Got Eem ",
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
	self.dispx = self.x + self.padding; self.dispy = self.y + self.padding;
	
	self.dispwidth = self.width - (self.padding*2); self.dispheight = self.height - (self.padding*2);
end

function TextBox:draw()

	love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.color[4]);
	love.graphics.rectangle("fill",self.dispx,self.dispy,self.dispwidth,self.dispheight);
	
	love.graphics.setColor(self.outlinecolor[1], self.outlinecolor[2], self.outlinecolor[3], self.outlinecolor[4]);
	love.graphics.rectangle("line",self.dispx,self.dispy,self.dispwidth,self.dispheight);
	
	love.graphics.setColor(1,1,1,1)
	love.graphics.printf(self.text, self.dispx, self.dispy, self.dispwidth, "left")
end

TextBox_TopBar = TextBox:new{

};

function TextBox_TopBar:update()
	TextBox.update(self)

	self.width = love.graphics.getWidth();
end