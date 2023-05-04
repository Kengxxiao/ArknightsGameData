local luaUtils = CS.Torappu.Lua.Util;








GridGachaV2SegmentView = Class("GridGachaV2SegmentView", UIWidget);

local function _SetActive(gameObj, isActive)
  luaUtils.SetActiveIfNecessary(gameObj, isActive);
end


function GridGachaV2SegmentView:OnInitialize()
  _SetActive(self._panelNotGet, true);
  _SetActive(self._panelMiss, false);
  _SetActive(self._panelGot, false);
end

function GridGachaV2SegmentView:Render(status)
  self.m_status = status;
  _SetActive(self._panelNotGet, (self.m_status == 0));
  _SetActive(self._panelMiss, (self.m_status ~= 0));
  _SetActive(self._panelGot, (self.m_status == 1));
end

return GridGachaV2SegmentView;