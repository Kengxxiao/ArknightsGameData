


local OpenServerV3StageCampaignProgressItemView = Class("OpenServerV3StageCampaignProgressItemView", UIWidget);


function OpenServerV3StageCampaignProgressItemView:Render(model)
  local isConfirmed = model ~= nil and
      model.currState == CS.Torappu.UI.Campaign.CampaignBreakDetailItemViewModel.State.CONFIRMED;
  SetGameObjectActive(self._panelComplete, isConfirmed);
  SetGameObjectActive(self._panelUncomplete, not isConfirmed); 
end

return OpenServerV3StageCampaignProgressItemView;