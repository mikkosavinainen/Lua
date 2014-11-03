require "camera"

function love.load()
	print("Peli alustettu")
	
	-- Asettaa pelin resoluution
	love.window.setMode(800, 608)
	
	-- Haetaan ja asetetaan ruudun koon leveys ja korkeus
	screenWidth = love.graphics.getWidth()
	screenHeight = love.graphics.getHeight()
	
	-- Lataa kuvat
	pelaajakuva = love.graphics.newImage("player.png")
	titlekuva = love.graphics.newImage("titlemenu.png")
	gameoverkuva = love.graphics.newImage("gameover.png")
	ohjekuva = love.graphics.newImage("1kenttaohjeet.png")
	background = love.graphics.newImage("background.png")
	
	-- Mappien muuttujat
	mapnumber = 1
	maxmaps = 9
	
	seppo = "seppo"
	
	deaths = 0
	total_time = 0
	
	--äänet
	jumpsound = love.audio.newSource("Jump8.wav", "static")
	doublejumpsound = love.audio.newSource("sounds/DoubleJump.wav", "static")
	deathsound = love.audio.newSource("sounds/Hit_Hurt70.wav", "static")
	endlevelsound = love.audio.newSource("sounds/Pickup_Coin17.wav", "static")
	gravitysound = love.audio.newSource("sounds/Powerup14.wav", "static")
	
	--musa
	bgm = love.audio.newSource("bgm.mp3", "stream")
	love.audio.play(bgm)
	
	-- Lataa pelaajan ja kameran
	load_player_and_camera()
	
	-- Peli alkaa game_state = 1, eli titlestä.
	game_state = 1
	
	-- Vasen ja oikean muuttujan arvot, jotka kääntävät pelaajan
	vasen = false
	oikea = false
	
	-- Pelin sisäinen aikalaskuri
	game_time = 0
	-- Kuinka usein kutsutaan game_step() funktiota, pelin nopeus
	-- 16ms = 60fps
	game_step_time = 0.01666666666
	-- Onko peli käynnissä
	game_running = true
	
	-- Mapin taustaväri
	love.graphics.setBackgroundColor(100, 140, 240)
	
	-- Kartan lataaminen
    loader = require("AdvTiledLoader.Loader")
    loader.path = "maps/"
    map = loader.load("titlemap.tmx") 
    map:setDrawRange(0, 0, map.width * map.tileWidth, map.height * map.tileHeight)
	camera:setBounds(0, 0, map.width * map.tileWidth - screenWidth, map.height * map.tileHeight - screenHeight)
end

function load_player_and_camera()
	-- Pelihahmon alkutiedot
	require "Player"
	p = Player:new()
	
    p.x = 48
    p.y = 532
    p.width = 32
    p.height = 32
    p.jumpSpeed = -800
    p.runSpeed = 200
	p.turbo = 300
	 
    gravity = 1800
	hasJumped = false
	delay = 120
	
	camera.x = 0
end

function title_menu_drawplayer()
	p = Player:new()
	
    p.x = 800
    p.y = 532
    p.width = 32
    p.height = 32
    p.jumpSpeed = -800
    p.runSpeed = 200
	p.turbo = 300
	 
    gravity = 1800
	hasJumped = false
	delay = 120
	
	camera.x = 0
end

function love.update(deltaTime)
	-- Titlescreen = game_state 1
	if game_state == 1 then
		title_menu()
		p:update(deltaTime, gravity, map)
		p:moveLeft()
		vasen = true
		if p.x < 0 then
			title_menu_drawplayer()
		end
	-- Pelitila = game_state 2
	elseif game_state == 2 then
		
		total_time = total_time + deltaTime
	
		pillunpallit()
		-- Tarkistaa onko peli käynnissä.
		if game_running then

			-- Päivittää mitä pelaaja painaa
			player_movement()
	
			-- Päivittää pelaajan paikan
			p:update(deltaTime, gravity, map)
		
			-- Kamera seuraa pelaajaa
			camera:setPosition(math.floor(p.x - screenWidth / 2), math.floor(p.y - screenHeight / 2))
	
			--gamesteppiä, jota käytetään joskus sitten.
			game_time = game_time + deltaTime
			if game_time >= game_step_time then
				game_time = game_time - game_step_time
				if game_running then
					game_step()
				end
			end
			
			-- Kutsuu funktioita, joita update tarkistaa
			end_level()
			gameover()
			change_gravity()
		end
	-- Gameover = game_state 3
	elseif game_state == 3 then
		if love.keyboard.isDown("u") then
			love.load()
		end
	end
end

function game_step()
	print("Askellus")
	--tarkista erikoistapaukset
end

function draw_player()
	-- Pyöristää alas x ja y ja laittaa lokaalit muuttujat.
    local x = math.floor(p.x)
    local y = math.floor(p.y)
	local xOffset = 0
	local yOffset = 0
	local xScale = 1
	local yScale = 1
	
	
	-- Jos painat oikealle, niin pelaajan kuva kääntyy oikealle.
	if oikea then
		xScale = 1
		xOffset = 0
	end
	
	-- Jos painat vasemmalle, niin pelaajan kuva kääntyy vasemmalle.
	if vasen then
		xScale = -1
		xOffset = p.width
	end
	
	-- Jos antigravity, niin pelaaja on väärinpäin
	if p.antiGravity then
		yScale = -1
		yOffset = p.height
	end
	
    -- Piirrä pelaaja
    love.graphics.setColor(255,255,255,255)
    love.graphics.draw(pelaajakuva, x - p.width / 2, y - p.height / 2, 0, xScale, yScale, xOffset, yOffset)
end

function love.draw()
	-- Titlemenu = game_state 1
	if game_state == 1 then
		love.graphics.setColor(255,255,255,255)
		love.graphics.draw(background, 0, 0)
		map:draw()
		draw_player()
		love.graphics.draw(titlekuva, 15, 100)
	-- Pelitila = game_state 2
	elseif game_state == 2 then
		love.graphics.setColor(255,255,255,255)
		love.graphics.draw(background, 0, 0)
		-- Asettaa kameran
		camera:set()
		
		-- Piirtää kartan ja pelaajan.
		local x, y = math.floor(p.x), math.floor(p.y)
		love.graphics.setColor(255,255,255,255)
		map:draw()
		draw_player()
		
		if map.name == "map01.tmx" then
			love.graphics.draw(ohjekuva, 128, 32)
			-- love.graphics.print("Arrow keys = movement", 128, 32)
			-- love.graphics.print("Z = Run, X = Jump", 128, 64)
			-- love.graphics.print("P = pause, R = restart", 128, 96)
		end
		
		-- Unset camera
		camera:unset()
		
		-- Jos pelitila on pausella, niin tulostaa ruudulle Pause
		if game_running == false then
			love.graphics.print("Pause", screenWidth/2 - 30, screenHeight/2)
		end
	
		-- Debug-info
		-- local tileX = math.floor(p.x / map.tileWidth)
		-- local tileY = math.floor(p.y / map.tileHeight)
  
		-- love.graphics.setColor(255, 255, 255)
		-- love.graphics.print("Player coordinates: ("..(x - p.width / 2)..","..(y - p.height / 2)..")", 5, 5)
		-- love.graphics.print("Current state: "..p.state, 5, 20)
		-- love.graphics.print("Current tile: ("..tileX..", "..tileY..")", 5, 35)
		-- love.graphics.print("runspeed: ".. p.xSpeed .."", 5, 50)
		-- love.graphics.print("ySpeed: ".. math.floor(p.ySpeed) .." ", 5,65)
		-- love.graphics.print("Falljump: ".. seppo .." ", 5, 80)
		love.graphics.print("Deaths: " .. deaths .." ", 5, 5)
	
	-- Game Over = game_state 3
	elseif game_state == 3 then
		love.graphics.draw(background, 0, 0)
		love.graphics.print("Congratulations, you have completed the game!", (screenWidth / 3) ,(screenHeight / 3) - 15)
		love.graphics.print("DLC and season passes are coming this holiday!", (screenWidth / 3) ,(screenHeight / 3))
		love.graphics.print("Total deaths: " .. deaths .." ", (screenWidth / 3) ,(screenHeight / 3) + 30)
		love.graphics.print("Total time: " .. total_time .." ", (screenWidth / 3) ,(screenHeight / 3) + 45)
	end
end

-- Pelaaja kuolee, niin resettaa pelaajan position ja kameran
function gameover()
	if p.y > 600 or p.lavaKillsPlayer == true or p.y < 0 then 
		load_player_and_camera()
		deaths = deaths + 1
		love.audio.play(deathsound)
	end
end

function pillunpallit()
	if p.falljump == true then
		seppo = "true"
	elseif p.falljump == false then
		seppo = "false"
	end
end

-- Pelaaja pääsee kentän loppuun, niin vaihtaa mappia tai lopettaa pelin
function end_level()
	if p.endLevel == true then
		if mapnumber < maxmaps then
			load_player_and_camera()
			mapnumber = mapnumber + 1
			map = loader.load("map0" ..mapnumber.. ".tmx")
			map:setDrawRange(0, 0, map.width * map.tileWidth, map.height * map.tileHeight)
			camera:setBounds(0, 0, map.width * map.tileWidth - screenWidth, map.height * map.tileHeight - screenHeight)
			p.endLevel = false
			love.audio.play(endlevelsound)
		else
			love.audio.play(endlevelsound)
			love.audio.stop(bgm)
			game_state = 3
			game_running = false
		end
	end
	
	
end

-- Gravity-palikan toiminto
function change_gravity()
	if p.antiGravity == true then
		gravity = -1800
		p.jumpSpeed = 800
	elseif p.antiGravity == false then
		gravity = 1800
		p.jumpSpeed = -800
	end
end

--funktio, jossa testataan kahden objectin osumista keskenään.
-- EI TEE MITÄÄN TÄLLÄH HETKELLÄ
function test_if_objects_collide(object1, object2)
	local left1 = object1.x
	local right1 = object1.x + object1.width - 1
	local top1 = object1.y
	local bottom1 = object1.y + object1.height - 1
	
	local left2 = object2.x
	local right2 = object2.x + object2.width - 1
	local top2 = object2.y
	local bottom2 = object2.y + object2.height - 1
	
	return left1 <= right2 and left2 <= right1 and top1 <= bottom2 and top2 <= bottom1
end

-- Titlemenussa enter = peli alkaa
function title_menu()
	if love.keyboard.isDown("return") then
		load_player_and_camera()
		vasen = false
		oikea = true
		loader = require("AdvTiledLoader.Loader")
		loader.path = "maps/"
		map = loader.load("map01.tmx") 
		map:setDrawRange(0, 0, map.width * map.tileWidth, map.height * map.tileHeight)
		camera:setBounds(0, 0, map.width * map.tileWidth - screenWidth, map.height * map.tileHeight - screenHeight)
		game_state = 2
		game_running = true
	end
end

-- Pelaajan liikkuminen ja juokseminen
function player_movement()
	if love.keyboard.isDown("z") then
		p.runSpeed = p.turbo
	end
	if love.keyboard.isDown("right") then
        p:moveRight()
		oikea = true
		vasen = false
    end
    if love.keyboard.isDown("left") then
        p:moveLeft()
		vasen = true
		oikea = false
    end
end

function love.keypressed(key)
	-- ESC sulkee pelin
    if key == "escape" then
        love.event.quit()
	
	-- Kutsuu player hyppy
	elseif key == "x" then
		p:jump()
	
	-- Pause-nappula = P
	elseif key == "p" then
		if game_running == true then
			game_running = false
			love.audio.pause(bgm)
		elseif game_running == false then
			game_running = true
			love.audio.play(bgm)
		end
		
	if key == "g" then
		love.audio.play(jumpsound)
	end
		
	-- R aloittaa alusta pelin
	elseif key == "r" then
		love.audio.stop(bgm)
		love.load()
	end
end

function love.keyreleased(key)

	-- Muuttaa pelaajan vauhdin nollaan kun päästää irti näppäimestä
    if (key == "right") or (key == "left") then
        p:stop()
    end
	if key == "z" then
		p.runSpeed = 200
	end
end

function love.quit()
    print("Peli suljettu")
end

function math.clamp(x, min, max)
  return x < min and min or (x > max and max or x)
end