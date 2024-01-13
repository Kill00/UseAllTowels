require "TimedActions/ISBaseTimedAction"

useAllTowelsAction = ISBaseTimedAction:derive("useAllTowelsAction")

function useAllTowelsAction:isValid()
    return true
end

function useAllTowelsAction:start()
    self.count = 0
    self.nowWetness = self.character:getBodyDamage():getWetness()
    self.targetWetness = self.nowWetness * 0.6
    self.remainWetness = self.nowWetness - self.targetWetness
    self.finished = false

    if (self.character:getBodyDamage():getWetness() == 0 or self.item:getUsedDelta() == 0) then
        self:forceComplete()
    end
end

function useAllTowelsAction:update() -- 배속 하면 이상해짐
    local jobDelta = self:getJobDelta() * 100

    if (self.character:getBodyDamage():getWetness() == 0 or self.item:getUsedDelta() == 0) then
        self.finished = false
        self:forceComplete()
    end

    local needCount = math.floor(jobDelta * 0.1)
    local jotDeltaInt = math.floor(jobDelta)
    local canDo = needCount ~= self.count and jotDeltaInt % 10 < 10

    if (self.count ~= needCount) then
        self.count = self.count + 1
    end

    if (canDo) then
        local nowItemWetness = self.item:getUsedDelta()
        if (nowItemWetness >= 0.1) then
            self.remainWetness = self.remainWetness - (self.nowWetness - self.targetWetness) * 0.1
            self.character:getBodyDamage():decreaseBodyWetness((self.nowWetness - self.targetWetness) * 0.1)
            self.item:setUsedDelta(nowItemWetness - 0.1)
            self.finished = true
        else
            self.finished = true
            self:forceComplete()
        end
    end
end

function useAllTowelsAction:stop()
    ISBaseTimedAction.stop(self)
end

function useAllTowelsAction:perform() -- Update 보완
    if (self.finished) then
        if (self.isBathTowel or self.isDishCloth) then
            if (self.nowWetness > 0) then
                self.character:getBodyDamage():decreaseBodyWetness(self.remainWetness)
                self.item:setUsedDelta(0)
            end
        end
    end

    if (self.item:getUsedDelta() == 0) then
        self.item:Use()
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
    o.remainWetness = 0

    o.finished = false
    o.count = 0

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