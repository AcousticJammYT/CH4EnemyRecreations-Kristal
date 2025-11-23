local DarkShapeTest, super = Class(Wave)

function DarkShapeTest:init()
    super.init(self)

    self.time = -1
end

function DarkShapeTest:onStart()
    Game.battle:swapSoul(FlashlightSoul())

    self.timer:everyInstant(15/30, function()
        local arena = Game.battle.arena
        local tempdist = 100 + MathUtils.random(40)
        local tempdir = math.rad(30 + MathUtils.random(360))

        self:spawnBullet("titan/darkshape", arena.x + MathUtils.lengthDirX(tempdist, tempdir), arena.y + MathUtils.lengthDirY(tempdist, tempdir))
    end)

    self.timer:everyInstant(240/30, function()
        local arena = Game.battle.arena
        local tempdist = 100 + MathUtils.random(40)
        local tempdir = math.rad(30 + MathUtils.random(360))

        self:spawnBullet("titan/redshape", arena.x + MathUtils.lengthDirX(tempdist, tempdir), arena.y + MathUtils.lengthDirY(tempdist, tempdir))
    end)
end

return DarkShapeTest