require "tile"
require "camera"
require "player"
require "note"

SPR_TILESET_0 = love.graphics.newImage("img/spr_tileset_0.png");
SPR_TILESET_1 = love.graphics.newImage("img/spr_tileset_1.png");
SPR_PLAYER_0  = love.graphics.newImage("img/spr_player_0.png");

SND_PLAYER = love.audio.newSource("snd/snd_player.wav", "static");
SND_ORGAN1 = love.audio.newSource("snd/snd_organ.wav" , "static");
SND_ORGAN2 = love.audio.newSource("snd/snd_organ.wav" , "static");
SND_ORGAN3 = love.audio.newSource("snd/snd_organ.wav" , "static");

function ChangeChord(offsetsX, offsetsY)
	player.safeTiles = {};
	player.chordTones = {};
	
	for i = 1, #offsetsX do
		
		if map[player.tileX + offsetsX[i]] ~= nil then
			tile = map[player.tileX + offsetsX[i]][player.tileY + offsetsY[i]]
			
			if tile ~= nil then
				table.insert(player.safeTiles, tile)
				table.insert(player.chordTones, tile.note)
			end
		end
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
		organ_tones[i]:setLooping(true);
		
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

function love.load()

	rooms = require "rooms"
	room = rooms[1];
	map = {};
	
	for i = 1, room.width do
		
		map[i] = {};
	
		for j = 1, room.height do
		
			t = Tile:new{ x = i, y = j };
			pitch = CalcPitchRatio(i,j)
			n = Note:new{ num = pitch[1], den = pitch[2] }
			t.note = n;
			
			map[i][j] = t;
		
		end 
	end	
	
	player = Player:new{ tileX = room.centerX, tileY = room.centerY };
end

function love.keypressed(key, scancode, isrepeat)

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

	if key == "up" then
		if player.tileY > 1 then
			player.tileY = player.tileY - 1;
			player.moving = true;
		end
	elseif key == "down" then
		if player.tileY < room.height then
			player.tileY = player.tileY + 1;
			player.moving = true;
		end
	end
	if key == "left" then
		if player.tileX > 1 then
			player.tileX = player.tileX - 1;
			player.moving = true;
		end
	elseif key == "right" then
		if player.tileX < room.width then
			player.tileX = player.tileX + 1;
			player.moving = true;
		end
	end
end

function love.update(dt)

	player:update();
	
end

function love.draw()
	
	for i = 1, room.width do
		for j = 1, room.height do
			love.graphics.draw(SPR_TILESET_1, tra_x(i*32), tra_y(j*32), 0, cam_zoom, cam_zoom)
		end
	end 
	for i = 1, #player.safeTiles do
		tile = player.safeTiles[i]
		love.graphics.draw(SPR_TILESET_0, tra_x(tile.x*32), tra_y(tile.y*32), 0, cam_zoom, cam_zoom)
	end
	love.graphics.draw(SPR_PLAYER_0, tra_x(player.x), tra_y(player.y), 0, cam_zoom, cam_zoom);
	
	love.graphics.print(player.currentnum .. "/" .. player.currentden, 0, 0)
end