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

local ADDON, Addon = ...
_G.PhanxFont = Addon

Addon.Retail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

PhanxFontDB = {
	normal = "Lato",
	bold   = "Lato Black",
	damage = "Lato Black",
	scale  = 1,
	damagescale = 2,
	chatbubblesize = 16,
}

local NORMAL       = [[Interface\AddOns\PhanxMedia\font\Lato.ttf]]
local BOLD         = [[Interface\AddOns\PhanxMedia\font\Lato-Black.otf]]
local DAMAGE       = [[Interface\AddOns\PhanxMedia\font\Lato-Black.otf]]
local BOLDITALIC   = BOLD
local ITALIC       = NORMAL
local NUMBER       = BOLD

------------------------------------------------------------------------

function Addon:SetFont(obj, font, size, style, r, g, b, sr, sg, sb, sox, soy)
	if not obj then return end
	if not size then
		size = select(2, obj:GetFont())
	end
	if not style then
		style = select(3, obj:GetFont())
	end
	obj:SetFont(font, floor(size * PhanxFontDB.scale + 0.5), style or "")
	if sr and sg and sb then
		obj:SetShadowColor(sr, sg, sb)
	end
	if sox and soy then
		obj:SetShadowOffset(sox, soy)
	end
	if r and g and b then
		obj:SetTextColor(r, g, b)
	elseif r then
		obj:SetAlpha(r)
	end
end

function Addon:SetFonts(event, addon)
	NORMAL     = LibStub("LibSharedMedia-3.0"):Fetch("font", PhanxFontDB.normal)
	BOLD       = LibStub("LibSharedMedia-3.0"):Fetch("font", PhanxFontDB.bold)
	DAMAGE     = LibStub("LibSharedMedia-3.0"):Fetch("font", PhanxFontDB.damage)
	BOLDITALIC = BOLD
	ITALIC     = NORMAL
	NUMBER     = BOLD

	UNIT_NAME_FONT     = NORMAL
	NAMEPLATE_FONT     = BOLD
	DAMAGE_TEXT_FONT   = DAMAGE
	STANDARD_TEXT_FONT = NORMAL

	-- Parsed from Fonts.xml and SharedFonts.xml
	self:SetFont(AchievementFont_Small,                     NORMAL, 10, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(ChatBubbleFont,                            NORMAL, 13, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(CoreAbilityFont,                           NORMAL, 32, "", 0.1, 0.1, 0.1, nil, nil, nil, nil, nil)
	self:SetFont(DestinyFontHuge,                           NORMAL, 32, "", 0.1, 0.1, 0.1, nil, nil, nil, nil, nil)
	self:SetFont(DestinyFontLarge,                          NORMAL, 18, "", 0.1, 0.1, 0.1, nil, nil, nil, nil, nil)
	self:SetFont(DestinyFontMed,                            NORMAL, 14, "", 0.1, 0.1, 0.1, nil, nil, nil, nil, nil)
	self:SetFont(Fancy12Font,                               NORMAL, 12, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Fancy14Font,                               NORMAL, 14, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Fancy16Font,                               NORMAL, 16, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Fancy18Font,                               NORMAL, 18, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Fancy20Font,                               NORMAL, 20, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Fancy22Font,                               NORMAL, 22, "", 1, .82, 0, nil, nil, nil, nil, nil)
	self:SetFont(Fancy24Font,                               NORMAL, 24, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Fancy27Font,                               NORMAL, 27, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Fancy30Font,                               NORMAL, 30, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Fancy32Font,                               NORMAL, 32, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Fancy36Font,                               NORMAL, 36, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Fancy40Font,                               NORMAL, 40, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Fancy48Font,                               NORMAL, 48, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(FriendsFont_11,                            NORMAL, 11, "", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(FriendsFont_Large,                         NORMAL, 14, "", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(FriendsFont_Normal,                        NORMAL, 12, "", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(FriendsFont_Small,                         NORMAL, 10, "", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(FriendsFont_UserText,                      NORMAL, 11, "", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(Game10Font_o1,                             NORMAL, 10, "OUTLINE", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Game11Font_o1,                             NORMAL, 11, "OUTLINE", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Game11Font_Shadow,                         NORMAL, 11, "", nil, nil, nil, 0, 0, 0, nil, nil)
	self:SetFont(Game11Font,                                NORMAL, 11, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Game120Font,                               NORMAL, 120, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Game12Font_o1,                             NORMAL, 12, "OUTLINE", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Game12Font,                                NORMAL, 12, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Game13Font_o1,                             NORMAL, 13, "OUTLINE", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Game13Font,                                NORMAL, 13, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Game13FontShadow,                          NORMAL, 13, "", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(Game15Font_o1,                             NORMAL, 15, "OUTLINE", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Game15Font_Shadow,                         NORMAL, 15, "", nil, nil, nil, 0, 0, 0, nil, nil)
	self:SetFont(Game15Font,                                NORMAL, 15, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Game16Font,                                NORMAL, 16, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Game17Font_Shadow,                         NORMAL, 17, "", nil, nil, nil, 0, 0, 0, nil, nil)
	self:SetFont(Game18Font,                                NORMAL, 18, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Game19Font,                                NORMAL, 19, "", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(Game20Font,                                NORMAL, 20, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Game21Font,                                NORMAL, 21, "", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(Game22Font,                                NORMAL, 22, "", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(Game24Font,                                NORMAL, 24, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Game27Font,                                NORMAL, 27, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Game30Font,                                NORMAL, 30, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Game32Font_Shadow2,                        NORMAL, 32, "", nil, nil, nil, 0, 0, 0, nil, nil)
	self:SetFont(Game32Font,                                NORMAL, 32, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Game36Font_Shadow2,                        NORMAL, 36, "", nil, nil, nil, 0, 0, 0, nil, nil)
	self:SetFont(Game36Font,                                NORMAL, 36, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Game40Font_Shadow2,                        NORMAL, 40, "", nil, nil, nil, 0, 0, 0, nil, nil)      
	self:SetFont(Game40Font,                                NORMAL, 40, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Game42Font,                                NORMAL, 42, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Game46Font_Shadow2,                        NORMAL, 46, "", nil, nil, nil, 0, 0, 0, nil, nil)
	self:SetFont(Game46Font,                                NORMAL, 46, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Game48Font,                                NORMAL, 48, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Game48FontShadow,                          NORMAL, 48, "", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(Game52Font_Shadow2,                        NORMAL, 52, "", nil, nil, nil, 0, 0, 0, nil, nil)
	self:SetFont(Game58Font_Shadow2,                        NORMAL, 58, "", nil, nil, nil, 0, 0, 0, nil, nil)
	self:SetFont(Game60Font,                                NORMAL, 60, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Game69Font_Shadow2,                        NORMAL, 69, "", nil, nil, nil, 0, 0, 0, nil, nil)      
	self:SetFont(Game72Font_Shadow,                         NORMAL, 72, "", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(Game72Font,                                NORMAL, 72, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(GameFont_Gigantic,                         NORMAL, 32, "", 1.0, 0.82, 0, 0.0, 0.0, 0.0, 1, -1)
	self:SetFont(GameTooltipHeader,                         NORMAL, 14, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(InvoiceFont_Med,                           NORMAL, 12, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(InvoiceFont_Small,                         NORMAL, 10, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(MailFont_Large,                            NORMAL, 15, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Number11Font,                              NORMAL, 11, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Number12Font_o1,                           NORMAL, 12, "OUTLINE", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Number12Font,                              NORMAL, 12, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Number12FontOutline,                       NORMAL, 12, "OUTLINE", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Number13Font,                              NORMAL, 13, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Number15Font,                              NORMAL, 15, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Number16Font,                              NORMAL, 16, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Number18Font,                              NORMAL, 18, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(NumberFont_GameNormal,                     NORMAL, 10, "", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(NumberFont_Normal_Med,                     NORMAL, 14, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(NumberFont_Outline_Huge,                   NORMAL, 30, "OUTLINE", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(NumberFont_Outline_Large,                  NORMAL, 16, "OUTLINE", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(NumberFont_Outline_Med,                    NORMAL, 14, "OUTLINE", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(NumberFont_OutlineThick_Mono_Small,        NORMAL, 12, "OUTLINE", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(NumberFont_Shadow_Large,                   NORMAL, 20, "", nil, nil, nil, 0, 0, 0, nil, nil)
	self:SetFont(NumberFont_Shadow_Med,                     NORMAL, 14, "", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(NumberFont_Shadow_Small,                   NORMAL, 12, "", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(NumberFont_Shadow_Tiny,                    NORMAL, 10, "", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(NumberFont_Small,                          NORMAL, 12, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(ObjectiveTrackerFont12,                    NORMAL, 12, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(ObjectiveTrackerFont13,                    NORMAL, 13, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(ObjectiveTrackerFont14,                    NORMAL, 14, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(ObjectiveTrackerFont15,                    NORMAL, 15, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(ObjectiveTrackerFont16,                    NORMAL, 16, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(ObjectiveTrackerFont17,                    NORMAL, 17, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(ObjectiveTrackerFont18,                    NORMAL, 18, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(ObjectiveTrackerFont19,                    NORMAL, 19, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(ObjectiveTrackerFont20,                    NORMAL, 20, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(ObjectiveTrackerFont21,                    NORMAL, 21, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(ObjectiveTrackerFont22,                    NORMAL, 22, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(OrderHallTalentRowFont,                    NORMAL, 18, "", 0.9, 0.8, 0.5, nil, nil, nil, nil, nil)
	self:SetFont(PriceFont,                                 NORMAL, 14, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(QuestFont_30,                              NORMAL, 30, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(QuestFont_39,                              NORMAL, 39, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(QuestFont_Enormous,                        NORMAL, 30, "", 1, .82, 0, nil, nil, nil, nil, nil)
	self:SetFont(QuestFont_Huge,                            NORMAL, 18, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(QuestFont_Large,                           NORMAL, 15, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(QuestFont_Outline_Huge,                    NORMAL, 18, "OUTLINE", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(QuestFont_Shadow_Small,                    NORMAL, 14, "", nil, nil, nil, 0.49, 0.35, 0.05, 1, -1)
	self:SetFont(QuestFont_Super_Huge_Outline,              NORMAL, 24, "OUTLINE", 1, .82, 0, nil, nil, nil, nil, nil)
	self:SetFont(QuestFont_Super_Huge,                      NORMAL, 24, "", 1, .82, 0, nil, nil, nil, nil, nil)
	self:SetFont(ReputationDetailFont,                      NORMAL, 10, "", 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 1, -1)
	self:SetFont(SpellFont_Small,                           NORMAL, 10, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(SplashHeaderFont,                          NORMAL, 24, "", 1, .82, 0, 0, 0, 0, 1, -2)
	self:SetFont(System_IME,                                NORMAL, 16, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(System15Font,                              NORMAL, 15, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(SystemFont_Huge1_Outline,                  NORMAL, 20, "OUTLINE", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(SystemFont_Huge1,                          NORMAL, 20, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(SystemFont_Huge2,                          NORMAL, 24, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(SystemFont_Huge4,                          NORMAL, 27, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(SystemFont_InverseShadow_Small,            NORMAL, 10, "", nil, nil, nil, .4, .4, .4, 1, -1)
	self:SetFont(SystemFont_Large,                          NORMAL, 16, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(SystemFont_Large2,                         NORMAL, 18, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(SystemFont_LargeNamePlate,                 NORMAL, 12, "", nil, nil, nil, 0, 0, 0, nil, nil)
	self:SetFont(SystemFont_LargeNamePlateFixed,            NORMAL, 20, "", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(SystemFont_Med1,                           NORMAL, 12, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(SystemFont_Med2,                           NORMAL, 13, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(SystemFont_Med3,                           NORMAL, 14, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(SystemFont_NamePlate,                      NORMAL, 9, "", nil, nil, nil, 0, 0, 0, nil, nil)
	self:SetFont(SystemFont_NamePlateCastBar,               NORMAL, 10, "OUTLINE", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(SystemFont_NamePlateFixed,                 NORMAL, 14, "", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(SystemFont_Outline_Small,                  NORMAL, 10, "OUTLINE", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(SystemFont_Outline_WTF2,                   NORMAL, 36, "OUTLINE", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(SystemFont_Outline,                        NORMAL, 13, "OUTLINE", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(SystemFont_OutlineThick_Huge2,             NORMAL, 22, "THICKOUTLINE", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(SystemFont_OutlineThick_Huge4,             NORMAL, 26, "THICKOUTLINE", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(SystemFont_OutlineThick_WTF,               NORMAL, 32, "THICKOUTLINE", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(SystemFont_Shadow_Huge1_Outline,           NORMAL, 20, "OUTLINE", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(SystemFont_Shadow_Huge1,                   NORMAL, 20, "", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(SystemFont_Shadow_Huge2_Outline,           NORMAL, 24, "OUTLINE", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(SystemFont_Shadow_Huge2,                   NORMAL, 24, "", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(SystemFont_Shadow_Huge3,                   NORMAL, 25, "", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(SystemFont_Shadow_Huge4_Outline,           NORMAL, 27, "OUTLINE", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(SystemFont_Shadow_Huge4,                   NORMAL, 27, "", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(SystemFont_Shadow_Large_Outline,           NORMAL, 16, "OUTLINE", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(SystemFont_Shadow_Large,                   NORMAL, 16, "", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(SystemFont_Shadow_Large2_Outline,          NORMAL, 18, "OUTLINE", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(SystemFont_Shadow_Large2,                  NORMAL, 18, "", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(SystemFont_Shadow_Med1_Outline,            NORMAL, 12, "OUTLINE", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(SystemFont_Shadow_Med1,                    NORMAL, 12, "", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(SystemFont_Shadow_Med2_Outline,            NORMAL, 14, "OUTLINE", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(SystemFont_Shadow_Med2,                    NORMAL, 14, "", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(SystemFont_Shadow_Med3_Outline,            NORMAL, 14, "OUTLINE", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(SystemFont_Shadow_Med3,                    NORMAL, 14, "", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(SystemFont_Shadow_Outline_Huge3,           NORMAL, 25, "OUTLINE", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(SystemFont_Shadow_Small_Outline,           NORMAL, 10, "OUTLINE", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(SystemFont_Shadow_Small,                   NORMAL, 10, "", nil, nil, nil, 0, 0, 0, nil, nil)
	self:SetFont(SystemFont_Shadow_Small2_Outline,          NORMAL, 11, "OUTLINE", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(SystemFont_Shadow_Small2,                  NORMAL, 11, "", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(SystemFont_Small,                          NORMAL, 10, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(SystemFont_Small2,                         NORMAL, 11, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(SystemFont_Tiny,                           NORMAL, 9, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(SystemFont_Tiny2,                          NORMAL, 8, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(SystemFont_World_ThickOutline,             NORMAL, 64, "THICKOUTLINE", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(SystemFont_World,                          NORMAL, 64, "", nil, nil, nil, 0, 0, 0, 1, -1)
	self:SetFont(SystemFont_WTF2,                           NORMAL, 36, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(SystemFont16_Shadow_ThickOutline,          NORMAL, 16, "THICKOUTLINE", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(SystemFont18_Shadow_ThickOutline,          NORMAL, 18, "THICKOUTLINE", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(SystemFont22_Outline,                      NORMAL, 22, "OUTLINE", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(SystemFont22_Shadow_Outline,               NORMAL, 22, "OUTLINE", nil, nil, nil, 0, 0, 0, 2, -2)
	self:SetFont(SystemFont22_Shadow_ThickOutline,          NORMAL, 18, "THICKOUTLINE", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Tooltip_Med,                               NORMAL, 12, "", nil, nil, nil, nil, nil, nil, nil, nil)
	self:SetFont(Tooltip_Small,                             NORMAL, 10, "", nil, nil, nil, nil, nil, nil, nil, nil)

	-- Override
	self:SetFont(AchievementFont_Small,              NORMAL, 12)
	self:SetFont(ChatBubbleFont,                     NORMAL, PhanxFontDB.chatbubblesize)
	self:SetFont(FriendsFont_Large,                  NORMAL, 15)
	self:SetFont(FriendsFont_Normal,                 NORMAL, 13)
	self:SetFont(FriendsFont_Small,                  NORMAL, 13)
	self:SetFont(FriendsFont_UserText,               NORMAL, 13)
	self:SetFont(GameTooltipHeader,                  NORMAL, 15)
	self:SetFont(InvoiceFont_Med,                    ITALIC, 13)
	self:SetFont(InvoiceFont_Small,                  ITALIC, 11)
	self:SetFont(Number12Font,                       NUMBER, 13)
	self:SetFont(Number12FontOutline,                NUMBER, 13)
	self:SetFont(NumberFont_GameNormal,              NUMBER, 13)
	self:SetFont(NumberFont_Outline_Large,           NUMBER, 17)
	self:SetFont(NumberFont_Outline_Med,             NUMBER, 15)
	self:SetFont(NumberFont_OutlineThick_Mono_Small, NUMBER, 13)
	self:SetFont(NumberFont_Shadow_Tiny,             NUMBER, 11)
	self:SetFont(ObjectiveTrackerFont12,             NORMAL, 13)
	self:SetFont(QuestFont_Large,                    NORMAL, 16)
	self:SetFont(QuestFont_Shadow_Small,             NORMAL, 16)
	self:SetFont(ReputationDetailFont,                 BOLD, 12)
	self:SetFont(SpellFont_Small,                      BOLD, 11)
	self:SetFont(SystemFont_InverseShadow_Small,       BOLD, 11)
	self:SetFont(SystemFont_Large,                   NORMAL, 17)
	self:SetFont(SystemFont_Large2,                  NORMAL, 19)
	self:SetFont(SystemFont_Med1,                    NORMAL, 13)
	self:SetFont(SystemFont_Med2,                    NORMAL, 14)
	self:SetFont(SystemFont_Med3,                    NORMAL, 15)
	self:SetFont(SystemFont_Outline_Small,           NUMBER, 13)
	self:SetFont(SystemFont_Shadow_Med1_Outline,     NORMAL, 13)
	self:SetFont(SystemFont_Shadow_Med1,             NORMAL, 13)
	self:SetFont(SystemFont_Shadow_Small_Outline,    NORMAL, 13)
	self:SetFont(SystemFont_Shadow_Small,            NORMAL, 13)
	self:SetFont(SystemFont_Shadow_Small2_Outline,   NORMAL, 13)
	self:SetFont(SystemFont_Shadow_Small2,           NORMAL, 13)
	self:SetFont(SystemFont_Small,                   NORMAL, 12)
	self:SetFont(SystemFont_Small2,                  NORMAL, 12)
	self:SetFont(SystemFont_Tiny,                    NORMAL, 11)
	self:SetFont(SystemFont_Tiny2,                   NORMAL, 10)
	self:SetFont(Tooltip_Med,                        NORMAL, 13)
	self:SetFont(Tooltip_Small,                      NORMAL, 12)

	-- Derived fonts in FontStyles.xml
	self:SetFont(BossEmoteNormalHuge,                  BOLD, 27, "THICKOUTLINE")
	self:SetFont(CombatTextFont,                     DAMAGE, 26)
	self:SetFont(ErrorFont,                            BOLD, 31, "OUTLINE", nil, nil, nil, nil, nil, nil, 1, -1)
	self:SetFont(QuestFontNormalSmall,                 BOLD, 13, "", nil, nil, nil, 0.54, 0.4, 0.1)
	self:SetFont(WorldMapTextFont,                     BOLD, 31, "THICKOUTLINE", nil, nil, nil, nil, nil, nil, 1, -1)

	--[[ Fancy stuff!
	self:SetFont(ZoneTextFont,           BOLD, 31, "THICKOUTLINE")
	self:SetFont(SubZoneTextFont,        BOLD, 27, "THICKOUTLINE")
	self:SetFont(PVPInfoTextFont,      NORMAL, 22, "THICKOUTLINE")
	]]

	-- Chat frames
	local _, size = ChatFrame1:GetFont()
	FCF_SetChatWindowFontSize(nil, ChatFrame1, size)

	-- CombatTextFont scale
	local SetCVar = C_CVar and C_CVar.SetCVar or SetCVar
	SetCVar("WorldTextScale", PhanxFontDB.damagescale)

	-- Fix for adventure journal
	if addon == "Blizzard_EncounterJournal" then
		self:SetFont(EncounterJournalSuggestFrame.Suggestion1.centerDisplay.description.text, NORMAL, 15)
	end

	-- WorldMap Bounty board
	if WorldMapFrame.overlayFrames then
		self:SetFont(WorldMapFrame.overlayFrames[4].BountyName, NORMAL, 16, "OUTLINE", nil, nil, nil, nil, nil, nil, 1, -1)
	end

	if Addon.Retail then
		-- There is something wonky with the Blizzard template, so we have to manually style them.
		self:SetFont(LFGListFrame.ApplicationViewer.NameColumnHeader.Label, NORMAL, 12)
		self:SetFont(LFGListFrame.ApplicationViewer.RoleColumnHeader.Label, NORMAL, 12)
		self:SetFont(LFGListFrame.ApplicationViewer.ItemLevelColumnHeader.Label, NORMAL, 12)
		self:SetFont(LFGApplicationViewerRatingColumnHeader.Label, NORMAL, 12) -- Blizz?!
	end
end

------------------------------------------------------------------------

local f = CreateFrame("Frame", "PhanxFont")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, addon)
	UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = 14
	CHAT_FONT_HEIGHTS = { 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24 }

	Addon:SetFonts(event, addon)

	if PaperDollTitlesPane then
		for _, button in pairs(PaperDollTitlesPane.buttons) do
			button.text:SetFontObject(GameFontHighlightSmallLeft)
		end
	end

	BattlePetTooltip.Name:SetFontObject(GameTooltipHeaderText)
	FloatingBattlePetTooltip.Name:SetFontObject(GameTooltipHeaderText)

	LFGListFrame.CategorySelection.CategoryButtons[1].Label:SetFontObject(GameFontNormal)
	WorldMapFrameHomeButtonText:SetFontObject(GameFontNormal)
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

if Addon.Retail then
	hooksecurefunc("BattlePetToolTip_Show", function()
		BattlePetTooltip:SetHeight(BattlePetTooltip:GetHeight() + 12)
	end)

	hooksecurefunc("FloatingBattlePet_Show", function()
		FloatingBattlePetTooltip:SetHeight(FloatingBattlePetTooltip:GetHeight() + 12)
	end)
end
