local luaUtils = CS.Torappu.Lua.Util;


local Act6funBattleFinishStarItemView = Class("Act6funBattleFinishStarItemView", UIWidget)

local function _SetActive(gameObj, isActive)
  luaUtils.SetActiveIfNecessary(gameObj, isActive);
end

function Act6funBattleFinishStarItemView:Render(hasGet)
  _SetActive(self._objGet, hasGet);
end

return Act6funBattleFinishStarItemView