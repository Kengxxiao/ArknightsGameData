local luaUtil = CS.Torappu.Lua.Util
local FadeSwitchTween = CS.Torappu.UI.FadeSwitchTween;

















local ReturnV2MissionTopBarDetailPanel = Class("ReturnV2MissionTopBarDetailPanel", UIPanel)
local ReturnV2MissionPointRewardDetailItem = require("Feature/Operation/ReturnV2/ReturnV2MissionPointRewardDetailItem")
local UICommonItemCard = require("Feature/Supportor/UI/UICommonItemCard");

function ReturnV2MissionTopBarDetailPanel:OnInit()
  self:AddButtonClickListener(self._btnBackPress, self._ClosePanel)
  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._btnBackPress)
  self.m_switchTween = FadeSwitchTween(self._canvasSelf, tonumber(self._floatTweenDur));
  self.m_switchTween:Reset(false);

  self.m_dailySupplyAdapter = self:CreateCustomComponent(
      UISimpleLayoutAdapter, self, self._dailySupplyContent,
      self._CreateDailySupplyItemView, self._GetDailySupplyItemCount, 
      self._UpdateDailySupplyItemView);
  self.m_dailySupplyItemList = {}
  self.m_pointRewardAdapter = self:CreateCustomComponent(
      UISimpleLayoutAdapter, self, self._pointRewardContent,
      self._CreatePriceRewardItemView, self._GetPriceRewardItemCount, 
      self._UpdatePriceRewardItemView);
  self.m_pointRewardGroupContent = {}
end


function ReturnV2MissionTopBarDetailPanel:OnViewModelUpdate(data)
  if data == nil or data.tabState ~= ReturnV2StateTabStatus.STATE_TAB_TASK then
    return
  end

  local showPanel = data.showTopBarDetailPanel
  self.m_switchTween.isShow = showPanel
  if showPanel then
    self._scrollRect.verticalNormalizedPosition = 1;
    self._textPointReward.text = data.topBarPointRewardDesc
    self._textDailySupply.text = data.topBarDailySupplyDesc
    self.m_dailySupplyItemList = data.topBarDailySupplyBundleList
    self.m_pointRewardGroupContent = data.topBarPointRewardGroupContent
    self.m_pointRewardState = data.priceRewardState

    self.m_dailySupplyAdapter:NotifyDataSetChanged()
    self.m_pointRewardAdapter:NotifyDataSetChanged()
  end
end

function ReturnV2MissionTopBarDetailPanel:_ClosePanel()
  if self.closePanelEvent then
    self.closePanelEvent:Call()
  end
end



function ReturnV2MissionTopBarDetailPanel:_CreateDailySupplyItemView(gameObj)
  local itemView = self:CreateWidgetByGO(UICommonItemCard, gameObj);
  return itemView;
end


function ReturnV2MissionTopBarDetailPanel:_GetDailySupplyItemCount()
  if self.m_dailySupplyItemList == nil then
    return 0
  end
  return #self.m_dailySupplyItemList;
end



function ReturnV2MissionTopBarDetailPanel:_UpdateDailySupplyItemView(index, view)
  view:Render(self.m_dailySupplyItemList[index + 1], {
    itemScale = tonumber(self._itemScale),
    isCardClickable = true,
    showItemName = false,
    showItemNum = true,
    showBackground = true,
  });
end



function ReturnV2MissionTopBarDetailPanel:_CreatePriceRewardItemView(gameObj)
  local view = self:CreateWidgetByGO(ReturnV2MissionPointRewardDetailItem, gameObj)
  view.loadSpriteFunc = function(hubPath, spriteId)
    return self:LoadSpriteFromAutoPackHub(hubPath, spriteId)
  end
  return view
end


function ReturnV2MissionTopBarDetailPanel:_GetPriceRewardItemCount()
  if self.m_pointRewardGroupContent == nil then
    return 0
  end
  return #self.m_pointRewardGroupContent
end



function ReturnV2MissionTopBarDetailPanel:_UpdatePriceRewardItemView(index, view)
  local item = self.m_pointRewardGroupContent[index + 1]
  local iconId = item.iconId
  local title = item.desc
  local rewardList = ToLuaArray(item.rewardList)
  local haveClaimed = self.m_pointRewardState[index + 1] == ReturnV2PriceRewardState.CLAIMED
  view:Render(iconId, title, rewardList, haveClaimed)
end

return ReturnV2MissionTopBarDetailPanel