local FadeSwitchTween = CS.Torappu.UI.FadeSwitchTween;
local FLOAT_TWEEN_DUR = 0.23;













local MainlineBuffFavorUpView = Class("MainlineBuffFavorUpView", UIWidget);


function MainlineBuffFavorUpView:Init(host, onBackClick)
  self.m_host = host;
  self.m_onBackClick = onBackClick;
end


function MainlineBuffFavorUpView:Render(viewModel)
  self:_InitIfNot();
  if viewModel == nil then
    return;
  end

  self.m_viewModel = viewModel;
  self.m_switchTween.isShow = viewModel.showFavorUpPanel;
  self.m_adapter:NotifyDataSetChanged();
end

function MainlineBuffFavorUpView:EventOnBackClick()
  local viewModel = self.m_viewModel;
  if viewModel == nil or not viewModel.showFavorUpPanel or self.m_host == nil or self.m_onBackClick == nil then
    return;
  end
  self.m_onBackClick(self.m_host);
end

function MainlineBuffFavorUpView:_InitIfNot()
  if self.m_hasInited then
    return;
  end
  self.m_hasInited = true;

  self:AddButtonClickListener(self._buttonBack, self.EventOnBackClick);
  self:AddButtonClickListener(self._btnBackPress, self.EventOnBackClick);
  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._btnBackPress);

  self.m_adapter = self:CreateCustomComponent(
      UISimpleLayoutAdapter, self, self._charLayout,
      self._CreateMissionGroupView, self._GetMissionGroupCount, self._UpdateMissionGroupView);

  self.m_switchTween = FadeSwitchTween(self._canvasSelf, FLOAT_TWEEN_DUR);
  self.m_switchTween:Reset(false);
end


function MainlineBuffFavorUpView:_CreateMissionGroupView(gameObj)
  return gameObj:GetComponent("Torappu.Activity.ActFavorUpCharView");
end



function MainlineBuffFavorUpView:_UpdateMissionGroupView(index, view)
  view:Render(self.m_viewModel.favorUpCharList[index + 1]);
end

function MainlineBuffFavorUpView:_GetMissionGroupCount()
  if self.m_viewModel == nil or self.m_viewModel.favorUpCharDesc == nil then
    return 0;
  end
  return #self.m_viewModel.favorUpCharList;
end

return MainlineBuffFavorUpView;