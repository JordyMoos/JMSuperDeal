
---
--- JMSuperDeal Function Dropdown
---
--- These are the functions to pick a sale from the history
--- It also deside if there are enough sales to pick one from etc
---

JMSuperDealFunctionDropdown = {}

local FunctionDropdown = JMSuperDealFunctionDropdown

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
    for _, description in pairs(JMPriceSuggestion.algorithms) do
        functionDropdown:AddItem(
            functionDropdown:CreateItemEntry(description, function (value)

            end)
        )
    end
    functionDropdown:SelectItem()


    -- The minimul sale count
    local countDropdown = ZO_ComboBox_ObjectFromContainer(JMSuperDealGuiMainWindowMinimumSaleCountDropdown)
    countDropdown:ClearItems()
    for count = 1, 10 do
        countDropdown:AddItem(
            countDropdown:CreateItemEntry(count)
        )
    end
    countDropdown:SelectFirstItem()


    -- The minimul sale age
    local ageDropdown = ZO_ComboBox_ObjectFromContainer(JMSuperDealGuiMainWindowMinimumSaleAgeDropdown)
    ageDropdown:ClearItems()
    for age = 1, 10 do
        ageDropdown:AddItem(
            ageDropdown:CreateItemEntry(age)
        )
    end
    ageDropdown:SelectFirstItem()
end

---
-- Get sale for this item
-- Use the selected dropdown function to find the sale
--
function FunctionDropdown:getSale(item)
    local functionDropdown = ZO_ComboBox_ObjectFromContainer(JMSuperDealGuiMainWindowFunctionDropdown)
    local functionKey = functionDropdown:GetSelectedItem()

    -- Count filter
    local countDropdown = ZO_ComboBox_ObjectFromContainer(JMSuperDealGuiMainWindowMinimumSaleCountDropdown)
    local minimumSaleCount = tonumber(countDropdown:GetSelectedItem())

    local saleList = JMSuperDealHistory:getSaleListFromItem(item)

    if minimumSaleCount > #saleList then
        return
    end

    -- Age filter
    local ageDropdown = ZO_ComboBox_ObjectFromContainer(JMSuperDealGuiMainWindowMinimumSaleAgeDropdown)
    local minimumSaleAge = tonumber(ageDropdown:GetSelectedItem())

    local newestSaleTime = 0
    for _, sale in ipairs(saleList) do
        newestSaleTime = math.max(newestSaleTime, sale.saleTimestamp)
    end

    if newestSaleTime < (GetTimeStamp() - (60 * 60 * 24 * minimumSaleAge)) then
        return
    end

    local result = JMPriceSuggestion.getPriceSuggestion(item.itemLink, functionKey)

    if not result.hasPrice then
        return false
    end

    return result.bestPrice
end
