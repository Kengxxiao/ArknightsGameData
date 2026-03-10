local ReturnMissionGroupViewBase = require("Feature/Operation/Returning/Mission/ReturnMissionGroupViewBase");





local ReturnMissionTitleView = Class("ReturnMissionTitleView", ReturnMissionGroupViewBase);


function ReturnMissionTitleView:OnRender(model)
  if model == nil or model.groupType ~= ReturnMissionGroupType.TITLE then
    return;
  end
  SetGameObjectActive(self._panelDaily, model.titleType == ReturnMissionTitleType.DAILY);
  SetGameObjectActive(self._panelNormal, model.titleType == ReturnMissionTitleType.NORMAL);
  SetGameObjectActive(self._panelRemain, model.showRemainTime);
  self._textRemain.text = model.remainTimeDesc;
end

return ReturnMissionTitleView;