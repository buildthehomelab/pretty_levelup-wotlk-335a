local L, private = ...;
local next = next;
local setmetatable = setmetatable;
local GetLocale = GetLocale;
local LOCALE = GetLocale();

private.locales = {
	["YOU_LEARNED_LABEL"] = {
		ruRU = "Вы изучили:",
		enGB = "You Learned:",
		esMX = "Has aprendido:",
		deDE = "Ihr habt erlernt:",
		frFR = "Vous avez appris :",
		itIT = "Hai appreso:",
		koKR = "배웠습니다:",
		ptBR = "Você aprendeu:",
		zhCN = "你学会了：",
		zhTW = "你學會了："
	},
};

setmetatable(private.locales,{
	__call = function(self, key)
		if not self[key] then
			return "Locale not found";
		end
		-- struct langstringref;
		if LOCALE == "ruRU" then
			return self[key].ruRU;
		elseif LOCALE == "esMX" or LOCALE == "esES" then
			return self[key].esMX;
		elseif LOCALE == "deDE" then
			return self[key].deDE;
		elseif LOCALE == "frFR" then
			return self[key].frFR;
		elseif LOCALE == "itIT" then
			return self[key].itIT;
		elseif LOCALE == "koKR" then
			return self[key].koKR;
		elseif LOCALE == "ptBR" or LOCALE == "ptPT" then
			return self[key].ptBR;
		elseif LOCALE == "zhCN" then
			return self[key].zhCN;
		elseif LOCALE == "zhTW" then
			return self[key].zhTW;
		else
			return self[key].enGB ~= "" and self[key].enGB or key;
		end
	end
});

for key in next, private.locales do
	_G[key] = private.locales(key);
end