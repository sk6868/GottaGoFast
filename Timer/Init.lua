local GottaGoFast = LibStub("AceAddon-3.0"):GetAddon("GottaGoFast")

function GottaGoFast.InitState()
  -- Default AddOn Globals
  GottaGoFast.inCM = false;
  GottaGoFast.minWidth = 200;
  GottaGoFast.unlocked = false;
  GottaGoFast.defaultTooltip = "Not In A CM";
  GottaGoFast.tooltip = GottaGoFast.defaultTooltip;
  GottaGoFast.demoMode = false;
  GottaGoFast.Models = {};
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
  --GottaGoFastTimerFrame.texture = GottaGoFastTimerFrame:CreateTexture(nil, "BACKGROUND");
  GottaGoFastFrame.timertexture = GottaGoFastFrame:CreateTexture(nil, "BACKGROUND");
  --GottaGoFastObjectiveFrame.texture = GottaGoFastObjectiveFrame:CreateTexture(nil, "BACKGROUND");
  GottaGoFastFrame.objectivestexture = GottaGoFastFrame:CreateTexture(nil, "BACKGROUND");

  -- Register Fonts
  --GottaGoFastTimerFrame.font = GottaGoFastTimerFrame:CreateFontString(nil, "OVERLAY");
  GottaGoFastFrame.timerfont = GottaGoFastFrame:CreateFontString(nil, "OVERLAY");
  --GottaGoFastObjectiveFrame.font = GottaGoFastObjectiveFrame:CreateFontString(nil, "OVERLAY");
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
  --GottaGoFastTimerFrame:SetHeight(40);
  --GottaGoFastTimerFrame:SetWidth(GottaGoFast.minWidth);
  --GottaGoFastTimerFrame:SetPoint("TOP", GottaGoFast.db.profile.TimerX, GottaGoFast.db.profile.TimerY);
  --GottaGoFastObjectiveFrame:SetHeight(300);
  --GottaGoFastObjectiveFrame:SetWidth(GottaGoFast.minWidth);
  --GottaGoFastObjectiveFrame:SetPoint("TOP", GottaGoFast.db.profile.ObjectiveX, GottaGoFast.db.profile.ObjectiveY);
  GottaGoFastFrame.timertexture:SetHeight(40);
  GottaGoFastFrame.timertexture:SetWidth(GottaGoFast.minWidth);
  GottaGoFastFrame.timertexture:SetPoint("TOP", GottaGoFast.db.profile.TimerX, GottaGoFast.db.profile.TimerY);
  GottaGoFastFrame.objectivestexture:SetHeight(300);
  GottaGoFastFrame.objectivestexture:SetWidth(GottaGoFast.minWidth);
  GottaGoFastFrame.objectivestexture:SetPoint("TOP", GottaGoFast.db.profile.ObjectiveX, GottaGoFast.db.profile.ObjectiveY);

  -- Set Font Settings
  --GottaGoFastTimerFrame.font:SetAllPoints(true);
  --GottaGoFastTimerFrame.font:SetJustifyH(GottaGoFast.db.profile.TimerAlign);
  --GottaGoFastTimerFrame.font:SetJustifyV("BOTTOM");
  --GottaGoFastTimerFrame.font:SetFont(GottaGoFast.LSM:Fetch("font", GottaGoFast.db.profile.TimerFont), GottaGoFast.db.profile.TimerFontSize, GottaGoFast.db.profile.TimerFontFlag);
  --GottaGoFastTimerFrame.font:SetTextColor(1, 1, 1, 1);
  GottaGoFastFrame.timerfont:SetPoint("TOP", GottaGoFast.db.profile.TimerX, GottaGoFast.db.profile.TimerY);
  GottaGoFastFrame.timerfont:SetJustifyH(GottaGoFast.db.profile.TimerAlign);
  GottaGoFastFrame.timerfont:SetJustifyV("BOTTOM");
  GottaGoFastFrame.timerfont:SetFont(GottaGoFast.LSM:Fetch("font", GottaGoFast.db.profile.TimerFont), GottaGoFast.db.profile.TimerFontSize, GottaGoFast.db.profile.TimerFontFlag);
  GottaGoFastFrame.timerfont:SetTextColor(1, 1, 1, 1);

  --GottaGoFastObjectiveFrame.font:SetAllPoints(true);
  --GottaGoFastObjectiveFrame.font:SetJustifyH(GottaGoFast.db.profile.ObjectiveAlign);
  --GottaGoFastObjectiveFrame.font:SetJustifyV("TOP");
  --GottaGoFastObjectiveFrame.font:SetFont(GottaGoFast.LSM:Fetch("font", GottaGoFast.db.profile.ObjectiveFont), GottaGoFast.db.profile.ObjectiveFontSize, GottaGoFast.db.profile.ObjectiveFontFlag);
  --GottaGoFastObjectiveFrame.font:SetTextColor(1, 1, 1, 1);
  GottaGoFastFrame.objectivesfont:SetPoint("TOP", GottaGoFast.db.profile.ObjectiveX, GottaGoFast.db.profile.ObjectiveY);
  GottaGoFastFrame.objectivesfont:SetJustifyH(GottaGoFast.db.profile.ObjectiveAlign);
  GottaGoFastFrame.objectivesfont:SetJustifyV("TOP");
  GottaGoFastFrame.objectivesfont:SetFont(GottaGoFast.LSM:Fetch("font", GottaGoFast.db.profile.ObjectiveFont), GottaGoFast.db.profile.ObjectiveFontSize, GottaGoFast.db.profile.ObjectiveFontFlag);
  GottaGoFastFrame.objectivesfont:SetTextColor(1, 1, 1, 1);

  -- Remove Frame Background
  GottaGoFastFrame.texture:SetAllPoints(GottaGoFastFrame);
  GottaGoFastFrame.texture:SetTexture(0.5, 0.5, 0.5, 0);
  --GottaGoFastTimerFrame.texture:SetAllPoints(GottaGoFastTimerFrame);
  --GottaGoFastTimerFrame.texture:SetTexture(0, 1, 0, 0);
  --GottaGoFastObjectiveFrame.texture:SetAllPoints(GottaGoFastObjectiveFrame);
  --GottaGoFastObjectiveFrame.texture:SetTexture(0, 1, 0, 0);
  GottaGoFastFrame.timertexture:SetAllPoints(GottaGoFastTimerFrame);
  GottaGoFastFrame.timertexture:SetTexture(0, 1, 0, 0);
  GottaGoFastFrame.objectivestexture:SetAllPoints(GottaGoFastObjectiveFrame);
  GottaGoFastFrame.objectivestexture:SetTexture(0, 1, 0, 0);

  -- Create Tooltip
  if (GottaGoFast.GetTimerTooltip(nil)) then
    --GottaGoFastTimerFrame:SetScript("OnEnter", GottaGoFast.TooltipOnEnter);
    --GottaGoFastTimerFrame:SetScript("OnLeave", GottaGoFast.TooltipOnLeave);
	GottaGoFastFrame:SetScript("OnEnter", GottaGoFast.TooltipOnEnter);
	GottaGoFastFrame:SetScript("OnLeave", GottaGoFast.TooltipOnLeave);
  end
end

function GottaGoFast.ResizeFrame()
  local width;
  local minWidth = GottaGoFast.minWidth;
  --local timerWidth = GottaGoFastTimerFrame.font:GetStringWidth();
  --local objectiveWidth = GottaGoFastObjectiveFrame.font:GetStringWidth();
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
  --GottaGoFastObjectiveFrame:SetWidth(width);
  --GottaGoFastTimerFrame:SetWidth(width);
  GottaGoFastFrame:SetWidth(width);
end

function GottaGoFast.ShowFrames()
  if (GottaGoFastFrame:IsShown() == false) then
    GottaGoFastFrame:Show();
  end
  --if (GottaGoFastTimerFrame:IsShown() == false) then
  --  GottaGoFastTimerFrame:Show();
  --end
  --if (GottaGoFastObjectiveFrame:IsShown() == false) then
  --  GottaGoFastObjectiveFrame:Show();
  --end
end

function GottaGoFast.HideFrames()
  if (GottaGoFastFrame:IsShown()) then
    GottaGoFastFrame:Hide();
  end
  --if (GottaGoFastTimerFrame:IsShown()) then
  --  GottaGoFastTimerFrame:Hide();
  --end
  --if (GottaGoFastObjectiveFrame:IsShown()) then
  --  GottaGoFastObjectiveFrame:Hide();
  --end
end
