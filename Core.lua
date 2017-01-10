local GottaGoFast = LibStub("AceAddon-3.0"):GetAddon("GottaGoFast")
local utility = GottaGoFast.Utility;
local debugPrint = utility.DebugPrint;

function GottaGoFast:OnInitialize()
    -- Called when the addon is loaded
    -- Register Frames
    GottaGoFastFrame = CreateFrame("Frame", "GottaGoFastFrame", UIParent);
    GottaGoFastHideFrame = CreateFrame("Frame");
    GottaGoFastHideFrame:Hide();
end

function GottaGoFast:OnEnable()
    -- Called when the addon is enabled

    -- Register Events
    RegisterAddonMessagePrefix("GottaGoFast");
    RegisterAddonMessagePrefix("GottaGoFastCM");
    self:RegisterEvent("CHALLENGE_MODE_START");
    self:RegisterEvent("CHALLENGE_MODE_COMPLETED");
    self:RegisterEvent("CHALLENGE_MODE_RESET");
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("SCENARIO_POI_UPDATE");
    self:RegisterEvent("WORLD_STATE_TIMER_START");
    self:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
    --self:RegisterEvent("GOSSIP_SHOW");
    self:RegisterChatCommand("ggf", "ChatCommand");
    self:RegisterChatCommand("GottaGoFast", "ChatCommand");
    self:RegisterComm("GottaGoFast", "ChatComm");
    self:RegisterComm("GottaGoFastCM", "CMChatComm");

    -- Setup AddOn
    self:InitState();
    self:InitOptions();
    self:InitFrame();
    self:VersionCheck();

end

function GottaGoFast:OnDisable()
  -- Called when the addon is disabled
end

function GottaGoFast:CHALLENGE_MODE_START()
  GottaGoFast.Utility.DebugPrint("CM Start");
  local _, _, difficulty, _, _, _, _, currentZoneID = GetInstanceInfo();
  GottaGoFast.InitCM(currentZoneID);
  GottaGoFast.StartCM(10);
end

function GottaGoFast:CHALLENGE_MODE_COMPLETED()
  GottaGoFast.Utility.DebugPrint("CM Complete");
  GottaGoFast.CompleteCM();
  if (GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM) ~= nil) then
    GottaGoFast.CreateRun(GottaGoFast.CurrentCM);
  end
end

function GottaGoFast:CHALLENGE_MODE_RESET()
  GottaGoFast.Utility.DebugPrint("CM Reset");
  local _, _, difficulty, _, _, _, _, currentZoneID = GetInstanceInfo();
  GottaGoFast.InitCM(currentZoneID);
end

function GottaGoFast:PLAYER_ENTERING_WORLD()
  GottaGoFast.Utility.DebugPrint("Player Entered World");
  GottaGoFast.CheckCount = 0;
  GottaGoFast.FirstCheck = false;
  --GottaGoFast.ResetState();
  GottaGoFast.WhereAmI();
end

function GottaGoFast:SCENARIO_POI_UPDATE()
  if (GottaGoFast.inCM) then
    GottaGoFast.Utility.DebugPrint("Scenario POI Update");
    if (GottaGoFast.CurrentCM["Steps"] == 0 and GottaGoFast.CurrentCM["Completed"] == false and next(GottaGoFast.CurrentCM["Bosses"]) == nil) then
      GottaGoFast.WhereAmI();
    end
    GottaGoFast.UpdateCMInformation();
    GottaGoFast.UpdateCMObjectives();
  end
end

function GottaGoFast:WORLD_STATE_TIMER_START()
  if (GottaGoFast.inCM == true) then
    if (GottaGoFast.CurrentCM == nil or next(GottaGoFast.CurrentCM) == nil or GottaGoFast.CurrentCM["Steps"] == 0) then
      local _, _, difficulty, _, _, _, _, currentZoneID = GetInstanceInfo();
      GottaGoFast.InitCM(currentZoneID)
    end
    if (GottaGoFast.CurrentCM["Completed"] == false) then
      local _, timeCM = GetWorldElapsedTime(1);
      if (timeCM ~= nil and timeCM <= 2) then
        GottaGoFast.StartCM(0);
        GottaGoFast.UpdateCMObjectives();
      elseif (GottaGoFast.CurrentCM["Deaths"]) then
        GottaGoFast.CurrentCM["Deaths"] = GottaGoFast.CurrentCM["Deaths"] + 1;
        GottaGoFast.UpdateCMObjectives();
      end
    end
  end
end

function GottaGoFast:UPDATE_MOUSEOVER_UNIT()
  if (self.inCM == true and self.GetIndividualMobValue(nil) == true and self.CurrentCM ~= nil and next(self.CurrentCM) ~= nil) then
    local npcID = GottaGoFast.MouseoverUnitID();
    local mapID = self.CurrentCM["ZoneID"];
    local isTeeming = self.HasTeeming(self.CurrentCM["Affixes"]);
    if (npcID ~= nil and mapID ~= nil and isTeeming ~= nil) then
      local weight = self.LOP:GetNPCWeightByMap(mapID, npcID, isTeeming);
      if (weight ~= nil) then
        local appendString = string.format(" (%.1f%%)", weight);
        GameTooltip:AppendText(appendString);
      end
    end
  end
end

--[[
function GottaGoFast:GOSSIP_SHOW()
  if (self.inCM == true and self.CurrentCM ~= nil and next(self.CurrentCM) ~= nil) then
    GottaGoFast.HandleGossip();
  end
end
]]--

function GottaGoFast:ChatCommand(input)
  if (string.lower(input) == "debugmode") then
    --local setting = not GottaGoFast.GetDebugMode(nil);
    GottaGoFast.SetDebugMode(nil, (not GottaGoFast.GetDebugMode(nil)));
  else
    InterfaceOptionsFrame_OpenToCategory(GottaGoFast.optionsFrame);
    InterfaceOptionsFrame_OpenToCategory(GottaGoFast.optionsFrame);
  end
end

function GottaGoFast:ChatComm(prefix, input, distribution, sender)
  GottaGoFast.Utility.DebugPrint("History Message (From History Addon) Received");
  if (prefix == "GottaGoFast" and input == "HistoryLoaded") then
    GottaGoFast.Utility.DebugPrint("Input: History Loaded")
    if (GottaGoFast.SendHistoryFlag == true) then
      GottaGoFast.SendHistory(self.db.profile.History);
    end
  end
end

function GottaGoFast:CMChatComm(prefix, input, distribution, sender)
  -- Right Now This Is Only Used For Syncing Timer
  GottaGoFast.Utility.DebugPrint("CM Message Received");
  if (prefix == "GottaGoFastCM" and input == "FixCM" and GottaGoFast.inCM == true and GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM) ~= nil) then
    GottaGoFast.CheckCMTimer();
  elseif (prefix == "GottaGoFastCM" and GottaGoFast.inCM == true and GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM) ~= nil) then
    -- Received Timer, See If You Need It, Then Update
    GottaGoFast.FixCMTimer(input)
  end
end

local reset_time = 8.0
local last_cm_zoneid = nil

function GottaGoFast.ResetState()
  GottaGoFast.WipeCM();
  GottaGoFast.inCM = false;
  GottaGoFast.demoMode = false;
  GottaGoFast.tooltip = GottaGoFast.defaultTooltip;
  GottaGoFastFrame:SetScript("OnUpdate", nil);
  GottaGoFast.HideFrames();
  GottaGoFast.ShowObjectiveTracker();
  last_cm_zoneid = nil
end

function GottaGoFast.WhereAmI()
  local _, _, difficulty, _, _, _, _, currentZoneID = GetInstanceInfo();
  GottaGoFast.Utility.DebugPrint("Difficulty: " .. difficulty);
  GottaGoFast.Utility.DebugPrint("Zone ID: " .. currentZoneID);
  if (GottaGoFast.FirstCheck == false) then
    GottaGoFast.FirstCheck = true;
    GottaGoFast:ScheduleTimer(GottaGoFast.WhereAmI, 0.2);
  elseif (difficulty == 8) then
	if (not last_cm_zoneid) or (last_cm_zoneid ~= currentZoneID) then
		last_cm_zoneid = currentZoneID;
		GottaGoFast.InitCM(currentZoneID);
	end
  else
    --GottaGoFast.ResetState();
	if GottaGoFast.CurrentCM["Completed"] == false then
		GottaGoFast:ScheduleTimer(GottaGoFast.CheckLeftForGood, reset_time, GottaGoFast.CurrentCM["ZoneID"]);
	else
		GottaGoFast:ScheduleTimer(GottaGoFast.CheckLeftForGood, 1, GottaGoFast.CurrentCM["ZoneID"]);
	end
  end
end

function GottaGoFast.CheckLeftForGood(ZoneID)
	local _, _, difficulty, _, _, _, _, currentZoneID = GetInstanceInfo();
	if (difficulty ~= 8) then
		GottaGoFast.ResetState();
	end
end
