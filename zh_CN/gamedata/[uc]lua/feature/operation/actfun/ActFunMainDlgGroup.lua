

local rapidjson = require("rapidjson")
local luaUtils = CS.Torappu.Lua.Util
ActFunMainDlgGroup = DlgMgr.DefineDialog("ActFunMainDlgGroup", nil, BridgeDlgBase)

ActFunMainDlgGroup.KEY_INITDLG = "init_dlg"
ActFunMainDlgGroup.KEY_REWARD = "first_reward"


function ActFunMainDlgGroup:OnInit()
  self.m_recentActStr = ""
  self:SetPureGroup();
  self:AddButtonClickListener(self._btnClose, self._EventOnClose);

  local initDlgName = nil
  local rewardStr = nil
  local inputBundle = self.m_parent:GetDataBundle("actMeta")
  if inputBundle ~= nil then
    initDlgName = inputBundle:GetString(ActFunMainDlgGroup.KEY_INITDLG)
    local reward = inputBundle:GetDataBundleList(ActFunMainDlgGroup.KEY_REWARD)
    self:GetReward(reward)
  end

  local initDlgCls = ActFun4MainDlg
  if initDlgName == ActFun1MainDlg.DLG_NAME then
    initDlgCls = ActFun1MainDlg
  elseif initDlgName == ActFun2MainDlg.DLG_NAME then
    initDlgCls = ActFun2MainDlg
  elseif initDlgName == ActFun3MainDlg.DLG_NAME then
    initDlgCls = ActFun3MainDlg
  elseif initDlgName == ActFun4MainDlg.DLG_NAME then
    initDlgCls = ActFun4MainDlg
  end

  local initDlgStack = {initDlgCls};
  self:GetGroup():InitList(initDlgStack);
end

function ActFunMainDlgGroup:GetReward(rewardBundles)
  if rewardBundles == nil then 
    return
  end
  local rewardViewModels = {}
  for idx = 0, rewardBundles.Count - 1 do
    local rewardBundle = rewardBundles[idx]
    if rewardBundle ~= nil then
      local reward = self:_ConverFromItemBundle(rewardBundle)
      table.insert(rewardViewModels, reward)
    end
  end
  CS.Torappu.Activity.ActivityUtil.DoShowGainedItems(rewardViewModels)
end

function  ActFunMainDlgGroup:_ConverFromItemBundle(bundle)
  local item = {
    id = bundle:GetString("id"),
    type = bundle:GetString("type"),
    count = bundle:GetInt("count")
  }
  return item
end


function ActFunMainDlgGroup:OnClose()
  self:_ClearBGM()
end

function ActFunMainDlgGroup:_EventOnClose()
  self:Close();
end

function ActFunMainDlgGroup:_ClearBGM()
  CS.Torappu.UI.UIMusicManager.RemoveMusicChunk(self:GetInstanceID())
  CS.Torappu.UI.UIMusicManager.SyncPlayingMusic()
end

function ActFunMainDlgGroup:GetInstanceID()
  return self:GetLuaLayout():GetInstanceID()
end

function ActFunMainDlgGroup:SetRecentPlayedAct(actStr)
  self.m_recentActStr = actStr
end

function ActFunMainDlgGroup:GetRecentPlayedAct()
  return self.m_recentActStr
end