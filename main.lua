require "tile"
require "camera"
require "player"
require "note"

SPR_TILESET_0 = love.graphics.newImage("img/spr_tileset_0.png");
SPR_PLAYER_0  = love.graphics.newImage("img/spr_player_0.png");

SND_PLAYER = love.audio.newSource("snd/snd_player.wav", "static");

function CalcPitchRatio( tilex, tiley ) 

	xdiff = tilex - 5;
	ydiff = tiley - 5;

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

	map = {};
	
	for i = 1, 10 do
		
		map[i] = {};
	
		for j = 1, 10 do
		
			t = Tile:new{ x = i, y = j };
			pitch = CalcPitchRatio(i,j)
			n = Note:new{ num = pitch[1], den = pitch[2] }
			t.note = n;
			
			map[i][j] = t;
		
		end 
	end	
	
	player = Player:new();
end

function love.keypressed(key, scancode, isrepeat)

	if key == "up" then
		player.tileY = player.tileY - 1;
		player.moving = true;
	elseif key == "down" then
		player.tileY = player.tileY + 1;
		player.moving = true;
	end
	if key == "left" then
		player.tileX = player.tileX - 1;
		player.moving = true;
	elseif key == "right" then
		player.tileX = player.tileX + 1;
		player.moving = true;
	end
end

function love.update(dt)

	player:update();
	
end

function love.draw()
	
	for i = 1, 10 do
		for j = 1, 10 do
			love.graphics.draw(SPR_TILESET_0, tra_x(i*32), tra_y(j*32), 0, cam_zoom, cam_zoom)
		end
	end 
	love.graphics.draw(SPR_PLAYER_0, tra_x(player.x), tra_y(player.y), 0, cam_zoom, cam_zoom);
	
	love.graphics.print(player.currentnum .. "/" .. player.currentden, 0, 0)
end