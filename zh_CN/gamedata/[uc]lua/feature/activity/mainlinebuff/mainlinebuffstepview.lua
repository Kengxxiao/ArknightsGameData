local luaUtils = CS.Torappu.Lua.Util;















local MainlineBuffStepView = Class("MainlineBuffStepView", UIWidget);


local function _CheckIfValueDirty(cache, target)
  if cache == nil or cache ~= target then
    return true;
  end
  return false;
end

local function _SetActive(gameObj, isActive)
  luaUtils.SetActiveIfNecessary(gameObj, isActive);
end


function MainlineBuffStepView:Render(viewModel)
  if self.m_viewCache == nil then
    self.m_viewCache = {};
  end
  if viewModel == nil then
    return;
  end
  local viewCache = self.m_viewCache;

  if _CheckIfValueDirty(viewCache.unlockDesc, viewModel.unlockDesc) then
    self._textFavorUpDesc1.text = viewModel.unlockDesc;
    self._textFavorUpDesc2.text = viewModel.unlockDesc;
    viewCache.unlockDesc = viewModel.unlockDesc;
  end
  if _CheckIfValueDirty(viewCache.favorUpDesc, viewModel.favorUpDesc) then
    self._textFavorUpPercent1.text = viewModel.favorUpDesc;
    self._textFavorUpPercent2.text = viewModel.favorUpDesc;
    viewCache.favorUpDesc = viewModel.favorUpDesc;
  end
  if _CheckIfValueDirty(viewCache.blockDesc, viewModel.blockDesc) then
    self._textFavorUpLockedDesc.text = viewModel.blockDesc;
    viewCache.blockDesc = viewModel.blockDesc;
  end

  local isBlock = viewModel:IsBlock();
  local isUnlock = viewModel:IsUnlock();
  if _CheckIfValueDirty(viewCache.isUnlock, isUnlock) then
    _SetActive(self._imgLineComplete, isUnlock);
    _SetActive(self._imgLineUncomplete, not isUnlock);
    _SetActive(self._panelTextComplete, isUnlock);
    _SetActive(self._panelTextUncomplete, not isUnlock);
    viewCache.isUnlock = isUnlock;
  end
  if _CheckIfValueDirty(viewCache.isBlock, isBlock) then
    _SetActive(self._panelLocked, isBlock);
    _SetActive(self._panelUnlock, not isBlock);
    viewCache.isBlock = isBlock;
  end
end

return MainlineBuffStepView;