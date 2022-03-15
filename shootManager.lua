local function newShoot(pX, pY, pVx, pVy, pRotation, pImage)
    local shoot = {
        x = pX,
        y = pY,
        vx = pVx,
        vy = pVy,
        rotation = pRotation,
        image = pImage
    }

    function shoot:load()

    end

    function shoot:update(dt)
        self.x = self.x + self.vx
        self.y = self.y + self.vy
    end

    function shoot:draw()
        love.graphics.draw(self.image, self.x, self.y, self.rotation, 1, 1, self.image:getWidth()/2,self.image:getHeight()/2)

    end
    return shoot
end

local shootManager = {
    listShoots={}
}
function shootManager:load()
    self.image = love.graphics.newImage("vault/Hero/shoot.png")
end

function shootManager:addShoot(pX,pY,pVx,pVy,pRotation)
    local shoot = newShoot(pX,pY,pVx,pVy,pRotation,self.image)
    table.insert(self.listShoots,shoot)
    print("Shoot "..#self.listShoots)

end

function shootManager:update(dt)
    for i=#self.listShoots, 1, -1 do
        local shoot = self.listShoots[i]
        shoot:update(dt)

    end
end

function shootManager:draw()
    for i=1, #self.listShoots do
        self.listShoots[i]:draw()
    end
end

return shootManager
