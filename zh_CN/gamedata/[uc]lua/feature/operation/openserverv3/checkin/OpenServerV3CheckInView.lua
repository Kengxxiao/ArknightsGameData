local UICommonItemCard = require("Feature/Supportor/UI/UICommonItemCard");
























local OpenServerV3CheckInView = Class("OpenServerV3CheckInView", UIPanel);

local OpenServerV3CheckInListAdapter = require("Feature/Operation/OpenServerV3/CheckIn/OpenServerV3CheckInListAdapter");
local OpenServerV3CharacterItemView = require("Feature/Operation/OpenServerV3/CheckIn/OpenServerV3CharacterItemView");

local SPECIAL_REWARD_ITEM_SCALE = 0.65;
local SPECIAL_REWARD_USED_COLOR = { r = 0.5, g = 0.5, b = 0.5, a = 1 };
local SPECIAL_REWARD_NORMAL_COLOR = { r = 1, g = 1, b = 1, a = 1 };


function OpenServerV3CheckInView:OnViewModelUpdate(data)
  self:_InitIfNot();
  if data == nil or data.checkinViewModel == nil then
    return;
  end
  self.m_viewModel = data.checkinViewModel;
  self:_Render();
end


function OpenServerV3CheckInView:_Render()
  self._textTitle.text = self.m_viewModel.textTitle;
  self._textDesc.text = self.m_viewModel.textDesc;
  self._imgCharacter.sprite = 
      self:LoadSpriteFromAutoPackHub(
      CS.Torappu.ResourceUrls.GetOpenServerCheckInCharacterHubPath(),
      self.m_viewModel.charImgId);
  self.m_listAdapter.onItemClick = self.onItemClicked;
  self.m_listAdapter.viewModel = self.m_viewModel;
  local sequenceNum = self.m_viewModel.sequenceNum or 0;
  if sequenceNum > self.m_cachedSequenceNum then
    self.m_cachedSequenceNum = sequenceNum;
    local focusIndex = self.m_viewModel:GetFocusIndex();
    if focusIndex > 0 then
      self.m_listAdapter:NotifyRebuildWithIndex(focusIndex - 1);
    else
      self.m_listAdapter:NotifyDataSourceChanged();
    end
  else
    self.m_listAdapter:NotifyDataSourceChanged();
  end
  self.m_characterAdapter:NotifyDataSetChanged();
  self:_RenderSpecialRewardPart();
end


function OpenServerV3CheckInView:_RenderSpecialRewardPart()
  if self.m_viewModel == nil then
    return;
  end
  local state = self.m_viewModel.specialRewardState;
  SetGameObjectActive(self._panelSpecialRewardOwned, state == OpenServerV3CheckInSpecialRewardState.OWNED);
  SetGameObjectActive(self._panelSpecialRewardUsed, state == OpenServerV3CheckInSpecialRewardState.USED);
  if self._textSpecialRewardDesc ~= nil then
    self._textSpecialRewardDesc.text = self.m_viewModel.specialRewardDesc or "";
  end
  local specialReward = self.m_viewModel.specialReward;
  if self.m_specialReward == nil or specialReward == nil then
    return;
  end
  self.m_specialReward:Render(specialReward, {
    itemScale = SPECIAL_REWARD_ITEM_SCALE,
    isCardClickable = false,
    showItemName = false,
    showItemNum = false,
    showBackground = true,
  });
  local color = SPECIAL_REWARD_NORMAL_COLOR;
  if state == OpenServerV3CheckInSpecialRewardState.USED then
    color = SPECIAL_REWARD_USED_COLOR;
  end
  self.m_specialReward:ChangeItemCardStyle({
    isCardClickable = false,
    mainColor = color,
  });
end


function OpenServerV3CheckInView:_InitIfNot()
  if self.m_hasInited then
    return;
  end
  self.m_hasInited = true;
  self.m_cachedSequenceNum = 0;
  self.m_listAdapter = self:CreateCustomComponent(
      OpenServerV3CheckInListAdapter, self._itemListAdapter, self);
  self.m_specialReward = self:CreateWidgetByGO(
      UICommonItemCard, self._specialRewardContainer);
  self.m_characterAdapter = self:CreateCustomComponent(
      UISimpleLayoutAdapter, self, self._characterItemContent,
      self._CreateCharacterItemView, self._GetCharacterItemCount, self._UpdateCharacterItemView);
  self:AddButtonClickListener(self._btnSpecialReward, self._EventOnSpecialRewardClicked);
end



function OpenServerV3CheckInView:_CreateCharacterItemView(gameObj)
  local itemView = self:CreateWidgetByGO(OpenServerV3CharacterItemView, gameObj);
  itemView.onItemClicked = self.onCharacterItemClicked;
  return itemView;
end


function OpenServerV3CheckInView:_GetCharacterItemCount()
  if self.m_viewModel == nil or self.m_viewModel.charIdList == nil then
    return 0;
  end
  return #self.m_viewModel.charIdList;
end



function OpenServerV3CheckInView:_UpdateCharacterItemView(index, itemView)
  if self.m_viewModel == nil or self.m_viewModel.charIdList == nil then
    return;
  end
  local luaIndex = index + 1;
  local charId = self.m_viewModel.charIdList[luaIndex];
  if charId == nil then
    return;
  end
  itemView:Render(charId);
end


function OpenServerV3CheckInView:_EventOnSpecialRewardClicked()
  if self.onSpecialRewardClicked == nil then
    return;
  end
  self.onSpecialRewardClicked:Call(self.m_specialReward:RootGameObject());
end

return OpenServerV3CheckInView;