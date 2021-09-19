




local HandbookHotfixer = Class("ShopHotfixer", HotfixBase)

local function _FixNewVoiceTrackPoint(self, charId)
  local isNPC = CS.Torappu.PlayerData.instance:GetCharInstById(charId) == nil
  if isNPC then
    return false
  end
  self:UpdateState(charId)
end

function HandbookHotfixer:OnInit()
  self:Fix_ex(CS.Torappu.UI.HandBook.HandBookNewVoiceTrackPointModel, "UpdateState", _FixNewVoiceTrackPoint)
end

function HandbookHotfixer:OnDispose()
end

return HandbookHotfixer