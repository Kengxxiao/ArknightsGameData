










local UniqueOnlyItemCardView = Class("UniqueOnlyItemCardView", UIPanel);
local UICommonItemCard = require("Feature/Supportor/UI/UICommonItemCard");

function UniqueOnlyItemCardView:OnInit()
  self.m_itemCard = self:CreateWidgetByPrefab(UICommonItemCard, self._itemCardPrefab, self._rectItemCardContainer);
end


function UniqueOnlyItemCardView:Render(viewModel)
  if viewModel == nil then
    return
  end

  local hasItemGot = viewModel.hasItemGot;
  local useItemNameIcon = viewModel.useItemNameIcon;
  self.m_itemCard:Render(viewModel.rewardItem, {
    itemScale = tonumber(self._itemCardScale),
    isCardClickable = not hasItemGot,
    showItemName = false,
    showItemNum = not useItemNameIcon,
    showBackground = true,
  });
  local color = CS.Torappu.ColorRes.TweenHtmlStringToColor(self._notHaveItemMainColor);
  if hasItemGot then
    color = CS.Torappu.ColorRes.TweenHtmlStringToColor(self._haveItemMainColor);
  end
  self.m_itemCard:ChangeItemCardStyle({
    isCardClickable = not hasItemGot,
    mainColor = color,
  });

  SetGameObjectActive(self._imgItemNameIcon.gameObject, useItemNameIcon);
  if useItemNameIcon then
    local sprite = self._atlasUniqueAct:GetSpriteByName(viewModel.itemNameIconId);
    self._imgItemNameIcon:SetSprite(sprite);
  end

  SetGameObjectActive(self._objGotMask, hasItemGot);
end

return UniqueOnlyItemCardView;