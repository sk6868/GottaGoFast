local GottaGoFast = LibStub("AceAddon-3.0"):GetAddon("GottaGoFast")
local constants = GottaGoFast.Constants;
local utility = GottaGoFast.Utility;

local affixID_to_Name = {
	[1] = "Overflowing",
	[2] = "Skittish",
	[3] = "Volcanic",
	[4] = "Necrotic",
	[5] = "Teeming",
	[6] = "Raging",
	[7] = "Bolstering",
	[8] = "Sanguine",
	[9] = "Tyrannical",
	[10] = "Fortified"
};

GottaGoFast.CurrentCM = {};
GottaGoFast.CurrentCM["Affixes"] = {};
GottaGoFast.CurrentCM["CurrentValues"] = {};
GottaGoFast.CurrentCM["FinalValues"] = {};
GottaGoFast.CurrentCM["ObjectiveTimes"] = {};
GottaGoFast.CurrentCM["Bosses"] = {};
GottaGoFast.CurrentCM["IncreaseTimers"] = {};

for affixID, _ in ipairs(affixID_to_Name) do
	local affixName, affixDesc, affixNum = C_ChallengeMode.GetAffixInfo(affixID);
	GottaGoFast.CurrentCM["Affixes"][affixID] = {};
	GottaGoFast.CurrentCM["Affixes"][affixID]["name"] = affixName;
	GottaGoFast.CurrentCM["Affixes"][affixID]["desc"] = affixDesc;
	GottaGoFast.CurrentCM["Affixes"][affixID].active = false;
	--print("affixID=", affixID, ", name =", affixName)
end
  
function GottaGoFast.SetupCM(currentZoneID)
  local _, _, steps = C_Scenario.GetStepInfo();
  local cmLevel, affixes, empowered = C_ChallengeMode.GetActiveKeystoneInfo();
  --GottaGoFast.CurrentCM = {};
  GottaGoFast.CurrentCM["StartTime"] = nil;
  GottaGoFast.CurrentCM["Time"] = nil;
  GottaGoFast.CurrentCM["CurrentTime"] = nil;
  GottaGoFast.CurrentCM["String"] = nil;
  GottaGoFast.CurrentCM["Name"], GottaGoFast.CurrentCM["ZoneID"], GottaGoFast.CurrentCM["GoldTimer"] = C_ChallengeMode.GetMapInfo(currentZoneID);
  GottaGoFast.CurrentCM["Deaths"] = 0;
  GottaGoFast.CurrentCM["Steps"] = steps;
  GottaGoFast.CurrentCM["Level"] = cmLevel;
  GottaGoFast.CurrentCM["Empowered"] = empowered;
  GottaGoFast.CurrentCM["Bonus"] = nil;
  GottaGoFast.CurrentCM["Completed"] = false;
  GottaGoFast.CurrentCM["AskedTime"] = nil;
  GottaGoFast.CurrentCM["AskedForTimer"] = false;
  GottaGoFast.CurrentCM["Version"] = constants.Version;
  --GottaGoFast.CurrentCM["Affixes"] = {};
  --GottaGoFast.CurrentCM["CurrentValues"] = {};
  --GottaGoFast.CurrentCM["FinalValues"] = {};
  --GottaGoFast.CurrentCM["ObjectiveTimes"] = {};
  --GottaGoFast.CurrentCM["Bosses"] = {};
  --GottaGoFast.CurrentCM["IncreaseTimers"] = {};
  wipe(GottaGoFast.CurrentCM["CurrentValues"]);
  wipe(GottaGoFast.CurrentCM["FinalValues"]);
  wipe(GottaGoFast.CurrentCM["ObjectiveTimes"]);
  wipe(GottaGoFast.CurrentCM["Bosses"]);
  wipe(GottaGoFast.CurrentCM["IncreaseTimers"]);

  if (cmLevel) then
    GottaGoFast.CurrentCM["Bonus"] = C_ChallengeMode.GetPowerLevelDamageHealthMod(cmLevel);
  end

  if (GottaGoFast.CurrentCM["Bonus"] == nil) then
    GottaGoFast.CurrentCM["Bonus"] = "?"
  end

  --[[
  for i, affixID in ipairs(affixes) do
    local affixName, affixDesc, affixNum = C_ChallengeMode.GetAffixInfo(affixID);
    GottaGoFast.CurrentCM["Affixes"][affixID] = {};
    GottaGoFast.CurrentCM["Affixes"][affixID]["name"] = affixName;
    GottaGoFast.CurrentCM["Affixes"][affixID]["desc"] = affixDesc;
  end
  ]]--
  for affixID, _ in ipairs(affixID_to_Name) do
	GottaGoFast.CurrentCM["Affixes"][affixID].active = false;
  end
  for _, affixID in ipairs(affixes) do
	GottaGoFast.CurrentCM["Affixes"][affixID].active = true;
  end

  for i = 1, steps do
    local name, _, status, curValue, finalValue, _, _, mobPoints = C_Scenario.GetCriteriaInfo(i);
    GottaGoFast.CurrentCM["CurrentValues"][i] = curValue;
    GottaGoFast.CurrentCM["FinalValues"][i] = finalValue;
    GottaGoFast.CurrentCM["Bosses"][i] = name;
    if (i == steps) then
      GottaGoFast.CurrentCM["CurrentValues"][i] = GottaGoFast.MobPointsToInteger(mobPoints);
    end
  end

  if (GottaGoFast.CurrentCM["GoldTimer"]) then
    GottaGoFast.CurrentCM["IncreaseTimers"][1] = GottaGoFast.CurrentCM["GoldTimer"];
    GottaGoFast.CurrentCM["IncreaseTimers"][2] = GottaGoFast.CurrentCM["GoldTimer"] * 0.8;
    GottaGoFast.CurrentCM["IncreaseTimers"][3] = GottaGoFast.CurrentCM["GoldTimer"] * 0.6;
  end

  GottaGoFast.BuildCMTooltip();
  GottaGoFast.HideObjectiveTracker();
  GottaGoFast.CreateDungeon(GottaGoFast.CurrentCM["Name"], GottaGoFast.CurrentCM["ZoneID"], GottaGoFast.CurrentCM["Bosses"]);
end

function GottaGoFast.SetupFakeCM()
  local affixes = {2, 7, 10};
  --GottaGoFast.CurrentCM = {};
  GottaGoFast.CurrentCM["StartTime"] = GetTime() - (60*5);
  GottaGoFast.CurrentCM["Time"] = nil;
  GottaGoFast.CurrentCM["CurrentTime"] = nil;
  GottaGoFast.CurrentCM["String"] = nil;
  GottaGoFast.CurrentCM["Name"], GottaGoFast.CurrentCM["ZoneID"], GottaGoFast.CurrentCM["GoldTimer"] = C_ChallengeMode.GetMapInfo(1458);
  GottaGoFast.CurrentCM["Deaths"] = 4;
  GottaGoFast.CurrentCM["Steps"] = 5;
  GottaGoFast.CurrentCM["Level"] = 10;
  GottaGoFast.CurrentCM["Empowered"] = true;
  GottaGoFast.CurrentCM["Bonus"] = 100;
  GottaGoFast.CurrentCM["Completed"] = false;
  GottaGoFast.CurrentCM["AskedTime"] = nil;
  GottaGoFast.CurrentCM["AskedForTimer"] = false;
  GottaGoFast.CurrentCM["Version"] = constants.Version;
  --GottaGoFast.CurrentCM["Affixes"] = {};
  --GottaGoFast.CurrentCM["CurrentValues"] = {1, 1, 0, 0, 40};
  --GottaGoFast.CurrentCM["FinalValues"] = {1, 1, 1, 1, 160};
  --GottaGoFast.CurrentCM["ObjectiveTimes"] = {"1:15.460", "3:45.012"};
  --GottaGoFast.CurrentCM["Bosses"] = {"Rokmora", "Ularogg Cragshaper", "Naraxas", "Dargrul", "Enemy Forces"};
  --GottaGoFast.CurrentCM["IncreaseTimers"] = {};
  wipe(GottaGoFast.CurrentCM["CurrentValues"]);
  wipe(GottaGoFast.CurrentCM["FinalValues"]);
  wipe(GottaGoFast.CurrentCM["ObjectiveTimes"]);
  wipe(GottaGoFast.CurrentCM["Bosses"]);
  wipe(GottaGoFast.CurrentCM["IncreaseTimers"]);
  
  GottaGoFast.CurrentCM["CurrentValues"][1] = 1
  GottaGoFast.CurrentCM["CurrentValues"][2] = 1
  GottaGoFast.CurrentCM["CurrentValues"][3] = 0
  GottaGoFast.CurrentCM["CurrentValues"][4] = 0
  GottaGoFast.CurrentCM["CurrentValues"][5] = 40
  
  GottaGoFast.CurrentCM["FinalValues"][1] = 1
  GottaGoFast.CurrentCM["FinalValues"][2] = 1
  GottaGoFast.CurrentCM["FinalValues"][3] = 1
  GottaGoFast.CurrentCM["FinalValues"][4] = 1
  GottaGoFast.CurrentCM["FinalValues"][5] = 160
  
  GottaGoFast.CurrentCM["ObjectiveTimes"][1] = 75.460
  GottaGoFast.CurrentCM["ObjectiveTimes"][2] = 225.012
  
  GottaGoFast.CurrentCM["Bosses"][1] = "Rokmora"
  GottaGoFast.CurrentCM["Bosses"][2] = "Ularogg Cragshaper"
  GottaGoFast.CurrentCM["Bosses"][3] = "Naraxas"
  GottaGoFast.CurrentCM["Bosses"][4] = "Dargrul"
  GottaGoFast.CurrentCM["Bosses"][5] = "Enemy Forces"
  
  --[[
  for i, affixID in ipairs(affixes) do
    local affixName, affixDesc, affixNum = C_ChallengeMode.GetAffixInfo(affixID);
    GottaGoFast.CurrentCM["Affixes"][affixID] = {};
    GottaGoFast.CurrentCM["Affixes"][affixID]["name"] = affixName;
    GottaGoFast.CurrentCM["Affixes"][affixID]["desc"] = affixDesc;
  end
  ]]--
  for affixID, _ in ipairs(affixID_to_Name) do
	GottaGoFast.CurrentCM["Affixes"][affixID].active = false;
  end
  for _, affixID in ipairs(affixes) do
	GottaGoFast.CurrentCM["Affixes"][affixID].active = true;
  end

  if (GottaGoFast.CurrentCM["GoldTimer"]) then
    GottaGoFast.CurrentCM["IncreaseTimers"][1] = GottaGoFast.CurrentCM["GoldTimer"];
    GottaGoFast.CurrentCM["IncreaseTimers"][2] = GottaGoFast.CurrentCM["GoldTimer"] * 0.8;
    GottaGoFast.CurrentCM["IncreaseTimers"][3] = GottaGoFast.CurrentCM["GoldTimer"] * 0.6;
  end

  GottaGoFast.BuildCMTooltip();
  GottaGoFast.HideObjectiveTracker();
end

local autoExceptionList = {
  [35642] = "Jeeves",
  [101462] = "Reaves"
};

function GottaGoFast.EmpoweredString()
  --if (GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM)) then
    local empowered = GottaGoFast.CurrentCM["Empowered"];
    if (empowered) then
      return "Empowered";
    else
      return "Depleted";
    end
  --end
  return "?";
end

function GottaGoFast.BuildCMTooltip()
  --if (GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM)) then
    local newTooltip;
    local cmLevel = GottaGoFast.CurrentCM["Level"];
    local empowered = GottaGoFast.EmpoweredString();
    local bonus = GottaGoFast.CurrentCM["Bonus"];
    if (cmLevel) then
      newTooltip = empowered .. ": Level " .. cmLevel .. " - " .. tostring(bonus) .. "%\n\n";
      if (next(GottaGoFast.CurrentCM["Affixes"])) then
        for i, affixID in pairs(GottaGoFast.CurrentCM["Affixes"]) do
		  if affixID.active then
            local affixName = affixID["name"];
            local affixDesc = affixID["desc"];
            newTooltip = newTooltip .. affixName .. "\n" .. affixDesc .. "\n\n";
		  end
        end
      end
      newTooltip = GottaGoFast.Utility.ShortenStr(newTooltip, 2);
      GottaGoFast.tooltip = newTooltip;
    else
      GottaGoFast.tooltip = GottaGoFast.defaultTooltip;
    end
  --end
end

function GottaGoFast.InitCM(currentZoneID)
  GottaGoFast.Utility.DebugPrint("Player Entered Challenge Mode");
  GottaGoFast.WipeCM();
  GottaGoFast.Utility.DebugPrint("Wiping CM");
  GottaGoFast.SetupCM(currentZoneID);
  GottaGoFast.Utility.DebugPrint("Setting Up CM");
  GottaGoFast.UpdateCMTimer();
  GottaGoFast.Utility.DebugPrint("Setting Up Timer");
  GottaGoFast.UpdateCMObjectives();
  GottaGoFast.Utility.DebugPrint("Setting Up Objectives");
  GottaGoFast.inCM = true;
  GottaGoFastFrame.TimeSinceLastUpdate = 0;
  GottaGoFastFrame:SetScript("OnUpdate", GottaGoFast.UpdateCM);
  GottaGoFast.Utility.DebugPrint("Setting Up Update Script");
  GottaGoFast.ShowFrames();
  GottaGoFast.Utility.DebugPrint("Showing Frames");
end

function GottaGoFast.MobPointsToInteger(mobPoints)
  return tonumber(utility.ShortenStr(mobPoints, 1));
end

function GottaGoFast.HasTeeming(affixes)
  if (next(affixes) ~= nil) then
    for k, v in pairs(affixes) do
      if v.active and (k == 5 or v.name == "Teeming") then
        return true;
      end
    end
  end
  return false;
end

function GottaGoFast.MouseoverUnitID()
  local guid = UnitGUID("mouseover");
  if (guid ~= nil) then
    local guidSplit = utility.ExplodeStr("-", guid);
    return tonumber(guidSplit[6]);
  end
  return nil;
end

function GottaGoFast.UnitID(guid)
  if (guid ~= nil) then
    local guidSplit = utility.ExplodeStr("-", guid);
    return tonumber(guidSplit[6]);
  end
  return nil;
end

--[[
function GottaGoFast.HandleSpy()
  if (GottaGoFast.GetSpyHelper(nil)) then
    local mobID = GottaGoFast.UnitID(UnitGUID("target"));
    if (mobID ~= nil and mobID == 107486) then
      if (GottaGoFast.GetAutoDialog(nil) == false and GossipTitleButton1 ~= nil) then
        GossipTitleButton1:Click();
      end
      if (GottaGoFast.PrintNext == nil or GottaGoFast.PrintNext + 3 < GetTime()) then
        GottaGoFast.PrintNext = GetTime();
      elseif (GossipGreetingText ~= nil) then
        local text = GossipGreetingText:GetText();
        local short = "";
        if (courtText[text] ~= nil) then
          short = " [" .. courtText[text] .. "]";
        end
        SendChatMessage("GGF" .. short .. ": " .. text, "PARTY");
      end
    end
  end
end

function GottaGoFast.HandleGossip()
  if (GottaGoFast.GetAutoDialog(nil) and GossipTitleButton1 ~= nil) then
    local mobID = GottaGoFast.UnitID(UnitGUID("target"));
    if (autoExceptionList[mobID] == nil) then
      GossipTitleButton1:Click();
    end
  end
  if (GottaGoFast.CurrentCM["ZoneID"] == 1571) then
    GottaGoFast.HandleSpy();
  end
end
]]--

local GGF_UpdateInterval = 1.0; -- How often the OnUpdate code will run (in seconds)

function GottaGoFast.UpdateCM(self, elapsed)
  --print("self.TimeSinceLastUpdate = ", self.TimeSinceLastUpdate, ",elapsed = ", elapsed)
  self.TimeSinceLastUpdate = (self.TimeSinceLastUpdate or 0) + elapsed; 	

  while (self.TimeSinceLastUpdate > GGF_UpdateInterval) do
    -- Insert your OnUpdate code here
    --if (GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM)) then
      GottaGoFast.UpdateCMTimer();
    --end

    self.TimeSinceLastUpdate = self.TimeSinceLastUpdate - GGF_UpdateInterval;
  end
end

function GottaGoFast.UpdateCMInformation()
  --if (GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM)) then
    if (GottaGoFast.CurrentCM["Completed"] == false) then
      for i = 1, GottaGoFast.CurrentCM["Steps"] do
        local name, _, status, curValue, finalValue, _, _, mobPoints = C_Scenario.GetCriteriaInfo(i);
        if (finalValue == 0 or not finalValue) then
          -- Final Value = 0 Means CM Complete
          GottaGoFast.CompleteCM();
          return false;
        end
        if (GottaGoFast.CurrentCM["CurrentValues"][i] ~= curValue) then
          -- Update Value
          if (i ~= GottaGoFast.CurrentCM["Steps"]) then
            GottaGoFast.CurrentCM["CurrentValues"][i] = curValue;
          else
            GottaGoFast.CurrentCM["CurrentValues"][i] = GottaGoFast.MobPointsToInteger(mobPoints);
          end
          if (curValue == finalValue or ((i == GottaGoFast.CurrentCM["Steps"]) and (curValue == 100))) then
            -- Add Objective Time
            --GottaGoFast.CurrentCM["ObjectiveTimes"][i] = GottaGoFast.ObjectiveCompleteString(GottaGoFast.Utility.ShortenStr(GottaGoFast.CurrentCM["Time"], 1));
			GottaGoFast.CurrentCM["ObjectiveTimes"][i] = GottaGoFast.CurrentCM["Time"];
          end
        elseif (GottaGoFast.CurrentCM["CurrentValues"][i] == GottaGoFast.CurrentCM["FinalValues"][i] and not GottaGoFast.CurrentCM["ObjectiveTimes"][i]) then
          -- Objective Already Complete But No Time Filled Out (Re-Log / Re-Zone)
          --GottaGoFast.CurrentCM["ObjectiveTimes"][i] = "?";
		  GottaGoFast.CurrentCM["ObjectiveTimes"][i] = -1;
        end
      end
    end
  --end
end

function GottaGoFast.CMFinalParse()
  --if (GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM)) then
    for i = 1, GottaGoFast.CurrentCM["Steps"] do
      GottaGoFast.CurrentCM["CurrentValues"][i] = GottaGoFast.CurrentCM["FinalValues"][i];
      if (not GottaGoFast.CurrentCM["ObjectiveTimes"][i]) then
        --GottaGoFast.CurrentCM["ObjectiveTimes"][i] = GottaGoFast.ObjectiveCompleteString(GottaGoFast.Utility.ShortenStr(GottaGoFast.CurrentCM["Time"], 1));
		GottaGoFast.CurrentCM["ObjectiveTimes"][i] = GottaGoFast.CurrentCM["Time"];
      end
    end
  --end
end

function GottaGoFast.StartCM(offset)
  --if (GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM)) then
    GottaGoFast.CurrentCM["StartTime"] = GetTime() + offset;
    GottaGoFast.BuildCMTooltip();
  --end
end

function GottaGoFast.CompleteCM()
  --if (GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM)) then
    GottaGoFast.CurrentCM["Completed"] = true;
    GottaGoFast.CMFinalParse();
  --end
end

function GottaGoFast.WipeCM()
  --if (GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM)) then
    --GottaGoFast.CurrentCM = table.wipe(GottaGoFast.CurrentCM);
  --end
end

local concat = table.concat

local str1 = "|c%s%02d:%02d|r";
local str2 = "|c%s%02d:%02d / %02d:%02d|r";
local str3 = "|c%s[%02d%s] %02d:%02d / %02d:%02d|r";
local str4 = "|c%s[%02d%s] %02d:%02d|r";

function GottaGoFast.PrintTimer(text, color, startMin, startSec, goldMin, goldSec, level, empowered)
	if level then
		if goldMin then
			text:SetFormattedText(str3, color, level, empowered and "" or "d", startMin, startSec, goldMin, goldSec)
		else
			text:SetFormattedText(str4, color, level, empowered and "" or "d", startMin, startSec)
		end
	else
		if goldMin then
			text:SetFormattedText(str2, color, startMin, startSec, goldMin, goldSec)
		else
			text:SetFormattedText(str1, color, startMin, startSec)
		end
	end
end

function GottaGoFast.UpdateCMTimer()
  --print("GottaGoFast.UpdateCMTimer ", GottaGoFast.CurrentCM["Completed"])
  --if (GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM)) then
    if (GottaGoFast.CurrentCM["Completed"] == false) then
      --local time = "";
      --local startMin, startSec, goldMin, goldSec;
	  local startMin, startSec, goldMin, goldSec, level;
      if (GottaGoFast.CurrentCM["StartTime"] and GottaGoFast.GetTrueTimer()) then
        local currentTime = GetTime();
        local deaths = GottaGoFast.CurrentCM["Deaths"] * 5;
        local secs = currentTime - GottaGoFast.CurrentCM["StartTime"];
        GottaGoFast.CurrentCM["CurrentTime"] = secs;
        secs = secs + deaths;
        if (secs < 0) then
          --startMin = "-00";
		  --startSec = GottaGoFast.FormatTimeNoMS(math.abs(secs));
		  startMin = 0;
          startSec = math.abs(secs);
        else
          startMin, startSec = GottaGoFast.SecondsToTime(secs);
          --startMin = GottaGoFast.FormatTimeNoMS(startMin);
          --startSec = GottaGoFast.FormatTimeNoMS(startSec);
        end
      else
        _, timeCM = GetWorldElapsedTime(1);
        GottaGoFast.AskForTimer(timeCM);
        startMin, startSec = GottaGoFast.SecondsToTime(timeCM);
        --startMin = GottaGoFast.FormatTimeNoMS(startMin);
        --startSec = GottaGoFast.FormatTimeNoMS(startSec);
      end
      --time = startMin .. ":" .. startSec .. " ";
      --GottaGoFast.CurrentCM["Time"] = time;
	  GottaGoFast.CurrentCM["Time"] = startMin*60 + startSec;
      --goldMin, goldSec = GottaGoFast.SecondsToTime(GottaGoFast.CurrentCM["GoldTimer"]);
      --goldMin = GottaGoFast.FormatTimeNoMS(goldMin);
      --goldSec = GottaGoFast.FormatTimeNoMS(goldSec);

      if (GottaGoFast.db.profile.GoldTimer) then
        --time = time .. "/ " .. goldMin .. ":" .. goldSec;
		goldMin, goldSec = GottaGoFast.SecondsToTime(GottaGoFast.CurrentCM["GoldTimer"]);
      end

      if (GottaGoFast.db.profile.LevelInTimer and GottaGoFast.CurrentCM["Level"]) then
        --local depleted = "";
        --if (GottaGoFast.CurrentCM["Empowered"] == false) then
        --  depleted = "d";
        --end
        --time = "[" .. GottaGoFast.CurrentCM["Level"] .. depleted .. "] " .. time;
		level = GottaGoFast.CurrentCM["Level"]
      end

      -- Update Frame
      --GottaGoFastTimerFrame.font:SetText(GottaGoFast.ColorTimer(time));
	  GottaGoFast.PrintTimer( GottaGoFastFrame.timerfont, 
							  GottaGoFast.db.profile.TimerColor,
							  startMin, startSec, goldMin, goldSec, level, GottaGoFast.CurrentCM["Empowered"])
      GottaGoFast.ResizeFrame();
    end
  --end
end

local objectiveStringTbl = {};
local prev_index = 0;

function GottaGoFast.UpdateCMObjectives()
  local index = 1;
  --if (GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM)) then
    local empowered = GottaGoFast.EmpoweredString();
    local objectiveString = "";
    local affixString = "";
    local increaseString = "";
    local goldMin, goldSec;
    local curCM = GottaGoFast.CurrentCM;
    if (GottaGoFast.db.profile.IncreaseInObjectives and next(GottaGoFast.CurrentCM["IncreaseTimers"])) then
      for k, v in pairs(GottaGoFast.CurrentCM["IncreaseTimers"]) do
        if (k ~= 1 or GottaGoFast.db.profile.GoldTimer == false) then
          goldMin, goldSec = GottaGoFast.SecondsToTime(v);
          goldMin = GottaGoFast.FormatTimeNoMS(goldMin);
          goldSec = GottaGoFast.FormatTimeNoMS(goldSec);
          increaseString = increaseString .. "+" .. k .. " = " .. goldMin .. ":" .. goldSec .. " / ";
        end
      end
      --objectiveString = objectiveString .. GottaGoFast.IncreaseColorString(GottaGoFast.Utility.ShortenStr(increaseString, 3) .. "\n");
	  objectiveStringTbl[index] = GottaGoFast.IncreaseColorString(GottaGoFast.Utility.ShortenStr(increaseString, 3) .. "\n");
	  index = index + 1;
    end
    if (GottaGoFast.db.profile.LevelInObjectives and GottaGoFast.CurrentCM["Level"]) then
      --objectiveString = objectiveString .. GottaGoFast.ObjectiveExtraString("Level " .. GottaGoFast.CurrentCM["Level"] .. " - (+" .. GottaGoFast.CurrentCM["Bonus"] .. "%) - " .. empowered .. "\n", GottaGoFast.db.profile.LevelColor);
	  objectiveStringTbl[index] = GottaGoFast.ObjectiveExtraString("Level " .. GottaGoFast.CurrentCM["Level"] .. " - (+" .. GottaGoFast.CurrentCM["Bonus"] .. "%) - " .. empowered .. "\n", GottaGoFast.db.profile.LevelColor);
	  index = index + 1;
    end
    if (GottaGoFast.db.profile.AffixesInObjectives and next(GottaGoFast.CurrentCM["Affixes"])) then
      for k, v in pairs(GottaGoFast.CurrentCM["Affixes"]) do
	    if v.active then
          affixString = affixString .. v["name"] .. " - ";
		end
      end
      --objectiveString = objectiveString .. GottaGoFast.ObjectiveExtraString(GottaGoFast.Utility.ShortenStr(affixString, 3) .. "\n", GottaGoFast.db.profile.AffixesColor);
	  objectiveStringTbl[index] = GottaGoFast.ObjectiveExtraString(GottaGoFast.Utility.ShortenStr(affixString, 3) .. "\n", GottaGoFast.db.profile.AffixesColor);
	  index = index + 1;
    end
    if (GottaGoFast.GetDeathInObjectives(nil) and GottaGoFast.CurrentCM["Deaths"]) then
      local deathString = "";
      local deathMin, deathSec = GottaGoFast.SecondsToTime((GottaGoFast.CurrentCM["Deaths"] * 5));
      deathMin = GottaGoFast.FormatTimeNoMS(deathMin);
      deathSec = GottaGoFast.FormatTimeNoMS(deathSec);
      if (GottaGoFast.CurrentCM["StartTime"] ~= nil) then
        deathString = "Deaths: " .. curCM["Deaths"] .. " - Time Lost: " .. deathMin .. ":" .. deathSec;
      else
        deathString = "Deaths: " .. curCM["Deaths"] .. "* - Time Lost: " .. deathMin .. ":" .. deathSec;
      end
      deathString = deathString .. "\n";
      --objectiveString = objectiveString .. GottaGoFast.ObjectiveExtraString(deathString, GottaGoFast.db.profile.DeathColor);
	  objectiveStringTbl[index] = GottaGoFast.ObjectiveExtraString(deathString, GottaGoFast.db.profile.DeathColor);
	  index = index + 1;
    end
	--[[
    for i = 1, GottaGoFast.CurrentCM["Steps"] do
      if (i == GottaGoFast.CurrentCM["Steps"]) then
        -- Last Step Should Be Enemies
        objectiveString = objectiveString .. GottaGoFast.ObjectiveEnemyString(GottaGoFast.CurrentCM["Bosses"][i], GottaGoFast.CurrentCM["CurrentValues"][i], GottaGoFast.CurrentCM["FinalValues"][i]);
      else
        objectiveString = objectiveString .. GottaGoFast.ObjectiveString(GottaGoFast.CurrentCM["Bosses"][i], GottaGoFast.CurrentCM["CurrentValues"][i], GottaGoFast.CurrentCM["FinalValues"][i]);
      end
      if (GottaGoFast.db.profile.ObjectiveCompleteInObjectives and GottaGoFast.CurrentCM["ObjectiveTimes"][i]) then
        -- Completed Objective
        objectiveString = objectiveString .. GottaGoFast.ObjectiveCompletedString(GottaGoFast.CurrentCM["ObjectiveTimes"][i]);
      end
      objectiveString = objectiveString .. "\n";
    end
	]]--
	--sk68 addition start
	local i = GottaGoFast.CurrentCM["Steps"]
	if i > 0 then
		--objectiveString = objectiveString .. GottaGoFast.ObjectiveEnemyString(GottaGoFast.CurrentCM["Bosses"][i], GottaGoFast.CurrentCM["CurrentValues"][i], GottaGoFast.CurrentCM["FinalValues"][i]);
		--objectiveString = objectiveString .. "\n";
		objectiveStringTbl[index] = GottaGoFast.ObjectiveEnemyString(GottaGoFast.CurrentCM["Bosses"][i], GottaGoFast.CurrentCM["CurrentValues"][i], GottaGoFast.CurrentCM["FinalValues"][i]) .. "\n";
		index = index + 1;
	end
	-- remove any extra elements from previous UpdateCMObjectives
	for i = #objectiveStringTbl, index, -1 do
		objectiveStringTbl[i] = nil
	end
	--sk68 addition end
    --GottaGoFastObjectiveFrame.font:SetText(objectiveString);
	GottaGoFastFrame.objectivesfont:SetText(concat(objectiveStringTbl));
    GottaGoFast.ResizeFrame();
  --end
end

function GottaGoFast.AskForTimer(timeCM)
  if (GottaGoFast.CurrentCM["StartTime"] == nil and timeCM > 1 and GottaGoFast.CurrentCM["AskedForTimer"] == false) then
    GottaGoFast.Utility.DebugPrint("Asking For Timer");
    GottaGoFast.CurrentCM["AskedTime"] = GetTime();
    GottaGoFast.CurrentCM["AskedForTimer"] = true;
    GottaGoFast:SendCommMessage("GottaGoFastCM", "FixCM", "PARTY", nil, "ALERT");
  end
end

function GottaGoFast.CheckCMTimer()
  --if (GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM) ~= nil and GottaGoFast.CurrentCM["StartTime"] ~= nil and GottaGoFast.CurrentCM["Steps"] ~= 0 and GottaGoFast.CurrentCM["CurrentTime"] ~= nil) then
  if (GottaGoFast.CurrentCM["StartTime"] ~= nil and GottaGoFast.CurrentCM["Steps"] ~= 0 and GottaGoFast.CurrentCM["CurrentTime"] ~= nil) then
    local CurrentCMString = GottaGoFast:Serialize(GottaGoFast.CurrentCM);
    GottaGoFast.Utility.DebugPrint("CM Timer Sent");
    GottaGoFast:SendCommMessage("GottaGoFastCM", CurrentCMString, "PARTY", nil, "ALERT");
  end
end

function GottaGoFast.FixCMTimer(input)
  --if (GottaGoFast.inCM == true and GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM) ~= nil) then
  if (GottaGoFast.inCM == true) then
    if (GottaGoFast.CurrentCM["StartTime"] == nil and GottaGoFast.CurrentCM["AskedTime"] ~= nil) then
      GottaGoFast.Utility.DebugPrint("Replacing CM Timer");
      local status, newCM = GottaGoFast:Deserialize(input);
      if (status and newCM and newCM["CurrentTime"] and newCM["Version"] ~= nil and newCM["Version"] >= constants.Version) then
        newCM["StartTime"] = GottaGoFast.CurrentCM["AskedTime"] - newCM["CurrentTime"];
        GottaGoFast.CurrentCM = newCM;
        -- Update Timer
        GottaGoFast.UpdateCMTimer();
        GottaGoFast.UpdateCMObjectives();
      end
    end
  end
end

local data = {};

function GottaGoFast.CreateDungeon(name, zoneID, objectives)
  --local data = {};
  wipe(data);
  data["name"] = name;
  data["zoneID"] = zoneID;
  data["objectives"] = objectives;
  data["msg"] = "CreateDungeon";
  local dataString = GottaGoFast:Serialize(data);
  GottaGoFast:SendCommMessage(constants.HistoryPrefix, dataString, "WHISPER", GetUnitName("player"), "ALERT");
end

function GottaGoFast.CreateRun(data)
  -- Why was this called twice?
  data["msg"] = "CreateRun";
  local dataString = GottaGoFast:Serialize(data);
  GottaGoFast:SendCommMessage(constants.HistoryPrefix, dataString, "WHISPER", GetUnitName("player"), "ALERT");
end

function GottaGoFast.SendHistory(data)
  if (data ~= nil and next(data) ~= nil) then
    data["msg"] = "InitHistory";
    local dataString = GottaGoFast:Serialize(data);
    utility.DebugPrint("Sending History For Sync");
    GottaGoFast:SendCommMessage(constants.HistoryPrefix, dataString, "WHISPER", GetUnitName("player"), "ALERT")
    utility.DebugPrint("Clearing History");
    GottaGoFast.db.profile.History = {};
  end
end
