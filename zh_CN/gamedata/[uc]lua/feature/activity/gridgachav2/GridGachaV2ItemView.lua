local luaUtils = CS.Torappu.Lua.Util;















local GridGachaV2ItemView = Class("GridGachaV2ItemView", UIWidget);

local ITEM_POS = {0, 53, 106, 159, 212, 264, 317, 370, 423, 476};

local function _SetActive(gameObj, isActive)
  luaUtils.SetActiveIfNecessary(gameObj, isActive);
end

function GridGachaV2ItemView:InitView(mainDlg, index)
  self.m_mainDlg = mainDlg;
  self.m_index = index;

  self._canvasGroupGrand.alpha = 0;
  _SetActive(self._imgNew, false);

  local position = mainDlg:CalPosition(index);
  self._selfRect.anchoredPosition = {x = ITEM_POS[position[2]], y = -ITEM_POS[position[1]], z = 0};
end


function GridGachaV2ItemView:Render(itemModel)
  if self.m_mainDlg == nil then
    return;
  end
  self.m_viewModel = itemModel;

  if self.m_viewModel.isGrand and not self.m_viewModel.isReward then
    self._canvasGroupGrand.alpha = 1;
  else
    self._canvasGroupGrand.alpha = 0;
  end

  _SetActive(self._imgNew, self.m_viewModel.isNew and self.m_viewModel.hasGacha);
  _SetActive(self._panelAnimationElement, not self.m_viewModel.hasGacha);

  if self.m_viewModel.isReward and self.m_viewModel.isCritical then
    _SetActive(self._panelCompleteCritical, true);
  elseif self.m_viewModel.isReward and self.m_viewModel.isGrand then
    _SetActive(self._panelCompleteGrand, true);
  elseif self.m_viewModel.isReward then
    _SetActive(self._panelCompleteNormal, true);
  end
end

return GridGachaV2ItemView;