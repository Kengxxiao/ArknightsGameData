








local ReturnNewsItemView = Class("ReturnNewsItemView", UIPanel);

function ReturnNewsItemView:OnInit()
  self:AddButtonClickListener(self._btnClick, self._EventOnClick);
end


function ReturnNewsItemView:Render(viewModel)
  if viewModel == nil then
    return;
  end
  self.m_model = viewModel;

  self._imgNews.sprite = self:LoadSpriteFromAutoPackHub(CS.Torappu.ResourceUrls.GetReturnNewsItemImgHubPath(), viewModel.iconId);
  self._textName.text = viewModel.tag;
  if (viewModel.isSelected) then
    self._selectedToggle.state = CS.Torappu.UI.TwoStateToggle.State.SELECT;
  else
    self._selectedToggle.state = CS.Torappu.UI.TwoStateToggle.State.UNSELECT;
  end
end

function ReturnNewsItemView:_EventOnClick()
  if self.onItemClick == nil then
    return;
  end
  self.onItemClick:Call(self.m_model.id);
end

return ReturnNewsItemView;