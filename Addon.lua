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

local ADDON_NAME, ns = ...
_G.PhanxFont = ns

ns.Retail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

-- the resolved font files, for PhanxFont_Plugins
ns.Fonts = {}

local function FindMediaName(mediaType, path)
	local media = LibStub("LibSharedMedia-3.0")
	path = path and path:lower()

	for _, name in ipairs(media:List(mediaType)) do
		local candidate = media:Fetch(mediaType, name)
		if candidate and candidate:lower() == path then
			return name
		end
	end
end

local DEFAULT_FONT = LibStub("LibSharedMedia-3.0"):GetDefault("font")

ns.Defaults = {
	normal = DEFAULT_FONT,
	bold   = DEFAULT_FONT,
	damage = FindMediaName("font", DAMAGE_TEXT_FONT) or DEFAULT_FONT,
	scale  = 1,
	damagescale = 2,
	chatbubblesize = 16,
	blizzardsizes = false,
	showderived = false,
	sizes = {},
}

PhanxFontDB = CopyTable(ns.Defaults)

-- the saved variables replace the table above once they load, which happens after this file runs,
-- so anything added to the defaults since the player last logged in has to be filled in later
local function ApplyDefaults()
	for key, value in next, ns.Defaults do
		if PhanxFontDB[key] == nil then
			PhanxFontDB[key] = type(value) == "table" and CopyTable(value) or value
		end
	end
end

--[[ PhanxFont.OwnSetting
Font objects sized by a setting of their own rather than by PhanxFont's opinion. Turning the
overrides off leaves them alone, and the font size list skips them.
--]]
ns.OwnSetting = {
	ChatBubbleFont = true,
}

local KEEP_OWN_SIZE = setmetatable({}, { __index = function(_, name)
	return ns.OwnSetting[name] or ns.FixedSize[name]
end })

--[[ PhanxFont.Sizes
The size each font object is given by the game, keyed by the font object's global name and filled in
as PhanxFont walks them. Used by the options to list what can be resized, and to put a size back.
--]]
ns.Sizes = {}

--[[ PhanxFont.Preferred
The size PhanxFont gives a font object instead of the game's own. Anything not listed keeps the size
the game gave it.
--]]
ns.Preferred = {
	AchievementDescriptionFont = 12,
	AchievementFont_Small      = 12,
	BossEmoteNormalHuge        = 27,
	ErrorFont                  = 20,
	FriendsFont_Large          = 15,
	FriendsFont_Normal         = 13,
	FriendsFont_Small          = 13,
	FriendsFont_UserText       = 13,
	GameTooltipHeader          = 15,
	InvoiceFont_Med            = 13,
	InvoiceFont_Small          = 11,
	NumberFont_GameNormal      = 12,
	ObjectiveTrackerFont12     = 13,
	QuestFontNormalSmall       = 13,
	ReputationDetailFont       = 12,
	SpellFont_Small            = 11,
	SystemFont_Outline_Small   = 12,
	SystemFont_Shadow_Med1     = 13,
	SystemFont_Shadow_Small    = 12,
	SystemFont_Shadow_Small2   = 12,
	Tooltip_Med                = 13,
	Tooltip_Small              = 13,
	WorldMapTextFont           = 27,
}

--[[ PhanxFont:GetFontSize(_name_)
The size the font object named _name_ ends up at: the size you set for it, or the game's own size
while the overrides are switched off, or the size PhanxFont prefers.
--]]
function ns:GetFontSize(name)
	if PhanxFontDB.sizes[name] then
		return PhanxFontDB.sizes[name]
	end

	if PhanxFontDB.blizzardsizes and not KEEP_OWN_SIZE[name] then
		return ns.Sizes[name]
	end

	return ns.Preferred[name] or ns.Sizes[name]
end

local NORMAL       = LibStub("LibSharedMedia-3.0"):Fetch("font", DEFAULT_FONT)
local BOLD         = NORMAL
local DAMAGE       = NORMAL
local BOLDITALIC   = BOLD
local ITALIC       = NORMAL
local NUMBER       = BOLD

------------------------------------------------------------------------

--[[ PhanxFont.Roles
Which replacement font each object gets, keyed by the font object's global name. Read from the file
the game gave it, on the first walk, before PhanxFont has replaced anything.
--]]
ns.Roles = {}

local FONT_ROLES = {
	["fonts\\frizqt__.ttf"]     = "normal",
	["fonts\\frizqt___cyr.ttf"] = "normal",
	["fonts\\2002.ttf"]         = "normal",
	["fonts\\arkai_t.ttf"]      = "normal",
	["fonts\\blei00d.ttf"]      = "normal",
	["fonts\\morpheus.ttf"]     = "bold",
	["fonts\\morpheus_cyr.ttf"] = "bold",
	["fonts\\2002b.ttf"]        = "bold",
	["fonts\\arkai_c.ttf"]      = "bold",
	["fonts\\bkai00m.ttf"]      = "bold",
	["fonts\\arialn.ttf"]       = "bold",
	["fonts\\skurri.ttf"]       = "damage",
	["fonts\\skurri_cyr.ttf"]   = "damage",
}

local OWN_SIZE = {
	ChatBubbleFont = function() return PhanxFontDB.chatbubblesize end,
}

--[[ PhanxFont:SetFont(_object_, _font_, _size_[, _style_])
Gives _object_ the _font_ file at _size_, keeping the colour and shadow the game gave it. _style_ is
the outline, and defaults to the one the object already has.
--]]
function ns:SetFont(object, font, size, style)
	if not object then return end

	local current, height, flags = object:GetFont()
	if not (font or current) then return end

	object:SetFont(font or current, floor((size or height) * PhanxFontDB.scale + 0.5), style or flags)
end

local function Record(name, object)
	local font, height = object:GetFont()
	if not font then return end

	if ns.Roles[name] == nil then
		ns.Roles[name] = FONT_ROLES[font:lower()] or "normal"
	end

	if ns.Sizes[name] == nil then
		ns.Sizes[name] = height
	end

	return true
end

local function Restyle(name, object)
	if not Record(name, object) then return end

	local font, height, flags = object:GetFont()

	if KEEP_OWN_SIZE[name] then
		local own = OWN_SIZE[name]
		object:SetFont(ns.Fonts[ns.Roles[name]] or font, own and own() or height, flags)
		return
	end

	local size = ns:GetFontSize(name) or height

	object:SetFont(ns.Fonts[ns.Roles[name]] or font, floor(size * PhanxFontDB.scale + 0.5), flags)
end

local function IsFontObject(object)
	if type(object) ~= "table" then return end
	if not (object.GetFont and object.CopyFontObject) then return end
	if object.GetFrameLevel or object.SetText then return end

	local ok, objectType = pcall(object.GetObjectType, object)
	return ok and objectType == "Font"
end

local function RestyleAll()
	for name, isFamily in pairs(ns.Objects) do
		local object = _G[name]
		if IsFontObject(object) then
			if isFamily or PhanxFontDB.sizes[name] then
				Restyle(name, object)
			else
				Record(name, object)
			end
		end
	end
end

function ns:SetFonts(event, addon)
	ApplyDefaults()

	NORMAL     = LibStub("LibSharedMedia-3.0"):Fetch("font", PhanxFontDB.normal)
	BOLD       = LibStub("LibSharedMedia-3.0"):Fetch("font", PhanxFontDB.bold)
	DAMAGE     = LibStub("LibSharedMedia-3.0"):Fetch("font", PhanxFontDB.damage)
	BOLDITALIC = BOLD
	ITALIC     = NORMAL
	NUMBER     = BOLD

	ns.Fonts.normal = NORMAL
	ns.Fonts.bold   = BOLD
	ns.Fonts.damage = DAMAGE

	UNIT_NAME_FONT     = NORMAL
	NAMEPLATE_FONT     = BOLD
	DAMAGE_TEXT_FONT   = DAMAGE
	STANDARD_TEXT_FONT = NORMAL

	RestyleAll()

	-- Chat frames
	local _, size = ChatFrame1:GetFont()
	FCF_SetChatWindowFontSize(nil, ChatFrame1, size)

	-- CombatTextFont scale
	local SetCVar = C_CVar and C_CVar.SetCVar or SetCVar
	SetCVar("WorldTextScale", PhanxFontDB.damagescale)

end

------------------------------------------------------------------------

local f = CreateFrame("Frame", "PhanxFont")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, addon)
	UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = 14
	CHAT_FONT_HEIGHTS = { 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24 }

	ns:SetFonts(event, addon)

	if BattlePetTooltip then
		BattlePetTooltip.Name:SetFontObject(GameTooltipHeaderText)
		FloatingBattlePetTooltip.Name:SetFontObject(GameTooltipHeaderText)
	end
end)

hooksecurefunc("FCF_SetChatWindowFontSize", function(self, frame, size)
	if not frame then
		frame = FCF_GetCurrentChatFrame()
	end
	if not size then
		size = self.value
	end

	-- Set all the other frames to the same size.
	for i = 1, 10 do
		local f = _G["ChatFrame"..i]
		if f then
			f:SetFont(NORMAL, size, "")
			SetChatWindowSize(i, size)
		end
	end

	-- Set the language override fonts to the same size.
	for _, f in pairs({
		ChatFontNormalKO,
		ChatFontNormalRU,
		ChatFontNormalZH,
	}) do
		local font, _, outline = f:GetFont()
		f:SetFont(font, size, outline)
	end
end)

if ns.Retail then
	hooksecurefunc("BattlePetToolTip_Show", function()
		BattlePetTooltip:SetHeight(BattlePetTooltip:GetHeight() + 12)
	end)

	hooksecurefunc("FloatingBattlePet_Show", function()
		FloatingBattlePetTooltip:SetHeight(FloatingBattlePetTooltip:GetHeight() + 12)
	end)
end
