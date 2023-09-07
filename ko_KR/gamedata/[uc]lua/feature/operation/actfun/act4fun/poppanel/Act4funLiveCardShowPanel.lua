local Act4funLivePhotoSimpleCard = require "Feature/Operation/ActFun/Act4fun/Photo/Act4funLivePhotoSimpleCard";





local Act4funLiveCardShowPanel = Class("Act4funLiveCardShowPanel", Act4funLivePopPanelBase);
Act4funLiveCardShowPanel.ANIM_NAME = "act4fun_live_photo_cardshow";

function Act4funLiveCardShowPanel:OnInit()
  self.m_card = self:CreateWidgetByGO(Act4funLivePhotoSimpleCard, self._card);
end


function Act4funLiveCardShowPanel:OnViewModelUpdate(data)

  local valid = data.currStep == Act4funLiveStep.PHOTO_USE_ANIM;
  self:SetVisible(valid);
  if not valid then
    return;
  end
  local usingPhoto = data.usingPhoto;

  self.m_card:Update(-1, usingPhoto, nil);
  CS.Torappu.TorappuAudio.PlayUI(AudioConsts.ACT4FUN_PHOTOUNFLOAD);

  
  local this = self;
  self._anim:InitIfNot();
  self._anim:Stop(self.ANIM_NAME, false);
  self._anim:Play(self.ANIM_NAME, {
    isFillAfter = true,
    isInverse = false,
    onAnimEnd = function()
      this:_CompleteAnim();
    end
  });
end

function Act4funLiveCardShowPanel:_CompleteAnim()
  CS.Torappu.TorappuAudio.PlayUI(AudioConsts.ACT4FUN_PHOTOFIX);
  self:SetVisible(false);
  self.m_curPhoto = nil;
  
  if self.m_cachedData:ExecutePhoto() then
    self.m_cachedData:NotifyUpdate();
  end
end

return Act4funLiveCardShowPanel;