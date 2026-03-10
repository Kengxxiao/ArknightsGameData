








local ReturnMissionPointItemView = Class("ReturnMissionPointItemView", UIWidget);

local ReturnMissionPointItemRewardView = require("Feature/Operation/Returning/Mission/ReturnMissionPointItemRewardView");


function ReturnMissionPointItemView:Render(model)
  self:_InitIfNot();
  if model == nil then
    return;
  end
  self._progress.value = model.progress;
  if self.m_rewardView ~= nil then
    self.m_rewardView:Render(model);
  end
end


function ReturnMissionPointItemView:_InitIfNot()
  if self.m_hasInited then
    return;
  end
  self.m_hasInited = true;
  if self.createWidgetByPrefab == nil then
    return;
  end
  self.m_rewardView = self.createWidgetByPrefab(ReturnMissionPointItemRewardView, self._prefabReward, self._rewardContainer);
  if self.m_rewardView ~= nil then
    self.m_rewardView.createWidgetByPrefab = self.createWidgetByPrefab;
  end
end

return ReturnMissionPointItemView;