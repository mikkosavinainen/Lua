Player = {}
loader = require("AdvTiledLoader.Loader")
 
-- Konstruktrori
function Player:new()
    -- Pelihahmon ominaisuuksia
    local object = {
    x = 0,
    y = 0,
    width = 0,
    height = 0,
    xSpeed = 0,
    ySpeed = 0,
	xSpeedMax = 700,
	ySpeedMax = 800,
    state = "",
    jumpSpeed = 0,
    runSpeed = 0,
    canJump = false,
	turbo = 0,
	hitWall = false,
	falljump = false,
	hasjumped = false,
	
	endLevel = false,
	antiGravity = false,
	lavaKillsPlayer = false
	
    }
    setmetatable(object, { __index = Player })
    return object
end
 
-- Liikkumisen funktiot
function Player:jump()
    if self.onFloor then
        self.ySpeed = self.jumpSpeed
        self.onFloor = false
		self.doubleJump = true
		self.canJump = true
		love.audio.play(jumpsound)
	elseif self.doubleJump then
		self.ySpeed = (self.jumpSpeed * 0.8)
		self.onFloor = false
		self.doubleJump = false
		self.canJump = true
		self.hasjumped = true
		love.audio.play(doublejumpsound)
	elseif self.falljump then
		self.ySpeed = self.jumpSpeed
		self.onFloor = false
		self.doubleJump = false
		self.canJump = true
		self.hasjumped = true
		love.audio.play(jumpsound)
	elseif self.hitWall then
		self.ySpeed = self.jumpSpeed * 0.5
		self.onFloor = false
		self.doubleJump = false
		self.canJump = true
		love.audio.play(doublejumpsound)
	end
end
 
function Player:moveRight()
    self.xSpeed = self.runSpeed
end
 
function Player:moveLeft()
    self.xSpeed = -1 * (self.runSpeed)
end
 
function Player:stop()
    self.xSpeed = 0
end
 
function Player:hitFloor(maxY)
    self.y = maxY - self.height
    self.ySpeed = 0
    self.canJump = true
end

function Player:check_lava(dt, gravity, map)
	local halfX = self.width / 2
    local halfY = self.height / 2

	local nextY = math.floor(self.y + (self.ySpeed * dt))
	local nextX = math.floor(self.x + (self.xSpeed * dt))
	if (self:hitLava(map, self.x - halfX, nextY - halfY))
        and (self:hitLava(map, self.x + halfX - 1, nextY - halfY)) then
			self.lavaKillsPlayer = true
    end
	if (self:hitLava(map, self.x - halfX, nextY + halfY))
		and (self:hitLava(map, self.x + halfX - 1, nextY + halfY)) then
			self.lavaKillsPlayer = true
	end
	if (self:hitLava(map, nextX + halfX, self.y - halfY))
		and (self:hitLava(map, nextX + halfX, self.y + halfY - 1)) then
			self.lavaKillsPlayer = true
    end
	if (self:hitLava(map, nextX - halfX, self.y - halfY))
		and (self:hitLava(map, nextX - halfX, self.y + halfY - 1)) then
			self.lavaKillsPlayer = true
    end
end

--[[
function Player:check_walljump(dt, gravity, map)
	local halfX = self.width / 2
    local halfY = self.height / 2

	local nextY = math.floor(self.y + (self.ySpeed * dt))
	local nextX = math.floor(self.x + (self.xSpeed * dt))
	if (self:isCollidingandJump(map, self.x - halfX, nextY - halfY))
        and (self:isCollidingandJump(map, self.x + halfX - 1, nextY - halfY)) then
        -- Osuma, siirrä lähimpään tilen rajaan
        self.y = nextY + map.tileHeight - ((nextY - halfY) % map.tileHeight)
        self:collide("ceiling")
		self.onFloor = true
    end
	if (self:isCollidingandJump(map, self.x - halfX, nextY + halfY))
        and (self:isCollidingandJump(map, self.x + halfX - 1, nextY + halfY)) then
        -- Osuma, siirrä lähimpään tilen rajaan
        self.y = nextY - ((nextY + halfY) % map.tileHeight)
        self:collide("floor")
    end
	if (self:isCollidingandJump(map, nextX + halfX, self.y - halfY))
        and (self:isCollidingandJump(map, nextX + halfX, self.y + halfY - 1)) then
        -- Ei osumaa, liiku normaalisti
        self.x = nextX - ((nextX + halfX) % map.tileWidth)
		self.hitWall = true
	elseif (self:isCollidingandJump(map, nextX - halfX, self.y - halfY))
        and (self:isCollidingandJump(map, nextX - halfX, self.y + halfY - 1)) then
        -- Osuma, siirrä lähimpään tilen rajaan ja pystyy kiipee seinillä
        self.x = nextX + map.tileWidth - ((nextX - halfX) % map.tileWidth)
		self.hitWall = true
	else
		self.hitWall = false
    end
end ]]--

function Player:calculate_player_y(dt, gravity, map)
	local halfX = self.width / 2
	local halfY = self.height / 2
	 
	local nextY = math.floor(self.y + (self.ySpeed * dt))
    if self.ySpeed < 0 then -- Tarkistaa ylöspäin
        if not(self:isColliding(map, self.x - halfX, nextY - halfY))
            and not(self:isColliding(map, self.x + halfX - 1, nextY - halfY)) then
            -- Ei osumaa, liiku normaalisti
            self.y = nextY
            self.onFloor = false
        else
            -- Osuma, siirrä lähimpään tilen rajaan
            self.y = nextY + map.tileHeight - ((nextY - halfY) % map.tileHeight)
            self:collide("ceiling")
			self.onFloor = true
        end
		
		-- Osuuko pelaaja kolikkoon(End) Y
		if (self:endThisLevel(map, self.x, nextY))
            and (self:endThisLevel(map, self.x - 1, nextY)) then
			self.endLevel = true
        end
		
		if (self:changeAntiGravity(map, self.x, nextY))
            and (self:changeAntiGravity(map, self.x - 1, nextY)) then
				self.antiGravity = true
				love.audio.play(gravitysound)
        end
		
		if (self:changeGravity(map, self.x, nextY))
            and (self:changeGravity(map, self.x - 1, nextY)) then
				self.antiGravity = false
				love.audio.play(gravitysound)
        end
		
    elseif self.ySpeed > 0 then -- Tarkistaa alaspäin
        if not(self:isColliding(map, self.x - halfX, nextY + halfY))
            and not(self:isColliding(map, self.x + halfX - 1, nextY + halfY)) then
            -- Ei osumaa, liiku normaalisti
            self.y = nextY
            self.onFloor = false
        else
            -- Osuma, siirrä lähimpään tilen rajaan
            self.y = nextY - ((nextY + halfY) % map.tileHeight)
            self:collide("floor")
			self.hasjumped = false
        end

		-- Osuuko pelaaja loppuun(End) Y
		if (self:endThisLevel(map, self.x, nextY))
            and(self:endThisLevel(map, self.x - 1, nextY)) then
				self.endLevel = true
        end
		
		if (self:changeAntiGravity(map, self.x, nextY))
            and(self:changeAntiGravity(map, self.x - 1, nextY)) then
				self.antiGravity = true
				love.audio.play(gravitysound)
        end
		if (self:changeGravity(map, self.x, nextY))
            and(self:changeGravity(map, self.x - 1, nextY)) then
				self.antiGravity = false
				love.audio.play(gravitysound)
        end
    end
end

function Player:calculate_player_x(dt, gravity, map)
	local halfX = self.width / 2
    local halfY = self.height / 2
	
	local nextX = math.floor(self.x + (self.xSpeed * dt))
    if self.xSpeed > 0 then -- Tarkistaa oikean
        if not(self:isColliding(map, nextX + halfX, self.y - halfY))
            and not (self:isColliding(map, nextX + halfX, self.y + halfY - 1)) then
            -- Ei osumaa, liiku normaalisti
            self.x = nextX
			self.hitWall = false
        else
            -- Osuma, siirrä lähimpään tilen rajaan
            self.x = nextX - ((nextX + halfX) % map.tileWidth)
			self.hitWall = true
        end
		
		if (self:endThisLevel(map, nextX, self.y))
            and (self:endThisLevel(map, nextX, self.y - 1)) then
				self.endLevel = true
        end
		
		if (self:changeAntiGravity(map, nextX, self.y))
            and (self:changeAntiGravity(map, nextX, self.y - 1)) then
				self.antiGravity = true
				love.audio.play(gravitysound)
        end
		
		if (self:changeGravity(map, nextX, self.y))
            and (self:changeGravity(map, nextX, self.y - 1)) then
				self.antiGravity = false
				love.audio.play(gravitysound)
        end
		
    elseif self.xSpeed < 0 then -- Tarkistaa vasemman
        if not(self:isColliding(map, nextX - halfX, self.y - halfY))
            and not(self:isColliding(map, nextX - halfX, self.y + halfY - 1)) then
            -- Ei osumaa, liiku normaalisti
            self.x = nextX
			self.hitWall = false
        else
            -- Osuma, siirrä lähimpään tilen rajaan
            self.x = nextX + map.tileWidth - ((nextX - halfX) % map.tileWidth)
			self.hitWall = true
        end
		
	-- Tarkistaa endLevel osuman
		if (self:endThisLevel(map, nextX, self.y))
            and (self:endThisLevel(map, nextX, self.y - 1)) then
				self.endLevel = true
        end
		
		if (self:changeAntiGravity(map, nextX, self.y))
            and (self:changeAntiGravity(map, nextX, self.y - 1)) then
				self.antiGravity = true
				love.audio.play(gravitysound)
        end
		
		if (self:changeGravity(map, nextX, self.y))
            and (self:changeGravity(map, nextX, self.y - 1)) then
				self.antiGravity = false
				love.audio.play(gravitysound)
        end
    end
end
 
-- Update funktio
function Player:update(dt, gravity, map)
    local halfX = self.width / 2
    local halfY = self.height / 2
    
    -- Lisää painovoima
    self.ySpeed = self.ySpeed + (gravity * dt)
    
    -- Rajoittaa maksiminopeutta
    self.xSpeed = math.clamp(self.xSpeed, -self.xSpeedMax, self.xSpeedMax)
    self.ySpeed = math.clamp(self.ySpeed, -self.ySpeedMax, self.ySpeedMax)
    
    -- Laskee Y sijainnin ja muuttaa tarvittaessa
    self:calculate_player_y(dt, gravity, map)

    -- Laskee X sijainnin ja muuttaa tarvittaessa
    self:calculate_player_x(dt, gravity, map)
	
	self:check_lava(dt, gravity, map)
	
	--self:check_walljump(dt, gravity, map)

    -- Päivittää pelaajan tilaa
    self.state = self:getState()
end

function Player:getState()
    local myState = ""
    if self.onFloor then
        if self.xSpeed > 0 then
            myState = "moveRight"
        elseif self.xSpeed < 0 then
            myState = "moveLeft"
        else
            myState = "stand"
        end
    end
    if self.ySpeed < 0 then
        myState = "jump"
		if self.antiGravity == true then
			if self.hasjumped == false then
				self.falljump = true
			elseif self.hasjumped == true then
				self.falljump = false
			end
		end
    elseif self.ySpeed > 0 then
        myState = "fall"
		if self.hasjumped == false then
			self.falljump = true
		elseif self.hasjumped == true then
			self.falljump = false
		end
    end
    return myState
end

function Player:isColliding(map, x, y)
    -- Haetaan tilen koordinaatit
    local layer = map.tl["Walls"]
	
	local tileX, tileY = math.floor(x / map.tileWidth), math.floor(y / map.tileHeight)
   
    -- Otetaan tile annetusta paikasta
    local tile = layer.tileData(tileX, tileY)
   
    -- Palauttaa truen kun pelaaja koskettaa tilen reunaa
    return not(tile == nil)
end

function Player:isCollidingandJump(map, x, y)
    -- Haetaan tilen koordinaatit
    local layer = map.tl["WallsJump"]
	
	local tileX, tileY = math.floor(x / map.tileWidth), math.floor(y / map.tileHeight)
   
    -- Otetaan tile annetusta paikasta
    local tile = layer.tileData(tileX, tileY)
   
    -- Palauttaa truen kun pelaaja koskettaa tilen reunaa
    return not(tile == nil)
end

function Player:collide(event)
    if event == "floor" then
        self.ySpeed = 0
        self.onFloor = true
    end
    if event == "ceiling" then
        self.ySpeed = 0
    end
end

function Player:hitLava(map, x, y)
	-- Haetaan tilen koordinaatit
    local layer = map.tl["Lava"]
	
	local tileX, tileY = math.floor(x / map.tileWidth), math.floor(y / map.tileHeight)
   
    -- Otetaan tile annetusta paikasta
    local tile = layer.tileData(tileX, tileY)
   
    -- Palauttaa truen kun pelaaja koskettaa tilen reunaa
    return not(tile == nil)
end

function Player:endThisLevel(map, x, y)
	-- Haetaan tilen koordinaatit
    local layer = map.tl["End"]
	
	local tileX, tileY = math.floor(x / map.tileWidth), math.floor(y / map.tileHeight)
   
    -- Otetaan tile annetusta paikasta
    local tile = layer.tileData(tileX, tileY)
   
    -- Palauttaa truen kun pelaaja osuu tileen
    return not(tile == nil)
end

function Player:changeAntiGravity(map, x, y)
	-- Haetaan tilen koordinaatit
    local layer = map.tl["Antigravity"]
	
	local tileX, tileY = math.floor(x / map.tileWidth), math.floor(y / map.tileHeight)
   
    -- Otetaan tile annetusta paikasta
    local tile = layer.tileData(tileX, tileY)
   
    -- Palauttaa truen kun pelaaja osuu tileen
    return not(tile == nil)
end

function Player:changeGravity(map, x, y)
	-- Haetaan tilen koordinaatit
    local layer = map.tl["Gravity"]
	
	local tileX, tileY = math.floor(x / map.tileWidth), math.floor(y / map.tileHeight)
   
    -- Otetaan tile annetusta paikasta
    local tile = layer.tileData(tileX, tileY)
   
    -- Palauttaa truen kun pelaaja osuu tileen
    return not(tile == nil)
end