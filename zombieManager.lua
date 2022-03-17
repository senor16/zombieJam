local WALK = "WALK"
local RUN = "RUN"
local ATTACK = "ATTACK"
local HURT = "HURT"
local DEAD = "DEAD"
local CHANGE = "CHANGE"
local function newZombie(pX, pY, pSpeed, pLevel, pListAnimations)
    local animation = WALK
    local chaos = { x = 0, y = 0 }
    local zombie = newElement(pX, pY, pSpeed)
    local angle = 0
    zombie.type = "ZOMBIE"
    zombie.state = CHANGE
    zombie.level = pLevel
    zombie.target = nil
    zombie.range = math.random(30, 120)
    zombie.listAnimations = pListAnimations
    zombie.speed = math.random(5, 30) / 500
    function zombie:load()
        playAnimation(self, animation)
    end

    function zombie:update(dt)
        updateAnimation(self, dt)
        -- CHANGE
        if self.state == CHANGE then
            self.target = nil
            angle = math.angle(self.x, self.y, love.math.random(0, screen.width / 2), love.math.random(0, screen.height / 2))
            self.vx = self.speed * 60 * dt * math.cos(angle)
            self.vy = self.speed * 60 * dt * math.sin(angle)
            if self.vx <= 0 then
                self.flip = -math.abs(self.flip)
            else
                self.flip = math.abs(self.flip)
            end
            self.state = WALK
            -- WALK
        elseif self.state == WALK then
            animation = WALK
            print(self.vx)
            if math.dist(self.x, self.y, serviceManager.hero.x, serviceManager.hero.y) <= zombie.range then
                self.state = RUN
                self.target=serviceManager.hero
            end

            if self.y - TILEHEIGHT / 2 < 0 then
                self.state = CHANGE
            end
            if self.x + TILEWIDTH / 2 > screen.width then
                self.flip = 1
                self.state = CHANGE
            end
            if self.y + TILEHEIGHT / 2 > screen.height then
                self.state = CHANGE
            end
            if self.x - TILEHEIGHT / 2 < 0 then
                self.flip = -1
                self.state = CHANGE
            end
            -- RUN
        elseif self.state == RUN then
            if self.target ~= nil then
                animation = RUN
                -- Some chaos in the direction
                chaos.x = self.target.x + math.random(-10, 10)
                chaos.y = self.target.y + math.random(-10, 10)
                -- Run faster when got angry
                angle = math.angle(self.x, self.y, chaos.x, chaos.y)
                self.vx = self.speed * 2 * 60 * math.cos(angle)
                self.vy = self.speed * 2 * 60 * math.sin(angle)
                if math.dist(self.x, self.y, self.target.x, self.target.y) > self.range then
                    self.state=CHANGE
                end
                if math.dist(self.x, self.y, self.target.x, self.target.y) <= 5 then
                    self.state = ATTACK
                end
            end
            -- ATTACK
        elseif self.state == ATTACK then
            animation = ATTACK
            if self.target ~= nil then
                if math.dist(self.x, self.y, self.target.x, self.target.y) <= 5 then
                    self.vx = 0
                    self.vy = 0
                    if(self.x>self.target.x) or self.x < self.target.x then

                    end
                else
                    self.state = RUN
                end
            end
        end
        playAnimation(self, animation)
        self.x = self.x + self.vx
        self.y = self.y + self.vy
    end

    function zombie:draw()
        if self.currentAnimation ~= nil then
            love.graphics.draw(self.currentAnimation.frames[self.currentFrameInAnimation], self.x, self.y, 0, self.flip, 1, TILEWIDTH / 2, TILEHEIGHT / 2)
            love.graphics.print(self.state, self.x, self.y - TILEHEIGHT)
            love.graphics.circle("line", self.x, self.y, self.range)
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

function zombieManager:addZombie(pX, pY, pLevel)
    local speed = { 1, 2, 3, 4 }
    local zombie = newZombie(pX, pY, speed[pLevel], pLevel, listAnimations[pLevel])
    table.insert(self.listZombies, zombie)
end

function zombieManager:load()
    for i = 1, #self.listZombies do
        self.listZombies[i]:load()
    end
end

function zombieManager:update(dt)
    for i = 1, #self.listZombies do
        self.listZombies[i]:update(dt)
    end
end

function zombieManager:draw()
    for i = 1, #self.listZombies do
        self.listZombies[i]:draw()
    end
end

return zombieManager