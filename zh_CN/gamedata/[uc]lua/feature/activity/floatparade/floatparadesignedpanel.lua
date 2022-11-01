






local FloatParadeSignedPanel = Class("FloatParadeSignedPanel", UIPanel);


function FloatParadeSignedPanel:Render(data)
  if data.todayData == nil or data.todayResult == nil then
    return;
  end

  if data.todayResult.reward then
    self._raffleCount.text = "×" .. data.todayResult.reward.reward.count;
    self._signDesc.text = data.todayResult.reward.name;
  else
    self._raffleCount.text = tostring(0);
  end
  local tactic = data.todayResult.tactic;
  if tactic then
    self._packName.text = tactic.packName;
    self._tacticName.text = tactic.name;
  end

  local extReward = data.todayData.extReward;
  CS.Torappu.Lua.Util.SetActiveIfNecessary(self._extRewardNode, extReward ~= nil);
  if extReward then
    self._extCount.text = "×" ..extReward.count
  else
    self._extCount.text = tostring(0);
  end
end

return FloatParadeSignedPanel;
