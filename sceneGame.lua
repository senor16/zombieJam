---@param pX number
---@param pY number
---@param pSpeed number
function newElement(pX,pY,pSpeed)
    return  {
        x=pX,
        y=pY,
        vx=0,
        vy=0,
        flip=1,
        speed=pSpeed,
        listAnimations={},
        currentAnimation=nil,
        currentFrameInAnimation=1,
        timer=0,
        type = "UNDEFINED"
    }
end

---@param pListAnimations table
---@param pName string
---@param pImages table
---@param pSpeed number
---@param pLoop boolean
function addAnimation(pListAnimations, pName, pImages, pSpeed, pLoop)
    if (pListAnimations[pName]==nil) then
        pListAnimations[pName] = {
            frames = pImages,
            speed = pSpeed,
            loop = pLoop,
            ended = false
        }
    end
end

---@param pEntity table
---@param pName string
function playAnimation(pEntity,pName)
    if pEntity.listAnimations[pName]==nil  then
        print("Error ! : "..pName.." animation doesn't exist on entity of type "..pEntity.type)
    elseif pEntity.currentAnimation==nil or (pEntity.currentAnimation~=nil and pEntity.listAnimations[pName]~=pEntity.currentAnimation) then
            pEntity.currentAnimation =pEntity.listAnimations[pName]
            pEntity.currentFrameInAnimation = 1
            pEntity.timer=0
    end
end

---@param pEntity table
---@param dt number
function updateAnimation(pEntity,dt)
    if(pEntity.currentAnimation~=nil) then
        pEntity.timer = pEntity.timer+dt
        if(pEntity.timer >= pEntity.currentAnimation.speed) then
            pEntity.currentFrameInAnimation = pEntity.currentFrameInAnimation+1
            pEntity.timer = pEntity.timer - pEntity.currentAnimation.speed
            if pEntity.currentFrameInAnimation > #pEntity.currentAnimation.frames then
                if(pEntity.currentAnimation.loop) then
                    pEntity.currentFrameInAnimation = 1
                else
                    pEntity.currentFrameInAnimation = #pEntity.currentAnimation.frames
                    pEntity.currentAnimation.ended=true
                end
            end
        end
    end
end

function dist(x1,y1,x2,y2)
    return ((x2-x1)^2+(y2-y1)^2)^0.5
end

function math.angle(x1,y1, x2,y2)
    return math.atan2(y2-y1, x2-x1)
end

local sceneGame = {}
local hero = require("hero")
local zombieManager = require("zombieManager")
serviceManager = {}
serviceManager.hero = hero
serviceManager.zombieManager = zombieManager
function sceneGame:load()
    hero:load()
    zombieManager:addZombie(100,200,1)
    zombieManager:addZombie(200,200,2)
    zombieManager:addZombie(300,200,3)
    zombieManager:addZombie(400,200,4)
    zombieManager:load()
end

---@param dt number
function sceneGame:update(dt)
    hero:update(dt)
    zombieManager:update(dt)
end

function sceneGame:draw()
    hero:draw()
    zombieManager:draw()
end

return sceneGame
