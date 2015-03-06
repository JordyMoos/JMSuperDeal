
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
--local GuildList = {
--
--}

-- Guild Id and Name as key
local GuildIdList = {}
local GuildNameList = {}

local TradingHouseList = {}

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

    Trading house

 ]]

local TradingHouse = {}

---
--
function TradingHouse:opened()
    self.isOpen = true
end

---
--
function TradingHouse:closed()
    self.isOpen = false
    JMSuperDealGuiMainWindow:SetHidden(true)
    JMSuperDealGuiHistoryWindow:SetHidden(true)
end

--[[

    History table

 ]]

local HistoryData = {

}

---
--
local HistoryTable = {
    position = 1,
    rowList = {},
}

---
--
function HistoryTable:initialize()
    for rowIndex = 1, 10 do
        local row = CreateControlFromVirtual(
            'JMSuperDealHistoryRow',
            JMSuperDealGuiHistoryWindowHistoryBackground,
            'JMSuperDealHistoryRow',
            rowIndex
        );
        row:SetSimpleAnchorParent(5, (row:GetHeight() + 2) * (rowIndex - 1))
        row:SetHidden(false)

        self.rowList[rowIndex] = row
    end
end

---
--
function HistoryTable:resetPosition()
    self.position = 0
end

---
--
function HistoryTable:onScrolled(direction)
    self:adjustPosition(direction)
    self:draw()
end

---
-- @param direction
--
function HistoryTable:adjustPosition(direction)
    local newPosition = self.position + direction;

    if (newPosition > #HistoryData - 10) then
        newPosition = #HistoryData - 10
    end

    if (newPosition < 1) then
        newPosition = 0
    end

    self.position = newPosition;
end

---
--
function HistoryTable:draw()
    for rowIndex = 1, 10 do
        local resultRow = self.rowList[rowIndex]

        local sale = HistoryData[rowIndex + self.position]
        if (sale == nil) then
            resultRow:SetHidden(true)
        else

            -- Fill the row
            resultRow:SetHidden(false)
            resultRow:GetNamedChild('_Piece'):SetText(sale.price)
            resultRow:GetNamedChild('_Quantity'):SetText(sale.quantity)
            resultRow:GetNamedChild('_Price'):SetText(sale.pricePerPiece)
            resultRow:GetNamedChild('_Buyer'):SetText(sale.buyer)
            resultRow:GetNamedChild('_Guild'):SetText(sale.guildName)
            resultRow:GetNamedChild('_Seller'):SetText(sale.seller)
            resultRow:GetNamedChild('_Ago'):SetText(
                ZO_FormatDurationAgo(GetTimeStamp() - sale.saleTimestamp)
            )
        end
    end

    JMSuperDealHistoryPaginationSummary:SetText((self.position + 1) .. ' - ' .. (math.min(self.position + 10, #HistoryData)) .. ' of ' .. #HistoryData)
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

            d(data.buy.itemLink)

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
                -- @todo map guildId to guildIndex in like GuildIdList
                data.buy.sellerName .. '   in   ' .. data.buy.guildName
            )

            -- Get history
            HistoryData = JMSuperDealHistory:getSaleListFromItem(data.buy)
            table.sort(HistoryData, function (a, b)
--                return a.pricePerPiece > b.pricePerPiece
                return a.saleTimestamp > b.saleTimestamp
            end)

            JMSuperDealGuiHistoryWindow:SetHidden(false)
            JMSuperDealGuiHistoryWindow:BringWindowToTop()

            local button = JMSuperDealGuiHistoryWindow_LookupButton
            button:SetHandler('OnClicked', function ()
                local item = data.buy
                local guildId = TradingHouseList[item.guildName]

                SelectTradingHouseGuildId(guildId)

                SetTradingHouseFilterRange(TRADING_HOUSE_FILTER_TYPE_ITEM, GetItemLinkItemType(item.itemLink))
                SetTradingHouseFilterRange(TRADING_HOUSE_FILTER_TYPE_WEAPON, GetItemLinkWeaponType(item.itemLink))
                SetTradingHouseFilterRange(TRADING_HOUSE_FILTER_TYPE_ARMOR, GetItemLinkArmorType(item.itemLink))
                SetTradingHouseFilterRange(TRADING_HOUSE_FILTER_TYPE_QUALITY, item.quality)
                SetTradingHouseFilterRange(TRADING_HOUSE_FILTER_TYPE_PRICE, item.price)

                ExecuteTradingHouseSearch(0, TRADING_HOUSE_SORT_SALE_PRICE, true)
            end)

            HistoryTable:resetPosition();
            HistoryTable:draw()
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
        resultRow:GetNamedChild('GuildIds'):SetText(item.guildName .. ' -> ' .. sell.guildName)
        resultRow:GetNamedChild('SellPricePerPiece'):SetText(sell.pricePerPiece)
    end

    JMSuperDealResultPaginationSummary:SetText((self.position + 1) .. ' - ' .. (self.position + 10) .. ' of ' .. #ParsedData)
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
--    GuildList = {}
    ParsedData = {}

    -- Make sure we have a snapshot
    d('Fetching snapshot')
    local snapshot = JMTradingHouseSnapshot.getSnapshot()
    if not snapshot.lastChangeTimestamp then
        d('We could not fetch the snapshot')
        return
    end

    Parser:fetchTradingHouseList()

    -- Items are listen per guild
    -- So loop through those guilds
    for guildName, data in pairs(snapshot.tradingHouseList) do
        if TradingHouseList[guildName] then
            for _, item in ipairs(data.itemList) do
                self:addItem(item, data.listingPercentage + data.cutPercentage)
            end
        end
    end

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
function Parser:addItem(item, taxPercentage)
    local priceSuggestion = JMSuperDealFunctionDropdown:getSale(item)

    if not priceSuggestion then
        return
    end

    -- Because we buy 10 items so we get 10 times that profit if we buy this
    local profit = (priceSuggestion.pricePerPiece * (100 - taxPercentage) / 100 - item.pricePerPiece) * item.stackCount 
    local profitPercentage = ((profit / item.stackCount) / item.pricePerPiece) * 100
    
    -- Sale is not profitable
    if profit < 0
        return
    end

    table.insert(ParsedData, {
        buy = item,
        sell = priceSuggestion,
        profit = {
            profit = profit,
            profitPercentage = profitPercentage,
        },
    })
end

function Parser:fetchTradingHouseList()
    TradingHouseList = {}
    for index = 1, GetNumTradingHouseGuilds() do
        local guildId, guildName, _ = GetTradingHouseGuildDetails(index)

        TradingHouseList[guildName] = guildId
    end
end

---
--
--
--function Parser:fetchGuildList()
--    for guildIndex = 1, GetNumGuilds() do
--        local id = GetGuildId(guildIndex)
--        local name = GetGuildName(id)
--
--        GuildList[guildIndex] = {
--            index = guildIndex,
--            id = id,
--            name = name,
--        }
--
--        GuildIdList[id] = GuildList[guildIndex]
--        GuildNameList[name] = GuildList[guildIndex]
--    end
--end

--[[

    Initialize

 ]]

---
-- Start of the addon
--
local function Initialize()
    ResultTable:initialize()
    HistoryTable:initialize()
    JMSuperDealFunctionDropdown:initialize()

    -- Button to the snapshot creation window
    local showMainWindowButton = JMSuperDealGuiOpenButton
    showMainWindowButton:SetParent(ZO_TradingHouseLeftPaneBrowseItemsCommon)
    showMainWindowButton:SetWidth(ZO_TradingHouseLeftPaneBrowseItemsCommonQuality:GetWidth())

    JMSuperDealGuiMainWindowResultBackground:SetMouseEnabled(true)
    JMSuperDealGuiMainWindowResultBackground:SetHandler("OnMouseWheel", function(_, direction)
        ResultTable:onScrolled(direction)
    end)

    JMSuperDealGuiHistoryWindowHistoryBackground:SetMouseEnabled(true)
    JMSuperDealGuiHistoryWindowHistoryBackground:SetHandler("OnMouseWheel", function(_, direction)
        HistoryTable:onScrolled(direction)
    end)

    EVENT_MANAGER:RegisterForEvent(
        Config.name,
        EVENT_OPEN_TRADING_HOUSE,
        function ()
            TradingHouse:opened()
        end
    )
    EVENT_MANAGER:RegisterForEvent(
        Config.name,
        EVENT_CLOSE_TRADING_HOUSE,
        function ()
            TradingHouse:closed()
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
