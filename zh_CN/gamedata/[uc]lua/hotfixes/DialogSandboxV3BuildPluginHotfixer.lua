

local DialogSandboxV3BuildPluginHotfixer = Class("DialogSandboxV3BuildPluginHotfixer", HotfixBase)

local DialogSandboxV3BuildPlugin = CS.Torappu.Battle.SandboxV3.DialogSandboxV3BuildPlugin
local DialogControllerGameModePlugin = CS.Torappu.Battle.Dialog.DialogController.DialogControllerGameModePlugin
local BattleController = CS.Torappu.Battle.BattleController
local CameraController = CS.Torappu.Battle.CameraController
local DraggableCameraPlugin = CS.Torappu.Battle.DraggableCameraPlugin
local CSString = CS.System.String
local eutil = CS.Torappu.Lua.Util

local TAG = "[Dialog Controller] "

local function _ExecuteHeaderHotfix(self, command)
  local input = self.m_currentNpcInput
  if input ~= nil then
    local paramType = self.param.type
    local buildManager = BattleController.instance.sandboxV3BuildGameMode.buildManager
    buildManager:AddNpcOutput(input.npcCfgId, paramType)
    buildManager:AddNpcChoice(input.npcCfgId, self.currentSignal, paramType)
  else
    eutil.LogError(TAG .. "_ExecuteHeader: m_currentNpcInput is null, skipping AddNpcOutput/AddNpcChoice.")
  end

  local cameraPlugin = CameraController.instance.plugin
  cameraPlugin:PauseDrag(DraggableCameraPlugin.DragPauseReason.BATTLE_AVG, true)
  return true
end

local function _ExecuteSaveHotfix(self, command)
  local input = self.m_currentNpcInput
  if input == nil or CSString.IsNullOrEmpty(input.npcCfgId) then
    local inputDesc = (input == nil) and "null" or "not null"
    local idDesc
    if input == nil or input.npcCfgId == nil then
      idDesc = "null"
    else
      idDesc = input.npcCfgId
    end
    eutil.LogError(string.format(
      TAG .. "Skipping unused sandbox build end story. m_currentNpcInput=%s, npcCfgId=%s",
      inputDesc, idDesc))
    return false
  end
  BattleController.instance.sandboxV3BuildGameMode.buildManager:SetNpcFinish(input.npcCfgId, self.param.type)
  return true
end

function DialogSandboxV3BuildPluginHotfixer:OnInit()
  if HOTFIX_ENABLE then
    if xlua and xlua.private_accessible then
      xlua.private_accessible(DialogControllerGameModePlugin)
      xlua.private_accessible(DialogSandboxV3BuildPlugin)
    end
    self:Fix_ex(DialogSandboxV3BuildPlugin, "_ExecuteHeader", _ExecuteHeaderHotfix)
    self:Fix_ex(DialogSandboxV3BuildPlugin, "_ExecuteSave", _ExecuteSaveHotfix)
  end
end

return DialogSandboxV3BuildPluginHotfixer
