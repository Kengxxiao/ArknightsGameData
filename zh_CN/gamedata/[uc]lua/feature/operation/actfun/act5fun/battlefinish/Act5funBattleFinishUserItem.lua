local luaUtils = CS.Torappu.Lua.Util;




local Act5funBattleFinishUserItem = Class("Act5funBattleFinishUserItem", UIWidget)

function Act5funBattleFinishUserItem:Render(hubPath, userItemModel)
  self._imgIcon.sprite = self:LoadSpriteFromAutoPackHub(hubPath, userItemModel.iconId)
  self._txtName.text = userItemModel.nameStr
  self._txtWinningStreak.text = userItemModel.winningStreakStr
end

return Act5funBattleFinishUserItem