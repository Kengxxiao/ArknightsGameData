





local TeamQuestRecordFriendSpineView = Class("TeamQuestRecordFriendSpineView", UIPanel)


function TeamQuestRecordFriendSpineView:Render(viewModel)
  self._headIcon:ApplyFriendData(viewModel);
  local spineAdapter = CS.Torappu.UI.UIBuildingSpineAdapter()
  local spineAdapterInput = CS.Torappu.UI.UIBuildingSpineAdapter.BuildingSpineInput()
  spineAdapterInput.skinId = viewModel.secretarySkinId
  spineAdapter:UpdateParam(spineAdapterInput)
  self._spineHolder:Init(spineAdapter);
  spineAdapter:NotifyRenderSpine();
end


function TeamQuestRecordFriendSpineView:_EventOnTabItemClick(tabType)
end

return TeamQuestRecordFriendSpineView