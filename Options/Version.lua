local GottaGoFast = LibStub("AceAddon-3.0"):GetAddon("GottaGoFast")
local constants = GottaGoFast.Constants;
local utility = GottaGoFast.Utility;
local version = constants.Version;

function GottaGoFast.VersionCheck()
  local lastVersion = GottaGoFast.GetVersion(nil);
  utility.DebugPrint("Last Version: " .. lastVersion);
  utility.DebugPrint("Current Version: " .. version);
  if (lastVersion == nil or lastVersion == 0) then
    -- First Time Run
    GottaGoFast.VersionFirstRun();
  elseif (lastVersion < version) then
    GottaGoFast:Print("Welcome To v" .. constants.VersionName);
  end
  GottaGoFast.SetVersion(nil, version);
end

function GottaGoFast.VersionFirstRun()
  utility.DebugPrint("First Run");
  GottaGoFast.SendHistoryFlag = true;
end
