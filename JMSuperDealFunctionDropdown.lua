
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
    ["Most expensive sale"] = function(saleList)

        -- Sort on most expensive first
        table.sort(saleList, function (a, b)
            return a.pricePerPiece > b.pricePerPiece
        end)

        return saleList[1]
    end,

    -- Return the cheapest sale
    ["Cheapest sale"] = function(saleList)

        -- Sort on most expensive first
        table.sort(saleList, function (a, b)
            return a.pricePerPiece > b.pricePerPiece
        end)

        return saleList[#saleList]
    end,

    -- Return the median sale
    ["Median sale"] = function(saleList)

        -- Sort on most expensive first
        table.sort(saleList, function (a, b)
            return a.pricePerPiece > b.pricePerPiece
        end)

        local index = math.ceil(#saleList / 2)

        return saleList[index]
    end,

    -- Return the newest sale
    ["Newest sale"] = function(saleList)

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
    local functionDropdown = ZO_ComboBox_ObjectFromContainer(JMSuperDealGuiMainWindowFunctionDropdown)
    functionDropdown:ClearItems()
    functionDropdown:SetSortsItems(false)

    -- Add all the functions
    for name, _ in pairs(FunctionList) do
        functionDropdown:AddItem(
            functionDropdown:CreateItemEntry(name)
        )
    end

    -- And select the first one
    functionDropdown:SelectFirstItem()

    -- The minimul sale count
    local countDropdown = ZO_ComboBox_ObjectFromContainer(JMSuperDealGuiMainWindowMinimumSaleCountDropdown)
    countDropdown:ClearItems()
    for count = 1, 10 do
        countDropdown:AddItem(
            countDropdown:CreateItemEntry(count)
        )
    end
    countDropdown:SelectFirstItem()
end

---
-- Get sale for this item
-- Use the selected dropdown function to find the sale
--
function FunctionDropdown:getSale(item)
    local functionDropdown = ZO_ComboBox_ObjectFromContainer(JMSuperDealGuiMainWindowFunctionDropdown)
    local functionKey = functionDropdown:GetSelectedItem()

    local countDropdown = ZO_ComboBox_ObjectFromContainer(JMSuperDealGuiMainWindowMinimumSaleCountDropdown)
    local minimumSaleCount = tonumber(countDropdown:GetSelectedItem())

    local saleList = JMSuperDealHistory:getSaleListFromItem(item)
    if minimumSaleCount > #saleList then
        return
    end

    return FunctionList[functionKey](saleList)
end
