Player = { 

	tileX = 4,
	tileY = 4,
	x = 40, -- displayed x and y on screen
	y = 40,
	moving = false, -- just a useless bool iunno
	moves_outside_chord = 0,

	currentnum = 1,
	currentden = 1,
	
	safeTiles = {},
	chordTones = {},
	
	health = 5,
	chordsRemaining = 20,
	
	dead = false, -- used to trigger die respawn anim
	RESPAWN_TIME = 100,
	respawn_timer = 0,
}

function Player:update()

	cam_x = player.x; cam_y = player.y;

	self.x = self.x + (((self.tileX * 32) - self.x) / 5);
	self.y = self.y + (((self.tileY * 32) - self.y) / 5);
	
	if math.floor(self.y + 0.5) == ( self.tileY * 32 ) and math.floor(self.x + 0.5) == ( self.tileX * 32 ) and self.moving then
	
		self.moving = false;
		
		love.audio.stop(SND_PLAYER)
		
		tile = map[self.tileX][self.tileY];
		note = tile.note;
		
		if self.uppercase then
			SND_PLAYER:setPitch((note.num * 2) / note.den);
		else
			SND_PLAYER:setPitch(note.num / note.den);
		end
		
		self.currentnum = note.num; self.currentden = note.den;
		
		love.audio.play(SND_PLAYER)
		
		-- initially steps moves_outside_chord
		self.moves_outside_chord = self.moves_outside_chord + 1
		-- but if it finds that you actually are on a chord tone it resets
		for i = 1, #self.safeTiles do
			if tile == self.safeTiles[i] then
				self.moves_outside_chord = 0
				break
			end
		end
		
		if self.moves_outside_chord > 2 then
			self.health = self.health - 1;
		end
		
		print(self.moves_outside_chord)
		
		next_turn();
	end
	
	-- enable this for cheat mode if you wanna debug
	--self.health = 1000;
	
	if self.health <= 0 and not self.dead then
		self.dead = true; self.respawn_timer = self.RESPAWN_TIME;
	end
	if self.dead then
		self.respawn_timer = self.respawn_timer - 1;
	end
end

function Player:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end