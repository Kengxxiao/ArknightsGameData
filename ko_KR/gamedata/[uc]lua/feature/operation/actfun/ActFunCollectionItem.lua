local luaUtils = CS.Torappu.Lua.Util;









local ActFunCollectionItem = Class("ActFunCollectionItem", UIWidget)

function ActFunCollectionItem:OnInitialize()
  self.m_type = 0
  self:AddButtonClickListener(self._btnItem, self.EventOnItemClick)
end

function ActFunCollectionItem:Bind(view)
  self.m_parentView = view
end

function ActFunCollectionItem:Render(cls, isCompleted, isRecentPlayed)
  self.m_dlgCls = cls
  SetGameObjectActive(self._imgCompleted, isCompleted)
  SetGameObjectActive(self._panelRecentPlayed, isRecentPlayed)
end

function ActFunCollectionItem:EventOnItemClick()
  if self.m_parentView == nil or self.m_dlgCls == nil then
    return
  end
  self.m_parentView:EventOnItemClick(self.m_dlgCls)
end

return ActFunCollectionItem
