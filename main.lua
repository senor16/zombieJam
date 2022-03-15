-- Afficher les traces dans la console
io.stdout:setvbuf("no")
-- Pour faire du pixel art
love.graphics.setDefaultFilter("nearest")
screen = {}
TILEWIDTH=32
TILEHEIGHT=32

local currentScene = "GAME"
local sceneGame = require("sceneGame")

function love.load()
    screen.width = love.graphics.getWidth()
    screen.height = love.graphics.getHeight()
    love.window.setTitle("Zombie Jam")
    if currentScene == "GAME" then
        sceneGame:load()
    end
end

---@param dt number
function love.update(dt)
    if currentScene == "GAME" then
        sceneGame:update(dt)
    end
end

function love.draw()
    if currentScene == "GAME" then
        sceneGame:draw()
    end
end

---@param key string
function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
