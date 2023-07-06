










local ReturnV2MissionPointPanel = Class("ReturnV2MissionPointPanel", UIPanel)
local ReturnV2MissionPointRewardItem = require("Feature/Operation/ReturnV2/ReturnV2MissionPointRewardItem")

function ReturnV2MissionPointPanel:OnInit()
  local pointRewardGroup = ReturnV2Model.me:GetPriceRewardGroup()
  self.m_pointRewardList = ToLuaArray(pointRewardGroup.contentList)
  table.sort(self.m_pointRewardList, function(a, b) 
    return a.sortId < b.sortId
  end)
  self.m_points = 0
  self.m_canClaimReward = false
  self.m_pointProgressAdapter = self:CreateCustomComponent(
      UISimpleLayoutAdapter, self, self._layoutPointProgress,
      self._CreatePointRewardItemView, self._GetPointRewardItemCount, 
      self._UpdatePointRewardItemView)
  self:AddButtonClickListener(self._btnClick, self._HandleClick)
end



function ReturnV2MissionPointPanel:Render(points, canClaimPriceReward)
  self.m_points = points
  self._textCurrentPointNum.text = self.m_points
  self.m_pointProgressAdapter:NotifyDataSetChanged()
  self.m_canClaimReward = canClaimPriceReward
  SetGameObjectActive(self._objCanClaimRewardBkg, self.m_canClaimReward)
end



function ReturnV2MissionPointPanel:_CreatePointRewardItemView(gameObj)
  local pointRewardItem = self:CreateWidgetByGO(ReturnV2MissionPointRewardItem, gameObj)
  pointRewardItem.loadPointIconFunc = function(hubPath, spriteId)
    return self:LoadSpriteFromAutoPackHub(hubPath, spriteId)
  end
  return pointRewardItem
end


function ReturnV2MissionPointPanel:_GetPointRewardItemCount()
  if self.m_pointRewardList == nil then
    return 0
  end
  return #self.m_pointRewardList
end



function ReturnV2MissionPointPanel:_UpdatePointRewardItemView(index, view)
  local pointReward = self.m_pointRewardList[index + 1]
  local pointRequire = pointReward.pointRequire
  local topIconId = pointReward.topIconId
  local lastPointRequire = 0
  if index > 0 then
    lastPointRequire = self.m_pointRewardList[index].pointRequire
  end
  local progress = 0
  if self.m_points <= lastPointRequire then
    progress = 0
  elseif self.m_points < pointRequire then
    progress = (self.m_points - lastPointRequire) / (pointRequire - lastPointRequire)
  else
    progress = 1
  end

  view:Render(progress, topIconId)
end

function ReturnV2MissionPointPanel:_HandleClick()
  if self.m_canClaimReward and self.claimPriceRewardEvent then
    self.claimPriceRewardEvent:Call()
    return
  end
  if not self.m_canClaimReward and self.openDetailEvent then
    self.openDetailEvent:Call()
    return
  end
end

return ReturnV2MissionPointPanel