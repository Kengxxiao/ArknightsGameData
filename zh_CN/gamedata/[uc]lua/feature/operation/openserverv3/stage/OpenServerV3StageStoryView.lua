







local luaUtil = CS.Torappu.Lua.Util;
local POINT_TARGET_FORMAT = "/{0}";
local OpenServerV3StageStoryView = Class("OpenServerV3StageStoryView", UIWidget);

function OpenServerV3StageStoryView:OnInitialize()
  self:AddButtonClickListener(self._btnMain, self._EventOnMainClicked);
  self:AddButtonClickListener(self._btnExtra, self._EventOnExtraClicked);
end


function OpenServerV3StageStoryView:Render(model)
  if model == nil then
    return;
  end
  local itemModel = model.storyRewardItemModel;
  if self._imgReward ~= nil and itemModel ~= nil then
    self._imgReward.sprite = CS.Torappu.UI.ItemUtil.LoadItemIconUI(
        itemModel:GetItemType(), itemModel.itemId, itemModel.itemIconId);
  end
  if self._textCurrent ~= nil then
    self._textCurrent.text = luaUtil.FormatNumberWithUnit(model.storyCurrentReward);
  end
  if self._textTotal ~= nil then
    self._textTotal.text = luaUtil.Format(
        POINT_TARGET_FORMAT, luaUtil.FormatNumberWithUnit(model.storyTotalReward));
  end
end


function OpenServerV3StageStoryView:_EventOnMainClicked()
  if self.onMainClicked ~= nil then
    self.onMainClicked:Call();
  end
end


function OpenServerV3StageStoryView:_EventOnExtraClicked()
  if self.onExtraClicked ~= nil then
    self.onExtraClicked:Call();
  end
end

return OpenServerV3StageStoryView;
