
local Act45SideHotfixer = Class("Act45SideHotfixer", HotfixBase)

local function Act45SideConfirmMailsFix(self)
  if self.m_cachedActId == nil then
    return;
  end

  local suc, playerActData = CS.Torappu.PlayerData.instance.data.activity.act45sideActivityList:TryGetValue(self.m_cachedActId);
  if not suc then
    return;
  end

  if playerActData.mailState == nil then
    return;
  end

  local hasMail = false;
  local State = CS.Torappu.PlayerActivity.PlayerAct45SideActivity.State;
  for id, state in pairs(playerActData.mailState) do    
    if state == State.UNLOCK then
      hasMail = true;
      break;
    end
  end

  if not hasMail then
    return;
  end

  self:_ConfirmMails()
end

local function Act45SideConfirmCharsFix(self)
  if self.m_cachedActId == nil then
    return;
  end

  local suc, playerActData = CS.Torappu.PlayerData.instance.data.activity.act45sideActivityList:TryGetValue(self.m_cachedActId);
  if not suc then
    return;
  end

  if playerActData.charState == nil then
    return;
  end

  local hasChar = false;
  local State = CS.Torappu.PlayerActivity.PlayerAct45SideActivity.State;
  for id, state in pairs(playerActData.charState) do    
    if state == State.UNLOCK then
      hasChar = true;
      break;
    end
  end

  if not hasChar then
    return;
  end

  self:_ConfirmChars()
end

local function  StoryReviewActivityDetailItemFix(self, storyModel, outOfTime)
  self:ApplyData(storyModel, outOfTime)
  local oldBrief = self._storyInfo.text;
  self._storyInfo.text = CS.Torappu.AVGTextManager.instance:Translate(oldBrief);
end

function Act45SideHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Activity.Act45Side.Act45SideCharUnlockDialog)
  xlua.private_accessible(CS.Torappu.Activity.Act45Side.Act45SideMailDialog)
  xlua.private_accessible(CS.Torappu.UI.StoryReview.StoryReviewActivityDetailItemView)

  self:Fix_ex(CS.Torappu.Activity.Act45Side.Act45SideCharUnlockDialog, "_ConfirmChars", Act45SideConfirmCharsFix)
  self:Fix_ex(CS.Torappu.Activity.Act45Side.Act45SideMailDialog, "_ConfirmMails", Act45SideConfirmMailsFix)
  self:Fix_ex(CS.Torappu.UI.StoryReview.StoryReviewActivityDetailItemView, "ApplyData", StoryReviewActivityDetailItemFix)
end

function Act45SideHotfixer:OnDispose()
end

return Act45SideHotfixer
