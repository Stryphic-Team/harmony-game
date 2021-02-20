function init_gui()

	WINDOW_MAIN = {};

	topbar = TextBox_TopBar:new{ x=0, y=0, height=200 }
	table.insert(WINDOW_MAIN, topbar);
	
	statusbox = TextBox_Status:new{ width=256 }
	topbar:appendElement(statusbox);
	table.insert(WINDOW_MAIN, statusbox);
	
	chord1box = TextBox_ChordShape:new{text="Z", id=1}
	topbar:appendElement(chord1box);
	table.insert(WINDOW_MAIN, chord1box);
	
	chord2box = TextBox_ChordShape:new{text="X", id=2}
	topbar:appendElement(chord2box);
	table.insert(WINDOW_MAIN, chord2box);
	
	chord3box = TextBox_ChordShape:new{text="C", id=3}
	topbar:appendElement(chord3box);
	table.insert(WINDOW_MAIN, chord3box);

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
	
	-- Auto height(if set to -1 then it fills up to the height of the parent div)
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

TextBox_ChordShape = TextBox:new{
	
	id = 1, -- ID corresponds to an id within the room metadata which is the source of the different chordshapes

};

function TextBox_ChordShape:draw()
	TextBox.draw(self)
	
	love.graphics.setColor(1,1,1,1)
	--love.graphics.line(self.dispx, self.dispy, self.dispx+self.dispwidth, self.dispy+self.dispheight);
	shape = room.chordshapes[self.id];
	
	extreme_L = 0; extreme_R = 0; extreme_U = 0; extreme_D = 0;
	
	for i = 1, #shape.xoffsets do
		
		offsetx = shape.xoffsets[i]; offsety = shape.yoffsets[i];
		if offsetx > extreme_R then
			extreme_R = offsetx;
		elseif offsetx < extreme_L then
			extreme_L = offsetx;
		end
		if offsety > extreme_D then
			extreme_D = offsety;
		elseif offsety < extreme_U then 
			extreme_U = offsety;
		end
	end
	shapewidth = extreme_R - extreme_L + 1; shapeheight = extreme_D - extreme_U + 1;

	TILE_DRAW_SIZE = 32;
	self.width = math.max(4*TILE_DRAW_SIZE, shapewidth * TILE_DRAW_SIZE * 2);
	
	--self.text = shapewidth
	
	for i = 1, #shape.xoffsets do
	
		offsetx = shape.xoffsets[i]; offsety = shape.yoffsets[i];
		
		centerx = self.dispx + (self.dispwidth / 2) - ( TILE_DRAW_SIZE / 2 ); centery = self.dispy + (self.dispheight/ 2) - ( TILE_DRAW_SIZE / 2 );
		
		tiledrawx = centerx + (offsetx*TILE_DRAW_SIZE); tiledrawy = centery + (offsety*TILE_DRAW_SIZE);
		
		--love.graphics.rectangle( "fill", tiledrawx, tiledrawy, TILE_DRAW_SIZE, TILE_DRAW_SIZE )
		
		if offsetx == 0 and offsety == 0 then
			love.graphics.draw(SPR_HUD_ROOT, tiledrawx, tiledrawy, 0, 4, 4);
		else
			love.graphics.draw(SPR_HUD_TILE, tiledrawx, tiledrawy, 0, 4, 4);
		end
	end
end

function TextBox_ChordShape:update()
	TextBox.update(self)
	
	self.text = string.sub(self.text, 1, 1)
	
	self.text = self.text .. "- " .. room.chordshapes[self.id].name
end

function TextBox_TopBar:update()
	TextBox.update(self)

	self.width = love.graphics.getWidth();
end

function TextBox_Status:update()
	TextBox.update(self)

	self.text = "\n\n\nChords remaining:" .. player.chordsRemaining
end