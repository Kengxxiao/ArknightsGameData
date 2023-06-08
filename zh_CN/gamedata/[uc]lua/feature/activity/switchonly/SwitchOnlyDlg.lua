local luaUtils = CS.Torappu.Lua.Util;











SwitchOnlyDlg = Class("SwitchOnlyDlg", DlgBase);
local SwitchOnlyItemView = require("Feature/Activity/SwitchOnly/SwitchOnlyItemView")
local SwitchOnlyTitleItemView = require("Feature/Activity/SwitchOnly/SwitchOnlyTitleItemView")

function SwitchOnlyDlg:OnInit()
  self.m_activityId = self.m_parent:GetData("actId");
  
  if self._buttonBackScreen ~= nil then
    self:AddButtonClickListener(self._buttonBackScreen, self._HandleSysClose);
  end
  self:_RefreshUI();

  local cacheKey = self.m_activityId;
  CS.Torappu.Activity.ActLocalCacheHandler.SaveParamToCache(cacheKey, 1);
end

function SwitchOnlyDlg:_RefreshUI()
  local suc, basicData = CS.Torappu.ActivityDB.data.basicInfo:TryGetValue(self.m_activityId);
  if not suc then
    return;
  end

  local suc, actData = CS.Torappu.ActivityDB.data.activity.switchCheckinData:TryGetValue(self.m_activityId);
  if not suc then
    return;
  end
  
  local suc, playerActData = CS.Torappu.PlayerData.instance.data.activity.switchOnlyList:TryGetValue(self.m_activityId);
  if not suc then
    return;
  end

  local rewardsDict = actData.rewards;
  local playerRewards = playerActData.rewards;
  local titleDict = actData.rewardsTitle;

  self._textRule.text = CS.Torappu.FormatUtil.FormatRichTextFromData(actData.constData.activityRule);
  self._textTime.text = actData.constData.activityTime;

  
  for k,v in pairs(rewardsDict) do
    local suc, playerData = playerRewards:TryGetValue(k);
    local got = false;
    local unlocked = false;
    if suc then
      got = playerData > 1;
      unlocked = playerData > 0;
    end
    local item = nil;
    item = self:CreateWidgetByPrefab(SwitchOnlyItemView, self._itemView, self._rectTrans);
    item:Refresh(self.m_activityId, unlocked, got, k, v);

    local title = nil;
    title = self:CreateWidgetByPrefab(SwitchOnlyTitleItemView, self._titleItemView, self._titleContainer)
    local suc, titleText = titleDict:TryGetValue(k);
    if not suc then
      titleText = "";
    end
    title:Refresh(unlocked, titleText);
  end
end
