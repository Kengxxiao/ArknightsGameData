local luaUtils = CS.Torappu.Lua.Util


























local CollectionSimpleRewardView = Class("CollectionSimpleRewardView", UIPanel)
local UICommonItemCard = require("Feature/Supportor/UI/UICommonItemCard")


function CollectionSimpleRewardView:_RenderRewardProgressBar(level)
  self.m_renderCollectionLevel = level
  local int, frac = math.modf(level)
  self._currRewardProgress.size = frac
end

function CollectionSimpleRewardView:OnInit()
  self.m_rewardItemCard = self:CreateWidgetByGO(UICommonItemCard, self._rewardItemCard)
end


function CollectionSimpleRewardView:Render(rewardModel)
  if not rewardModel then
    return
  end
  self:_RenderThemeColor(rewardModel.themeColor)
  self._currPointCount.text = tostring(rewardModel.currentPointCount)
  if not self.m_lastCollectionLevel then
    self:_RenderRewardProgressBar(rewardModel.collectionLevel)
    self.m_lastCollectionLevel = self.m_renderCollectionLevel
  else
    if self.m_tween then
      self.m_tween:Kill(true)
      self.m_tween = nil
    end
    self.m_targetCollectionLevel = rewardModel.collectionLevel
    self.m_tween = TweenModel:Play({
      setFunc = function(lerpValue)
        local renderLevel = self.m_lastCollectionLevel + (self.m_targetCollectionLevel - self.m_lastCollectionLevel) * lerpValue
        self:_RenderRewardProgressBar(renderLevel)
      end,
      easeFunc = TweenModel.EaseFunc.easeOutQuart,
      duration = tonumber(self._progressBarDuration),
      onComplete = function ()
        self.m_lastCollectionLevel = self.m_renderCollectionLevel
      end
    })
  end
  self._nextRewardNeedPointCount.text = tostring(rewardModel.nextRewardNeedPoint - rewardModel.currentPointCount)
  self._rewardToggle.selected = rewardModel.claimedRewardCount >= rewardModel.totalRewardCount
  self._claimedRewardCount.text = tostring(rewardModel.claimedRewardCount)
  self._totalRewardCount.text = tostring(rewardModel.totalRewardCount)
  self.m_rewardItemCard:Render(rewardModel.rewardItemModel, {
    itemScale = tonumber(self._itemCardScale),
    isCardClickable = true,
    showItemName = false,
    showItemNum = false,
    showBackground = true,
  })
end


function CollectionSimpleRewardView:_RenderThemeColor(color)
  if not color then
    return
  end
  self._themePointIcon.color = color
  self._themePointCount.color = color
  self._themeUncompleteProgressHander.color = color
  self._themeUncompleteProgressDot.color = color
  self._themeUncompleteProgressPointIcon.color = color
  self._themeUncompleteProgressPointCount.color = color
  self._themeUncompleteProgressArrow.color = color
  self._themeCompleteProgressHander.color = color
  self._themeRewardClaimedCount.color = color
end

return CollectionSimpleRewardView