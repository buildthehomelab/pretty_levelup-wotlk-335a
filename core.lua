---
-- /@ level up toast; based on pretty_lootalert by s0h2x, pretty_wow @/

local select = select;
local unpack = unpack;
local ipairs = ipairs;
local tonumber = tonumber;
local format = string.format;
local tRemove = table.remove;
local tInsert = table.insert;
local tWipe = table.wipe;

local private = select(2,...);
local config = private.config;
local mixin = private.Mixin;

-- /* config */
local scale = config.scale;
local offset_x = config.offset_x;
local point_x = config.point_x;
local point_y = config.point_y;
local uptime = config.time;
local spell_quality = config.spell_quality or 4;

local LEVELUPALERT_NUM_BUTTONS = config.numbuttons;

-- /* api's */
local PlaySoundFile = PlaySoundFile;
local GetSpellInfo = GetSpellInfo;
local GetSpellLink = GetSpellLink;
local GetSpellName = GetSpellName;
local GetSpellTexture = GetSpellTexture;
local GetTime = GetTime;
local GameTooltip = GameTooltip;

-- /* assets */
local assets = [[Interface\AddOns\pretty_levelup\assets\]];
local SOUND_SPELL_LEARNED = assets..(config.sound_file or "levelup.mp3");
local FALLBACK_ICON = [[Interface\Icons\INV_Misc_Book_09]];

-- /* consts */
local BORDER_BY_QUALITY = {
	[2] = {0.34082, 0.397461, 0.53125, 0.644531},
	[3] = {0.272461, 0.329102, 0.785156, 0.898438},
	[4] = {0.34082, 0.397461, 0.882812, 0.996094},
	[5] = {0.34082, 0.397461, 0.765625, 0.878906},
	[6] = {0.272461, 0.329102, 0.667969, 0.78125},
	[7] = {0.34082, 0.397461, 0.648438, 0.761719},
};

-- /* patterns */
local PATTERNS_LEARN_SPELL = {};
for _, str in ipairs({ERR_LEARN_SPELL_S, ERR_LEARN_ABILITY_S, ERR_LEARN_PASSIVE_S}) do
	if str then
		tInsert(PATTERNS_LEARN_SPELL, "^"..str:gsub("([%.%(%)%-%+%*%?%[%]])", "%%%1"):gsub("%%s", "(.+)"));
	end
end

-- /* tables */
local LevelUpAlertFrameMixIn = {};
LevelUpAlertFrameMixIn.alertQueue = {};
LevelUpAlertFrameMixIn.alertButton = {};

function LevelUpAlertFrameMixIn:AddAlert(name, link, texture, spellName, spellRank)
	tInsert(self.alertQueue, {
		name 		= name,
		link 		= link,
		texture 	= texture,
		spellName 	= spellName,
		spellRank 	= spellRank,
	});
end

-- name/rank lookups miss for ranked spells, so find the spell in the spellbook instead
local function FindInSpellBook(name, rank)
	local i = 1;
	while true do
		local bookName, bookRank = GetSpellName(i, BOOKTYPE_SPELL);
		if not bookName then return; end
		if bookName == name and (not rank or bookRank == rank) then
			return GetSpellLink(i, BOOKTYPE_SPELL), GetSpellTexture(i, BOOKTYPE_SPELL);
		end
		i = i + 1;
	end
end

-- fill in a missing link/icon; the spellbook may not have updated when the chat message arrived
local function ResolveSpell(data)
	if data.link or not data.spellName then return; end
	local link, icon = FindInSpellBook(data.spellName, data.spellRank);
	data.link = link;
	if icon and data.texture == FALLBACK_ICON then
		data.texture = icon;
	end
end

-- learned is either a spell link or plain text like "Frost Nova (Rank 1)"
function LevelUpAlertFrameMixIn:AddSpell(learned)
	local spellID = tonumber(learned:match("|Hspell:(%d+)"));
	local text = learned:match("|h%[(.-)%]|h") or learned;
	local name, rank = text:match("^(.-)%s*%((.+)%)$");
	name = name or text;

	local icon, link, spellName = nil, nil, name;
	if spellID then
		local spellName, spellRank, spellIcon = GetSpellInfo(spellID);
		name = spellName or name;
		rank = (spellRank ~= "" and spellRank) or rank;
		icon = spellIcon;
		link = GetSpellLink(spellID);
	else
		-- lookups by name only work as "Name(Rank N)" or plain "Name"
		local query = rank and format("%s(%s)", name, rank) or name;
		local bookLink, bookIcon = FindInSpellBook(name, rank);
		icon = bookIcon or select(3, GetSpellInfo(query)) or select(3, GetSpellInfo(name));
		link = bookLink or GetSpellLink(query);
	end

	if rank then
		name = format("%s |cffffffff(%s)|r", name, rank);
	end
	self:AddAlert(name, link, icon or FALLBACK_ICON, spellName, rank);
end

function LevelUpAlertFrameMixIn:CreateAlert()
	if #self.alertQueue > 0 then
		for i=1, LEVELUPALERT_NUM_BUTTONS do
			local button = self.alertButton[i];
			if button and not button:IsShown() then
				button.data = tRemove(self.alertQueue, 1);
				return button;
			end
		end
	end
	return nil;
end

function LevelUpAlertFrameMixIn:AdjustAnchors()
	local previousButton;
	for i=1, LEVELUPALERT_NUM_BUTTONS do
		local button = self.alertButton[i];
		if button then
			button:ClearAllPoints();
			if button:IsShown() then
				if button.waitAndAnimOut:GetProgress() <= 0.74 then
					if not previousButton then
						if DungeonCompletionAlertFrame1:IsShown() then
							button:SetPoint("BOTTOM", DungeonCompletionAlertFrame1, "TOP", point_x, point_y);
						else
							button:SetPoint("CENTER", DungeonCompletionAlertFrame1, "CENTER", point_x, point_y);
						end
					else
						button:SetPoint("BOTTOM", previousButton, "TOP", 0, offset_x);
					end
				end
				previousButton = button;
			end
		end
	end
end

function LevelUpAlertFrame_OnLoad(self)
	self.updateTime = uptime;

	self:RegisterEvent("CHAT_MSG_SYSTEM");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");

	mixin(self, LevelUpAlertFrameMixIn);
end

function LevelUpAlertFrame_OnEvent(self, event, ...)
	-- dual spec swaps and loading screens re-announce known spells, so ignore those for a moment
	if event == "PLAYER_ENTERING_WORLD" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
		self.spellMuteUntil = GetTime() + 5;
		return;
	end

	if event == "CHAT_MSG_SYSTEM" and GetTime() >= (self.spellMuteUntil or 0) then
		local message = ...;
		for _, pattern in ipairs(PATTERNS_LEARN_SPELL) do
			local learned = message:match(pattern);
			if learned then
				LevelUpAlertFrameMixIn:AddSpell(learned);
				break;
			end
		end
	end
end

function LevelUpAlertFrame_OnUpdate(self, elapsed)
	self.updateTime = self.updateTime - elapsed;
	if self.updateTime <= 0 then
		local alert = LevelUpAlertFrameMixIn:CreateAlert();
		if alert then
			alert:SetScale(scale);
			alert:ClearAllPoints();
			alert:Show();
			alert.animIn:Play();
			LevelUpAlertFrameMixIn:AdjustAnchors();
		end
		self.updateTime = uptime;
	end
end

function LevelUpAlertButtonTemplate_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	tInsert(LevelUpAlertFrameMixIn.alertButton, self);
end

function LevelUpAlertButtonTemplate_OnShow(self)
	local data = self.data;
	if not data or not data.name then
		self:Hide();
		return;
	end

	ResolveSpell(data);
	local qualityColor = ITEM_QUALITY_COLORS[spell_quality];

	self.Icon:SetTexture(data.texture);
	self.ItemName:SetText(data.name);
	self.Label:SetText(YOU_LEARNED_LABEL);

	if qualityColor then
		self.ItemName:SetTextColor(qualityColor.r, qualityColor.g, qualityColor.b);
	end
	if BORDER_BY_QUALITY[spell_quality] then
		self.IconBorder:SetTexCoord(unpack(BORDER_BY_QUALITY[spell_quality]));
	end

	-- several spells arrive at once on level up, so only play the sound once per batch
	if config.sound and GetTime() - (LevelUpAlertFrameMixIn.lastSound or 0) > 3 then
		LevelUpAlertFrameMixIn.lastSound = GetTime();
		PlaySoundFile(SOUND_SPELL_LEARNED);
	end

	if config.anims then
		self.glow.animIn:Play();
		self.shine.animIn:Play();
	end

	self.hyperLink = data.link;
end

local function GetButtonLink(self)
	if not self.hyperLink and self.data then
		ResolveSpell(self.data);
		self.hyperLink = self.data.link;
	end
	return self.hyperLink;
end

function LevelUpAlertButtonTemplate_OnHide(self)
	self.animIn:Stop();
	self.waitAndAnimOut:Stop();

	if config.anims then
		self.glow.animIn:Stop();
		self.shine.animIn:Stop();
	end

	if self.data then
		tWipe(self.data);
	end
	LevelUpAlertFrameMixIn:AdjustAnchors();
end

function LevelUpAlertButtonTemplate_OnClick(self, button)
	if button == "RightButton" then
		self:Hide();
	elseif GetButtonLink(self) then
		HandleModifiedItemClick(self.hyperLink);
	end
end

function LevelUpAlertButtonTemplate_OnEnter(self)
	if not GetButtonLink(self) then return; end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -14, -6);
	GameTooltip:SetHyperlink(self.hyperLink);
	GameTooltip:Show();
end

-- /levelup test: fakes the chat message for a spell you know, so the toast can be checked anytime
SLASH_PRETTYLEVELUP1 = "/levelup";
SlashCmdList["PRETTYLEVELUP"] = function(msg)
	if msg == "test" then
		local name, rank = GetSpellInfo(6603); -- Attack, every class has it
		local sample = (rank and rank ~= "") and format("%s (%s)", name, rank) or name;
		LevelUpAlertFrameMixIn:AddSpell(sample);
	else
		print("pretty_levelup: /levelup test - show a sample toast");
	end
end
