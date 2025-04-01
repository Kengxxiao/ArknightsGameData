local luaUtils = CS.Torappu.Lua.Util;





local Act6funBattleFinishAchieveItemView = Class("Act6funBattleFinishAchieveItemView", UIWidget)

local function _SetActive(gameObj, isActive)
  luaUtils.SetActiveIfNecessary(gameObj, isActive);
end

function Act6funBattleFinishAchieveItemView:Render(itemModel)
  if itemModel == nil then
    return;
  end

  local isReached = itemModel.hasComplete;
  _SetActive(self._objReached, isReached);
  _SetActive(self._objNotReached, not isReached);
  if isReached then
    self._txtReachedDesc.text = itemModel.description;
  else
    self._txtNotReachedDesc.text = itemModel.description;
  end
end

return Act6funBattleFinishAchieveItemView