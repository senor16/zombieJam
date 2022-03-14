---@param pEntity table
---@param pName string
---@param pImages table
---@param pSpeed number
---@param pLoop boolean
function addAnimation(pEntity, pName, pImages, pSpeed, pLoop)
    if (pEntity.listAnimations[pName]==nil) then
        pEntity.listAnimations[pName] = {
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
    if(pEntity.currentAnimation==nil or (pEntity.listAnimations[pName]~=nil and pEntity.listAnimations[pName]~=pEntity.currentAnimation)) then
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

local sceneGame = {}
local hero = require("hero")
function sceneGame:load()
    hero:load()
end

---@param dt number
function sceneGame:update(dt)
    hero:update(dt)
end

function sceneGame:draw()
    hero:draw()
end

return sceneGame
