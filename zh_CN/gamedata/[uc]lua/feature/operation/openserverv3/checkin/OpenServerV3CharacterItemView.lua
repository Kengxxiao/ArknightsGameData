






local OpenServerV3CharacterItemView = Class("OpenServerV3CharacterItemView", UIPanel);


function OpenServerV3CharacterItemView:Render(charId)
  self:_InitIfNot();
  self.m_cachedCharId = charId;
end


function OpenServerV3CharacterItemView:_InitIfNot()
  if self.m_hasInited then
    return;
  end
  self.m_hasInited = true;
  self:AddButtonClickListener(self._btnChar, self._EventOnItemClicked);
end


function OpenServerV3CharacterItemView:_EventOnItemClicked()
  if self.onItemClicked ~= nil then
    self.onItemClicked:Call(self.m_cachedCharId);
  end 
end

return OpenServerV3CharacterItemView;