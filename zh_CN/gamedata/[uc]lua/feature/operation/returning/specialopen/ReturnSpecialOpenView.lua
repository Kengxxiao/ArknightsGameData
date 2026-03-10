












local ReturnSpecialOpenView = Class("ReturnSpecialOpenView", UIPanel);

local ReturnSpecialOpenMultiView = require("Feature/Operation/Returning/SpecialOpen/ReturnSpecialOpenMultiView");
local ReturnSpecialOpenResOnlyView = require("Feature/Operation/Returning/SpecialOpen/ReturnSpecialOpenResOnlyView");

function ReturnSpecialOpenView:OnInit()
  self.m_hasInited = false;
  self.m_multiView = self:CreateWidgetByGO(ReturnSpecialOpenMultiView, self._multiEntryPanel);
  self.m_resOnlyView = self:CreateWidgetByGO(ReturnSpecialOpenResOnlyView, self._resOnlyEntryPanel);
end


function ReturnSpecialOpenView:OnViewModelUpdate(data)
  if data == nil or data.specialOpenViewModel == nil then
    return;
  end
  local model = data.specialOpenViewModel;
  local selectedModel = model:GetSelectedOpenTypeModel();
  if selectedModel == nil then
    return;
  end
  self._imgTitle.sprite = self:_LoadSprite(CS.Torappu.ResourceUrls.GetReturnAllOpenBkgHubPath(), selectedModel.imgBkgId);
  self._imgIcon.sprite = self:_LoadSprite(CS.Torappu.ResourceUrls.GetReturnAllOpenIconHubPath(), selectedModel.imgIconId);

  local isResOpenOnly = model.isResOpenOnly;
  SetGameObjectActive(self._multiEntryPanel.gameObject, not isResOpenOnly);
  SetGameObjectActive(self._resOnlyEntryPanel.gameObject, isResOpenOnly);

  if isResOpenOnly then
    self.m_resOnlyView.onGotoClick = self.onGotoClick;
    self.m_resOnlyView:Render(model);
  else
    self.m_multiView.loadFunc = self.loadFunc;
    self.m_multiView.onEntryClick = self.onEntryClick;
    self.m_multiView.onGotoClick = self.onGotoClick;
    self.m_multiView:Render(model);
  end
end





function ReturnSpecialOpenView:_LoadSprite(hubPath, spriteName)
  if self.loadFunc == nil then
    return nil;
  end
  return self.loadFunc(hubPath, spriteName);
end

return ReturnSpecialOpenView;