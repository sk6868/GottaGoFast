local GottaGoFast = LibStub("AceAddon-3.0"):GetAddon("GottaGoFast")
local utility = GottaGoFast.Utility;
local debugPrint = utility.DebugPrint;
local LOP = LibStub("LibObjectiveProgress-1.0", true);

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
    self:RegisterEvent("CHALLENGE_MODE_COMPLETED");
    self:RegisterEvent("CHALLENGE_MODE_RESET");
    self:RegisterEvent("CHALLENGE_MODE_START");
    --self:RegisterEvent("GOSSIP_SHOW");
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("SCENARIO_POI_UPDATE");
    self:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
    self:RegisterEvent("WORLD_STATE_TIMER_START");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
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

function GottaGoFast:CHALLENGE_MODE_COMPLETED()
  GottaGoFast.Utility.DebugPrint("CM Complete");
  GottaGoFast.CompleteCM();
  if (GottaGoFast.CurrentCM and next(GottaGoFast.CurrentCM) ~= nil) then
    GottaGoFast.CreateRun(GottaGoFast.CurrentCM);
  end
end

function GottaGoFast:CHALLENGE_MODE_RESET()
  GottaGoFast.Utility.DebugPrint("CM Reset")
  GottaGoFast.ResetState()
  GottaGoFast.HideObjectiveTracker()
end

function GottaGoFast:CHALLENGE_MODE_START()
  GottaGoFast.Utility.DebugPrint("CM Start")
  GottaGoFast.ResetState()
  GottaGoFast.HideObjectiveTracker()
end

function GottaGoFast:PLAYER_ENTERING_WORLD()
  self.Utility.DebugPrint("Player Entered World")
  self:WhereAmI()
end

function GottaGoFast:SCENARIO_POI_UPDATE()
  if (self.inCM) then
    self.Utility.DebugPrint("Scenario POI Update");
    if (self.CurrentCM["Steps"] == 0 and self.CurrentCM["Completed"] == false and next(self.CurrentCM["Bosses"]) == nil) then
      self:WhereAmI();
    end
    self.UpdateCMInformation();
    self.UpdateCMObjectives();
  end
end

function GottaGoFast:WORLD_STATE_TIMER_START(_, timerID)
  self.Utility.DebugPrint("World Start Timer Start"..timerID)
  if (self.inCM == false or next(self.CurrentCM) == nil or next(self.CurrentCM) == nil or self.CurrentCM["Steps"] == 0) then
    self:WhereAmI()
  end
  if (self.inCM and self.CurrentCM["Completed"] == false) then
      local _, timeCM, type = GetWorldElapsedTime(timerID)
      if (type == LE_WORLD_ELAPSED_TIMER_TYPE_CHALLENGE_MODE and timeCM ~= nil and timeCM <= 2) then
        self.StartCM(0)
        self.UpdateCMObjectives()
      elseif (self.CurrentCM["Deaths"]) then
        self.CurrentCM["Deaths"] = self.CurrentCM["Deaths"] + 1
        self.UpdateCMObjectives()
      end
  end
end

function GottaGoFast:UPDATE_MOUSEOVER_UNIT()
  if (self.inCM == true and self.GetIndividualMobValue(nil) == true and self.CurrentCM ~= nil and next(self.CurrentCM) ~= nil) then
    local npcID = GottaGoFast.MouseoverUnitID();
    local mapID = self.CurrentCM["ZoneID"];
	local cmID = self.CurrentCM["CmID"]
    local isTeeming = self.HasTeeming(self.CurrentCM["Affixes"]);
    if (npcID ~= nil and mapID ~= nil and isTeeming ~= nil) then
	  -- Upper Karazhan Check Should Be Param 4
      local upper = cmID == 234
      local weight = LOP:GetNPCWeightByMap(mapID, npcID, isTeeming, upper);
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

function GottaGoFast:ZONE_CHANGED_NEW_AREA()
  self.Utility.DebugPrint("Zone Changed New Area")
  self:WhereAmI();
end

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

function GottaGoFast:WhereAmI()
  local _, _, difficulty, _, _, _, _, currentZoneID = GetInstanceInfo();
  self.Utility.DebugPrint("Difficulty: " .. difficulty);
  self.Utility.DebugPrint("Zone ID: " .. currentZoneID);
  local challengeMapID = C_ChallengeMode.GetActiveChallengeMapID()
  if (difficulty == 8 and challengeMapID ~= nil) then
	if (not last_cm_zoneid) or (last_cm_zoneid ~= currentZoneID) then
		last_cm_zoneid = currentZoneID;
		self:InitCM(challengeMapID, currentZoneID);
	end
  else
    --GottaGoFast.ResetState();
	if self.CurrentCM["Completed"] == false then
		self:ScheduleTimer(self.CheckLeftForGood, reset_time, self.CurrentCM["ZoneID"]);
	else
		self:ScheduleTimer(self.CheckLeftForGood, 1, self.CurrentCM["ZoneID"]);
	end
  end
end

function GottaGoFast.CheckLeftForGood(ZoneID)
	local _, _, difficulty, _, _, _, _, currentZoneID = GetInstanceInfo();
	if (difficulty ~= 8) then
		GottaGoFast.ResetState();
	end
end
