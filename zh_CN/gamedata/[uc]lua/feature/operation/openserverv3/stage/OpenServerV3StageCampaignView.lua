











local luaUtil = CS.Torappu.Lua.Util;
local POINT_TARGET_FORMAT = "/{0}";
local OpenServerV3StageCampaignView = Class("OpenServerV3StageCampaignView", UIWidget);

function OpenServerV3StageCampaignView:OnInitialize()
  self:AddButtonClickListener(self._btnMain, self._EventOnMainClicked);
  self:AddButtonClickListener(self._btnDetail, self._EventOnDetailClicked);
end


function OpenServerV3StageCampaignView:Render(model)
  if model == nil then
    return;
  end
  local itemModel = model.campaignRewardItemModel;
  if self._imgReward ~= nil and itemModel ~= nil then
    self._imgReward.sprite = CS.Torappu.UI.ItemUtil.LoadItemIconUI(
        itemModel:GetItemType(), itemModel.itemId, itemModel.itemIconId);
  end
  if self._textCurrent ~= nil then
    self._textCurrent.text = luaUtil.FormatNumberWithUnit(model.campaignCurrentFee);
  end
  if self._textTotal ~= nil then
    self._textTotal.text = luaUtil.Format(
        POINT_TARGET_FORMAT, luaUtil.FormatNumberWithUnit(model.campaignTotalFee));
  end
  if self._sliderProgress ~= nil then
    self._sliderProgress.value = model.campaignTotalFee > 0 and
        model.campaignCurrentFee / model.campaignTotalFee or 1;
  end
  SetGameObjectActive(self._panelLocked, not model.isCampaignUnlock);
  SetGameObjectActive(self._panelUnlocked, model.isCampaignUnlock);
  self._textLocked.text = model.campaignLockedTip or "";
end


function OpenServerV3StageCampaignView:_EventOnMainClicked()
  if self.onMainClicked ~= nil then
    self.onMainClicked:Call();
  end
end


function OpenServerV3StageCampaignView:_EventOnDetailClicked()
  if self.onDetailClicked ~= nil then
    self.onDetailClicked:Call();
  end
end

return OpenServerV3StageCampaignView;
