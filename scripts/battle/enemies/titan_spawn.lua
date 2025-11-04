local TitanSpawn, super = Class(EnemyBattler, "titan_spawn")

function TitanSpawn:init()
    super.init(self)

    self.name = "Titan Spawn"
    self:setActor("titan_spawn")

    self.max_health = 3000
    self.health = 3000
    self.attack = 18
    self.defense = 0
    self.money = 0

    self.disable_mercy = true

    self.tired = false
    self.tired_percentage = -1

    self.can_freeze = false

    self.waves = {}

    self.text = {
        "* You hear your heart beating in \nyour ears.",
        "* When did you start being \nyourself?",
        "* It sputtered in a voice like \ncrushed glass."
    }
    if Game:hasPartyMember("ralsei") then
        table.insert(self.text, "* Ralsei mutters to himself to \nstay calm.")
    end

	self.low_health_text = nil
	self.tired_text = nil
	self.spareable_text = nil

    self:registerAct("Brighten", "Powerup\nlight", "all", 4)
    self:registerAct("DualHeal", "Heal\nparty",    "all", 16)
    self:registerAct("Banish",   "Defeat\nenemy",  nil,   64)

    self.text_override = nil
end

function TitanSpawn:getGrazeTension()
    return 0
end

function TitanSpawn:isXActionShort(battler)
    return true
end

function TitanSpawn:onShortAct(battler, name)
    if name == "Standard" then
        return "* " .. battler.chara:getName() .. " tried to ACT, but failed!"
    end
    return nil
end

function TitanSpawn:onAct(battler, name)
	if name == "Check" then
        if Game:getTension() >= 64 then
            return {
                "* TITAN SPAWN - AT 30 DF 200\n* A shard of fear. Appears \nin places of deep dark.",
                "* The atmosphere feels tense...\n* (You can use [color:yellow]BANISH[color:reset]!)"
            }
        else
            return {
                "* TITAN SPAWN - AT 30 DF 200\n* A shard of fear. Appears \nin places of deep dark.",
                "* Expose it to LIGHT... and gather COURAGE to gain TP.",
                "* Then, \"[color:yellow]BANISH[color:reset]\" it!",
            }
        end

    elseif name == "Banish" then
        battler:setAnimation("act")
        Game.battle:startCutscene(function(cutscene)
            cutscene:text("* "..battler.chara:getName().."'s SOUL emitted a brilliant \nlight!")
            battler:flash()

            local bx, by = battler:getRelativePos(battler.width/2 + 4, battler.height/2 + 4)

            local soul = Game.battle:addChild(TitanSpawnPurifySoul(bx, by))
            soul.color = Game:getPartyMember(Game.party[1].id).soul_color or { 1, 0, 0 }
            soul.layer = 501

            local wait = function() return soul.t >= 550 end
            cutscene:wait(wait)
            cutscene:after(function()
                if #Game.battle.enemies == 0 then
                    Game.battle:setState("VICTORY")
                end
            end)
        end)
        return

    elseif name == "Standard" then
        Game.battle:startActCutscene(function(cutscene)
            cutscene:text("* "..battler.chara:getName().." tried to \"[color:yellow]ACT[color:reset]\"...\n* But, the enemy couldn't understand!")
        end)
        return
    end
    return super.onAct(self, battler, name)
end

function TitanSpawn:getEnemyDialogue()
    return false
end

function TitanSpawn:update()
    super.update(self)
end

function TitanSpawn:onSpared()
    --self:recruitMessage("purified")
end

function TitanSpawn:onHurt(damage, battler)
	super.onHurt(self, damage, battler)

    Assets.stopAndPlaySound("spawn_weaker")
end

function TitanSpawn:onDefeat(damage, battler)
	super.onDefeat(self, damage, battler)

    self:onDefeatFatal(damage, battler)
end

function TitanSpawn:freeze()
    self:onDefeat()
end

function TitanSpawn:getEncounterText()
	if Game:getTension() < 64 and MathUtils.randomInt(100) < 4 then
		return "* Smells like adrenaline."
    elseif Game:getTension() >= 64 then 
		return "* The atmosphere feels tense...\n* (You can use [color:yellow]BANISH[color:reset]!)"
	else
		return super.getEncounterText(self)
	end
end

return TitanSpawn