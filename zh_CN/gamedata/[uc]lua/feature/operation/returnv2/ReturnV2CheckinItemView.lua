local ReturnV2CheckinRewardModel = require("Feature/Operation/ReturnV2/ReturnV2CheckinRewardModel")
local UICommonItemCard = require("Feature/Supportor/UI/UICommonItemCard")
















local ReturnV2CheckinItemView = Class("ReturnV2CheckinItemView", UIPanel)

ReturnV2CheckinItemView.ITEM_SCALE = 0.55




function ReturnV2CheckinItemView:Render(luaIndex, itemModel)
  self:_InitIfNot()
  self._numText.text = tostring(luaIndex)
  self.m_itemModel = itemModel

  local signState = itemModel:GetState()
  local SIGN_REWARD_STATE = ReturnV2CheckinRewardModel.SIGN_REWARD_STATE
  SetGameObjectActive(self._btnCollectedGo, signState == SIGN_REWARD_STATE.GAINED)
  SetGameObjectActive(self._btnCollectableGo, signState == SIGN_REWARD_STATE.CAN_GAIN)
  SetGameObjectActive(self._btnUncollectableGo, signState == SIGN_REWARD_STATE.INCOMING)

  SetGameObjectActive(self._collectedMaskRoot, signState == SIGN_REWARD_STATE.GAINED)
  SetGameObjectActive(self._dotMaskUncollectable, signState == SIGN_REWARD_STATE.INCOMING)
  SetGameObjectActive(self._dotMask, signState ~= SIGN_REWARD_STATE.INCOMING)

  self.m_rewardListAdapter:NotifyDataSetChanged()
end

function ReturnV2CheckinItemView:_InitIfNot()
  if self.m_hasInited then
    return
  end
  self.m_hasInited = true

  self:AddButtonClickListener(self._btnGain, self._HandleBtnGainClick)
  self.m_rewardListAdapter = self:CreateCustomComponent(
      UISimpleLayoutAdapter, self, self._rewardItemList, self._CreateRewardItemView,
      self._GetRewardItemCount, self._UpdateRewardItemView)
end



function ReturnV2CheckinItemView:_CreateRewardItemView(gameObj)
  local itemView = self:CreateWidgetByGO(UICommonItemCard, gameObj)
  return itemView
end


function ReturnV2CheckinItemView:_GetRewardItemCount()
  if self.m_itemModel == nil then
    return 0
  end

  local rewardList = self.m_itemModel:GetRewardList()
  if rewardList == nil then
    return 0
  end
  return rewardList.Count
end




function ReturnV2CheckinItemView:_UpdateRewardItemView(index, itemView)
  local rewardList = self.m_itemModel:GetRewardList()

  itemView:Render(rewardList[index], {
    itemScale = self.ITEM_SCALE,
    isCardClickable = true,
    showItemName = false,
    showItemNum = true,
    showBackground = true
  })
end

function ReturnV2CheckinItemView:_HandleBtnGainClick()
  if self.onSignItemClick == nil or self.m_itemModel == nil then
    return
  end
  self.onSignItemClick:Call(self.m_itemModel:GetItemIdx())
end

return ReturnV2CheckinItemView