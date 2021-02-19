function init_gui()

	WINDOW_MAIN = {};

	topbar = TextBox_TopBar:new{ x=0, y=0, height=200 }
	table.insert(WINDOW_MAIN, topbar);
	
	statusbox = TextBox_Status:new{ width=256 }
	topbar:appendElement(statusbox);
	table.insert(WINDOW_MAIN, statusbox);
	
	testchild = TextBox:new{text="Z"}
	topbar:appendElement(testchild);
	table.insert(WINDOW_MAIN, testchild);
	
	testchild2 = TextBox:new{text="X"}
	topbar:appendElement(testchild2);
	table.insert(WINDOW_MAIN, testchild2);
	
	testchild3 = TextBox:new{text="C"}
	topbar:appendElement(testchild3);
	table.insert(WINDOW_MAIN, testchild3);

	window = WINDOW_MAIN;
end

TextBox = {

	x = -1, -- physical x and y of the dom element
	y = -1,
	-- if not manually assigned, (-1, -1) is the "auto" setting to fill up the parent box
	
	width = 100, height = -1, padding = 10,
	
	-- x and y as they appear on the screen and to the children divs
	dispx = -1, dispy = -1,
	dispwidth = 100, dispheight = 100,
	
	color        = {0.0, 0.0, 0.0, 0.5},
	outlinecolor = {1.0, 1.0, 1.0, 1.0},
	
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

	-- auto positioning setting. Floats left 
	if (self.x == -1 and self.y == -1) then
		
		p = self.parent;
		
		self.dispx = p.dispx + p.padding;
		self.dispy = p.dispy + p.padding;
		
		for i = 1, #p.children do
			
			if p.children[i] == self then
				break;
			else
				self.dispx = self.dispx + p.children[i].dispwidth + (p.padding)
			end
		end
		
	-- Manual positioning setting
	else	
		self.dispx = self.x + self.padding; self.dispy = self.y + self.padding;
	end
	
	self.dispwidth = self.width - (self.padding*2); self.dispheight = self.height - (self.padding*2);
	
	if (self.height == -1) then
	
		self.dispheight = self.parent.dispheight - self.parent.padding * 2
	
	end
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

TextBox_Status = TextBox:new{

};

function TextBox_TopBar:update()
	TextBox.update(self)

	self.width = love.graphics.getWidth();
end

function TextBox_Status:update()
	TextBox.update(self)

	self.text = "\n\n\nChords remaining:" .. player.chordsRemaining
end