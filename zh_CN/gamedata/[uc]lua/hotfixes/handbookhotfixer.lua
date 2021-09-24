




local HandbookHotfixer = Class("ShopHotfixer", HotfixBase)

local function _FixNewVoiceTrackPoint(self, charId)
  local isNPC = CS.Torappu.PlayerData.instance:GetCharInstById(charId) == nil
  if isNPC then
    return false
  end
  self:UpdateState(charId)
end

local function _GetVoicePathByType(self, wordData, preferLang, param3)
  return self:GetVoicePathByType(wordData, preferLang, true)
end

function HandbookHotfixer:OnInit()
  self:Fix_ex(CS.Torappu.UI.HandBook.HandBookNewVoiceTrackPointModel, "UpdateState", _FixNewVoiceTrackPoint)
  self:Fix_ex(CS.Torappu.CharWord.VoiceLangManager, "GetVoicePathByType", _GetVoicePathByType)
end

function HandbookHotfixer:OnDispose()
end

return HandbookHotfixer