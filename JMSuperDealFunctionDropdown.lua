
---
--- JMSuperDeal Function Dropdown
---
--- These are the functions to pick a sale from the history
--- It also deside if there are enough sales to pick one from etc
---

JMSuperDealFunctionDropdown = {}

local FunctionDropdown = JMSuperDealFunctionDropdown

---
-- List of function algorithms
--
local FunctionList = {

    -- Return the most expensive sale
    ["Most expensive sale"] = function(item)
        local saleList = JMSuperDealHistory:getSaleListFromItem(item)

        -- Sort on most expensive first
        table.sort(saleList, function (a, b)
            return a.pricePerPiece > b.pricePerPiece
        end)

        return saleList[1]
    end,

    -- Return the cheapest sale
    ["Cheapest sale"] = function(item)
        local saleList = JMSuperDealHistory:getSaleListFromItem(item)

        -- Sort on most expensive first
        table.sort(saleList, function (a, b)
            return a.pricePerPiece > b.pricePerPiece
        end)

        return saleList[#saleList]
    end,

    -- Return the sale in the middle
    ["Median sale"] = function(item)
        local saleList = JMSuperDealHistory:getSaleListFromItem(item)

        -- Sort on most expensive first
        table.sort(saleList, function (a, b)
            return a.pricePerPiece > b.pricePerPiece
        end)

        local index = math.ceil(#saleList / 2)

        return saleList[index]
    end,

    -- Return the sale in the middle but only of sales where are atleast 5 of
    ["Median sale + atleast 5 sales"] = function(item)
        local saleList = JMSuperDealHistory:getSaleListFromItem(item)

        -- Sort on most expensive first
        table.sort(saleList, function (a, b)
            return a.pricePerPiece > b.pricePerPiece
        end)

        if #saleList < 5 then
            return
        end

        local index = math.ceil(#saleList / 2)

        return saleList[index]
    end,

    -- Return the newest sale
    ["Newest sale"] = function(item)
        local saleList = JMSuperDealHistory:getSaleListFromItem(item)

        -- Sort on sale timestamp
        -- The newest will now be the first sale
        table.sort(saleList, function (a, b)
            return a.saleTimestamp > b.saleTimestamp
        end)

        return saleList[1]
    end,
}

---
-- Initialize the Function Dropdown
--
-- Add the function algorithms to the dropdown
--
function FunctionDropdown:initialize()

    -- Get and clear the dropdown
    local dropdown = ZO_ComboBox_ObjectFromContainer(JMSuperDealGuiMainWindowFunctionDropdown)
    dropdown:ClearItems()
    dropdown:SetSortsItems(false)

    -- Add all the functions
    for name, _ in pairs(FunctionList) do
        dropdown:AddItem(
            dropdown:CreateItemEntry(name)
        )
    end

    -- And select the first one
    dropdown:SelectFirstItem()
end

---
-- Get sale for this item
-- Use the selected dropdown function to find the sale
--
function FunctionDropdown:getSale(item)
    local dropdown = ZO_ComboBox_ObjectFromContainer(JMSuperDealGuiMainWindowFunctionDropdown)
    local functionKey = dropdown:GetSelectedItem()

    return FunctionList[functionKey](item)
end
