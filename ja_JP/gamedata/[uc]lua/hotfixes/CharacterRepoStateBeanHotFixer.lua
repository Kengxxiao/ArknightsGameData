




local CharacterRepoStateBeanHotfixer = Class("CharacterRepoStateBeanHotfixer", HotfixBase)

local function _FixLoadData(self)
  local avgRuning = CS.Torappu.AVG.AVGController.instance.isRunning
  if avgRuning then
    CS.Torappu.UI.UILocalCache.instance:SetPlayerRepoStarTopMode(false)
  end
  self:LoadData()
end

function CharacterRepoStateBeanHotfixer:OnInit()
  self:Fix_ex(CS.Torappu.UI.CharacterRepo.CharacterRepoStateBean, "LoadData", _FixLoadData)
end

function CharacterRepoStateBeanHotfixer:OnDispose()
end

return CharacterRepoStateBeanHotfixer