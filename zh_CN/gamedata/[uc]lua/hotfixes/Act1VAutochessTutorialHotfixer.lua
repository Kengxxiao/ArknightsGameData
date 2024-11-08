local Act1VAutochessTutorialHotfixer = Class("Act1VAutochessTutorialHotfixer", HotfixBase)

local function Fix_OnPlaneAnim(self, arg)
  self:_OnPlaneAnim(arg)
  if CS.Torappu.Battle.GameMode.AutoChessBattleUtil.IsTrainingMode() then
    local autoChessGameMode = CS.Torappu.Battle.GameMode.GameModeFactory.AutoChessGameMode.instance
    if autoChessGameMode ~= nil then
      local binderManager = autoChessGameMode.binderManager
      if binderManager ~= nil and binderManager.m_binders ~= nil and binderManager.m_binders.Count >= 8 and binderManager.m_binders[7] ~= nil then
        if tostring(binderManager.m_binders[7]:GetType().FullName) == "Torappu.Battle.GameMode.GameModeFactory+AutoChessGameMode+BinderManager+TutorialChecker" then
          local center = CS.Torappu.DataCenter.AutoChessDataCenter.instanceOrNull
          if center ~= nil then
            binderManager.m_binders[7]:OnDummyAsyncBuildChanged(center)
          else
            LogError("[Act1VAutochessTutorialHotfixer] AutoChessDataCenter instance is nil")
          end
        end 
      else
        LogError("[Act1VAutochessTutorialHotfixer] binderManager or m_binders[7] is nil")
      end
    else
      LogError("[Act1VAutochessTutorialHotfixer] AutoChessGameMode instance is nil")
    end
  end
end

function Act1VAutochessTutorialHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Battle.UI.AutoChessUIPlugin)
  xlua.private_accessible(CS.Torappu.Battle.GameMode.GameModeFactory.AutoChessGameMode.BinderManager)
  xlua.private_accessible(CS.Torappu.Battle.GameMode.GameModeFactory.AutoChessGameMode.BinderManager.AutoChessDataBinder)
  self:Fix_ex(CS.Torappu.Battle.UI.AutoChessUIPlugin, "_OnPlaneAnim", function(self, arg)
    local ok, result = xpcall(Fix_OnPlaneAnim, debug.traceback, self, arg)
    if not ok then
      LogError("[Act1VAutochessTutorialHotfixer] fix" .. result)
    end
  end)
end

function Act1VAutochessTutorialHotfixer:OnDispose()
end

return Act1VAutochessTutorialHotfixer