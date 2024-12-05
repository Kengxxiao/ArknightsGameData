local luaUtils = CS.Torappu.Lua.Util;











SwitchOnlyDlg = Class("SwitchOnlyDlg", DlgBase);
local SwitchOnlyItemView = require("Feature/Activity/SwitchOnly/SwitchOnlyItemView")
local SwitchOnlyTitleItemView = require("Feature/Activity/SwitchOnly/SwitchOnlyTitleItemView")
local SwitchOnlyItemViewModel = require("Feature/Activity/SwitchOnly/SwitchOnlyItemViewModel");

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
  local sortIdDict = actData.sortIdDict;

  self._textRule.text = CS.Torappu.FormatUtil.FormatRichTextFromData(actData.constData.activityRule);
  self._textTime.text = actData.constData.activityTime;

  local itemModelList = {};
  for k, v in pairs(rewardsDict) do
    local itemModel = SwitchOnlyItemViewModel.new();
    local suc, sortId = sortIdDict:TryGetValue(k);
    if not suc then
      sortId = -1;
    end
    itemModel.sortId = sortId;
    itemModel.id = k;
    itemModel.rewards = v;
    local suc, playerData = playerRewards:TryGetValue(k);
    if suc then
      itemModel.isReceived = playerData > 1;
      itemModel.isUnlocked = playerData > 0;
    else
      itemModel.isReceived = false;
      itemModel.isUnlocked = false;
    end
    local suc, titleText = titleDict:TryGetValue(k);
    if not suc then
      titleText = "";
    end
    itemModel.title = titleText;
    table.insert(itemModelList, itemModel);
  end
  table.sort(itemModelList, function(l, r)
    if l.sortId ~= r.sortId then
      return l.sortId < r.sortId;
    end
    return l.id < r.id;
  end)

  
  for k, v in pairs(itemModelList) do
    local item = nil;
    item = self:CreateWidgetByPrefab(SwitchOnlyItemView, self._itemView, self._rectTrans);
    item:Refresh(self.m_activityId, v.isUnlocked, v.isReceived, v.id, v.rewards);

    local title = nil;
    title = self:CreateWidgetByPrefab(SwitchOnlyTitleItemView, self._titleItemView, self._titleContainer)  
    title:Refresh(v.isUnlocked, v.title);
  end
end
