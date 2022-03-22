--- Create a new zombie
---@param pX number
---@param pY number
---@param pLevel number
---@param pListAnimations table
---@return table
local function newZombie(pX, pY, pSpeed, pLevel, pListAnimations)
    local animation = ZS_WALK
    local chaos = { x = 0, y = 0 }
    local zombie = newElement(pX, pY, pSpeed)
    local angle = 0
    local oldX, oldY
    zombie.timerAttack = 0
    zombie.previousState = ""
    zombie.canRemove = false
    zombie.timerDisappear = 1
    zombie.type = "ZOMBIE"
    zombie.state = ZS_CHANGE
    zombie.level = pLevel
    zombie.target = nil
    zombie.range = math.random(40, 100)
    zombie.listAnimations = pListAnimations
    zombie.speed = pLevel * 3 / 1000
    zombie.energy = pLevel*2.5
    --- Update the zombie
    function zombie:load()
        playAnimation(self, animation)
    end

    --- Inflict damage to the zombie
    function zombie:hurt()
        self.energy = self.energy - 1
        self.state = ZS_HURT
        if self.energy <= 0 then
            self.state = ZS_DEAD
        end
    end

    --- Update the zombie
    function zombie:update(dt)
        updateAnimation(self, dt)
        -- Backup zombie position
        oldX = self.x
        oldY = self.y
        -- ZS_CHANGE
        if self.state == ZS_CHANGE then
            self.target = nil
            angle = math.angle(self.x, self.y, love.math.random(0, screen.width / 2), love.math.random(0, screen.height / 2))
            self.vx = self.speed * 60 * dt * math.cos(angle)
            self.vy = self.speed * 60 * dt * math.sin(angle)
            self.state = ZS_WALK
        end
        -- ZS_WALK
        if self.state == ZS_WALK then
            animation = ZS_WALK
            -- Look for the hero, then run at him
            if math.dist(self.x, self.y, serviceManager.hero.x, serviceManager.hero.y) <= zombie.range then
                self.state = ZS_RUN
                self.target = serviceManager.hero
            end

            if self.y - TILEHEIGHT / 2 < 0 then
                self.state = ZS_CHANGE
            end
            if self.x + TILEWIDTH / 2 > screen.width then
                self.state = ZS_CHANGE
            end
            if self.y + TILEHEIGHT / 2 > screen.height then
                self.state = ZS_CHANGE
            end
            if self.x - TILEHEIGHT / 2 < 0 then
                self.state = ZS_CHANGE
            end
        end
        -- ZS_RUN
        if self.state == ZS_RUN then
            if self.target ~= nil then
                animation = self.state
                -- Some chaos in the direction
                chaos.x = self.target.x + math.random(-10, 10)
                chaos.y = self.target.y + math.random(-10, 10)
                -- Run faster when got angry
                angle = math.angle(self.x, self.y, chaos.x, chaos.y)
                self.vx = self.speed * 2 * 60 * math.cos(angle)
                self.vy = self.speed * 2 * 60 * math.sin(angle)
                if math.dist(self.x, self.y, self.target.x, self.target.y) > self.range then
                    self.state = ZS_CHANGE
                end
                if math.dist(self.x, self.y, self.target.x, self.target.y) <= 5 then
                    self.state = ZS_ATTACK
                end
            end
        end
        -- ZS_ATTACK
        if self.state == ZS_ATTACK then
            animation = self.state
            if self.target ~= nil then
                if math.dist(self.x, self.y, self.target.x, self.target.y) <= 5 then
                    self.vx = 0
                    self.vy = 0
                    self.timerAttack = self.timerAttack - dt
                    if (self.timerAttack <= 0) then
                        self.target:hurt()
                        self.timerAttack = self.currentAnimation.speed * #self.currentAnimation.frames
                    end
                else
                    self.state = ZS_RUN
                end
            end
        end

        -- ZS_HURT
        if self.state == ZS_HURT then
            animation = ZS_HURT
            self.vx = 0
            self.vy = 0
            if self.currentAnimation.ended then
                self.state = ZS_CHANGE
            end
        end

        -- ZS_DEAD
        if self.state == ZS_DEAD then
            animation = ZS_DEAD
            self.vx = 0
            self.vy = 0
            -- Make the zombie ready to be remove from the zombie list
            if self.currentAnimation.ended then
                self.timerDisappear = self.timerDisappear - dt
                if self.timerDisappear <= 0 then
                    self.canRemove = true
                end
            end
        end

        playAnimation(self, animation)
        if self.vx < 0.5 then
            self.flip = -math.abs(self.flip)
        else
            self.flip = math.abs(self.flip)
        end

        self.x = self.x + self.vx
        self.y = self.y + self.vy
        ---- Check if the hero is not in a wall
        if self.state ~= ZS_DEAD then
            if isWall(getPosition(self.x - TILEWIDTH / 3, self.y - TILEHEIGHT / 3)) or isWall(getPosition(self.x + TILEWIDTH / 3, self.y + TILEHEIGHT / 3)) then
                -- If he is, bring him back
                self.x = oldX
                self.y = oldY
                self.state = ZS_CHANGE
            end
        end
    end

    --- Draw the zombie
    function zombie:draw()
        if self.currentAnimation ~= nil then
            love.graphics.setColor(1, 1, 1, self.timerDisappear)
            love.graphics.draw(self.currentAnimation.frames[self.currentFrameInAnimation], self.x, self.y, 0, self.flip, 1, TILEWIDTH / 2, TILEHEIGHT / 2)
            love.graphics.setColor(1, 1, 1, 1)
--             love.graphics.print(self.state, self.x, self.y - TILEHEIGHT)
--             love.graphics.circle("line", self.x, self.y, self.range)
            love.graphics.print(self.energy, self.x - TILEWIDTH / 1.5, self.y - TILEHEIGHT)
--             love.graphics.print(math.floor(math.dist(serviceManager.hero.x, serviceManager.hero.y, self.x, self.y)), self.x - TILEWIDTH, self.y - TILEHEIGHT)

        end
    end

    return zombie
end

local zombieManager = {
    listZombies = {},
    countTypes={0,0,0,0},
    currentFrameInAnimation=1
}
local listAnimations = {}
listAnimations[1] = {}
listAnimations[2] = {}
listAnimations[3] = {}
listAnimations[4] = {}

--- Add zombie animations according to each zombie level
local images = {}
for level = 1, #listAnimations do
    -- IDLE
    images = {}
    for i = 1, 4 do
        images[i] = love.graphics.newImage("vault/Zombies/Zombie" .. level .. "/animation/Idle" .. i .. ".png")
    end
    addAnimation(listAnimations[level], "IDLE", images, 1 / 8, true)

    -- ZS_WALK
    images = {}
    for i = 1, 6 do
        images[i] = love.graphics.newImage("vault/Zombies/Zombie" .. level .. "/animation/Walk" .. i .. ".png")
    end
    addAnimation(listAnimations[level], "ZS_WALK", images, 1 / 8, true)


    -- ZS_RUN
    images = {}
    for i = 1, 5 do
        images[i] = love.graphics.newImage("vault/Zombies/Zombie" .. level .. "/animation/Run" .. i + 5 .. ".png")
    end
    addAnimation(listAnimations[level], "ZS_RUN", images, 1 / 8, true)

    -- ZS_ATTACK
    images = {}
    for i = 1, 6 do
        images[i] = love.graphics.newImage("vault/Zombies/Zombie" .. level .. "/animation/Attack" .. i .. ".png")
    end
    addAnimation(listAnimations[level], "ZS_ATTACK", images, 1 / 8, true)

    -- ZS_HURT
    images = {}
    for i = 1, 5 do
        images[i] = love.graphics.newImage("vault/Zombies/Zombie" .. level .. "/animation/Hurt" .. i .. ".png")
    end
    addAnimation(listAnimations[level], "ZS_HURT", images, 1 / 8, false)

    -- ZS_DEAD
    images = {}
    for i = 1, 8 do
        images[i] = love.graphics.newImage("vault/Zombies/Zombie" .. level .. "/animation/Dead" .. i .. ".png")
    end
    addAnimation(listAnimations[level], "ZS_DEAD", images, 1 / 8, false)
end

local headAnimations={}

for level=1,4 do
    images = {}
    headAnimations[level]={}
    for i = 1, 6 do
        images[i] = love.graphics.newImage("vault/Zombies/Zombie" .. level .. "/animation/head" .. i .. ".png")
    end
    headAnimations[level] = images
end


--- Register a zombie to the zombie manager
function zombieManager:addZombie(pX, pY, pLevel)
    local speed = { 1, 2, 3, 4 }
    self.countTypes[pLevel] = self.countTypes[pLevel]+1
    local zombie = newZombie(pX, pY, speed[pLevel], pLevel, listAnimations[pLevel])
    table.insert(self.listZombies, zombie)
end

--- Load the zombie manager
function zombieManager:load()
    for i = 1, #self.listZombies do
        self.listZombies[i]:load()
    end
end

--- Update the zombie manager
function zombieManager:update(dt)
    self.currentFrameInAnimation = self.currentFrameInAnimation+1/12
    if self.currentFrameInAnimation > 6 then
        self.currentFrameInAnimation = self.currentFrameInAnimation -5
    end

    for i = #self.listZombies, 1, -1 do
        self.listZombies[i]:update(dt)
        local zom = self.listZombies[i]
        -- Look at others zombie
        -- If anyone found the hero, then follow that zombie
        for j=#self.listZombies,1,-1 do
            if i~= j then
                local z = self.listZombies[j]
                if math.dist(zom.x, zom.y, z.x,z.y) <= zom.range*2 and z.state== ZS_RUN and zom.state ~= ZS_ATTACK and zom.state~= ZS_DEAD then
                    zom.state = ZS_RUN
                    zom.target = z.target
                    break
                end
            end
        end

        if self.listZombies[i].canRemove then
            self.countTypes[self.listZombies[i].level] = self.countTypes[self.listZombies[i].level] -1
            table.remove(self.listZombies, i)
        end
    end
end

--- Draw the zombie manager
function zombieManager:draw()
    for i = 1, #self.listZombies do
        self.listZombies[i]:draw()
    end


    -- GUI:
    -- Show how many zombie is left
    love.graphics.draw(headAnimations[1][math.floor(self.currentFrameInAnimation)],10,525)
    love.graphics.print(self.countTypes[1],50,535)
    love.graphics.draw(headAnimations[2][math.floor(self.currentFrameInAnimation)],80,525)
    love.graphics.print(self.countTypes[2],120,535)
    love.graphics.draw(headAnimations[3][math.floor(self.currentFrameInAnimation)],160,525)
    love.graphics.print(self.countTypes[3],200,535)
    love.graphics.draw(headAnimations[4][math.floor(self.currentFrameInAnimation)],240,525)
    love.graphics.print(self.countTypes[4],275,535)

end

return zombieManager
