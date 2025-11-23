---@class FlashlightSoul : Soul
---@overload fun(...) : FlashlightSoul
local FlashlightSoul, super = Class(Soul)

function FlashlightSoul:init(x, y)
    super.init(self, x, y)
	
    self.light_radius = 0        -- Initial radius of the light.
    self.light_radius_goal = 48  -- Max radius of the light.
    self.light_timer = 0
end

function FlashlightSoul:getDebugInfo()
    local info = super.getDebugInfo(self)
    table.insert(info, "Radius: " .. self.light_radius)
    table.insert(info, "Radius Goal: " .. self.light_radius_goal)
    return info
end

local function draw_set_alpha(a)
    local r,g,b = love.graphics.getColor()
    love.graphics.setColor(r,g,b,a)
end

function FlashlightSoul:draw()
    self.light_timer = self.light_timer + DTMULT
    self.light_radius = MathUtils.approach(self.light_radius, self.light_radius_goal, math.abs(self.light_radius_goal - self.light_radius) * 0.1)

    Draw.setColor(COLORS.white)
    local i = 0.25
    while i <= 0.5 do
        draw_set_alpha((0.5 - (i * 0.5)) * 0.5)
        love.graphics.circle("fill", 0, 0, (self.light_radius * i * 2) + (math.sin(self.light_timer) * 0.5))
        i = i + math.max(0.025, 0.1 - (((math.pow(i * 10, 1.035) / 10) - 0.25) / 3)) * DTMULT
    end

    draw_set_alpha(1)
	
    super.draw(self)
end

return FlashlightSoul