
---
--- JMSuperDeal
---

--[[

    Variable declaration

 ]]

JMSuperDealGuiDetailWindow = {}
function JMSuperDealGuiDetailWindow:show(button)
    d(button)
end

---
-- Guild Index as key
--
local GuildList = {

}

-- Guild Id and Name as key
local GuildIdList = {}
local GuildNameList = {}

local ParsedData = {

}

--[[

 guildList = {
    index = {
        id,
        index,
        name,
    },
 }


 -- First put all sales in there that have a lower buy then sale
 -- Then filter with min 80% profit (So it can be a setting)
 CheaperList / ParsedData = {
    buy = {
        snapshot_item_data
    },
    sell = {
        history_sale_data
    },
    profit = {
        profit,
        profitPercentage,
    }
 }

--]]

---
-- @field name
-- @field savedVariablesName
--
local Config = {
    name = 'JMSuperDeal',
    savedVariablesName = 'JMSuperDealSavedVariables',
}

--[[

 History

 ]]

local History = {}

---
-- @param itemLink
--
function History:getCodeFromItemLink(itemLink)
    return string.format(
        '%d_%d_%d',
        GetItemLinkQuality(itemLink),
        GetItemLinkRequiredLevel(itemLink),
        GetItemLinkRequiredVeteranRank(itemLink)
    )
end

---
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

--[[

    Result table

 ]]

---
--
local ResultTable = {
    position = 1,
    rowList = {},
}

---
--
function ResultTable:initialize()
    for rowIndex = 1, 10 do
        local row = CreateControlFromVirtual(
            'JMSuperDealResultRow',
            JMSuperDealGuiMainWindowResultBackground,
            'JMSuperDealResultRow',
            rowIndex
        );
        row:SetSimpleAnchorParent(5, (row:GetHeight() + 2) * (rowIndex - 1))
        row:SetHidden(false)
        row:SetHandler("OnClicked", function ()
            local data = ParsedData[rowIndex + self.position]
            local icon = GetItemLinkInfo(data.buy.itemLink)

            -- Item naming
            JMSuperDealGuiHistoryWindow_Buy_ItemIcon:SetTexture(icon)
            JMSuperDealGuiHistoryWindow_Buy_ItemName:SetText(zo_strformat('<<t:1>>', data.buy.itemLink))
            JMSuperDealGuiHistoryWindow_Buy_ItemId:SetText(data.buy.itemId)

            -- Buy price
            JMSuperDealGuiHistoryWindow_Buy_Price:SetText(data.buy.price)
            JMSuperDealGuiHistoryWindow_Buy_Quantity:SetText(data.buy.stackCount)
            JMSuperDealGuiHistoryWindow_Buy_Piece:SetText(data.buy.pricePerPiece)

            -- Seller and guild
            JMSuperDealGuiHistoryWindow_Buy_Seller:SetText(
                data.buy.sellerName .. '   in   ' .. GuildList[data.buy.guildId].name
            )
--            JMSuperDealGuiHistoryWindow_Buy_Seller:SetText(data.buy.sellerName)
--            JMSuperDealGuiHistoryWindow_Buy_GuildName:SetText(
--                GuildList[data.buy.guildId].name -- @todo map guildId to guildIndex in like GuildIdList
--            )

            -- Get history
            local saleList = History:getSaleListFromItem(data.buy)

            JMSuperDealGuiHistoryWindow:SetHidden(false)
            JMSuperDealGuiHistoryWindow:BringWindowToTop()

            d(#saleList)

        end)

        self.rowList[rowIndex] = row
    end
end

---
--
function ResultTable:resetPosition()
    self.position = 0
end

---
--
function ResultTable:onScrolled(direction)
    self:adjustPosition(direction)
    self:draw()
end

---
-- @param direction
--
function ResultTable:adjustPosition(direction)
    local newPosition = self.position + direction;

    if (newPosition > #ParsedData - 10) then
        newPosition = #ParsedData - 10
    end

    if (newPosition < 1) then
        newPosition = 0
    end

    self.position = newPosition;
end

---
--
function ResultTable:draw()
    for rowIndex = 1, 10 do
        local record = ParsedData[rowIndex + self.position]
        if (record == nil) then
            return
        end

        local resultRow = self.rowList[rowIndex]
        local item = record.buy
        local sell = record.sell
        local profit = record.profit

        resultRow:GetNamedChild('ItemName'):SetText((rowIndex + self.position) .. ' ' .. item.itemLink)
        resultRow:GetNamedChild('ProfitPercentage'):SetText(math.ceil(profit.profitPercentage) .. ' %')
        resultRow:GetNamedChild('ProfitValue'):SetText(profit.profit)
        resultRow:GetNamedChild('BuyPricePerPiece'):SetText(item.pricePerPiece)
        resultRow:GetNamedChild('BuyStackCount'):SetText(item.stackCount)
        resultRow:GetNamedChild('GuildIds'):SetText(item.guildId .. ' -> ' .. sell.guildIndex)
        resultRow:GetNamedChild('SellPricePerPiece'):SetText(sell.pricePerPiece)
        resultRow:GetNamedChild('SellStackCount'):SetText(sell.quantity)
    end

    JMSuperDealResultPaginationSummary:SetText(self.position .. ' - ' .. (self.position + 10) .. ' of ' .. #ParsedData)
end

--[[

    Parser

 ]]

---
-- Parser object
--
local Parser = {

}

---
-- Parse the trading house snapshot to something we can use
--
function Parser:startParsing()
    d('Start parsing')

    -- Clear our cached data
    GuildList = {}
    ParsedData = {}

    -- Make sure we have a snapshot
    d('Fetching snapshot')
    local snapshot = JMTradingHouseSnapshot.getSnapshot()
    if not snapshot.creationTimestamp then
        d('We could not fetch the snapshot')
        return
    end

    Parser:fetchGuildList()

    -- Items are listen per guild
    -- So loop through those guilds
    for _, itemList in pairs(snapshot.tradingHouseItemList) do
        for _, item in ipairs(itemList) do
            self:addItem(item)
        end
    end

    d('Calculate potential profit')
--    Calculator:calculatePotentialProfit()

    -- Sort the most profit table
    table.sort(ParsedData, function (a, b)
        return a.profit.profitPercentage > b.profit.profitPercentage
    end)

    ResultTable:resetPosition();
    ResultTable:draw()
end

---
-- Add given item to our parsed data
--
-- @param guildId
-- @param item
--
function Parser:addItem(item)
    local sale = Parser:getExpensivestSaleFromItem(item)

    if not sale then
        return
    end

    local profit = (sale.pricePerPiece - item.pricePerPiece) * item.stackCount -- Because we buy 10 items so we get 10 times that profit if we buy this
    local profitPercentage = ((profit / item.stackCount) / item.pricePerPiece) * 100

    table.insert(ParsedData, {
        buy = item,
        sell = sale,
        profit = {
            profit = profit,
            profitPercentage = profitPercentage,
        },
    })
end

---
-- @param item
--
function Parser:getExpensivestSaleFromItem(item)
    local itemCode = Parser:getCodeFromItemLink(item.itemLink)
    local saleList = JMGuildSaleHistoryTracker.getSalesFromItemId(item.itemId)

    local mostExpensiveSale
    for _, sale in ipairs(saleList) do
        local saleCode = Parser:getCodeFromItemLink(sale.itemLink)
        sale.guildIndex = GuildNameList[sale.guildName].index

        if sale.guildIndex ~= 4 and itemCode == saleCode then
            if not mostExpensiveSale then
                mostExpensiveSale = sale
            end

            if sale.pricePerPiece > item.pricePerPiece then
                if sale.pricePerPiece > mostExpensiveSale.pricePerPiece then
                    mostExpensiveSale = sale
                end
            end
        end
    end

    return mostExpensiveSale
end

---
-- @param itemLink
--
function Parser:getCodeFromItemLink(itemLink)
    return string.format(
        '%d_%d_%d',
        GetItemLinkQuality(itemLink),
        GetItemLinkRequiredLevel(itemLink),
        GetItemLinkRequiredVeteranRank(itemLink)
    )
end

---
--
--
function Parser:fetchGuildList()
    for guildIndex = 1, GetNumGuilds() do
        local id = GetGuildId(guildIndex)
        local name = GetGuildName(id)

        GuildList[guildIndex] = {
            index = guildIndex,
            id = id,
            name = name,
        }

        GuildIdList[id] = GuildList[guildIndex]
        GuildNameList[name] = GuildList[guildIndex]
    end
end

--[[

    Initialize

 ]]

---
-- Start of the addon
--
local function Initialize()
    ResultTable:initialize()

    -- Button to the snapshot creation window
    local showMainWindowButton = JMSuperDealGuiOpenButton
    showMainWindowButton:SetParent(ZO_TradingHouseLeftPaneBrowseItemsCommon)
    showMainWindowButton:SetWidth(ZO_TradingHouseLeftPaneBrowseItemsCommonQuality:GetWidth())

    JMSuperDealGuiMainWindowResultBackground:SetMouseEnabled(true)
    JMSuperDealGuiMainWindowResultBackground:SetHandler("OnMouseWheel", function(_, direction)
        ResultTable:onScrolled(direction)
    end)

    JMGuildSaleHistoryTracker.registerForEvent(
        JMGuildSaleHistoryTracker.events.NEW_GUILD_SALES,
        function (guildId, newSaleList)
            d('Got ' .. #newSaleList .. ' new sales for guild id ' .. guildId)
        end
    )
end

--[[

    Events

 ]]

--- Adding the initialize handler
EVENT_MANAGER:RegisterForEvent(
    Config.name,
    EVENT_ADD_ON_LOADED,
    function (event, addonName)
        if addonName ~= Config.name then
            return
        end

        Initialize()
        EVENT_MANAGER:UnregisterForEvent(Config.name, EVENT_ADD_ON_LOADED)
    end
)

--[[

    Api

 ]]

JMSuperDeal = {

    parse = function()
        Parser:startParsing()
    end,
}
