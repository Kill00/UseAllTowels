require "TimedActions/ISBaseTimedAction"

useAllTowelsRestoreAction = ISBaseTimedAction:derive("useAllTowelsRestoreAction")

function useAllTowelsRestoreAction:isValid()
    return true
end

function useAllTowelsRestoreAction:perform()
    local wet = 0
    if (self.items[1]:getContainer() ~= self.wasContainer) then
        for _, item in ipairs(self.items) do
            if (item:getUsedDelta() == 0) then
                wet = wet + 1
            end
        end

        local rawWetTowels = self.character:getInventory():getAllType(self.items[1]:getReplaceOnDeplete())
        local wetTowels = {}

        for i = 1, rawWetTowels:size() do
            table.insert(wetTowels, i, rawWetTowels:get(i - 1))
        end


        for i, item in ipairs(self.items) do
            if (i <= wet) then
                ISTimedActionQueue.add(ISInventoryTransferAction:new(self.character, wetTowels[i], wetTowels[i]:getContainer(), self.wasContainer))
            else
                ISTimedActionQueue.add(ISInventoryTransferAction:new(self.character, item, item:getContainer(), self.wasContainer))
            end
        end
    end

    ISBaseTimedAction.perform(self)
end

function useAllTowelsRestoreAction:stop()
    ISBaseTimedAction.stop(self)
end

function useAllTowelsRestoreAction:new(character, items, wasContainer)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.maxTime = 1
    o.items = items
    o.stopOnWalk = false
    o.stopOnRun = true

    o.isBathTowel = false
    o.isDishCloth = false

    o.wasContainer = wasContainer

    if (items[1]:getType() == "BathTowel") then
        o.isBathTowel = true
    elseif (items[1]:getType() == "DishCloth") then
        o.isDishCloth = true
    else
        o.maxTime = 1
    end

    if (o.character:isTimedActionInstant()) then
        o.maxTime = 1
    end

    return o
end