local GottaGoFast = LibStub("AceAddon-3.0"):GetAddon("GottaGoFast")
local constants = GottaGoFast.Constants;
local utility = GottaGoFast.Utility;
local debugPrint = utility.DebugPrint;

local affixID_to_Name = {
	[1] = "Overflowing", -- removed in 7.2
	[2] = "Skittish",
	[3] = "Volcanic",
	[4] = "Necrotic",
	[5] = "Teeming",
	[6] = "Raging",
	[7] = "Bolstering",
	[8] = "Sanguine",
	[9] = "Tyrannical",
	[10] = "Fortified",
	[11] = "Bursting",
	[12] = "Grievous",
	[13] = "Explosive",
	[14] = "Quaking",
};

GottaGoFast.CurrentCM = {};
local current_CM = GottaGoFast.CurrentCM

do
	current_CM["Affixes"] = {};
	current_CM["CurrentValues"] = {};
	current_CM["FinalValues"] = {};
	current_CM["ObjectiveTimes"] = {};
	current_CM["Bosses"] = {};
	current_CM["IncreaseTimers"] = {};
end

for affixID, _ in ipairs(affixID_to_Name) do
	local affixName, affixDesc, affixNum = C_ChallengeMode.GetAffixInfo(affixID);
	current_CM["Affixes"][affixID] = {};
	current_CM["Affixes"][affixID]["name"] = affixName;
	current_CM["Affixes"][affixID]["desc"] = affixDesc;
	current_CM["Affixes"][affixID].active = false;
	--print("affixID=", affixID, ", name =", affixName)
end
  
function GottaGoFast:SetupCM(challengeMapID, currentZoneID)
  local _, _, steps = C_Scenario.GetStepInfo();
  local cmLevel, affixes, empowered = C_ChallengeMode.GetActiveKeystoneInfo();
  --local mapID = C_ChallengeMode.GetActiveChallengeMapID();
  --GottaGoFast.CurrentCM = {};
  current_CM["Name"], current_CM["CmID"], current_CM["GoldTimer"] = C_ChallengeMode.GetMapInfo(challengeMapID);
  current_CM["StartTime"] = nil;
  current_CM["Time"] = nil;
  current_CM["CurrentTime"] = nil;
  current_CM["String"] = nil;
  current_CM["ZoneID"] = currentZoneID
  current_CM["Deaths"] = 0;
  current_CM["Steps"] = steps;
  current_CM["Level"] = cmLevel;
  current_CM["Empowered"] = empowered;
  current_CM["Bonus"] = nil;
  current_CM["Completed"] = false;
  current_CM["AskedTime"] = nil;
  current_CM["AskedForTimer"] = false;
  current_CM["Version"] = constants.Version;
  wipe(current_CM["CurrentValues"]);
  wipe(current_CM["FinalValues"]);
  wipe(current_CM["ObjectiveTimes"]);
  wipe(current_CM["Bosses"]);
  wipe(current_CM["IncreaseTimers"]);

  if (cmLevel) then
    current_CM["Bonus"] = C_ChallengeMode.GetPowerLevelDamageHealthMod(cmLevel);
  end

  if (current_CM["Bonus"] == nil) then
    current_CM["Bonus"] = "?"
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
	current_CM["Affixes"][affixID].active = false;
  end
  for _, affixID in ipairs(affixes) do
	current_CM["Affixes"][affixID].active = true;
  end

  for i = 1, steps do
    local name, _, status, curValue, finalValue, _, _, mobPoints = C_Scenario.GetCriteriaInfo(i);
    current_CM["CurrentValues"][i] = curValue;
    current_CM["FinalValues"][i] = finalValue;
    current_CM["Bosses"][i] = name;
    if (i == steps) then
      current_CM["CurrentValues"][i] = self.MobPointsToInteger(mobPoints);
    end
  end

  if (current_CM["GoldTimer"]) then
    current_CM["IncreaseTimers"][1] = current_CM["GoldTimer"];
    current_CM["IncreaseTimers"][2] = current_CM["GoldTimer"] * 0.8;
    current_CM["IncreaseTimers"][3] = current_CM["GoldTimer"] * 0.6;
  end

  self.BuildCMTooltip();
  self.HideObjectiveTracker();
  self.CreateDungeon(current_CM["Name"], current_CM["ZoneID"], current_CM["Bosses"]);
end

function GottaGoFast:SetupFakeCM()
  local affixes = {2, 7, 10};
  --GottaGoFast.CurrentCM = {};
  current_CM["StartTime"] = GetTime() - (60*5);
  current_CM["Time"] = nil;
  current_CM["CurrentTime"] = nil;
  current_CM["String"] = nil;
  current_CM["Name"], current_CM["CmID"], current_CM["GoldTimer"] = C_ChallengeMode.GetMapInfo(206);
  current_CM["ZoneID"] = 1492;
  current_CM["Deaths"] = 4;
  current_CM["Steps"] = 5;
  current_CM["Level"] = 10;
  current_CM["Empowered"] = true;
  current_CM["Bonus"] = 100;
  current_CM["Completed"] = false;
  current_CM["AskedTime"] = nil;
  current_CM["AskedForTimer"] = false;
  current_CM["Version"] = constants.Version;
  --GottaGoFast.CurrentCM["Affixes"] = {};
  --GottaGoFast.CurrentCM["CurrentValues"] = {1, 1, 0, 0, 40};
  --GottaGoFast.CurrentCM["FinalValues"] = {1, 1, 1, 1, 160};
  --GottaGoFast.CurrentCM["ObjectiveTimes"] = {"1:15.460", "3:45.012"};
  --GottaGoFast.CurrentCM["Bosses"] = {"Rokmora", "Ularogg Cragshaper", "Naraxas", "Dargrul", "Enemy Forces"};
  --GottaGoFast.CurrentCM["IncreaseTimers"] = {};
  wipe(current_CM["CurrentValues"]);
  wipe(current_CM["FinalValues"]);
  wipe(current_CM["ObjectiveTimes"]);
  wipe(current_CM["Bosses"]);
  wipe(current_CM["IncreaseTimers"]);
  
  current_CM["CurrentValues"][1] = 1
  current_CM["CurrentValues"][2] = 1
  current_CM["CurrentValues"][3] = 0
  current_CM["CurrentValues"][4] = 0
  current_CM["CurrentValues"][5] = 40

  current_CM["FinalValues"][1] = 1
  current_CM["FinalValues"][2] = 1
  current_CM["FinalValues"][3] = 1
  current_CM["FinalValues"][4] = 1
  current_CM["FinalValues"][5] = 160

  current_CM["ObjectiveTimes"][1] = 75.460
  current_CM["ObjectiveTimes"][2] = 225.012

  current_CM["Bosses"][1] = "Rokmora"
  current_CM["Bosses"][2] = "Ularogg Cragshaper"
  current_CM["Bosses"][3] = "Naraxas"
  current_CM["Bosses"][4] = "Dargrul"
  current_CM["Bosses"][5] = "Enemy Forces"
  
  for affixID, _ in ipairs(affixID_to_Name) do
	current_CM["Affixes"][affixID].active = false;
  end
  for _, affixID in ipairs(affixes) do
	current_CM["Affixes"][affixID].active = true;
  end

  if (current_CM["GoldTimer"]) then
    current_CM["IncreaseTimers"][1] = current_CM["GoldTimer"];
    current_CM["IncreaseTimers"][2] = current_CM["GoldTimer"] * 0.8;
    current_CM["IncreaseTimers"][3] = current_CM["GoldTimer"] * 0.6;
  end

  self.BuildCMTooltip();
  self.HideObjectiveTracker();
end

function GottaGoFast.EmpoweredString()
  --if (GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM)) then
    local empowered = current_CM["Empowered"];
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
    local cmLevel = current_CM["Level"];
    local empowered = GottaGoFast.EmpoweredString();
    local bonus = current_CM["Bonus"];
    if (cmLevel) then
      newTooltip = empowered .. ": Level " .. cmLevel .. " - " .. tostring(bonus) .. "%\n\n";
      if (next(current_CM["Affixes"])) then
        for i, affixID in pairs(current_CM["Affixes"]) do
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

function GottaGoFast:InitCM(challengeMapID, currentZoneID)
  debugPrint("Player Entered Challenge Mode");
  self.WipeCM();
  debugPrint("Wiping CM");
  self:SetupCM(challengeMapID, currentZoneID);
  debugPrint("Setting Up CM");
  self.UpdateCMTimer();
  debugPrint("Setting Up Timer");
  self.UpdateCMObjectives();
  debugPrint("Setting Up Objectives");
  self.inCM = true;
  GottaGoFastFrame.TimeSinceLastUpdate = 0;
  GottaGoFastFrame:SetScript("OnUpdate", self.UpdateCM);
  debugPrint("Setting Up Update Script");
  self.ShowFrames();
  debugPrint("Showing Frames");
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
    if (current_CM["Completed"] == false) then
      for i = 1, current_CM["Steps"] do
        local name, _, status, curValue, finalValue, _, _, mobPoints = C_Scenario.GetCriteriaInfo(i);
        if (finalValue == 0 or not finalValue) then
          -- Final Value = 0 Means CM Complete
          GottaGoFast.CompleteCM();
          return false;
        end
        if (current_CM["CurrentValues"][i] ~= curValue) then
          -- Update Value
          if (i ~= current_CM["Steps"]) then
            current_CM["CurrentValues"][i] = curValue;
          else
            current_CM["CurrentValues"][i] = GottaGoFast.MobPointsToInteger(mobPoints);
          end
          if (curValue == finalValue or ((i == current_CM["Steps"]) and (curValue == 100))) then
            -- Add Objective Time
            --GottaGoFast.CurrentCM["ObjectiveTimes"][i] = GottaGoFast.ObjectiveCompleteString(GottaGoFast.Utility.ShortenStr(GottaGoFast.CurrentCM["Time"], 1));
			current_CM["ObjectiveTimes"][i] = current_CM["Time"];
          end
        elseif (current_CM["CurrentValues"][i] == current_CM["FinalValues"][i] and not current_CM["ObjectiveTimes"][i]) then
          -- Objective Already Complete But No Time Filled Out (Re-Log / Re-Zone)
          --GottaGoFast.CurrentCM["ObjectiveTimes"][i] = "?";
		  current_CM["ObjectiveTimes"][i] = -1;
        end
      end
    end
  --end
end

function GottaGoFast.CMFinalParse()
  --if (GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM)) then
    for i = 1, current_CM["Steps"] do
      current_CM["CurrentValues"][i] = current_CM["FinalValues"][i];
      if (not current_CM["ObjectiveTimes"][i]) then
        --GottaGoFast.CurrentCM["ObjectiveTimes"][i] = GottaGoFast.ObjectiveCompleteString(GottaGoFast.Utility.ShortenStr(GottaGoFast.CurrentCM["Time"], 1));
		current_CM["ObjectiveTimes"][i] = current_CM["Time"];
      end
    end
  --end
end

function GottaGoFast.StartCM(offset)
  --if (GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM)) then
    current_CM["StartTime"] = GetTime() + offset;
    GottaGoFast.BuildCMTooltip();
  --end
end

function GottaGoFast.CompleteCM()
  --if (GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM)) then
    current_CM["Completed"] = true;
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
    if (current_CM["Completed"] == false) then
      --local time = "";
      --local startMin, startSec, goldMin, goldSec;
	  local startMin, startSec, goldMin, goldSec, level;
      if (current_CM["StartTime"] and GottaGoFast.GetTrueTimer()) then
        local currentTime = GetTime();
        local deaths = current_CM["Deaths"] * 5;
        local secs = currentTime - current_CM["StartTime"];
        current_CM["CurrentTime"] = secs;
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
	  current_CM["Time"] = startMin*60 + startSec;
      --goldMin, goldSec = GottaGoFast.SecondsToTime(GottaGoFast.CurrentCM["GoldTimer"]);
      --goldMin = GottaGoFast.FormatTimeNoMS(goldMin);
      --goldSec = GottaGoFast.FormatTimeNoMS(goldSec);

      if (GottaGoFast.db.profile.GoldTimer) then
        --time = time .. "/ " .. goldMin .. ":" .. goldSec;
		goldMin, goldSec = GottaGoFast.SecondsToTime(current_CM["GoldTimer"]);
      end

      if (GottaGoFast.db.profile.LevelInTimer and current_CM["Level"]) then
        --local depleted = "";
        --if (GottaGoFast.CurrentCM["Empowered"] == false) then
        --  depleted = "d";
        --end
        --time = "[" .. GottaGoFast.CurrentCM["Level"] .. depleted .. "] " .. time;
		level = current_CM["Level"]
      end

      -- Update Frame
      --GottaGoFastTimerFrame.font:SetText(GottaGoFast.ColorTimer(time));
	  GottaGoFast.PrintTimer( GottaGoFastFrame.timerfont, 
							  GottaGoFast.db.profile.TimerColor,
							  startMin, startSec, goldMin, goldSec, level, current_CM["Empowered"])
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
    if (GottaGoFast.db.profile.IncreaseInObjectives and next(current_CM["IncreaseTimers"])) then
      for k, v in pairs(current_CM["IncreaseTimers"]) do
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
    if (GottaGoFast.db.profile.LevelInObjectives and current_CM["Level"]) then
      --objectiveString = objectiveString .. GottaGoFast.ObjectiveExtraString("Level " .. GottaGoFast.CurrentCM["Level"] .. " - (+" .. GottaGoFast.CurrentCM["Bonus"] .. "%) - " .. empowered .. "\n", GottaGoFast.db.profile.LevelColor);
	  objectiveStringTbl[index] = GottaGoFast.ObjectiveExtraString("Level " .. current_CM["Level"] .. " - (+" .. current_CM["Bonus"] .. "%) - " .. empowered .. "\n", GottaGoFast.db.profile.LevelColor);
	  index = index + 1;
    end
    if (GottaGoFast.db.profile.AffixesInObjectives and next(current_CM["Affixes"])) then
      for k, v in pairs(current_CM["Affixes"]) do
	    if v.active then
          affixString = affixString .. v["name"] .. " - ";
		end
      end
      --objectiveString = objectiveString .. GottaGoFast.ObjectiveExtraString(GottaGoFast.Utility.ShortenStr(affixString, 3) .. "\n", GottaGoFast.db.profile.AffixesColor);
	  objectiveStringTbl[index] = GottaGoFast.ObjectiveExtraString(GottaGoFast.Utility.ShortenStr(affixString, 3) .. "\n", GottaGoFast.db.profile.AffixesColor);
	  index = index + 1;
    end
    if (GottaGoFast.GetDeathInObjectives(nil) and current_CM["Deaths"]) then
      local deathString = "";
      local deathMin, deathSec = GottaGoFast.SecondsToTime((current_CM["Deaths"] * 5));
      deathMin = GottaGoFast.FormatTimeNoMS(deathMin);
      deathSec = GottaGoFast.FormatTimeNoMS(deathSec);
      if (current_CM["StartTime"] ~= nil) then
        deathString = "Deaths: " .. current_CM["Deaths"] .. " - Time Lost: " .. deathMin .. ":" .. deathSec;
      else
        deathString = "Deaths: " .. current_CM["Deaths"] .. "* - Time Lost: " .. deathMin .. ":" .. deathSec;
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
	local i = current_CM["Steps"]
	if i > 0 then
		--objectiveString = objectiveString .. GottaGoFast.ObjectiveEnemyString(GottaGoFast.CurrentCM["Bosses"][i], GottaGoFast.CurrentCM["CurrentValues"][i], GottaGoFast.CurrentCM["FinalValues"][i]);
		--objectiveString = objectiveString .. "\n";
		objectiveStringTbl[index] = GottaGoFast.ObjectiveEnemyString(current_CM["Bosses"][i], current_CM["CurrentValues"][i], current_CM["FinalValues"][i]) .. "\n";
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
  if (current_CM["StartTime"] == nil and timeCM > 1 and current_CM["AskedForTimer"] == false) then
    debugPrint("Asking For Timer");
    current_CM["AskedTime"] = GetTime();
    current_CM["AskedForTimer"] = true;
    GottaGoFast:SendCommMessage("GottaGoFastCM", "FixCM", "PARTY", nil, "ALERT");
  end
end

function GottaGoFast.CheckCMTimer()
  --if (GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM) ~= nil and GottaGoFast.CurrentCM["StartTime"] ~= nil and GottaGoFast.CurrentCM["Steps"] ~= 0 and GottaGoFast.CurrentCM["CurrentTime"] ~= nil) then
  if (current_CM["StartTime"] ~= nil and current_CM["Steps"] ~= 0 and current_CM["CurrentTime"] ~= nil) then
    local CurrentCMString = GottaGoFast:Serialize(current_CM);
    debugPrint("CM Timer Sent");
    GottaGoFast:SendCommMessage("GottaGoFastCM", CurrentCMString, "PARTY", nil, "ALERT");
  end
end

function GottaGoFast.FixCMTimer(input)
  --if (GottaGoFast.inCM == true and GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM) ~= nil) then
  if (GottaGoFast.inCM == true) then
    if (current_CM["StartTime"] == nil and current_CM["AskedTime"] ~= nil) then
      debugPrint("Replacing CM Timer");
      local status, newCM = GottaGoFast:Deserialize(input);
      if (status and newCM and newCM["CurrentTime"] and newCM["Version"] ~= nil and newCM["Version"] >= constants.Version) then
        newCM["StartTime"] = current_CM["AskedTime"] - newCM["CurrentTime"];
        GottaGoFast.CurrentCM = newCM;
		current_CM = newCM;
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
    debugPrint("Sending History For Sync");
    GottaGoFast:SendCommMessage(constants.HistoryPrefix, dataString, "WHISPER", GetUnitName("player"), "ALERT")
    debugPrint("Clearing History");
    GottaGoFast.db.profile.History = {};
  end
end
