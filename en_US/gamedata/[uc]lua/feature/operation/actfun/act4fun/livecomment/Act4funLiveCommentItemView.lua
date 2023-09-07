local luaUtils = CS.Torappu.Lua.Util;









local Act4funLiveCommentItemView = Class("Act4funLiveCommentItemView", UIWidget);



function Act4funLiveCommentItemView:Render(model, loadFunc)
  if model == nil or loadFunc == nil then
    return;
  end
  local icon = loadFunc(model.iconId);
  self._imgAvatar.sprite = icon;
  local content = luaUtils.Format(StringRes.ACTFUN_COMMENT_FORMAT, 
      model.name, model.desc);
  self._content.text = content;

  local isIndexChanged = self.m_model ~= model;
  if not isIndexChanged then
    return;
  end
  self.m_model = model;
  self:_ShowTween();
end

function Act4funLiveCommentItemView:_ShowTween()
  self:_ClearTween();
  if self._animWrapper == nil or self._animName == nil or self._animName == "" then
    return;
  end
  self._animWrapper:SampleClipAtBegin(self._animName);
  self.m_activeTween = self._animWrapper:PlayWithTween(self._animName);
end

function Act4funLiveCommentItemView:_ClearTween()
  local tween = self.m_activeTween;
  if tween ~= nil then
    tween:Kill();
    self.m_activeTween = nil;
  end
end

return Act4funLiveCommentItemView;