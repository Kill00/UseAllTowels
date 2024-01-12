useAllTowelsMenu = {}

function useAllTowelsAction.canUse(item)
    if item:getType() == "BathTowel" then
        return true
    elseif item:getType() == "DishCloth" then
        return true
    end
    return false
end

function useAllTowelsMenu.contextMenu(player, context, items)
    local character = getSpecificPlayer(player)

    if #items > 1 and character:getBodyDamage():getWetness() ~= 0 then
        for i, v in ipairs(items) do
            local itemValue = v

            if not instanceof(itemValue, "InventoryItem") then
                itemValue = v.items[1]
            end

            if useAllTowelsAction.canUse(itemValue) then
                context:addOption(getText("ContextMenu_DrySelfAll"), player, useAllTowelsMenu.onUseTowel, items)
                break
            end
        end
    end
end

function useAllTowelsMenu.onUseTowel(player, items)
    local character = getSpecificPlayer(player)

    for i, v in ipairs(items) do
        local itemValue = v
        if not instanceof(itemValue, "InventoryItem") then
            itemValue = v.items[1]
        end

        if useAllTowelsAction.canUse(itemValue) then
            if luautils.haveToBeTransfered(character, itemValue) then
                ISTimedActionQueue.add(ISInventoryTransferAction:new(character, itemValue, itemValue:getContainer(), character:getInventory()))
            end
        end
    end

    for i, v in ipairs(items) do
        local itemValue = v
        if not instanceof(itemValue, "InventoryItem") then
            itemValue = v.items[1]
        end

        if useAllTowelsAction.canUse(itemValue) then
            ISTimedActionQueue.add(useAllTowelsAction:new(character, itemValue))
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(useAllTowelsMenu.contextMenu)