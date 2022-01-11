














local GridGachaPackageView = Class("GridGachaPackageView", UIWidget);

local PACKAGE_POS = {0, 53, 106, 159, 212, 264, 317, 370, 423, 476};

local function _CreateSwitch(canvasGroup)
  local ret = CS.Torappu.UI.FadeSwitchTween(canvasGroup);
  ret:Reset(false);
  return ret;
end


function GridGachaPackageView:InitView(mainDlg, index)
  self.m_mainDlg = mainDlg;
  self.m_index = index;

  self._panelGrandScanShine.color = {r = 1, g = 1, b = 1, a = 0};
  self._panelScanShine.color = {r = 1, g = 1, b = 1, a = 0};

  self._panelGrand.color = {r = 1, g = 1, b = 1, a = 0};
  self._panelReward.alpha = 0;
  self._imgCritical.color = {r = 1, g = 1, b = 1, a = 0};
  local position = mainDlg:CalPosition(index);
  self._selfRect.localPosition = {x = PACKAGE_POS[position[2]], y = -PACKAGE_POS[position[1]], z = 0};
end


function GridGachaPackageView:Render(packModel)
  local mainDlg = self.m_mainDlg;
  if mainDlg == nil then
    return
  end
  self.m_viewModel = packModel;

  if self.m_viewModel.isGrandAward then
    self._panelGrand.color = {r = 1, g = 1, b = 1, a = 1};
    self._imgCritical.color = {r = 1, g = 1, b = 1, a = 1};
  else
    self._panelGrand.color = {r = 1, g = 1, b = 1, a = 0};
    self._imgCritical.color = {r = 1, g = 1, b = 1, a = 0};
  end

  if packModel.isReward and (not packModel.isGrandAward) then
    self._panelReward.alpha = 1;
  else
    self._panelReward.alpha = 0;
  end

  if packModel.isCritical then
    self._imgCritical.color = {r = 1, g = 1, b = 1, a = 1};
  else
    self._imgCritical.color = {r = 1, g = 1, b = 1, a = 0};
  end
end

return GridGachaPackageView;