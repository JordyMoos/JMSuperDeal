
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
            resultRow:GetNamedChild('_Buyer'):SetText(
                sale.buyer  .. '   in   ' .. sale.guildName .. '   from   ' .. sale.seller
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
                data.buy.sellerName .. '   in   ' .. GuildIdList[data.buy.guildId].name
            )
--            JMSuperDealGuiHistoryWindow_Buy_Seller:SetText(data.buy.sellerName)
--            JMSuperDealGuiHistoryWindow_Buy_GuildName:SetText(
--                GuildList[data.buy.guildId].name -- @todo map guildId to guildIndex in like GuildIdList
--            )

            -- Get history
            HistoryData = JMSuperDealHistory:getSaleListFromItem(data.buy)
            table.sort(HistoryData, function (a, b)
                return a.pricePerPiece > b.pricePerPiece
            end)

            JMSuperDealGuiHistoryWindow:SetHidden(false)
            JMSuperDealGuiHistoryWindow:BringWindowToTop()

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
        resultRow:GetNamedChild('GuildIds'):SetText(item.guildId .. ' -> ' .. sell.guildIndex)
        resultRow:GetNamedChild('SellPricePerPiece'):SetText(sell.pricePerPiece)
        resultRow:GetNamedChild('SellStackCount'):SetText(sell.quantity)
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
    local sale = JMSuperDealFunctionDropdown:getSale(item)

    if not sale then
        return
    end

    -- Sale is not expensive enough
    if sale.pricePerPiece <= item.pricePerPiece then
        return
    end

    -- Add guildIndex to the sale
    --
    -- @todo
    -- Should be removed we should be happy with the guild name
    -- and map it to the guildIndex only in places where we want it
    --
    -- Also the guild magic might better be off in a other addon
    -- Or atleast in a other script managing guild related stuff
    sale.guildIndex = GuildNameList[sale.guildName].index

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
