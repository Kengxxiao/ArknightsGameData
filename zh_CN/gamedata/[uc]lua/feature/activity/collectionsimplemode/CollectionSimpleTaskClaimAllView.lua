local luaUtils = CS.Torappu.Lua.Util





local CollectionSimpleTaskClaimAllView = Class("CollectionSimpleTaskClaimAllView", UIWidget)

function CollectionSimpleTaskClaimAllView:OnInitialize()
  self:AddButtonClickListener(self._hotspot, self._EventOnClaimAllClicked)
end



function CollectionSimpleTaskClaimAllView:Render(model, isAllRewardClaimed)
  if not model or not model.actConfig then
    return
  end

  luaUtils.SetActiveIfNecessary(self._rootGameObject, model.showClaimAllObject and not isAllRewardClaimed)
  self._themeBg.color = model.actConfig.baseColor
end

function CollectionSimpleTaskClaimAllView:_EventOnClaimAllClicked()
  if not self.onClaimAllClicked then
    return
  end
  Event.Call(self.onClaimAllClicked)
end

return CollectionSimpleTaskClaimAllView