local CharacterRepoPageHotfixer = Class("CharacterRepoPageHotfixer", HotfixBase)

local function _FixCustomSetActive(self, active)
  local ret = self:CustomSetActive(active)

  local rootCanvasGroup = self:GetComponent(typeof(CS.UnityEngine.CanvasGroup))
  if rootCanvasGroup ~= nil and not active then
    rootCanvasGroup:DOKill(false)
  end

  return ret
end

function CharacterRepoPageHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.CharacterRepo.CharacterRepoPage)
  self:Fix_ex(CS.Torappu.UI.CharacterRepo.CharacterRepoPage, "CustomSetActive", function(self, active)
    local ok, ret = xpcall(_FixCustomSetActive, debug.traceback, self, active)
    if not ok then
      LogError("[CharacterRepoPage] fix failed: " .. ret)
    else
      return ret
    end
  end)
end

return CharacterRepoPageHotfixer