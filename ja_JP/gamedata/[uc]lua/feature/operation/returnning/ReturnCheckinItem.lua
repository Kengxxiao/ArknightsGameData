local luaUtils = CS.Torappu.Lua.Util





















local ITEM_CARD_SCALE = 0.54
local ReturnCheckinItem = Class("ReturnCheckinItem",UIWidget)
ReturnCheckinItem.ITEM_STATE = {
  COLLECTED = 1,
  COLLECTABLE = 2,
  UNCOLLETABLE = 3
}

function ReturnCheckinItem:SetState(itemState, itemBundleFirst, itemBundleSecond, index)
  self.m_index = index
  self.m_itemFirst = itemBundleFirst
  self.m_itemSecond = itemBundleSecond
  self.m_state = itemState
end

function ReturnCheckinItem:Bind(view)
  self.m_parentView = view
end

function ReturnCheckinItem:_OnClick()
  if self.m_parentView == nil or self.m_index == nil then
    return
  end
  
  self.m_parentView:_EventOnClaimRewardClick(self.m_index)
end
function ReturnCheckinItem:Render()
  if self.m_parentView == nil then
    return
  end
  SetGameObjectActive(self._btnCollectedObj,self.m_state == self.ITEM_STATE.COLLECTED)
  SetGameObjectActive(self._btnUncollectableObj,self.m_state == self.ITEM_STATE.UNCOLLETABLE)
  SetGameObjectActive(self._btnCollectable.gameObject,self.m_state == self.ITEM_STATE.COLLECTABLE)
  
  SetGameObjectActive(self._collectedMaskRoot,self.m_state == self.ITEM_STATE.COLLECTED)
  SetGameObjectActive(self._dotMask,self.m_state ~= self.ITEM_STATE.UNCOLLETABLE)
  SetGameObjectActive(self._dotMaskUncollectable,self.m_state == self.ITEM_STATE.UNCOLLETABLE)

  
  self._numText.text = self.m_index

  
  local itemCardAsset = CS.Torappu.UI.UIAssetLoader.instance.itemCardPrefab
  if self.m_itemFirstObj == nil then
    self.m_itemFirstObj = self:SpawnItemCard(self._itemContainerFirst,ITEM_CARD_SCALE,self.m_itemFirst)
  end
  if self.m_itemSecondObj == nil then
    self.m_itemSecondObj = self:SpawnItemCard(self._itemContainerSecond,ITEM_CARD_SCALE,self.m_itemSecond)
  end
end

function ReturnCheckinItem:SpawnItemCard(parent,scale,itemBundle)
  local itemCardAsset = CS.Torappu.UI.UIAssetLoader.instance.itemCardPrefab
  local itemCardBehavior = CS.UnityEngine.GameObject.Instantiate(itemCardAsset,parent)
  itemCardBehavior.isCardClickable = true
  local viewModel = CS.Torappu.UI.UIItemViewModel()
  viewModel:LoadGameData(itemBundle.id, itemBundle.type)
  viewModel.itemCount = itemBundle.count
  itemCardBehavior.showItemName = false
  itemCardBehavior:Render(-1, viewModel)
  local scaler = itemCardBehavior:GetComponent("Torappu.UI.UIScaler");
  if scaler then
    scaler.scale = scale
  end
  self:AsignDelegate(itemCardBehavior,"onItemClick", function()
    CS.Torappu.UI.UIItemDescFloatController.ShowItemDesc(itemCardBehavior.gameObject,viewModel)
  end)
  return itemCardBehavior
end

function ReturnCheckinItem:OnInitialize()
  self:AddButtonClickListener(self._btnCollectable, self._OnClick)
end





















return ReturnCheckinItem