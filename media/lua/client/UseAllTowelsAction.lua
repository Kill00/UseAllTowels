require "TimedActions/ISBaseTimedAction"

useAllTowelsAction = ISBaseTimedAction:derive("useAllTowelsAction")

function useAllTowelsAction:isValid()
    return true
end

function useAllTowelsAction:start()
    self.nowWetness = self.character:getBodyDamage():getWetness()
    self.targetWetness = self.nowWetness * 0.6
end

function useAllTowelsAction:update()
    if (self.character:getBodyDamage():getWetness() == 0) then
        self:forceComplete()
    end
end

function useAllTowelsAction:stop()
    ISBaseTimedAction.stop(self)
end

function useAllTowelsAction:perform()
    local wetness = self.character:getBodyDamage():getWetness()
    if (self.isBathTowel or self.isDishCloth) then
        if (self.nowWetness > 0) then
            if (wetness > self.targetWetness) then
                self.character:getBodyDamage():decreaseBodyWetness(self.nowWetness - self.targetWetness)
                self.item:setUsedDelta(0)
                self.item:Use()
            end
        end
    end

    ISBaseTimedAction.perform(self)
end

function useAllTowelsAction:new(character, item)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.maxTime = 50
    o.item = item
    o.stopOnWalk = true
    o.stopOnRun = true

    o.isBathTowel = false
    o.isDishCloth = false
    o.nowWetness = 0
    o.targetWetness = 0

    if (item:getType() == "BathTowel") then
        o.isBathTowel = true
    elseif (item:getType() == "DishCloth") then
        o.isDishCloth = true
    else
        o.maxTime = 1
    end

    if (o.character:isTimedActionInstant()) then
        o.maxTime = 1
    end

    return o
end