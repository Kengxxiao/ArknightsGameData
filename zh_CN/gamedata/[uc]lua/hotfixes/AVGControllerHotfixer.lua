local AVGControllerHotfixer = Class("AVGControllerHotfixer", HotfixBase)

local function _FindDecisionPanel(controller)
  if controller == nil then
    return nil
  end
  local comps = controller.m_components
  if comps == nil then
    return nil
  end
  for i = 0, comps.Length - 1 do
    local comp = comps[i]
    if comp ~= nil and comp:GetType() == typeof(CS.Torappu.AVG.DecisionPanel) then
      return comp
    end
  end
  return nil
end

local function _TryGetDecisionExecutorFromPanel(decisionPanel)
  if decisionPanel == nil then
    return nil
  end

  local panelExecutors = decisionPanel.m_executorWrappers

  if panelExecutors == nil then
    return nil
  end

  for e = 0, panelExecutors.Length - 1 do
    local ex = panelExecutors[e]
    if ex ~= nil and ex.command == "decision" then
      return ex
    end
  end

  return nil
end



local function _SnapshotDecisionExecutors(csList)
  if csList == nil or csList.Count <= 0 then
    return nil
  end
  local snapshot = {}
  for i = 0, csList.Count - 1 do
    snapshot[i + 1] = csList[i]
  end
  return snapshot
end

local function _FinishDecisionExecutors(snapshot, decisionPanel, decisionExecutor)
  local finishedDecisionPanel = false
  for i = #snapshot, 1, -1 do
    local executor = snapshot[i]
    if executor ~= nil then
      if (not finishedDecisionPanel) and decisionPanel ~= nil and decisionExecutor ~= nil and executor == decisionExecutor then
        finishedDecisionPanel = true
        decisionPanel:FinishCommand()
      else
        executor:ForceEnd()
      end
    end
  end
end

local function _TryFinishDecisionExecutors(controller, snapshot)
  if controller == nil then
    return
  end
  if snapshot == nil or #snapshot == 0 then
    return
  end

  local decisionPanel = _FindDecisionPanel(controller)
  local decisionExecutor = _TryGetDecisionExecutorFromPanel(decisionPanel)
  _FinishDecisionExecutors(snapshot, decisionPanel, decisionExecutor)
end

local function OnDecisionSelectedFix(self, decisionValue, decisionIndex)
  local snapshot = _SnapshotDecisionExecutors(self.m_decisionExecutors)
  self:OnDecisionSelected(decisionValue, decisionIndex)
  _TryFinishDecisionExecutors(self, snapshot)
  snapshot = nil
end

function AVGControllerHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.AVG.AVGController)
  xlua.private_accessible(CS.Torappu.AVG.ExecutorComponent)
  xlua.private_accessible(CS.Torappu.AVG.DecisionPanel)
  self:Fix_ex(CS.Torappu.AVG.AVGController, "OnDecisionSelected", function(self,decisionValue, decisionIndex)
    local ok, errorInfo = xpcall(OnDecisionSelectedFix, debug.traceback, self, decisionValue,
        decisionIndex)
    if not ok then
      LogError("[AVGControllerHotfixer] OnDecisionSelected fix: " .. tostring(errorInfo))
      self:OnDecisionSelected(decisionValue, decisionIndex)
    end
  end)
end

function AVGControllerHotfixer:OnDispose()
end

return AVGControllerHotfixer