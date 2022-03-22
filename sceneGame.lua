-- constants
ZS_WALK = "ZS_WALK"
ZS_RUN = "ZS_RUN"
ZS_ATTACK = "ZS_ATTACK"
ZS_HURT = "ZS_HURT"
ZS_DEAD = "ZS_DEAD"
ZS_CHANGE = "ZS_CHANGE"

--- Create a new element
---@param pX number
---@param pY number
---@param pSpeed number
function newElement(pX, pY, pSpeed)
    return {
        x = pX,
        y = pY,
        vx = 0,
        vy = 0,
        flip = 1,
        energy = 10,
        speed = pSpeed,
        listAnimations = {},
        currentAnimation = nil,
        currentFrameInAnimation = 1,
        timer = 0,
        type = "UNDEFINED"
    }
end

--- Add an animation to an element
---@param pListAnimations table
---@param pName string
---@param pImages table
---@param pSpeed number
---@param pLoop boolean
function addAnimation(pListAnimations, pName, pImages, pSpeed, pLoop)
    if (pListAnimations[pName] == nil) then
        pListAnimations[pName] = {
            frames = pImages,
            speed = pSpeed,
            loop = pLoop,
            ended = false
        }
    end
end

--- Play a given animation
---@param pEntity table
---@param pName string
function playAnimation(pEntity, pName)
    if pEntity.listAnimations[pName] == nil then
        print("Error ! : " .. pName .. " animation doesn't exist on entity of type " .. pEntity.type)
    elseif pEntity.currentAnimation == nil or pEntity.listAnimations[pName] ~= pEntity.currentAnimation then
        pEntity.currentAnimation = pEntity.listAnimations[pName]
        pEntity.currentFrameInAnimation = 1
        pEntity.timer = 0
        pEntity.currentAnimation.ended = false
    end
end

--- Update animation frames
---@param pEntity table
---@param dt number
function updateAnimation(pEntity, dt)
    if (pEntity.currentAnimation ~= nil) then
        pEntity.timer = pEntity.timer + dt
        if (pEntity.timer >= pEntity.currentAnimation.speed) then
            pEntity.currentFrameInAnimation = pEntity.currentFrameInAnimation + 1
            pEntity.timer = pEntity.timer - pEntity.currentAnimation.speed
            if pEntity.currentFrameInAnimation > #pEntity.currentAnimation.frames then
                if (pEntity.currentAnimation.loop) then
                    pEntity.currentFrameInAnimation = 1
                else
                    pEntity.currentFrameInAnimation = #pEntity.currentAnimation.frames
                    pEntity.currentAnimation.ended = true
                end
            end
        end
    end
end

--- Check whether to elements are colliding
---@param x1 number
---@param x2 number
---@param y1 number
---@param y2 number
---@param w1 number
---@param w2 number
---@param h1 number
---@param h2 number
function isColliding(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1
end

local sceneGame = {}
local hero = require("hero")
local zombieManager = require("zombieManager")
local shootManager = require("shootManager")
local image
local quads = {}
local id = 1
local x, y = 0, 0
local map
local background
local wall, entities
local sprite = 0
local tile
local currentLevel = 1
local maxLevel = 3
local victory = false
local gameComplete = false
local start = false
serviceManager = {}

--- Get object position in the map
---@param pX number
---@param pY number
function getPosition(pX, pY)
    local col = math.floor(pX / map.tilewidth) + 1
    local line = math.floor(pY / map.tileheight) + 1
    return (line - 1) * map.width + col
end

--- Check is a tile is a wall
---@param pNum number
function isWall(pNum)
    return wall.data[pNum] ~= 0
end

function loadZombies()
    id = 1
    for l = 1, map.height do
        for c = 1, map.width do
            if entities.data[id] == 16 then

                zombieManager:addZombie((c - 1) * TILEWIDTH + TILEWIDTH / 2, (l - 1) * TILEHEIGHT + TILEHEIGHT / 2, 1)
            elseif entities.data[id] == 146 or entities.data[id] == 36 then
                zombieManager:addZombie((c - 1) * TILEWIDTH + TILEWIDTH / 2, (l - 1) * TILEHEIGHT + TILEHEIGHT / 2, 2)
            elseif entities.data[id] == 186 or entities.data[id] == 18 then
                zombieManager:addZombie((c - 1) * TILEWIDTH + TILEWIDTH / 2, (l - 1) * TILEHEIGHT + TILEHEIGHT / 2, 3)
            elseif entities.data[id] == 171 then

                zombieManager:addZombie((c - 1) * TILEWIDTH + TILEWIDTH / 2, (l - 1) * TILEHEIGHT + TILEHEIGHT / 2, 4)
            end
            id = id + 1
        end
    end
end

function loadLevel(pLevel)
    map = require("vault/levels/level" .. pLevel)
    background = map.layers[1]
    tile = map.tilesets[1]
    wall = map.layers[2]
    entities = map.layers[3]
    image = love.graphics.newImage(tile.image)
    id = 1
    quads = {}
    y = 0
    for j = 1, tile.imageheight / TILEHEIGHT do
        x = 0
        for i = 1, tile.columns do
            quads[id] = love.graphics.newQuad(x, y, map.tilewidth, map.tileheight, image:getWidth(), image:getHeight())
            id = id + 1
            x = x + map.tilewidth
        end
        y = y + map.tileheight
    end
end

--- Load the game scene
function sceneGame:load()
    hero:load()
    if currentLevel == 1 then
        hero:reset(32 * 2, 32 * 14)
    elseif currentLevel == 2 then
        hero:reset(32, 32)
    elseif currentLevel == 3 then
        hero:reset(32 * 2, 32*8)
    end
    serviceManager.hero = hero
    serviceManager.zombieManager = zombieManager
    serviceManager.shootManager = shootManager
    zombieManager:load()
    shootManager:load()
    loadLevel(currentLevel)
    loadZombies()
end

--- Update the game scene
---@param dt number
function sceneGame:update(dt)
    if start then
        hero:update(dt)
        zombieManager:update(dt)
        shootManager:update(dt)
        if #zombieManager.listZombies <= 0 then
            victory = true
        end
    end
end

function drawMap()
    x, y = 0, 0
    id = 1
    for j = 1, background.height do
        x = 0
        for i = 1, background.width do
            sprite = background.data[id]
            if sprite ~= 0 then
                love.graphics.draw(image, quads[sprite], x, y)
            end
            sprite = wall.data[id]
            if sprite ~= 0 then
                love.graphics.draw(image, quads[sprite], x, y)
            end

            id = id + 1
            x = x + map.tilewidth
        end
        y = y + map.tileheight
    end

end

--- Draw the game scene
function sceneGame:draw()
    drawMap()
    if start then
        zombieManager:draw()
        shootManager:draw()
        hero:draw()
        if hero.dead then
            love.graphics.setFont(font50)
            love.graphics.print("Vous êtes mort :(", 100, 190)
            love.graphics.setFont(font30)
            love.graphics.print("Appuiyez sur Entrer pour réessayer", 80, 280)
            love.graphics.setFont(font12)
        end

        if victory and not gameComplete then
            love.graphics.setColor(0, 0, 0, .5)
            love.graphics.rectangle("fill", 0, 0, screen.width, screen.height)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.setFont(font50)
            love.graphics.print("Niveau complété", 100, 170)
            love.graphics.setFont(font30)
            love.graphics.print("Appuiyez sur Entrer pour continuer", 80, 280)
            love.graphics.setFont(font12)
        end

        if gameComplete then
            love.graphics.setColor(0, 0, 0, .5)
            love.graphics.rectangle("fill", 0, 0, screen.width, screen.height)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.setFont(font50)
            love.graphics.print("Vous avez terminé le jeu :)", 30, 170)
            love.graphics.setFont(font30)
            love.graphics.print("Merci d'y avoir joué", 190, 280)
            love.graphics.setFont(font12)
        end
    else
        love.graphics.setColor(0, 0, 0, .5)
        love.graphics.rectangle("fill", 0, 0, screen.width, screen.height)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(font70)
        love.graphics.print("ZOMBIE JAM", 150, 30)
        love.graphics.setFont(font40)
        love.graphics.print("PAR Sesso Kosga ", 190, 170)
        love.graphics.setFont(font30)
        love.graphics.print("Appuiyez sur Entrer", 190, 280)
        love.graphics.setFont(font12)
    end
end

function sceneGame:keypressed(key)
    if start then
        if hero.dead then
            if key == "return" then
                zombieManager:clean()
                loadZombies()
                if currentLevel == 1 then
                    hero:reset(32 * 2, 32 * 14)
                elseif currentLevel == 2 then
                    hero:reset(32, 32)
                elseif currentLevel == 3 then
                    hero:reset(32 * 2, 32*8)
                end
            end
        end
        if victory then
            if key == "return" then
                if currentLevel < maxLevel then
                    currentLevel = currentLevel + 1
                    zombieManager:clean()
                    if currentLevel == 1 then
                        hero:reset(32 * 2, 32 * 14)
                    elseif currentLevel == 2 then
                        hero:reset(32, 32)
                    elseif currentLevel == 3 then
                        hero:reset(32 * 2, 32*8)
                    end
                    victory = false
                    loadLevel(currentLevel)
                    loadZombies()
                else
                    gameComplete = true
                end
            end
        end
    else
        if key == "return" then
            start = true
        end
    end
end

return sceneGame
