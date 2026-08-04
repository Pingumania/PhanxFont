--[[--------------------------------------------------------------------
	PhanxFont
	Simple font replacement and scaling.
	Based on tekticles by Tekkub, which is based on ClearFont2 by Kirkburn.
	Copyright 2012-2018 Phanx <addons@phanx.net>
	Zlib license; see LICENSE.txt for the full license text.
	https://www.wowinterface.com/downloads/info24565-PhanxFont.html
	https://www.curseforge.com/wow/addons/phanxfont
	https://github.com/phanx-wow/PhanxFont
----------------------------------------------------------------------]]

local _, Addon = ...
local L = Addon.L

local SAMPLE_KEYS = {"SampleEnglish", "SampleCyrillic", "SampleChinese"}

local DAMAGE_SAMPLES = {"7", "42", "396", "2.185", "86.337"}

local PREVIEW_SIZE = 16
local DAMAGE_PREVIEW_SIZE = 22

local previews = {}

local function SampleTexts(kind)
	if kind == "damage" then
		return {table.concat(DAMAGE_SAMPLES, "    ")}
	end

	local texts = {}
	for index, key in ipairs(SAMPLE_KEYS) do
		texts[index] = L[key]
	end

	return texts
end

local function RefreshPreview()
	local media = LibStub("LibSharedMedia-3.0")

	for kind, preview in next, previews do
		local file = media:Fetch("font", PhanxFontDB[kind] or PhanxFontDB.normal)

		if preview.Bubble then
			preview.Bubble:SetFont(file, PhanxFontDB.chatbubblesize, "")
		end

		local width = preview:GetWidth()

		for _, fontString in ipairs(preview.strings) do
			fontString:SetFont(file, kind == "damage" and DAMAGE_PREVIEW_SIZE or PREVIEW_SIZE, "")

			if width > 0 then
				fontString:SetWidth(width)
				fontString:SetText(fontString.sampleText)
			end
		end
	end
end

local function CreateFontPreview(kind)
	return function(panel)
		local preview = CreateFrame("Frame", nil, panel)
		preview:SetPoint("TOPLEFT", 30, -10)
		preview:SetPoint("BOTTOMRIGHT", -30, 10)
		preview.strings = {}

		local centred = kind == "damage"

		local previous
		for _, text in ipairs(SampleTexts(kind)) do
			local fontString = preview:CreateFontString(nil, "ARTWORK", "GameFontNormal")
			fontString:SetJustifyH(centred and "CENTER" or "LEFT")
			fontString:SetTextColor(NORMAL_FONT_COLOR:GetRGB())

			fontString:SetWordWrap(true)
			fontString:SetNonSpaceWrap(true)

			fontString.sampleText = text

			if previous then
				fontString:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -6)
			elseif centred then
				fontString:SetPoint("CENTER")
			else
				fontString:SetPoint("TOPLEFT")
			end

			table.insert(preview.strings, fontString)
			previous = fontString
		end

		previews[kind] = preview
		preview:SetScript("OnSizeChanged", RefreshPreview)
		RefreshPreview()

		return preview
	end
end

local function CreateBubblePreview(panel)
	local preview = CreateFrame("Frame", nil, panel)
	preview:SetAllPoints()
	preview.strings = {}

	local bubble = CreateFrame("Frame", nil, preview, "ChatBubbleTemplate")
	bubble.String:SetPoint("CENTER", preview, "CENTER")
	bubble.String:SetText(L["BubbleText"])
	bubble.String:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
	bubble.Tail:Hide()

	preview.Bubble = bubble.String

	previews.bubble = preview
	RefreshPreview()

	return preview
end

local function SetFont(key, value)
	PhanxFontDB[key] = value
	Addon:SetFonts()
	RefreshPreview()
end

local function CreateFontRow(key)
	return function(rowFrame)
		return Addon:CreateMediaDropdown(rowFrame, "font", function()
			return PhanxFontDB[key]
		end, function(value)
			SetFont(key, value)
		end)
	end
end

local function ResetFont(key)
	return function()
		SetFont(key, Addon.Defaults[key])
	end
end

Addon:RegisterSettings("PhanxFontDB", {
	{
		type = "custom",
		title = L["Normal Font"],
		createControl = CreateFontRow("normal"),
		onDefaults = ResetFont("normal"),
	},
	{
		type = "preview",
		height = 95,
		createPreview = CreateFontPreview("normal"),
	},
	{
		type = "custom",
		title = L["Bold Font"],
		createControl = CreateFontRow("bold"),
		onDefaults = ResetFont("bold"),
	},
	{
		type = "preview",
		height = 95,
		createPreview = CreateFontPreview("bold"),
	},
	{
		key = "scale",
		type = "slider",
		title = L["Scale"],
		tooltip = L["ScaleTooltip"],
		default = Addon.Defaults.scale,
		minValue = 0.5,
		maxValue = 2,
		valueStep = 0.05,
		valueFormat = "%.2f",
	},
	{
		type = "custom",
		title = L["Damage Font"],
		tooltip = L["DamageFontTooltip"],
		createControl = CreateFontRow("damage"),
		onDefaults = ResetFont("damage"),
	},
	{
		type = "preview",
		height = 55,
		createPreview = CreateFontPreview("damage"),
	},
	{
		key = "damagescale",
		type = "slider",
		title = L["Damage Scale"],
		default = Addon.Defaults.damagescale,
		minValue = 0.5,
		maxValue = 4,
		valueStep = 0.05,
		valueFormat = "%.2f",
	},
	{
		key = "chatbubblesize",
		type = "slider",
		title = L["Chatbubble Size"],
		default = Addon.Defaults.chatbubblesize,
		minValue = 12,
		maxValue = 32,
		valueStep = 1,
	},
	{
		type = "preview",
		height = 80,
		createPreview = CreateBubblePreview,
	},
})

for _, key in ipairs({"scale", "damagescale", "chatbubblesize"}) do
	Addon:RegisterOptionCallback(key, function()
		Addon:SetFonts()
		RefreshPreview()
	end)
end

------------------------------------------------------------------------

local MIN_FONT_SIZE = 6
local MAX_FONT_SIZE = 72
local ROW_HEIGHT = 32
local SLIDER_WIDTH = 200

-- the template anchors its value label 25 points right of the slider, which is itself inset 19
-- from the frame's edge, so the text lands outside the frame and needs room reserved for it
local SLIDER_VALUE_INSET = 46
local SLIDER_VALUE_LABEL = MinimalSliderWithSteppersMixin.Label.Right

local SLIDER_FORMATTERS = {
	[SLIDER_VALUE_LABEL] = function(value)
		return tostring(math.floor(value))
	end,
}

local sizeList

local function SortedFontNames()
	local names = {}
	for name in next, Addon.Sizes do
		if not (Addon.OwnSetting[name] or Addon.FixedSize[name])
			and (PhanxFontDB.showderived or Addon.Objects[name] or PhanxFontDB.sizes[name]) then
			table.insert(names, name)
		end
	end

	table.sort(names)
	return names
end

local function CurrentSize(name)
	return Addon:GetFontSize(name) or MIN_FONT_SIZE
end

-- a handful of the game's own fonts are far larger than anything worth offering as a default
-- ceiling, so those rows stretch to fit rather than every row carrying their range
local function SizeRange(name)
	local largest = math.max(MAX_FONT_SIZE, Addon.Sizes[name] or 0, CurrentSize(name))
	return MIN_FONT_SIZE, math.ceil(largest)
end

local function InitSizeRow(row, data)
	if not row.Label then
		row.Label = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		row.Label:SetPoint("LEFT", 8, 0)
		row.Label:SetJustifyH("LEFT")
		row.Label:SetWordWrap(false)

		row.Slider = CreateFrame("Frame", nil, row, "MinimalSliderWithSteppersTemplate")
		row.Slider:SetWidth(SLIDER_WIDTH)
		row.Slider:SetPoint("RIGHT", -SLIDER_VALUE_INSET, 0)

		row.Label:SetPoint("RIGHT", row.Slider, "LEFT", -10, 0)

		-- registered once per recycled row, so the current name is read when the value changes
		-- rather than captured here
		row.Slider:RegisterCallback(MinimalSliderWithSteppersMixin.Event.OnValueChanged, function(_, value)
			if row.name and not row.settingUp then
				PhanxFontDB.sizes[row.name] = value
				Addon:SetFonts()
			end
		end, row)
	end

	row.name = data.name
	local family = PhanxFontDB.showderived and Addon.Objects[data.name]
	row.Label:SetText(family and L["FontFamilyName"]:format(data.name) or data.name)

	local minValue, maxValue = SizeRange(data.name)

	row.settingUp = true
	row.Slider:Init(CurrentSize(data.name), minValue, maxValue, maxValue - minValue, SLIDER_FORMATTERS)
	row.settingUp = nil
end

local function RefreshSizeList()
	if not sizeList then return end

	local filter = sizeList.Search:GetText():lower()
	local provider = CreateDataProvider()

	for _, name in ipairs(sizeList.names) do
		if filter == "" or name:lower():find(filter, 1, true) then
			provider:Insert({ name = name })
		end
	end

	sizeList.ScrollBox:SetDataProvider(provider)
end

local function CreateSizeCanvas(canvas)
	local description = canvas:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	description:SetPoint("TOPLEFT", 16, -16)
	description:SetPoint("TOPRIGHT", -16, -16)
	description:SetJustifyH("LEFT")
	description:SetText(L["FontSizesDescription"])

	-- the template's hover highlight anchors to its parent's parent, expecting to sit in a settings
	-- row, so it needs a row of its own or it lights up the whole page
	local toggleRow = CreateFrame("Frame", nil, canvas)
	toggleRow:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, -12)
	toggleRow:SetPoint("TOPRIGHT", description, "BOTTOMRIGHT", 0, -12)
	toggleRow:SetHeight(30)

	local blizzardSizes = CreateFrame("CheckButton", nil, toggleRow, "SettingsCheckboxTemplate")
	blizzardSizes:SetPoint("LEFT")
	-- called with no arguments, after OnEnter has made SettingsTooltip the owner
	blizzardSizes:Init(PhanxFontDB.blizzardsizes, function()
		GameTooltip_AddNormalLine(SettingsTooltip, L["DisableSizeOverridesTooltip"])
	end)
	blizzardSizes:RegisterCallback(SettingsCheckboxMixin.Event.OnValueChanged, function(_, checked)
		PhanxFontDB.blizzardsizes = checked
		Addon:SetFonts()
		RefreshSizeList()
	end, blizzardSizes)

	blizzardSizes.HoverBackground:ClearAllPoints()
	blizzardSizes.HoverBackground:SetPoint("TOPLEFT", toggleRow)
	blizzardSizes.HoverBackground:SetPoint("BOTTOMRIGHT", toggleRow)

	local blizzardLabel = toggleRow:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	blizzardLabel:SetPoint("LEFT", blizzardSizes, "RIGHT", 6, 0)
	blizzardLabel:SetText(L["DisableSizeOverrides"])

	local derivedRow = CreateFrame("Frame", nil, canvas)
	derivedRow:SetPoint("TOPLEFT", toggleRow, "BOTTOMLEFT", 0, 0)
	derivedRow:SetPoint("TOPRIGHT", toggleRow, "BOTTOMRIGHT", 0, 0)
	derivedRow:SetHeight(30)

	local showDerived = CreateFrame("CheckButton", nil, derivedRow, "SettingsCheckboxTemplate")
	showDerived:SetPoint("LEFT")
	showDerived:Init(PhanxFontDB.showderived, function()
		GameTooltip_AddNormalLine(SettingsTooltip, L["ShowDerivedFontsTooltip"])
	end)
	showDerived:RegisterCallback(SettingsCheckboxMixin.Event.OnValueChanged, function(_, checked)
		PhanxFontDB.showderived = checked
		sizeList.names = SortedFontNames()
		RefreshSizeList()
	end, showDerived)

	showDerived.HoverBackground:ClearAllPoints()
	showDerived.HoverBackground:SetPoint("TOPLEFT", derivedRow)
	showDerived.HoverBackground:SetPoint("BOTTOMRIGHT", derivedRow)

	local derivedLabel = derivedRow:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	derivedLabel:SetPoint("LEFT", showDerived, "RIGHT", 6, 0)
	derivedLabel:SetText(L["ShowDerivedFonts"])

	-- one container, so the search box and the list resolve to the same width whatever size the
	-- canvas ends up
	local body = CreateFrame("Frame", nil, canvas)
	body:SetPoint("TOPLEFT", derivedRow, "BOTTOMLEFT", 8, -8)
	body:SetPoint("BOTTOMRIGHT", canvas, "BOTTOMRIGHT", -16, 16)

	local search = CreateFrame("EditBox", nil, body, "SearchBoxTemplate")
	search:SetPoint("TOPLEFT")
	search:SetPoint("TOPRIGHT")
	search:SetHeight(22)
	search:SetScript("OnTextChanged", function(self)
		SearchBoxTemplate_OnTextChanged(self)
		RefreshSizeList()
	end)

	local scrollBox = CreateFrame("Frame", nil, body, "WowScrollBoxList")
	scrollBox:SetPoint("TOPLEFT", search, "BOTTOMLEFT", 0, -10)
	scrollBox:SetPoint("BOTTOMRIGHT", body, "BOTTOMRIGHT", -24, 0)

	local scrollBar = CreateFrame("EventFrame", nil, body, "MinimalScrollBar")
	scrollBar:SetPoint("TOPLEFT", scrollBox, "TOPRIGHT", 8, 0)
	scrollBar:SetPoint("BOTTOMLEFT", scrollBox, "BOTTOMRIGHT", 8, 0)

	local view = CreateScrollBoxListLinearView()
	view:SetElementExtent(ROW_HEIGHT)
	view:SetElementInitializer("Frame", InitSizeRow)
	ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, view)

	sizeList = {
		Search = search,
		ScrollBox = scrollBox,
		BlizzardSizes = blizzardSizes,
		ShowDerived = showDerived,
		names = SortedFontNames(),
	}

	canvas:SetDefaultsHandler(function()
		wipe(PhanxFontDB.sizes)
		PhanxFontDB.blizzardsizes = Addon.Defaults.blizzardsizes
		PhanxFontDB.showderived = Addon.Defaults.showderived
		blizzardSizes:SetValue(PhanxFontDB.blizzardsizes)
		showDerived:SetValue(PhanxFontDB.showderived)
		Addon:SetFonts()
		sizeList.names = SortedFontNames()
		RefreshSizeList()
	end)

	RefreshSizeList()
end

Addon:RegisterSubSettingsCanvas(L["Font Sizes"], CreateSizeCanvas)

Addon:RegisterSettingsSlash("/font", "/phanxfont")
