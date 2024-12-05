local luaUtils = CS.Torappu.Lua.Util;



local CheckinVideoRewardItemView = Class("CheckinVideoRewardItemView", UIWidget);


function CheckinVideoRewardItemView:Render(hasReceived)
  if hasReceived == nil then
    return;
  end
  luaUtils.SetActiveIfNecessary(self._panelReceived, hasReceived);
end

return CheckinVideoRewardItemView;