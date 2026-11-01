















local OpenServerV3StageCampaignItemView = Class("OpenServerV3StageCampaignItemView", UIWidget);

local OpenServerV3StageCampaignProgressItemView = require("Feature/Operation/OpenServerV3/StageCampaign/OpenServerV3StageCampaignProgressItemView");



function OpenServerV3StageCampaignItemView:Render(itemModel, onClicked)
  self:_InitIfNot();
  self.m_eventOnClicked = onClicked;

  if itemModel == nil then
    return;
  end

  self.m_stageId = itemModel.stageId;
  self.m_stateModel = itemModel.stateModel;
  self._textTitle.text = itemModel.stageCode;
  self._textName.text = itemModel.stageName;
  SetGameObjectActive(self._panelLocked, not itemModel.isUnlock);
  if self._textUnlockTip ~= nil then
    self._textUnlockTip.text = itemModel.unlockTip or "";
  end

  if self._imgStage ~= nil and itemModel.imgId ~= nil and itemModel.imgId ~= "" then
    self._imgStage.sprite = self:LoadSpriteFromAutoPackHub(
        CS.Torappu.ResourceUrls.GetStageCampaignZoneStageHubPath(), itemModel.imgId);
  end

  self.m_progressAdapter:NotifyDataSetChanged();
end


function OpenServerV3StageCampaignItemView:_InitIfNot()
  if self.m_hasInited then
    return;
  end
  self.m_hasInited = true;

  self.m_progressAdapter = self:CreateCustomComponent(
      UISimpleLayoutAdapter, self, self._content,
      self._CreateProgressItemView, self._GetProgressItemCount, self._UpdateProgressItemView);
  if self._btnSelf ~= nil then
    self:AddButtonClickListener(self._btnSelf, self._EventOnItemClicked);
  end
end



function OpenServerV3StageCampaignItemView:_CreateProgressItemView(gameObj)
  if self.createWidgetByGO == nil then
    return nil;
  end
  return self.createWidgetByGO(OpenServerV3StageCampaignProgressItemView, gameObj);
end


function OpenServerV3StageCampaignItemView:_GetProgressItemCount()
  if self.m_stateModel == nil or self.m_stateModel.breakLadders == nil then
    return 0;
  end
  return self.m_stateModel.breakLadders.Count;
end



function OpenServerV3StageCampaignItemView:_UpdateProgressItemView(index, progressItemView)
  if self.m_stateModel == nil or self.m_stateModel.breakLadders == nil then
    return;
  end
  local breakLadders = self.m_stateModel.breakLadders;
  progressItemView:Render(breakLadders[index]);
end

function OpenServerV3StageCampaignItemView:_EventOnItemClicked()
  if self.m_eventOnClicked == nil then
    return;
  end
  self.m_eventOnClicked:Call(self.m_stageId);
end

return OpenServerV3StageCampaignItemView;
