local luaUtil = CS.Torappu.Lua.Util;
local ResourceUrls = CS.Torappu.ResourceUrls;

local TOTAL_COUNT_FORMAT = "/{0}";

local UICommonItemCard = require("Feature/Supportor/UI/UICommonItemCard");


















local OpenServerV3StageStorySsItemView = Class("OpenServerV3StageStorySsItemView", UIWidget);

function OpenServerV3StageStorySsItemView:OnInitialize()
  if self._btnItem ~= nil then
    self:AddButtonClickListener(self._btnItem, self._EventOnItemClicked);
  end
end



function OpenServerV3StageStorySsItemView:Render(itemModel, onClicked)
  self.m_eventOnClicked = onClicked;
  if itemModel == nil then
    return;
  end
  self.m_itemModel = itemModel;

  if self._textCount ~= nil then
    self._textCount.text = tostring(itemModel.awardCount);
  end
  if self._textTotalCount ~= nil then
    self._textTotalCount.text = luaUtil.Format(TOTAL_COUNT_FORMAT, itemModel.totalAwardCount);
  end

  self:_LoadKvImage(itemModel.kvImageId);
  self:_LoadTitleImage(itemModel.titleImageId);
  self:_RenderItemCard(itemModel);

  if self._pnlCheck ~= nil then
    SetGameObjectActive(self._pnlCheck, itemModel.isCoreRewardClaimed == true);
  end

  local isCompleted = itemModel.awardCount >= itemModel.totalAwardCount;

  SetGameObjectActive(self._pnlCompleted, isCompleted);
  SetGameObjectActive(self._pnlNotCompleted, not isCompleted);
end



function OpenServerV3StageStorySsItemView:_RenderItemCard(itemModel)
  self:_CreateItemViewIfNeed();
  if self.m_itemView == nil then
    return;
  end
  local uiItemModel = CS.Torappu.UI.UIItemViewModel();
  uiItemModel:LoadGameData(itemModel.coreRewardId, itemModel.coreRewardType);
  self.m_itemView:Render(uiItemModel, {
    itemScale = tonumber(self._itemCardScale),
    isCardClickable = true,
    showItemName = false,
    showItemNum = false,
    showBackground = true,
  });
  if self._textCharName ~= nil then
    self._textCharName.text = uiItemModel.name;
  end

  if itemModel.isCoreRewardClaimed == true then
    local color = CS.Torappu.ColorRes.TweenHtmlStringToColor(self._itemCardColorGot);
    self.m_itemView:ChangeItemCardStyle({ isCardClickable = false, mainColor = color });
  else
    self.m_itemView:ChangeItemCardStyle({ isCardClickable = true, mainColor = CS.UnityEngine.Color.white });
  end
end


function OpenServerV3StageStorySsItemView:_CreateItemViewIfNeed()
  if self.m_itemView ~= nil or self.createWidgetByGO == nil or self._itemCardLayout == nil then
    return;
  end
  self.m_itemView = self.createWidgetByGO(UICommonItemCard, self._itemCardLayout);
end



function OpenServerV3StageStorySsItemView:_LoadKvImage(kvImageId)
  if self._imgKv == nil or kvImageId == nil or kvImageId == "" then
    return;
  end
  self._imgKv.sprite = self:LoadSpriteFromAutoPackHub(
      ResourceUrls.GetMixStoryKvSpriteHubPath(), kvImageId);
end



function OpenServerV3StageStorySsItemView:_LoadTitleImage(titleImageId)
  if self._imgTitle == nil or titleImageId == nil or titleImageId == "" then
    return;
  end
  self._imgTitle.sprite = self:LoadSpriteFromAutoPackHub(
      ResourceUrls.GetMixStoryTitleSpriteHubPath(), titleImageId);
end


function OpenServerV3StageStorySsItemView:_EventOnItemClicked()
  if self.m_itemModel == nil or self.m_eventOnClicked == nil then
    return;
  end
  self.m_eventOnClicked:Call(self.m_itemModel.storySetId);
end

return OpenServerV3StageStorySsItemView;
