function love.load()
      g = love.graphics
      playerColor = {255,0,128}
      groundColor = {25,200,25}
 
      xPos = 300
      yPos = 300
      playerWidth = 25
      playerHeight = 40
      xVelocity = 0
      yVelocity = 0
      playerState = "stand"
 
      playerJumpVelocity = -800
      runSpeed = 500
 
      gravity = 1800
 
      yFloor = 500
end
 
function love.update(dt)
      -- move left and right
      if love.keyboard.isDown("right") then
            xVelocity = runSpeed
      end
      if love.keyboard.isDown("left") then
            xVelocity = -1 * runSpeed
      end
     
      -- if the x key is pressed...
      if not(playerState == "jump") and love.keyboard.isDown("x") then
      -- make the player jump
            yVelocity = playerJumpVelocity
            playerState = "jump"
      end
 
      -- update the player's position
      xPos = xPos + (xVelocity * dt)
      yPos = yPos + (yVelocity * dt)
 
      -- apply gravity
      yVelocity = yVelocity + (gravity * dt)
 
      -- stop the player when they hit the ground
      if yPos >= yFloor - playerHeight then
            yPos = yFloor - playerHeight
            yVelocity = 0
            playerState = "stand"
      end
end
 
function love.draw()
      -- draw the player shape
      g.setColor(playerColor)
      g.rectangle("fill", xPos, yPos, playerWidth, playerHeight)
 
      -- draw the ground
      g.setColor(groundColor)
      g.rectangle("fill", 100, yFloor, 800, 100)
	  
end
 
function love.keyreleased(key)
      if key == "escape" then
            love.event.quit()  -- actually causes the app to quit
      end
      if (key == "right") or (key == "left") then
            xVelocity = 0
      end
end