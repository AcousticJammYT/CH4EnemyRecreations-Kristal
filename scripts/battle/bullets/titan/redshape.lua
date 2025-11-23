---@class RedShape : DarkShapeBullet
---@overload fun(...) : RedShape
local RedShape, super = Class(DarkShapeBullet)

function RedShape:init(x, y)
    super.init(self, x, y, "battle/bullets/titan/red/body")

    self.radius = 22
    self.light = 0
    self.color = COLORS.red
    self.tracking_val2 = 1
    self.destroy_on_hit = false
    self.speed_max = self.speed_max * 2.5

    self:setScale(1, 1)
    self.scalefactor = 1

    self.can_do_shrivel = false
    self.can_do_pushback = false
    self.can_destroy = false
end

function RedShape:chaseHeart()
    local hx, hy = Game.battle.soul.x, Game.battle.soul.y

    if (MathUtils.dist(self.x, self.y, hx, hy) < (Game.battle.soul.light_radius + 8)) or self.light > 0 then
        self.physics.speed = MathUtils.approach(self.physics.speed, self.speed_max * self.speed_max_multiplier * 0.5, self.physics.speed * 0.25)
    else
        self.physics.speed = MathUtils.approach(self.physics.speed, self.speed_max * self.speed_max_multiplier, self.accel * self.speed_max_multiplier * (1 - self.light))
    end
    
    local anglediff = MathUtils.angleDiff(self.physics.direction, Utils.angle(self.x, self.y, hx, hy))
        
    if self.tracking_val2 > 0 then
        self.physics.direction = MathUtils.angleLerp(self.physics.direction, Utils.angle(self.x, self.y, hx, hy), self.tracking_val2 * 0.3)
    end
end

function RedShape:update()
    super.update(self)

    self.collider = CircleCollider(self, 25, 24, self.radius/2)

    self.rotation = self.rotation + -math.rad(2.8125) * DTMULT

    if self.tracking_val2 > 0 then
        self.tracking_val2 = MathUtils.approach(self.tracking_val2, 0, 0.00875)
    end

    -- Spawns the afterimage trail when the bullet's speed reaches 2.
    if self.physics.speed > 2 then
    end
end

return RedShape