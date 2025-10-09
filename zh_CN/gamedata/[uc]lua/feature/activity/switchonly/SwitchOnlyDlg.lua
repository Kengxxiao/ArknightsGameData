local luaUtils = CS.Torappu.Lua.Util;











SwitchOnlyDlg = Class("SwitchOnlyDlg", DlgBase);
local SwitchOnlyItemView = require("Feature/Activity/SwitchOnly/SwitchOnlyItemView")
local SwitchOnlyTitleItemView = require("Feature/Activity/SwitchOnly/SwitchOnlyTitleItemView")
local SwitchOnlyItemViewModel = require("Feature/Activity/SwitchOnly/SwitchOnlyItemViewModel");
local SwitchOnlyMainRewardShowViewModel = require("Feature/Activity/SwitchOnly/SwitchOnlyMainRewardShowViewModel");
local SwitchOnlyRewardItemViewModel = require("Feature/Activity/SwitchOnly/SwitchOnlyRewardItemViewModel");

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

  local rewardsShowDict = actData.rewardShowDatas;
  local playerRewards = playerActData.rewards;
  local sortIdDict = actData.sortIdDict;

  self._textRule.text = CS.Torappu.FormatUtil.FormatRichTextFromData(actData.constData.activityRule);
  self._textTime.text = actData.constData.activityTime;

  local itemModelList = {};
  for k, v in pairs(rewardsShowDict) do
    local itemModel = SwitchOnlyItemViewModel.new();
    local suc, sortId = sortIdDict:TryGetValue(k);
    if not suc then
      sortId = -1;
    end

    local checkinRewardData = v;
    itemModel.sortId = sortId;
    itemModel.id = checkinRewardData.checkinId;
    itemModel.title = checkinRewardData.rewardsTitle;
    local rewardShowItemData = checkinRewardData.rewardShowItemDatas;
    if rewardShowItemData ~= nil then
      local rewards = {}
      for iReward = 0, rewardShowItemData.Length - 1 do
        local rewardItemShowData = rewardShowItemData[iReward];
        table.insert(rewards, SwitchOnlyRewardItemViewModel.new(rewardItemShowData));
      end
      itemModel.rewards = rewards;
    else
      itemModel.rewards = {}
    end
    
    local mainRewardShowData = checkinRewardData.mainRewardShowData;
    local mainRewardShowViewModel = SwitchOnlyMainRewardShowViewModel.new();
    mainRewardShowViewModel.mainRewardPicId = mainRewardShowData.mainRewardPicId;
    mainRewardShowViewModel.mainRewardName = mainRewardShowData.mainRewardName;
    mainRewardShowViewModel.mainRewardCount = mainRewardShowData.mainRewardCount;
    mainRewardShowViewModel.hasTip = mainRewardShowData.hasTip;
    mainRewardShowViewModel.tipItemBundle = mainRewardShowData.tipItemBundle;

    itemModel.mainRewardShowViewModel = mainRewardShowViewModel;
    local suc, playerData = playerRewards:TryGetValue(k);
    if suc then
      itemModel.isReceived = playerData > 1;
      itemModel.isUnlocked = playerData > 0;
    else
      itemModel.isReceived = false;
      itemModel.isUnlocked = false;
    end

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
    item:Refresh(self.m_activityId, v.isUnlocked, v.isReceived, v.id, v);

    local title = nil;
    title = self:CreateWidgetByPrefab(SwitchOnlyTitleItemView, self._titleItemView, self._titleContainer)  
    title:Refresh(v.isUnlocked, v.title);
  end
end
