local luaUtils = CS.Torappu.Lua.Util
local UICommonItemCard = require("Feature/Supportor/UI/UICommonItemCard")






















local TeamQuestMilestoneItemView = Class("TeamQuestMilestoneItemView", UIPanel)

TeamQuestMilestoneItemView.itemScale = 0.85

function TeamQuestMilestoneItemView:_InitIfNot()
  if self.m_hasInited then
    return
  end
  self.m_hasInited = true

  self.m_itemCard = self:CreateWidgetByPrefab(UICommonItemCard, self._itemCardPrefab, self._itemCardRoot)
  self:AddButtonClickListener(self._btnClick, self._EventOnItemClick)
end



function TeamQuestMilestoneItemView:Render(milestoneModel, themeColorStr)
  self:_InitIfNot()

  if milestoneModel == nil then
    return
  end
  self.m_milestoneId = milestoneModel.id

  local isUncomplete = milestoneModel.statusType == TeamQuestMilestoneStatusType.UNCOMPLETE
  SetGameObjectActive(self._completePartGO, not isUncomplete)
  SetGameObjectActive(self._uncompletePartGO, isUncomplete)

  self._btnClick.enabled = milestoneModel.statusType == TeamQuestMilestoneStatusType.AVAIL

  local itemCnt = 0
  local itemName = ""
  if milestoneModel.itemModel ~= nil then
    itemCnt = milestoneModel.itemModel.itemCount
    itemName = milestoneModel.itemModel.name
  end
  self._textItemCnt.text = tostring(itemCnt)
  if self._changeRewardCntSizeAuto == nil or self._changeRewardCntSizeAuto == false then
    local cntW = math.ceil( math.log(itemCnt, 10) );
    self._textItemCnt.fontSize = math.ceil(92-cntW*16);
  end 
  self._textItemName.text = itemName
  self._textPointCnt.text = tostring(milestoneModel.needPointCnt)

  SetGameObjectActive(self._iconBetterShow, milestoneModel.isBetterShow)

  local colorItemStr = isUncomplete and self._colorItemUncomplete or self._colorItemComplete
  local colorItem = luaUtils.FormatColorFromData(colorItemStr)
  self._textItemName.color = colorItem
  self._textItemCnt.color = colorItem
  self._iconItemCount.color = colorItem
  local colorPointStr = isUncomplete and self._colorPointUncomplete or themeColorStr
  local colorPoint = luaUtils.FormatColorFromData(colorPointStr)
  self._textPointCnt.color = colorPoint
  self._imgBgComplete.color = colorPoint

  self.m_itemCard:Render(milestoneModel.itemModel, {
      itemScale = tonumber(self.itemScale),
      isCardClickable = true,
      showItemName = false,
      showItemNum = false,
      showBackground = true,
      fastClickBlock = true,
  })

  local colorGraphic
  local isComplete = milestoneModel.statusType == TeamQuestMilestoneStatusType.COMPLETE
  if isComplete then
    colorGraphic = luaUtils.FormatColorFromData(self._colorCompleteMask)
  else
    colorGraphic = CS.UnityEngine.Color.white
  end
  self.m_itemCard:ChangeItemCardStyle({
    isCardClickable = not isComplete,
    mainColor = colorGraphic,
    fadeDuration = 0,
  })
  self._colorGraphic:CrossFadeColor(colorGraphic, 0, true, false)
end

function TeamQuestMilestoneItemView:_EventOnItemClick()
  if self.onItemClick == nil then
    return
  end
  self.onItemClick:Call(self.m_milestoneId)
end

return TeamQuestMilestoneItemView