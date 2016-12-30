local GottaGoFast = LibStub("AceAddon-3.0"):GetAddon("GottaGoFast")

local Utility = {};

function Utility.ExplodeStr(div,str)
	--[[
    if (div=='') then return {} end
    local pos,arr = 0,{}
    local count = 0;
    for st,sp in function() return string.find(str,div,pos,true) end do
        table.insert(arr,string.sub(str,pos,st-1))
        pos = sp + 1
        count = count + 1;
    end
    table.insert(arr,string.sub(str,pos))
	return arr, count + 1;
	]]--
	return strsplit(div, str);
end

function Utility.TrimStr(str)
  if (str == nil) then
    return "";
  end
  return str:match( "^%s*(.-)%s*$" );
end

function Utility.DebugPrint(str)
  if (GottaGoFast.db.profile.DebugMode) then
    GottaGoFast:Print(str);
  end
end

function Utility.ShortenStr(str, by)
  if (str and by) then
    return string.sub(str, 1, string.len(str) - by);
  else
    return str
  end
end

function Utility.count_all(f)
	local seen = {}
	local count_table
	count_table = function(t)
		if seen[t] then return end
		f(t)
		seen[t] = true
		for k,v in pairs(t) do
			if type(v) == "table" then
				count_table(v)
			elseif type(v) == "userdata" then
				f(v)
			end
		end
	end
	count_table(_G)
end

local global_type_table = nil

function Utility.type_name(o)
	if global_type_table == nil then
		global_type_table = {}
		for k,v in pairs(_G) do
			global_type_table[v] = k
		end
		global_type_table[0] = "table"
	end
	return global_type_table[getmetatable(o) or 0] or "Unknown"
end

function Utility.type_count()
	local counts = {}
	local enumerate = function (o)
		local t = Utility.type_name(o)
		counts[t] = (counts[t] or 0) + 1
	end
	Utility.count_all(enumerate)
	return counts
end

GottaGoFast.Utility = Utility;
