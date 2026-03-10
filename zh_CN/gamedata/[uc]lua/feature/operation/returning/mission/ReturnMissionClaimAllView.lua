local ReturnMissionGroupViewBase = require("Feature/Operation/Returning/Mission/ReturnMissionGroupViewBase");




local ReturnMissionClaimAllView = Class("ReturnMissionClaimAllView", ReturnMissionGroupViewBase);

function ReturnMissionClaimAllView:OnInit()
  self:AddButtonClickListener(self._btnClaimAll, self.EventOnBtnClicked);
end

function ReturnMissionClaimAllView:EventOnBtnClicked()
  if self.eventOnClicked ~= nil then
    self.eventOnClicked:Call();
  end
end


function ReturnMissionClaimAllView:OnRender(viewModel)
end

return ReturnMissionClaimAllView;