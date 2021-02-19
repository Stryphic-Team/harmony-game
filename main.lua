require "tile"
require "camera"
require "entity"
require "player"
require "note"
require "gui"

TILE_FREE = 1
TILE_CNTR = 130
TILE_HOLE = 4
TILE_WALL = 5
TILE_SPAWNMOB_ANT = 131

SPR_TILESET   = love.graphics.newImage("img/tileset.png");
SPR_TILESET_0 = love.graphics.newImage("img/spr_tileset_0.png");
SPR_TILESET_1 = love.graphics.newImage("img/spr_tileset_1.png");
SPR_PLAYER_0  = love.graphics.newImage("img/spr_player_0.png");
SPR_PLAYER_1  = love.graphics.newImage("img/spr_player_1.png");
SPR_ENEMY     = love.graphics.newImage("img/spr_enemy.png");
SPR_HEART     = love.graphics.newImage("img/spr_heart.png");

SND_PLAYER = love.audio.newSource("snd/snd_player.wav", "static");
SND_ORGAN1 = love.audio.newSource("snd/pianuh.wav" , "static");
SND_ORGAN2 = love.audio.newSource("snd/pianuh.wav" , "static");
SND_ORGAN3 = love.audio.newSource("snd/pianuh.wav" , "static");
SND_ENEMY  = love.audio.newSource("snd/snd_enemy.wav", "static");

function ChangeChord(offsetsX, offsetsY)
	player.safeTiles = {};
	player.chordTones = {};
	
	for i = 1, #offsetsX do
		
		if map[player.tileX + offsetsX[i]] ~= nil then
			tile = map[player.tileX + offsetsX[i]][player.tileY + offsetsY[i]]
			
			if tile ~= nil and tile.tiletype == 1 then
				table.insert(player.safeTiles, tile)
				table.insert(player.chordTones, tile.note)
				
				-- Scans the room for entitys and kills any that are on the safe tiles
				for j = 1, #room.entities do
				
					e = room.entities[j]
					if e.tileX == tile.x and e.tileY == tile.y then
						e.dead = true;
					end
				end
			end
		end
	end
	
	player.chordsRemaining = player.chordsRemaining - 1;
		
	next_turn();
	
	if player.chordsRemaining == 0 then
		player.dead = true; player.respawn_timer = player.RESPAWN_TIME;
	end
end

function PlayChord()
	organ_tones = {SND_ORGAN1, SND_ORGAN2, SND_ORGAN3}
	
	for i = 1, #organ_tones do
		love.audio.stop( organ_tones[i] );
	end
	for i = 1, #player.chordTones do	
		
		organ_tones[i]:setPitch(player.chordTones[i].num / player.chordTones[i].den);
		organ_tones[i]:setVolume(0.25);
		organ_tones[i]:setLooping(false);
		
		love.audio.play(organ_tones[i]);
	end
end

function CalcPitchRatio( tilex, tiley ) 

	xdiff = tilex - room.centerX;
	ydiff = tiley - room.centerY;

	output = {}
	numerator = 1;
	denominator = 1;
	
	xout = math.pow( 3, math.abs( xdiff ) );
	yout = math.pow( 5, math.abs( ydiff ) );
	
	if xdiff >= 0 then
		numerator = numerator * xout
	else
		denominator = denominator * xout
	end
	if ydiff >= 0 then
		numerator = numerator * yout
	else
		denominator = denominator * yout
	end
	output[1] = numerator; output[2] = denominator;
	
	-- octave reduction
	if output[1]/output[2] > 2.0 then
		while output[1]/output[2] > 2.0 do
			output[2] = output[2] * 2;
		end
	end
	if output[1]/output[2] < 1.0 then
		while output[1]/output[2] < 1.0 do
			output[1] = output[1] * 2;
		end
	end
	
	return output;

end

function next_turn()
	for i = 1, #room.entities do
		e = room.entities[i];
		if not e.dead then
			e:nextTurn();
		end
	end
end

function init_room( id )
	room = rooms[id]
	room_data = require(room_paths[id])
	
	room.width = room_data.width; room.height = room_data.height;
	room.entities = {};
	room.particles = {};
	
	map = {};
	
	-- First pass on room initialization just looks for the center tile (Its marked with the red circle in the editor but not in game)
	for i = 1, room.height do
		for j = 1, room.width do

			index = ((j-1) * room.width) + (i-1)
			tilefromdata = room_data.layers[1].data[index+1]
		
			if tilefromdata == TILE_CNTR then 
				room.centerX = i; room.centerY = j;
				tilefromdata = TILE_FREE
			end
		end
	end
	
	-- Second pass on room initialization creates all the tile objects and, with the known center tile, calculates the note pitches and makes note objects
	for i = 1, room.height do
		
		map[i] = {};
	
		for j = 1, room.width do
		
			index = ((j-1) * room.width) + (i-1)
			tilefromdata = room_data.layers[1].data[index+1]
				
			if tilefromdata == 2 or tilefromdata == TILE_CNTR then
				tilefromdata = TILE_FREE
			end
			
			if tilefromdata == TILE_SPAWNMOB_ANT then
			
				e = Entity:new{ tileX = i, tileY = j };
				table.insert(room.entities, e)
			
				tilefromdata = TILE_FREE
			end
		
			t = Tile:new{ x = i, y = j, tiletype = tilefromdata };
			pitch = CalcPitchRatio(i,j)
			n = Note:new{ num = pitch[1], den = pitch[2] }
			t.note = n;
			
			map[i][j] = t;
		
		end 
	end	
	
	-- new player object is created every room init ( maybe it shouldnt be like that I DONT KNOW )
	player = Player:new{ tileX = room.centerX, tileY = room.centerY };
end

function love.load()

	success = love.window.setMode( 800, 600, {resizable=true} )
	love.window.setTitle("JI Deez game")
	font = love.graphics.newFont("zeldadxt.ttf", 24)
	love.graphics.setFont(font)
	
	init_gui();

	room_paths = {
	"room/testroom",
	"room/testroom2",
	"room/testroom3"}

	rooms = require "rooms"

	init_room(3)
end

function love.keypressed(key, scancode, isrepeat)

	if not player.dead and player.chordsRemaining > 0 then
		if key == "z" then
			ChangeChord( { 0, 0, 1 }, { 0, 1, 0 } ) -- major triad
			PlayChord();
		end
		if key == "x" then
			ChangeChord( { 0, 1, 1 }, { 0, -1, 0 } ) -- minor triad
			PlayChord();
		end
		if key == "c" then
			ChangeChord( { 0, -1, 1 }, { 0, 0, 0 } ) -- sus chord
			PlayChord();
		end
		if key == "r" then
			ChangeChord({}, {});
			PlayChord();
		end
	end
	
	if not player.moving and not player.dead then
		if key == "up" then
			if player.tileY > 1 then
			
				targettile = map[player.tileX][player.tileY - 1]
				if targettile.tiletype == 1 then
				
					player.tileY = player.tileY - 1;
					player.moving = true;
				
				end
			end
		elseif key == "down" then
			if player.tileY < room.height then
			
				targettile = map[player.tileX][player.tileY + 1]
				if targettile.tiletype == 1 then			
				
					player.tileY = player.tileY + 1;
					player.moving = true;
				
				end
			end
		end
		if key == "left" then
			if player.tileX > 1 then
			
				targettile = map[player.tileX - 1][player.tileY]
				if targettile.tiletype == 1 then	
				
					player.tileX = player.tileX - 1;
					player.moving = true;
				end
			end
		elseif key == "right" then
			if player.tileX < room.width then
			
				targettile = map[player.tileX + 1][player.tileY]
				if targettile.tiletype == 1 then
				
					player.tileX = player.tileX + 1;
					player.moving = true;
				end
			end
		end
	end
end

function love.update(dt)

	player.uppercase = love.keyboard.isDown("lshift")

	player:update();
	
	-- for i = 1, #room.entities do
		-- if e.dead then
			-- table.remove(room.entities, i)
		-- end
	-- end
	
	for i = 1, #room.entities do
		e = room.entities[i];
		
		e:update();
	end
	
	for i = 1, #window do
		e = window[i];
		e:update();
	end
	
	
	if player.dead and player.respawn_timer <= (player.RESPAWN_TIME / 2) then
		init_room(3);
	end
end

function love.draw()
	
	for i = 1, room.width do
		for j = 1, room.height do
		
			t = map[i][j]
			tx = ((t.tiletype - 1) % 16) * 32
			ty = math.floor((t.tiletype - 1) / 16) * 32
			
			if t.tiletype ~= 0 then
				quad = love.graphics.newQuad( tx, ty, 32, 32, SPR_TILESET:getDimensions() )
				
				love.graphics.draw(SPR_TILESET, quad, tra_x(i*32), tra_y(j*32), 0, cam_zoom, cam_zoom)
			end
		end
	end 
	for i = 1, #player.safeTiles do
		tile = player.safeTiles[i]
		love.graphics.draw(SPR_TILESET_0, tra_x(tile.x*32), tra_y(tile.y*32), 0, cam_zoom, cam_zoom)
	end
	
	for i = 1, #room.entities do
		e = room.entities[i]
		if not e.dead then
			love.graphics.draw(SPR_ENEMY, tra_x(e.x), tra_y(e.y), 0, cam_zoom, cam_zoom);
		end
	end
	
	if player.uppercase then
		love.graphics.draw(SPR_PLAYER_1, tra_x(player.x), tra_y(player.y - 32), 0, cam_zoom, cam_zoom);
	else 
		love.graphics.draw(SPR_PLAYER_0, tra_x(player.x), tra_y(player.y), 0, cam_zoom, cam_zoom);
	end
	
	if player.dead then
	
		opacity = 0.5 + ( math.sin( (player.RESPAWN_TIME - 20 - player.respawn_timer) * (math.pi / ( player.RESPAWN_TIME / 2 )) ) / 2 )
	
		love.graphics.setColor(0,0,0,opacity)
		love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
		love.graphics.setColor(1,1,1,1)
	end
	
	for i = 1, #window do
		box = window[i];
		box:draw();
	end
	
	for i = 0, player.health - 1 do
		love.graphics.draw(SPR_HEART, 36 + (i*40), 32)
	end
	
	-- love.graphics.print(player.currentnum .. "/" .. player.currentden, 0, 0)
	
	-- cents = 1200 * (math.log( player.currentnum / player.currentden ) / math.log( 2 ))
	
	-- love.graphics.print(cents, 0, 80)
	-- love.graphics.print("Chords remaining: " .. player.chordsRemaining, 0, 120)
end