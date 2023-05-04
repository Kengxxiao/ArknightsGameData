local luaUtils = CS.Torappu.Lua.Util;






ActFun3BattleRankItem = Class("ActFun3BattleRankItem", UIWidget);

function ActFun3BattleRankItem:Render(idx, name, score)
  self._nameText.text = name
  self._scoreText.text = score
  local rank = ""
  if idx < 10 then
    rank = string.format("0%s", idx)
  else
    rank = string.format("%s", idx)
  end
  self._rankText.text = rank
end
