


local rapidjson = require("rapidjson")
local luaUtils = CS.Torappu.Lua.Util
ActFunMainDlgGroup = DlgMgr.DefineDialog("ActFunMainDlgGroup", nil, BridgeDlgBase)

ActFunMainDlgGroup.KEY_INITDLG = "init_dlg"
ActFunMainDlgGroup.KEY_REWARD = "first_reward"
ActFunMainDlgGroup.KEY_NEXT_STAGE = "unlock_next_stage"

function ActFunMainDlgGroup:OnInit()
  self.m_recentActStr = ""
  self:SetPureGroup();
  self:AddButtonClickListener(self._btnClose, self._EventOnClose);
  self:_SetBackgroundImg();

  local initDlgName = nil
  local rewardStr = nil
  local inputBundle = self.m_parent:GetDataBundle("actMeta")
  if inputBundle ~= nil then
    initDlgName = inputBundle:GetString(ActFunMainDlgGroup.KEY_INITDLG)
    local reward = inputBundle:GetDataBundleList(ActFunMainDlgGroup.KEY_REWARD)
    local hasNextStage = inputBundle:GetBool(ActFunMainDlgGroup.KEY_NEXT_STAGE)
    self:PlayCallback(reward, hasNextStage)
  end

  local initDlgCls = ActFun7MainDlg
  if initDlgName == ActFun1MainDlg.DLG_NAME then
    initDlgCls = ActFun1MainDlg
  elseif initDlgName == ActFun2MainDlg.DLG_NAME then
    initDlgCls = ActFun2MainDlg
  elseif initDlgName == ActFun3MainDlg.DLG_NAME then
    initDlgCls = ActFun3MainDlg
  elseif initDlgName == ActFun4MainDlg.DLG_NAME then
    initDlgCls = ActFun4MainDlg
  elseif initDlgName == ActFun5MainDlg.DLG_NAME then
    initDlgCls = ActFun5MainDlg
  elseif initDlgName == ActFun6MainDlg.DLG_NAME then
    initDlgCls = ActFun6MainDlg
  elseif initDlgName == ActFun7MainDlg.DLG_NAME then
    initDlgCls = ActFun7MainDlg
  end

  local initDlgStack = {initDlgCls};
  self:GetGroup():InitList(initDlgStack);
end

function ActFunMainDlgGroup:PlayCallback(rewardBundles, hasNextStage)
  if rewardBundles == nil then 
    self:TextNextStageToast(hasNextStage)
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

  CS.Torappu.Activity.ActivityUtil.DoShowGainedItemsWithCallback(rewardViewModels, function ()
    self:TextNextStageToast(hasNextStage)
  end)
end

function ActFunMainDlgGroup:TextNextStageToast(hasNextStage)
  if not hasNextStage then 
    return
  end
  local toastText = CS.Torappu.I18N.I18nUtils.GetText(CS.Torappu.TextRes.COMMON_MISSION_UNLOCKED_TOAST)
  luaUtils.TextToast(toastText)
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

function ActFunMainDlgGroup:_SetBackgroundImg()
    local bgId = CS.Torappu.PlayerData.instance.data.playerHomeBackground.selectedId;
    local wrapperPath = CS.Torappu.ResourceUrls.GetHomeBackgroundAssetsWrapperPath(bgId);
    local assets = self:LoadScriptableObject(wrapperPath)
    if assets == nil then
        return
    end
    self._bgImage.sprite = CS.Torappu.DataConvertUtil.CalcHomeBackgroundBlurImg(bgId, assets);
end
