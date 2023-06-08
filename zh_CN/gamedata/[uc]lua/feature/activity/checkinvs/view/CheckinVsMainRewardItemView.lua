local UIItemViewModel = CS.Torappu.UI.UIItemViewModel







local CheckinVsMainRewardItemView = Class("CheckinVsMainRewardItemView", UIWidget)

CheckinVsMainRewardItemView.ITEM_CARD_SCALE = 0.5



function CheckinVsMainRewardItemView:Render(itemBundle)
  if self.m_itemModel == nil then
    self.m_itemModel = UIItemViewModel()
  end
  self.m_itemModel:LoadGameData(itemBundle.id, itemBundle.type)
  self.m_itemModel.itemCount = itemBundle.count

  self:_CreateRewardCardIfNeed()
  if self.m_itemCard ~= nil then
    self.m_itemCard:Render(0, self.m_itemModel)
  end
end

function CheckinVsMainRewardItemView:_CreateRewardCardIfNeed()
  if self.m_itemCard ~= nil then
    return
  end
  local itemCard = CS.Torappu.UI.UIAssetLoader.instance.staticOutlinks.uiItemCard
  local rewardCard = CS.UnityEngine.GameObject.Instantiate(itemCard, self._itemParent):GetComponent("Torappu.UI.UIItemCard")
  rewardCard.isCardClickable = true
  rewardCard.showItemName = false
  rewardCard.showItemNum = true
  rewardCard.showBackground = true
  local scaler = rewardCard:GetComponent("Torappu.UI.UIScaler")
  if scaler ~= nil then
    scaler.scale = self.ITEM_CARD_SCALE
  end
  self:AsignDelegate(rewardCard, "onItemClick", self._OnRewardItemClick)

  self.m_itemCard = rewardCard
end 

function CheckinVsMainRewardItemView:_OnRewardItemClick(index)
  if self.m_itemModel == nil then
    return
  end
  CS.Torappu.UI.UIItemDescFloatController.ShowItemDesc(self.m_itemCard.gameObject, self.m_itemModel)
end

return CheckinVsMainRewardItemView 