













local CheckinAllPlayerExtRewardView = Class("CheckinAllPlayerBhvRewardView", UIPanel);
local CheckinAllPlayerBhvInfoView = require "Feature/Activity/CheckinAllPlayer/View/CheckinAllPlayerBhvInfoView"

function CheckinAllPlayerExtRewardView:OnInit()
  if self._infoView then
  self.m_infoView = self:CreateWidgetByGO(CheckinAllPlayerBhvInfoView, self._infoView);
  end
  self:AddButtonClickListener(self._getBtn, self._HandleGetClick);
  self:AddButtonClickListener(self._rewardBtn, self._HandleShowRewardTips);
end


function CheckinAllPlayerExtRewardView:OnViewModelUpdate(model)
  if self.index == nil then
    return;
  end
  local bhvRewardModel = model.bhvRewards[self.index];
  if not bhvRewardModel then
    return;
  end

  if not self.m_itemViewModel then
    self.m_itemViewModel = CS.Torappu.UI.UIItemViewModel();
  end
  if bhvRewardModel.pubBhvData.rewards.Count > 0 then
    local item = bhvRewardModel.pubBhvData.rewards[0];
    self.m_itemViewModel:LoadGameData(item.id, item.type);
    self.m_itemViewModel.itemCount = item.count;
  end

  local normal = bhvRewardModel.status == CheckinAllPlayerRewardStatus.NONE or bhvRewardModel.status == CheckinAllPlayerRewardStatus.DISABLE;
  SetGameObjectActive(self._normalNode, normal);
  SetGameObjectActive(self._canNode, bhvRewardModel.status == CheckinAllPlayerRewardStatus.AVAILABLE);
  SetGameObjectActive(self._gotNode, bhvRewardModel.status == CheckinAllPlayerRewardStatus.RECEIVED);

  local max = bhvRewardModel.pubBhvData.requiringValue;
  self._prg.fillAmount = bhvRewardModel.num / max;
  self._prgText.text = string.formatWithThousand(bhvRewardModel.num);
  self._gotText.text = bhvRewardModel.pubBhvData.rewardReceivedDesc;
  if not model.fresh then
    self._prg.fillAmount = 0;
    self._prgText.text = "LOADING";
  end

  if self.m_infoView then
    self.m_infoView:Render(bhvRewardModel);
  end
end

function CheckinAllPlayerExtRewardView:_HandleGetClick()
  if self.eventGet then
    self.eventGet:Call(self.index);
  end
end

function CheckinAllPlayerExtRewardView:_HandleShowRewardTips()
  if not self.m_itemViewModel then
    return;
  end

  CS.Torappu.UI.UIItemDescFloatController.ShowItemDesc(self._rewardBtn.gameObject, self.m_itemViewModel);
end
return CheckinAllPlayerExtRewardView;