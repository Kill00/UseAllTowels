useAllTowelsMenu = {}

function useAllTowelsAction.canUse(item)
    if (item:getType() == "BathTowel") then
        return true
    elseif (item:getType() == "DishCloth") then
        return true
    end
    return false
end

function useAllTowelsMenu.contextMenu(player, context, items)
    local character = getSpecificPlayer(player)

    if (character:getBodyDamage():getWetness() ~= 0) then
        for _, v in ipairs(items) do
            if (not instanceof(v, "InventoryItem") and #items == 1 and #v.items > 2 and useAllTowelsAction.canUse(v.items[1])) then -- 선택한 아이템의 타입이 한 개 이면서 모두 선택한 경우
                context:addOption(getText("ContextMenu_DrySelfAll"), player, useAllTowelsMenu.onUseTowel, v.items)
            elseif (instanceof(v, "InventoryItem") and #items > 1 and useAllTowelsAction.canUse(v)) then -- 선택한 아이템의 타입이 한 개 이면서 특정 개수만 선택한 경우
                context:addOption(getText("ContextMenu_DrySelfAll"), player, useAllTowelsMenu.onUseTowel, items)
            end

            break
        end
    end
end

function useAllTowelsMenu.onUseTowel(player, items)
    local character = getSpecificPlayer(player)
    local wasContainer

    -- 수건이 캐릭터 메인 인벤토리에 없을경우 수건을 메인 인벤토리로 옮김
    for _, item in ipairs(items) do
        wasContainer = item:getContainer()
        if (useAllTowelsAction.canUse(item)) then
            if (luautils.haveToBeTransfered(character, item)) then
                ISTimedActionQueue.add(ISInventoryTransferAction:new(character, item, item:getContainer(), character:getInventory()))
            end
        end
    end

    -- 수건 사용
    for _, item in ipairs(items) do
        if (useAllTowelsAction.canUse(item)) then
            ISTimedActionQueue.add(useAllTowelsAction:new(character, item))
        end
    end

    -- 컨테이너가 캐릭터 인벤토리에 있을때만 다시 이전 보관함에 넣어줌
    if (wasContainer:isInCharacterInventory(character)) then
        ISTimedActionQueue.add(useAllTowelsRestoreAction:new(character, items, wasContainer))
    end
end

Events.OnFillInventoryObjectContextMenu.Add(useAllTowelsMenu.contextMenu)