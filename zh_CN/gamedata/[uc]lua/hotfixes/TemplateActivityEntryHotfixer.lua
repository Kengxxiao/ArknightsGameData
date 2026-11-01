local TemplateActivityEntry = CS.Torappu.UI.ActivityStage.TemplateActivityEntry
local eutil = CS.Torappu.Lua.Util


local TemplateActivityEntryHotfixer = Class("TemplateActivityEntryHotfixer", HotfixBase)

local function _SampleAllAnimClipAtBeginFix(self)
  self:_SampleAllAnimClipAtBegin()
  local playableList = self:_GetPlayableAnimList()
  if playableList == nil then
    return
  end
  for i = 0, playableList.Count - 1 do
    local animationLocation = playableList[i].animLocaction
    animationLocation.animationWrapper:InitIfNot()
    animationLocation.animationWrapper:SampleClipAtBegin(animationLocation.animationName)
  end
end

function TemplateActivityEntryHotfixer:OnInit()
  xlua.private_accessible(TemplateActivityEntry)
  self:Fix_ex(TemplateActivityEntry, "_SampleAllAnimClipAtBegin", function(self)
    local ok, err = xpcall(_SampleAllAnimClipAtBeginFix, debug.traceback, self)
    if not ok then
      eutil.LogHotfixError("[TemplateActivityEntryHotfixer] _SampleAllAnimClipAtBegin: " .. err)
    end
  end)
end

function TemplateActivityEntryHotfixer:OnDispose()
end

return TemplateActivityEntryHotfixer
