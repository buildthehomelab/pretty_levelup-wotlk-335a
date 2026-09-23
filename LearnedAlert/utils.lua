---
-- LearnedAlert: a toast for every spell you learn; based on pretty_lootalert by s0h2x

local _, private = ...;
local next, pairs = next, pairs;
local getmetatable = getmetatable;

local texture, fontstring;
local prototype = {CreateFrame("Frame"), CreateFrame("Button")};

local subinit = function()
	for _, data in pairs(prototype) do
		texture = getmetatable(data:CreateTexture());
		fontstring = getmetatable(data:CreateFontString());
	end
end
subinit();

-- mixin frames to table
private.Mixin = function(object, ...)
	local mixins = {...};
	for _, mixin in pairs(mixins) do
		for k, v in next, mixin do
			object[k] = v;
		end
	end
	return object;
end

-- method shown
local methodshown = function(self, data)
	if data and data ~= false then
		self:Show();
	else
		self:Hide();
	end
end

function texture.__index:SetShown(...)
	methodshown(self, ...);
end

function fontstring.__index:SetShown(...)
	methodshown(self, ...);
end
