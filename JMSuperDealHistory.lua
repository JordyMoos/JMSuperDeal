
---
--- JMSuperDeal History
---

JMSuperDealHistory = {}

local History = JMSuperDealHistory

---
-- Create a unique enough code from the itemLink
-- Items are not unique enough, There is a big difference between a level 1 and level 50
-- So we add some more information to the code
--
-- @param itemLink
--
--function History:getCodeFromItemLink(itemLink)
--    return itemLink
--    --    return string.format(
--    --        '%d_%d_%d',
--    --        GetItemLinkQuality(itemLink),
--    --        GetItemLinkRequiredLevel(itemLink),
--    --        GetItemLinkRequiredVeteranRank(itemLink)
--    --    )
--end

function History:getCodeFromItemLinkNew(itemLink)
    local array = {ZO_LinkHandler_ParseLink(itemLink)}
    array[6] = 0 -- Looted from
    array[20] = 0 -- Crafted
    array[22] = 0 -- Stolen
    array[23] = 0 -- Condition

    return table.concat(array, '_')
end

function History:getCodeFromItemLink(itemLink)
--    return itemLink

    local _, setName, setBonusCount, _ = GetItemLinkSetInfo(itemLink)
    local glyphMinLevel, glyphMaxLevel, glyphMinVetLevel, glyphMaxVetLevel = GetItemLinkGlyphMinMaxLevels(itemLink)
    local _, enchantHeader, _ = GetItemLinkEnchantInfo(itemLink)
    local hasAbility, abilityHeader, _ = GetItemLinkOnUseAbilityInfo(itemLink)
    local traitType, _ = GetItemLinkTraitInfo(itemLink)
    local craftingSkillRank = GetItemLinkRequiredCraftingSkillRank(itemLink)

    local abilityInfo = abilityHeader
    if not hasAbility then
        for i = 1, GetMaxTraits() do
            local hasTraitAbility, traitAbilityDescription, _ = GetItemLinkTraitOnUseAbilityInfo(itemLink, i)
            if(hasTraitAbility) then
                abilityInfo = abilityInfo .. ':' .. traitAbilityDescription
            end
        end
    end

    return string.format(
        '%s_%s_%s_%s_%s_' .. '%s_%s_%s_%s_%s_' .. '%s_%s_%s_%s_%s_' .. '%s_%s',

        GetItemLinkQuality(itemLink),
        GetItemLinkRequiredLevel(itemLink),
        GetItemLinkRequiredVeteranRank(itemLink),
        GetItemLinkWeaponPower(itemLink),
        GetItemLinkArmorRating(itemLink),

        GetItemLinkValue(itemLink),
        GetItemLinkMaxEnchantCharges(itemLink),
        setName,
        glyphMinLevel or '',
        glyphMaxLevel or '',

        glyphMinVetLevel or '',
        glyphMaxVetLevel or '',
        enchantHeader,
        traitType or '',
        setBonusCount or '',

        craftingSkillRank,
        abilityInfo
    )
end

---
-- Get all sales matching the given store item
--
-- @param item
--
function History:getSaleListFromItem(item)
    local itemCode = JMItemCode.getCode(item.itemLink)

    -- Get sale history of this item id
    local saleList = JMGuildSaleHistoryTracker.getSalesFromItemId(item.itemId)

    -- Remove sales which are not really the same
    -- Like not having the same level etc
    -- Desided by the itemCode
    for saleIndex = #(saleList), 1, -1 do
        local sale = saleList[saleIndex]
        local saleCode = JMItemCode.getCode(sale.itemLink)

        if itemCode ~= saleCode then
            table.remove(saleList, saleIndex)
        end
    end

    return saleList
end
