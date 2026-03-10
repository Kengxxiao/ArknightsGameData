














local ReturnSpecialOpenMultiView = Class("ReturnSpecialOpenMultiView", UIPanel);

local ReturnSpecialOpenEntryView = require("Feature/Operation/Returning/SpecialOpen/ReturnSpecialOpenEntryView");

function ReturnSpecialOpenMultiView:OnInit()
  self.m_entryAdapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self, self._entryContent,
      self._CreateEntryItemView, self._GetEntryItemCount, self._UpdateEntryItemView);
  self:AddButtonClickListener(self._gotoBtn, self._EventOnClick);
end


function ReturnSpecialOpenMultiView:Render(model)
  if model == nil then
    return;
  end
  self.m_cachedModel = model;

  self.m_entryAdapter:NotifyDataSetChanged();
  local selectedModel = model:GetSelectedOpenTypeModel();
  if selectedModel == nil then
    return;
  end

  SetGameObjectActive(self._pauseGo, selectedModel.openState == ReturnSpecialOpenState.PAUSE);
  SetGameObjectActive(self._layoutPlaceholder, selectedModel.openState ~= ReturnSpecialOpenState.PAUSE);
  self._pauseNoticeText.text = selectedModel.pauseDesc;
  self._contentText.text = selectedModel.desc;
  self._textTitle.text = selectedModel.title;
end



function ReturnSpecialOpenMultiView:_CreateEntryItemView(gameObj)
  local itemView = self:CreateWidgetByGO(ReturnSpecialOpenEntryView, gameObj);
  itemView.loadFunc = self.loadFunc;
  itemView.onEntryClick = self.onEntryClick;
  return itemView;
end


function ReturnSpecialOpenMultiView:_GetEntryItemCount()
  if self.m_cachedModel == nil or self.m_cachedModel.typeModels == nil then
    return 0;
  end
  return #self.m_cachedModel.typeModels;
end



function ReturnSpecialOpenMultiView:_UpdateEntryItemView(index, view)
  if self.m_cachedModel == nil or self.m_cachedModel.typeModels == nil then
    return;
  end
  if index < 0 or index >= #self.m_cachedModel.typeModels then
    return;
  end
  view:Render(self.m_cachedModel.typeModels[index + 1], self.m_cachedModel.selectedType);
end

function ReturnSpecialOpenMultiView:_EventOnClick()
  if self.onGotoClick == nil then
    return;
  end
  self.onGotoClick:Call();
end

return ReturnSpecialOpenMultiView;