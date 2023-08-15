




local StickerPanelHotfixer = Class("StickerPanelHotfixer", HotfixBase)

local function Fix_RecycleStickers(self)
  if self.m_currentTimer ~= nil then
    self.m_currentTimer:StopTimer(0)
  end
  self:_RecycleStickers()
end

function StickerPanelHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.AVG.StickerPanel)

  self:Fix_ex(CS.Torappu.AVG.StickerPanel, "_RecycleStickers", function(self)
    local ok, errorInfo = xpcall(Fix_RecycleStickers, debug.traceback, self)
    if not ok then
      LogError("[StickerPanelHotfixer] fix" .. errorInfo)
    end
  end)
end

function StickerPanelHotfixer:OnDispose()
end

return StickerPanelHotfixer