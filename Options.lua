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
		default = Addon.Defaults.scale,
		minValue = 0.5,
		maxValue = 2,
		valueStep = 0.05,
		valueFormat = "%.2f",
	},
	{
		type = "custom",
		title = L["Damage Font"],
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

Addon:RegisterSettingsSlash("/font", "/phanxfont")
