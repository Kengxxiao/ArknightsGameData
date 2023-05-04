local luaUtils = CS.Torappu.Lua.Util;



GridGachaRuleView = Class("GridGachaRuleView", UIWidget);

function GridGachaRuleView:Render(text)
  self._ruleText.text = text;
end

return GridGachaRuleView;