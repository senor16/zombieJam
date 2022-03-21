local hero = newElement(100, 100, 6)
hero.type = "HERO"
hero.shootTimer = 0
hero.shootTimerMax = .3
hero.range = 120
local animation = "IDLE"
local zombie
local dist
local oldX, oldY
local target = { id = 0, dist = 8000 }
local fired = false
local shoot = { vx = 0, vy = 0, angle = 0 }
function hero:load()
    local images = {}
    --- Add animations
    -- IDLE
    for i = 0, 11 do
        if i <= 9 then
            images[i] = love.graphics.newImage("vault/Hero/Animations/Idle/Idle_00" .. i .. ".png")
        else
            images[i] = love.graphics.newImage("vault/Hero/Animations/Idle/Idle_0" .. i .. ".png")
        end
    end
    addAnimation(self.listAnimations, "IDLE", images, 1 / 25, true)

    -- RUN
    images = {}
    for i = 0, 13 do
        if i <= 9 then
            images[i] = love.graphics.newImage("vault/Hero/Animations/Run/Run_00" .. i .. ".png")
        else
            images[i] = love.graphics.newImage("vault/Hero/Animations/Run/Run_0" .. i .. ".png")
        end
    end
    addAnimation(self.listAnimations, "RUN", images, 1 / 25, true)

    -- SHOOT
    images = {}
    for i = 0, 14 do
        if i <= 9 then
            images[i] = love.graphics.newImage("vault/Hero/Animations/Shoot/Shoot_00" .. i .. ".png")
        else
            images[i] = love.graphics.newImage("vault/Hero/Animations/Shoot/Shoot_0" .. i .. ".png")
        end
    end
    addAnimation(self.listAnimations, "SHOOT", images, 1 / 25, true)

    -- HURT
    images = {}
    for i = 0, 9 do
        images[i] = love.graphics.newImage("vault/Hero/Animations/Hurt/Hurt_00" .. i .. ".png")
    end
    addAnimation(self.listAnimations, "HURT", images, 1 / 25, true)

    -- DEATH
    images = {}
    for i = 0, 14 do
        if i <= 9 then
            images[i] = love.graphics.newImage("vault/Hero/Animations/Death/Death_00" .. i .. ".png")
        else
            images[i] = love.graphics.newImage("vault/Hero/Animations/Death/Death_0" .. i .. ".png")
        end
    end
    addAnimation(self.listAnimations, "DEATH", images, 1 / 25, true)

    playAnimation(self, "IDLE")
end

--- Hurt the hero
function hero:hurt()
    self.energy = self.energy - 1
    playAnimation(self, "HURT")
end

--- Update the hero
---@param dt number
function hero:update(dt)
    animation = "IDLE"
    -- Hero movement
    self.vx = 0
    self.vy = 0
    -- Backup hero position
    oldX = self.x
    oldY = self.y
    if love.keyboard.isDown("up") and self.y - TILEHEIGHT / 2 > 0 then
        self.vy = -self.speed * 60 * dt
        animation = "RUN"
    end
    if love.keyboard.isDown("right") and self.x + TILEWIDTH / 2 < screen.width then
        self.vx = self.speed * 60 * dt
        self.flip = 1
        animation = "RUN"
    end
    if love.keyboard.isDown("down") and self.y + TILEHEIGHT / 2 < screen.height then
        self.vy = self.speed * 60 * dt
        animation = "RUN"
    end
    if love.keyboard.isDown("left") and self.x - TILEHEIGHT / 2 > 0 then
        self.vx = -self.speed * 60 * dt
        self.flip = -1
        animation = "RUN"
    end
    self.x = self.x + self.vx
    self.y = self.y + self.vy
    ---- Check if the hero is not in a wall
    if isWall(getPosition(self.x-TILEWIDTH/3, self.y-TILEHEIGHT/3)) or isWall(getPosition(self.x+TILEWIDTH/3, self.y+TILEHEIGHT/3)) then
        -- If he is, bring him back
        self.x = oldX
        self.y = oldY
    end

    -- Hero animation
    updateAnimation(self, dt)

    --- Shoot at zombies
    self.shootTimer = self.shootTimer - dt
    if love.keyboard.isDown("space") then
        fired = false
        if self.shootTimer <= 0 then
            -- Find the nearest zombie
            target.dist = 9000
            target.id = 0
            for z = #serviceManager.zombieManager.listZombies, 1, -1 do
                zombie = serviceManager.zombieManager.listZombies[z]
                dist = math.dist(zombie.x, zombie.y, self.x, self.y)
                if dist < self.range then
                    if target.dist > dist then
                        target.dist = dist
                        target.id = z
                    end
                end
            end
            -- Shoot a the nearest zombie
            zombie = serviceManager.zombieManager.listZombies[target.id]
            if zombie ~= nil then
                shoot.angle = math.angle(self.x, self.y, zombie.x, zombie.y)
                shoot.vx = 4 * math.cos(shoot.angle)
                shoot.vy = 4 * math.sin(shoot.angle)
                if shoot.vx <= 0 then
                    self.flip = -math.abs(self.flip)
                else
                    self.flip = math.abs(self.flip)
                end
                serviceManager.shootManager:addShoot(self.x, self.y, shoot.vx, shoot.vy, shoot.angle)
                fired = true
            end
            if fired == false then
                if self.flip < 0 then
                    angle = math.rad(180)
                else
                    angle = 0
                end
                serviceManager.shootManager:addShoot(self.x, self.y, self.flip * 4, 0, angle)
            end
            self.shootTimer = self.shootTimerMax
        end
        animation = "SHOOT"
    end

    playAnimation(self, animation)
end

--- Draw the hero
function hero:draw  ()
    if self.currentAnimation ~= nil then
        love.graphics.draw(self.currentAnimation.frames[self.currentFrameInAnimation], self.x, self.y, 0, self.flip, 1, TILEWIDTH / 2, TILEHEIGHT / 2)
        love.graphics.circle("line", self.x, self.y, self.range)
        love.graphics.print(self.energy, self.x, self.y - TILEHEIGHT)
        for i = 1, #serviceManager.zombieManager.listZombies do
            zombie = serviceManager.zombieManager.listZombies[i]
            love.graphics.line(self.x, self.y, zombie.x, zombie.y)
        end
    end
end

return hero