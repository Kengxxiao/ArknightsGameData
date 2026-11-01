local luaUtil = CS.Torappu.Lua.Util;
local ResourceUrls = CS.Torappu.ResourceUrls;

local TOTAL_COUNT_FORMAT = "/{0}";














local OpenServerV3StageStoryMainStoryItemView = Class("OpenServerV3StageStoryMainStoryItemView", UIWidget);

function OpenServerV3StageStoryMainStoryItemView:OnInitialize()
  if self._btnItem ~= nil then
    self:AddButtonClickListener(self._btnItem, self._EventOnItemClicked);
  end
end



function OpenServerV3StageStoryMainStoryItemView:Render(itemModel, onClicked)
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
  self:_LoadDecoImage(itemModel.decoImageId);

  local isUnlocked = itemModel.isUnlocked;
  local isCompleted = itemModel.awardCount >= itemModel.totalAwardCount;

  SetGameObjectActive(self._pnlLocked, not isUnlocked);
  SetGameObjectActive(self._pnlNormal, isUnlocked);
  SetGameObjectActive(self._pnlCompleted, isUnlocked and isCompleted);
  SetGameObjectActive(self._pnlNotCompleted, isUnlocked and not isCompleted);
end



function OpenServerV3StageStoryMainStoryItemView:_LoadKvImage(kvImageId)
  if self._imgKv == nil or kvImageId == nil or kvImageId == "" then
    return;
  end
  self._imgKv.sprite = self:LoadSpriteFromAutoPackHub(
      ResourceUrls.GetMixStoryKvSpriteHubPath(), kvImageId);
end



function OpenServerV3StageStoryMainStoryItemView:_LoadDecoImage(decoImageId)
  if self._imgDeco == nil or decoImageId == nil or decoImageId == "" then
    return;
  end
  self._imgDeco.sprite = self:LoadSpriteFromAutoPackHub(
      ResourceUrls.GetMixStoryDecoSpriteHubPath(), decoImageId);
end


function OpenServerV3StageStoryMainStoryItemView:_EventOnItemClicked()
  if self.m_itemModel == nil or self.m_eventOnClicked == nil then
    return;
  end
  self.m_eventOnClicked:Call(self.m_itemModel.zoneId);
end

return OpenServerV3StageStoryMainStoryItemView;
