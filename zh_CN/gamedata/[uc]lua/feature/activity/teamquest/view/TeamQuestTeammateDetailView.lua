local luaUtils = CS.Torappu.Lua.Util

















local TeamQuestTeammateDetailView = Class("TeamQuestTeammateDetailView", UIPanel)


function TeamQuestTeammateDetailView:Init(detailViewInput)
  self.m_onBtnCloseClick = detailViewInput.onBtnCloseClick
  self.m_onBtnRequestFriend = detailViewInput.onBtnRequestFriendClick
  self.m_onBtnViewNameCard = detailViewInput.onBtnViewNameCard

  self:AddButtonClickListener(self._btnRequestFriend, function ()
    if self.m_onBtnRequestFriend == nil or self.m_viewModel == nil then
      return
    end
    self.m_onBtnRequestFriend:Call(self.m_viewModel.uid)
  end)

  self:AddButtonClickListener(self._btnViewNameCard, function ()
    if self.m_onBtnViewNameCard == nil or self.m_viewModel == nil then
      return
    end
    self.m_onBtnViewNameCard:Call(self.m_viewModel.uid)
  end)

  self:_AddOutsideHandler()
end

function TeamQuestTeammateDetailView:_AddOutsideHandler()
  self._outsideHandler.OnClick:AddListener(function()
    if self.m_onBtnCloseClick == nil then
      return
    end
    self.m_onBtnCloseClick:Call()
  end)

  self:_AddToDoWhenClose(function()
    if not luaUtils.IsDestroyed(self._outsideHandler) then
      self._outsideHandler.OnClick:RemoveAllListeners()
    end
  end)
end


function TeamQuestTeammateDetailView:Render(viewModel)
  if viewModel.showDetailMatePos ~= nil then
    luaUtils.AlignRectTransToPos(self._detailViewTrans, viewModel.showDetailMatePos)
  end

  if viewModel == nil then
    return
  end

  local showDetailMateId = viewModel.showDetailMateId
  if showDetailMateId == nil then
    return
  end

  local showMateModel = viewModel.mateModelDict[showDetailMateId]
  if showMateModel == nil then
    return
  end

  self.m_viewModel = showMateModel
end

return TeamQuestTeammateDetailView