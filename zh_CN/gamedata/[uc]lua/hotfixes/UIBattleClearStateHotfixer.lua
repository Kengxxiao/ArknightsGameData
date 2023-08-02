local UIBattleClearStateHotfixer = Class("UIBattleClearStateHotfixer", HotfixBase)

local function Fix_ClearImpl(self)
  for i = 0, CS.Torappu.Battle.BattleController.instance.unitManager.characters.count - 1 do
  	local character = CS.Torappu.Battle.BattleController.instance.unitManager.characters[i]
  	if (string.find(character.name, "char_1033_swire2")) and character.skill ~= nil and character.skill.m_behaviours ~= nil then
	    for j = 0, character.skill.m_behaviours.Length - 1 do
	    	character.skill.m_behaviours[j]:OnOwnerFinish(CS.Torappu.Battle.Entity.FinishReason.OTHER)
	    end
  	end
  end

  self:_ClearImpl()
end

function UIBattleClearStateHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Battle.UI.UIBattleClearState)
  xlua.private_accessible(CS.Torappu.Battle.BasicSkill)

  self:Fix_ex(CS.Torappu.Battle.UI.UIBattleClearState, "_ClearImpl", function(self)
    local ok, errorInfo = xpcall(Fix_ClearImpl, debug.traceback, self)
    if not ok then
      LogError("[UIBattleClearStateHotfixer] fix" .. errorInfo)
    end
  end)
end

function UIBattleClearStateHotfixer:OnDispose()
end

return UIBattleClearStateHotfixer