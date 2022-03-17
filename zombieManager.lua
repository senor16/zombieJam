local WALK = "WALK"
local RUN = "RUN"
local ATTACK = "ATTACK"
local HURT = "HURT"
local DEAD = "DEAD"
local CHANGE = "CHANGE"

--- Create a new zombie
---@param pX number
---@param pY number
---@param pLevel number
---@param pListAnimations table
---@return table
local function newZombie(pX, pY, pSpeed, pLevel, pListAnimations)
    local animation = WALK
    local chaos = { x = 0, y = 0 }
    local zombie = newElement(pX, pY, pSpeed)
    local angle = 0
    zombie.timerAttack = 0
    zombie.previousState = ""
    zombie.type = "ZOMBIE"
    zombie.state = CHANGE
    zombie.level = pLevel
    zombie.target = nil
    zombie.range = math.random(30, 120)
    zombie.listAnimations = pListAnimations
    zombie.speed = pLevel * 5 / 1000

    --- Update the zombie
    function zombie:load()
        playAnimation(self, animation)
    end

    --- Inflict damage to the zombie
    function zombie:hurt()
        self.energy = self.energy - 1
        self.state = HURT
    end

    --- Update the zombie
    function zombie:update(dt)
        updateAnimation(self, dt)

        -- CHANGE
        if self.state == CHANGE then
            self.target = nil
            angle = math.angle(self.x, self.y, love.math.random(0, screen.width / 2), love.math.random(0, screen.height / 2))
            self.vx = self.speed * 60 * dt * math.cos(angle)
            self.vy = self.speed * 60 * dt * math.sin(angle)
            self.state = WALK
        end
        -- WALK
        if self.state == WALK then
            animation = WALK
            if math.dist(self.x, self.y, serviceManager.hero.x, serviceManager.hero.y) <= zombie.range then
                self.state = RUN
                self.target = serviceManager.hero
            end

            if self.y - TILEHEIGHT / 2 < 0 then
                self.state = CHANGE
            end
            if self.x + TILEWIDTH / 2 > screen.width then
                self.state = CHANGE
            end
            if self.y + TILEHEIGHT / 2 > screen.height then
                self.state = CHANGE
            end
            if self.x - TILEHEIGHT / 2 < 0 then
                self.state = CHANGE
            end
        end
        -- RUN
        if self.state == RUN then
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
                    self.state = CHANGE
                end
                if math.dist(self.x, self.y, self.target.x, self.target.y) <= 5 then
                    self.state = ATTACK
                end
            end
        end
        -- ATTACK
        if self.state == ATTACK then
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
                    self.state = RUN
                end
            end
        end

        -- HURT
        if self.state == HURT then
            animation = HURT
            self.vx = 0
            self.vy = 0
            if self.currentAnimation.ended then
                self.state = CHANGE
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
    end

    --- Draw the zombie
    function zombie:draw()
        if self.currentAnimation ~= nil then
            love.graphics.draw(self.currentAnimation.frames[self.currentFrameInAnimation], self.x, self.y, 0, self.flip, 1, TILEWIDTH / 2, TILEHEIGHT / 2)
            love.graphics.print(self.state, self.x, self.y - TILEHEIGHT)
            --love.graphics.circle("line", self.x, self.y, self.range)
            love.graphics.print(self.energy, self.x - TILEWIDTH/1.5, self.y - TILEHEIGHT)
            --love.graphics.print(math.floor(math.dist(serviceManager.hero.x,serviceManager.hero.y,self.x,self.y)), self.x - TILEWIDTH, self.y - TILEHEIGHT)

        end
    end

    return zombie
end

local zombieManager = {
    listZombies = {}
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

    -- WALK
    images = {}
    for i = 1, 6 do
        images[i] = love.graphics.newImage("vault/Zombies/Zombie" .. level .. "/animation/Walk" .. i .. ".png")
    end
    addAnimation(listAnimations[level], "WALK", images, 1 / 8, true)


    -- RUN
    images = {}
    for i = 1, 5 do
        images[i] = love.graphics.newImage("vault/Zombies/Zombie" .. level .. "/animation/Run" .. i + 5 .. ".png")
    end
    addAnimation(listAnimations[level], "RUN", images, 1 / 8, true)

    -- ATTACK
    images = {}
    for i = 1, 6 do
        images[i] = love.graphics.newImage("vault/Zombies/Zombie" .. level .. "/animation/Attack" .. i .. ".png")
    end
    addAnimation(listAnimations[level], "ATTACK", images, 1 / 8, true)

    -- HURT
    images = {}
    for i = 1, 5 do
        images[i] = love.graphics.newImage("vault/Zombies/Zombie" .. level .. "/animation/Hurt" .. i .. ".png")
    end
    addAnimation(listAnimations[level], "HURT", images, 1 / 8, false)

    -- DEAD
    images = {}
    for i = 1, 8 do
        images[i] = love.graphics.newImage("vault/Zombies/Zombie" .. level .. "/animation/Dead" .. i .. ".png")
    end
    addAnimation(listAnimations[level], "DEAD", images, 1 / 8, false)

end

--- Register a zombie to the zombie manager
function zombieManager:addZombie(pX, pY, pLevel)
    local speed = { 1, 2, 3, 4 }
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
    for i = 1, #self.listZombies do
        self.listZombies[i]:update(dt)
    end
end

--- Draw the zombie manager
function zombieManager:draw()
    for i = 1, #self.listZombies do
        self.listZombies[i]:draw()
    end
end

return zombieManager