
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

function History:getCodeFromItemLink(itemLink)
    return itemLink

--    local _, setName = GetItemLinkSetInfo(itemLink)
--    local glyphMinLevel, glyphMaxLevel, glyphMinVetLevel, glyphMaxVetLevel = GetItemLinkGlyphMinMaxLevels(itemLink)
--
--    return string.format(
--        '%s_%s_%s_%s_%s_%s_%s_%s_%s_%s_%s_%s',
--        GetItemLinkQuality(itemLink),
--        GetItemLinkRequiredLevel(itemLink),
--        GetItemLinkRequiredVeteranRank(itemLink),
--        GetItemLinkWeaponPower(itemLink),
--        GetItemLinkArmorRating(itemLink),
--        GetItemLinkValue(itemLink),
--        GetItemLinkMaxEnchantCharges(itemLink),
--        setName,
--        glyphMinLevel or '',
--        glyphMaxLevel or '',
--        glyphMinVetLevel or '',
--        glyphMaxVetLevel or ''
--    )
end

---
-- Get all sales matching the given store item
--
-- @param item
--
function History:getSaleListFromItem(item)
    local itemCode = History:getCodeFromItemLink(item.itemLink)

    -- Get sale history of this item id
    local saleList = JMGuildSaleHistoryTracker.getSalesFromItemId(item.itemId)

    -- Remove sales which are not really the same
    -- Like not having the same level etc
    -- Desided by the itemCode
    for saleIndex = #(saleList), 1, -1 do
        local sale = saleList[saleIndex]
        local saleCode = History:getCodeFromItemLink(sale.itemLink)

        if itemCode ~= saleCode then
            table.remove(saleList, saleIndex)
        end
    end

    return saleList
end
