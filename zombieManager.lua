local function newZombie(pX, pY, pSpeed, pLevel, pListAnimations)
    local zombie = newElement(pX, pY, pSpeed)
    zombie.type = "ZOMBIE"
    zombie.level = pLevel
    zombie.listAnimations = pListAnimations

    function zombie:load()
        playAnimation(self, "WALK")
    end

    function zombie:update(dt)
        updateAnimation(self, dt)
    end

    function zombie:draw()
        if self.currentAnimation ~= nil then
            love.graphics.draw(self.currentAnimation.frames[self.currentFrameInAnimation], self.x, self.y, 0, self.flip, 1, TILEWIDTH / 2, TILEHEIGHT / 2)

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
        images[i] = love.graphics.newImage("vault/Zombies/Zombie"..level.."/animation/Idle" .. i .. ".png")
    end
    addAnimation(listAnimations[level], "IDLE", images, 1 / 8, true)

    -- WALK
    images = {}
    for i = 1, 6 do
        images[i] = love.graphics.newImage("vault/Zombies/Zombie"..level.."/animation/Walk" .. i .. ".png")
    end
    addAnimation(listAnimations[level], "WALK", images, 1 / 8, true)


    -- RUN
    images = {}
    for i = 1, 5 do
        images[i] = love.graphics.newImage("vault/Zombies/Zombie"..level.."/animation/Run" .. i + 5 .. ".png")
    end
    addAnimation(listAnimations[level], "RUN", images, 1 / 8, true)

    -- ATTACK
    images = {}
    for i = 1, 6 do
        images[i] = love.graphics.newImage("vault/Zombies/Zombie"..level.."/animation/Attack" .. i .. ".png")
    end
    addAnimation(listAnimations[level], "ATTACK", images, 1 / 8, true)

    -- HURT
    images = {}
    for i = 1, 5 do
        images[i] = love.graphics.newImage("vault/Zombies/Zombie"..level.."/animation/Hurt" .. i .. ".png")
    end
    addAnimation(listAnimations[level], "HURT", images, 1 / 8, false)

    -- DEAD
    images = {}
    for i = 1, 8 do
        images[i] = love.graphics.newImage("vault/Zombies/Zombie"..level.."/animation/Dead" .. i .. ".png")
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