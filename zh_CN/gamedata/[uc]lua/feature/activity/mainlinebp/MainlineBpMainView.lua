local luaUtils = CS.Torappu.Lua.Util;





























local MainlineBpMainView = Class("MainlineBpMainView", UIPanel);

function MainlineBpMainView:OnInit()
  self:AddButtonClickListener(self._btnTabBp, self._EventOnBpTabClick);
  self:AddButtonClickListener(self._btnTabMission, self._EventOnMissionTabClick);
  self:AddButtonClickListener(self._btnStageJump, self._EventOnStageJumpBtnClick);
  self:AddButtonClickListener(self._btnBpUpDetail, self._EventOnBpUpDetailClick);
end


function MainlineBpMainView:OnViewModelUpdate(data)
  if data == nil then
    return;
  end

  luaUtils.SetActiveIfNecessary(self._panelBpSelected, data.tabState == MainlineBpTabState.BP);
  luaUtils.SetActiveIfNecessary(self._panelBpUnselected, data.tabState ~= MainlineBpTabState.BP);
  luaUtils.SetActiveIfNecessary(self._panelMissionSelected, data.tabState == MainlineBpTabState.MISSION);
  luaUtils.SetActiveIfNecessary(self._panelMissionUnselected, data.tabState ~= MainlineBpTabState.MISSION);
  self._textEndTime.text = data.endTimeDesc;
  self._textStageCode.text = data.currStageCode;
  luaUtils.SetActiveIfNecessary(self._panelStageJumpBtn, not data.isAllStageComplete);
  self._imgBpUpSlider1.fillAmount = data.bpUpPercent;
  self._imgBpUpSlider2.fillAmount = data.bpUpPercent;
  luaUtils.SetActiveIfNecessary(self._panelBpUpSliderActive, data.isBpUpActive);
  luaUtils.SetActiveIfNecessary(self._panelBpUpActive, data.isBpUpActive);
  luaUtils.SetActiveIfNecessary(self._panelBpUpSliderInactive, not data.isBpUpActive);
  luaUtils.SetActiveIfNecessary(self._panelBpUpInactive, not data.isBpUpActive);
  self._textCurrBpPoint.text = data.bpPoint;
  self._textBpUpCondDesc.text = data.bpUpCondDesc;
  self._textBpUpDesc.text = data.bpUpDesc;
  self._textBpItemName.text = data.bpItemName;
  luaUtils.SetActiveIfNecessary(self._panelMissionTrackPoint, data.showMissionTrackPoint);
  luaUtils.SetActiveIfNecessary(self._panelBpTrackPoint, data.showBpTrackPoint);
end


function MainlineBpMainView:_EventOnBpTabClick()
  if self.onBpTabClick == nil then
    return;
  end
  self.onBpTabClick:Call();
end


function MainlineBpMainView:_EventOnMissionTabClick()
  if self.onMissionTabClick == nil then
    return;
  end
  self.onMissionTabClick:Call();
end


function MainlineBpMainView:_EventOnStageJumpBtnClick()
  if self.onStageJumpBtnClick == nil then
    return;
  end
  self.onStageJumpBtnClick:Call();
end


function MainlineBpMainView:_EventOnBpUpDetailClick()
  if self.onBpUpDetailClick == nil then
    return;
  end
  self.onBpUpDetailClick:Call();
end

return MainlineBpMainView;