






local ReturnV2MissionPointRewardItem = Class("ReturnV2MissionPointRewardItem", UIWidget)
local SLIDE_SIDE_OFFSET = 3.6
local SLIDE_TOTAL_LENGTH = 122

function ReturnV2MissionPointRewardItem:OnInitialize()
  self.m_hubPath = CS.Torappu.ResourceUrls.GetReturnV2PointIconHubPath()
end



function ReturnV2MissionPointRewardItem:_GetFiltedProgress(clampedProgress)
  if clampedProgress <= 0 then
    return 0
  end
  local filtedPixelWidth = (SLIDE_TOTAL_LENGTH - 2*SLIDE_SIDE_OFFSET) * clampedProgress
  return (2*SLIDE_SIDE_OFFSET + filtedPixelWidth) / SLIDE_TOTAL_LENGTH
end



function ReturnV2MissionPointRewardItem:Render(progress, iconId)
  if self.loadPointIconFunc == nil then
    return
  end
  local clampedProgress = 0
  if progress < 0 then
    clampedProgress = 0
  elseif progress > 1 then
    clampedProgress = 1
  else
    clampedProgress = progress
  end

  local completeFlag = clampedProgress == 1
  SetGameObjectActive(self._objFullProgress, completeFlag)
  SetGameObjectActive(self._objNotFullProgress, not completeFlag)
  local filtedProgress = self:_GetFiltedProgress(clampedProgress)
  self._sliderProgress.value = filtedProgress
  self._imgNumberIcon.sprite = self.loadPointIconFunc(self.m_hubPath, iconId)
end

return ReturnV2MissionPointRewardItem