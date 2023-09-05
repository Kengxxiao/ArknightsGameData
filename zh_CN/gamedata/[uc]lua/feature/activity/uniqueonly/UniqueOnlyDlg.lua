local luaUtils = CS.Torappu.Lua.Util;











UniqueOnlyDlg = Class("UniqueOnlyDlg", DlgBase)

local UniqueOnlyViewModel = require("Feature/Activity/UniqueOnly/UniqueOnlyViewModel");
local UniqueOnlyItemCardView = require("Feature/Activity/UniqueOnly/UniqueOnlyItemCardView");

function UniqueOnlyDlg:OnInit()
  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._btnClose);
  self:AddButtonClickListener(self._btnClaim, self._HandleClaimRewards);
  self:_InitItemContainerListIfNot();

  self.m_actId = self.m_parent:GetData("actId");
  UniqueOnlyUtil.SetUniqueOnlyActClicked(self.m_actId);
  self.m_viewModel = UniqueOnlyViewModel.new();
  self.m_viewModel:LoadData(self.m_actId);
  self.m_itemCardViewList = {}
  local itemList = self.m_viewModel.itemList;
  for idx = 1, #itemList do
    local container = self:_PickItemContainer(idx);
    if container ~= nil then
      local itemView = self:CreateWidgetByPrefab(UniqueOnlyItemCardView, self._prefabItemCard, container);
      itemView.cacheItemListIndex = idx;
      table.insert(self.m_itemCardViewList, itemView);
    end
  end

  local endTime = self.m_viewModel.endTime
  local timeStr = luaUtils.Format(StringRes.DATE_FORMAT_YYYY_MM_DD_HH_MM,
      endTime.Year, endTime.Month, endTime.Day, endTime.Hour, endTime.Minute)
  self._textEndTime.text = timeStr
  self:_RefreshUI();
end

function UniqueOnlyDlg:_HandleClaimRewards()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return
  end

  UISender.me:SendRequest(UniqueOnlyServiceCode.GET_REWARD, 
      {
        activityId = self.m_actId
      }, 
      {
        onProceed = Event.Create(self, self._HandleClaimRewardsResponse)
      }
  )
end

function UniqueOnlyDlg:_HandleClaimRewardsResponse(response)
  self:_RefreshUI();
  CS.Torappu.Activity.ActivityUtil.DoShowGainedItems(response.reward);
end

function UniqueOnlyDlg:_InitItemContainerListIfNot()
  if self.m_itemContainerList == nil then
    local rectTransList = self._objItemHolderParent:GetComponentsInChildren(typeof(CS.UnityEngine.RectTransform));
    self.m_itemContainerList = {};

    
    for i = 1, rectTransList.Length - 1 do
      table.insert(self.m_itemContainerList, rectTransList[i]);
    end
  end
end



function UniqueOnlyDlg:_PickItemContainer(luaIndex)
  if self.m_itemContainerList == nil or #self.m_itemContainerList == 0 or 
      luaIndex < 1 or luaIndex > #self.m_itemContainerList then
    return nil
  end

  return self.m_itemContainerList[luaIndex];
end

function UniqueOnlyDlg:_RefreshUI()
  self.m_viewModel:RefreshData();

  
  local itemModelList = self.m_viewModel.itemList;
  for idx = 1, #self.m_itemCardViewList do
    local itemCardView = self.m_itemCardViewList[idx];
    local cachedIndex = itemCardView.cacheItemListIndex;
    if cachedIndex >= 1 and cachedIndex <= #itemModelList then
      local cachedItemModel = itemModelList[cachedIndex];
      itemCardView:Render(cachedItemModel);
    end
  end
  
  SetGameObjectActive(self._objBtnClaim, self.m_viewModel.canClaimReward);
end