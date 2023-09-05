

local UIItemViewModel = CS.Torappu.UI.UIItemViewModel












local UICommonItemCard = Class("UICommonItemCard", UIWidget)




function UICommonItemCard:Render(itemBundle, initConfig)
  if itemBundle == nil then
    return
  end

  if initConfig.itemScale == nil then
    self.m_itemScale = 1
  else
    self.m_itemScale = initConfig.itemScale
  end

  if initConfig.isCardClickable == nil then
    self.m_isCardClickable = false
  else
    self.m_isCardClickable = initConfig.isCardClickable
  end

  if initConfig.showItemName == nil then
    self.m_showItemName = false
  else
    self.m_showItemName = initConfig.showItemName
  end

  if initConfig.showItemNum == nil then
    self.m_showItemNum = false
  else
    self.m_showItemNum = initConfig.showItemNum
  end

  if initConfig.showBackground == nil then
    self.m_showBkg = false
  else
    self.m_showBkg = initConfig.showBackground
  end

  if initConfig.fastClickBlock == nil then
    self.m_fastClickBlock = false
  else
    self.m_fastClickBlock = initConfig.fastClickBlock
  end

  self.m_itemModel = UIItemViewModel.FromSharedItemGetModel(itemBundle);

  self:_CreateRewardCardIfNeed()
  if self.m_itemCard ~= nil then
    self.m_itemCard:Render(0, self.m_itemModel)
  end
end

function UICommonItemCard:_CreateRewardCardIfNeed()
  if self.m_itemCard ~= nil then
    return
  end
  local itemCard = CS.Torappu.UI.UIAssetLoader.instance.staticOutlinks.uiItemCard
  local rewardCard = CS.UnityEngine.GameObject.Instantiate(itemCard, self._itemParent):GetComponent("Torappu.UI.UIItemCard")
  rewardCard.isCardClickable = self.m_isCardClickable
  rewardCard.showItemName = self.m_showItemName 
  rewardCard.showItemNum = self.m_showItemNum
  rewardCard.showBackground = self.m_showBkg
  local scaler = rewardCard:GetComponent("Torappu.UI.UIScaler")
  if scaler ~= nil then
    scaler.scale = self.m_itemScale
  end

  if self.m_isCardClickable then
    self:AsignDelegate(rewardCard, "onItemClick", self._OnRewardItemClick)
  end

  self.m_itemCard = rewardCard
end 

function UICommonItemCard:_OnRewardItemClick(index)
  if self.m_itemModel == nil then
    return
  end
  if self.m_fastClickBlock and CS.Torappu.FastActionDetector.IsFastAction() then
    return
  end
  CS.Torappu.UI.UIItemDescFloatController.ShowItemDesc(self.m_itemCard.gameObject, self.m_itemModel)
end


function UICommonItemCard:ChangeItemCardStyle(styleConfig)
  if self.m_itemCard == nil or styleConfig == nil then
    return
  end

  
  if styleConfig.isCardClickable ~= nil then
    self.m_itemCard.isCardClickable = styleConfig.isCardClickable;
  end

  if styleConfig.mainColor ~= nil then
    self.m_itemCard.mainColor = styleConfig.mainColor;
  end
end

return UICommonItemCard 