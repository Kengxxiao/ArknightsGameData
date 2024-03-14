local SandboxV2PreprocessRuneInputHotfixer = Class("SandboxV2PreprocessRuneInputHotfixer", HotfixBase)

local function _Fix_PreprocessRuneInput(self, manager)
    if not manager or not manager.m_runes then
        self:PreprocessRuneInput(manager)
        return
    end

    local dupRuneCnt = 0
    for runeI=0, manager.m_runes.count-1 do
        local rune = manager.m_runes[runeI]
        if rune and rune.rData and rune.rData.blackboard and rune.rData.blackboard.Count > 0 then
            if rune.rData.blackboard:GetStringOrDefault("key", "", false) == "env_008_lightning_ally_enemy" then
                dupRuneCnt = dupRuneCnt + 1
                if dupRuneCnt > 1 then
                    rune.valid = false
                end
            end
        end
    end
    self:PreprocessRuneInput(manager)
end


function SandboxV2PreprocessRuneInputHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.Runes.RuneManager)
    self:Fix_ex(CS.Torappu.Battle.Sandbox.SandboxBattleManager, "PreprocessRuneInput", function(self, manager)
        local ok, ret = xpcall(_Fix_PreprocessRuneInput, debug.traceback, self, manager)
        if not ok then
          LogError("[Hotfix] failed to _Fix_PreprocessRuneInput : ".. ret)
          return self:PreprocessRuneInput(manager)
        else
          return ret
        end
      end)
    end

return SandboxV2PreprocessRuneInputHotfixer