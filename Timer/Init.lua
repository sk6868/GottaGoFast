local GottaGoFast = LibStub("AceAddon-3.0"):GetAddon("GottaGoFast")

function GottaGoFast:InitState()
  -- Default AddOn Globals
  self.inCM = false;
  self.minWidth = 200;
  self.unlocked = false;
  self.defaultTooltip = "Not In A CM";
  self.tooltip = self.defaultTooltip;
  self.demoMode = false;
  self.Models = {};
end

function GottaGoFast.TooltipOnEnter(self)
  if not InCombatLockdown() then
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
	GameTooltip:SetText(GottaGoFast.tooltip, nil, nil, nil, nil, 1);
  end
end

function GottaGoFast.TooltipOnLeave(self)
  GameTooltip_Hide();
end

function GottaGoFast.InitFrame()
  -- Register Textures
  GottaGoFastFrame.texture = GottaGoFastFrame:CreateTexture(nil,"BACKGROUND");
  GottaGoFastFrame.timertexture = GottaGoFastFrame:CreateTexture(nil, "BACKGROUND");
  GottaGoFastFrame.objectivestexture = GottaGoFastFrame:CreateTexture(nil, "BACKGROUND");

  -- Register Fonts
  GottaGoFastFrame.timerfont = GottaGoFastFrame:CreateFontString(nil, "OVERLAY");
  GottaGoFastFrame.objectivesfont = GottaGoFastFrame:CreateFontString(nil, "OVERLAY");

  -- Move Frame When Unlocked
  GottaGoFastFrame:SetScript("OnMouseDown", function(self, button)
    if GottaGoFast.unlocked and button == "LeftButton" and not self.isMoving then
     self:StartMoving();
     self.isMoving = true;
    end
  end);

  GottaGoFastFrame:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" and self.isMoving then
     self:StopMovingOrSizing();
     self.isMoving = false;
     local point, relativeTo, relativePoint, xOffset, yOffset = GottaGoFastFrame:GetPoint(1);

     GottaGoFast.db.profile.FrameAnchor = point;
     GottaGoFast.db.profile.FrameX = xOffset;
     GottaGoFast.db.profile.FrameY = yOffset;
    end
  end);

  GottaGoFastFrame:SetScript("OnHide", function(self)
    if ( self.isMoving ) then
     self:StopMovingOrSizing();
     self.isMoving = false;
    end
  end);

  -- Set Frame Width / Height
  GottaGoFastFrame:SetHeight(340);
  GottaGoFastFrame:SetWidth(GottaGoFast.minWidth);
  GottaGoFastFrame:SetPoint(GottaGoFast.db.profile.FrameAnchor, GottaGoFast.db.profile.FrameX, GottaGoFast.db.profile.FrameY);
  GottaGoFastFrame:SetMovable(GottaGoFast.unlocked);
  GottaGoFastFrame:EnableMouse(GottaGoFast.unlocked);
  GottaGoFastFrame.timertexture:SetHeight(40);
  GottaGoFastFrame.timertexture:SetWidth(GottaGoFast.minWidth);
  GottaGoFastFrame.timertexture:SetPoint("TOP", GottaGoFast.db.profile.TimerX, GottaGoFast.db.profile.TimerY);
  GottaGoFastFrame.objectivestexture:SetHeight(300);
  GottaGoFastFrame.objectivestexture:SetWidth(GottaGoFast.minWidth);
  GottaGoFastFrame.objectivestexture:SetPoint("TOP", GottaGoFast.db.profile.ObjectiveX, GottaGoFast.db.profile.ObjectiveY);

  -- Set Font Settings
  GottaGoFastFrame.timerfont:SetPoint("TOP", GottaGoFast.db.profile.TimerX, GottaGoFast.db.profile.TimerY);
  GottaGoFastFrame.timerfont:SetJustifyH(GottaGoFast.db.profile.TimerAlign);
  GottaGoFastFrame.timerfont:SetJustifyV("BOTTOM");
  GottaGoFastFrame.timerfont:SetFont(GottaGoFast.LSM:Fetch("font", GottaGoFast.db.profile.TimerFont), GottaGoFast.db.profile.TimerFontSize, GottaGoFast.db.profile.TimerFontFlag);
  GottaGoFastFrame.timerfont:SetTextColor(1, 1, 1, 1);

  GottaGoFastFrame.objectivesfont:SetPoint("TOP", GottaGoFast.db.profile.ObjectiveX, GottaGoFast.db.profile.ObjectiveY);
  GottaGoFastFrame.objectivesfont:SetJustifyH(GottaGoFast.db.profile.ObjectiveAlign);
  GottaGoFastFrame.objectivesfont:SetJustifyV("TOP");
  GottaGoFastFrame.objectivesfont:SetFont(GottaGoFast.LSM:Fetch("font", GottaGoFast.db.profile.ObjectiveFont), GottaGoFast.db.profile.ObjectiveFontSize, GottaGoFast.db.profile.ObjectiveFontFlag);
  GottaGoFastFrame.objectivesfont:SetTextColor(1, 1, 1, 1);

  -- Remove Frame Background
  GottaGoFastFrame.texture:SetAllPoints(GottaGoFastFrame);
  GottaGoFastFrame.texture:SetTexture(0.5, 0.5, 0.5, 0);
  GottaGoFastFrame.timertexture:SetAllPoints(GottaGoFastTimerFrame);
  GottaGoFastFrame.timertexture:SetTexture(0, 1, 0, 0);
  GottaGoFastFrame.objectivestexture:SetAllPoints(GottaGoFastObjectiveFrame);
  GottaGoFastFrame.objectivestexture:SetTexture(0, 1, 0, 0);

  -- Create Tooltip
  if (GottaGoFast.GetTimerTooltip(nil)) then
	GottaGoFastFrame:SetScript("OnEnter", GottaGoFast.TooltipOnEnter);
	GottaGoFastFrame:SetScript("OnLeave", GottaGoFast.TooltipOnLeave);
  end
end

function GottaGoFast.ResizeFrame()
  local width;
  local minWidth = GottaGoFast.minWidth;
  local timerWidth = GottaGoFastFrame.timerfont:GetStringWidth();
  local objectiveWidth = GottaGoFastFrame.objectivesfont:GetStringWidth();
  if (minWidth >= timerWidth and minWidth >= objectiveWidth) then
    -- minWidth
    width = minWidth;
  elseif (timerWidth >= minWidth and timerWidth >= objectiveWidth) then
    -- Timer Width
    width = timerWidth;
  else
    -- Objective Width
    width = objectiveWidth
  end
  GottaGoFastFrame:SetWidth(width);
end

function GottaGoFast.ShowFrames()
  if (GottaGoFastFrame:IsShown() == false) then
    GottaGoFastFrame:Show();
  end
end

function GottaGoFast.HideFrames()
  if (GottaGoFastFrame:IsShown()) then
    GottaGoFastFrame:Hide();
  end
end
