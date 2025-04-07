local luaUtils = CS.Torappu.Lua.Util;













local CheckinAccessRewardItemView = Class("CheckinAccessRewardItemView", UIWidget);

local UICommonItemCard = require("Feature/Supportor/UI/UICommonItemCard")

local ALPHA_CONFIRMED = 0.5;
local ALPHA_NORMAL = 1;



function CheckinAccessRewardItemView:Render(viewModel, isConfirmed)
  self:_InitIfNot();
  if viewModel == nil then
    return;
  end
  if isConfirmed then
    self._canvasGroup.alpha = ALPHA_CONFIRMED;
  else
    self._canvasGroup.alpha = ALPHA_NORMAL;
  end
  luaUtils.SetActiveIfNecessary(self._panelReceived, isConfirmed);
  self.m_itemCard:Render(viewModel, {
      itemScale = tonumber(self._rewardItemScale),
      isCardClickable = true,
      showItemName = false,
      showItemNum = true,
      showBackground = true,
      fastClickBlock = true,
    });
end


function CheckinAccessRewardItemView:_InitIfNot()
  if self.m_hasInited then
    return;
  end
  self.m_hasInited = true;
  if self.createWidgetByPrefab == nil then
    return;
  end
  self.m_itemCard = self.createWidgetByPrefab(UICommonItemCard,
      self._itemCardPrefab, self._itemCardContainer);
end

return CheckinAccessRewardItemView;