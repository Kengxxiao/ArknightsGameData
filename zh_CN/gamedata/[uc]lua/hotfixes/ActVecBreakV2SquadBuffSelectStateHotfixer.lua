local luaUtils = CS.Torappu.Lua.Util;

local ActVecBreakV2SquadBuffSelectStateHotfixer = Class("ActVecBreakV2SquadBuffSelectStateHotfixer", HotfixBase)

local function _BuffItemClickFix(self, stageId)
  local model = self.m_stateBean.property.Value;
  local page = self:GetPage();
  if not model or not model.buffListModel or not model.selectedBuffIdList or
      string.isNullOrEmpty(stageId) or not page then
    return;
  end
  local buffItemModel = model.buffListModel:GetBuffItemByStageId(stageId);
  if not buffItemModel then
    return;
  end
  if not buffItemModel.isStageStarted then
    local timeStr = CS.Torappu.FormatUtil.FormatTimeDeltaStrFromNow(buffItemModel.stageStartTs);
    CS.Torappu.Activity.VecBreakV2.ActVecBreakV2Util.TextToast(page, luaUtils.Format(StringRes.VEC_BREAK_V2_UNLOCK_TIME_HINT_STR, timeStr));
    return;
  end
  if not buffItemModel.isBuffUnlocked then
    CS.Torappu.Activity.VecBreakV2.ActVecBreakV2Util.TextToast(page, model.buffLockToast);
    return;
  end
  self:_BuffItemClick(stageId);
end

function ActVecBreakV2SquadBuffSelectStateHotfixer:OnInit()
  xlua.private_accessible(typeof(CS.Torappu.Activity.VecBreakV2.ActVecBreakV2SquadBuffSelectState))
  self:Fix_ex(CS.Torappu.Activity.VecBreakV2.ActVecBreakV2SquadBuffSelectState, "_BuffItemClick", function (self, stageId)
    local ok, errorInfo = xpcall(_BuffItemClickFix, debug.traceback, self, stageId)
    if not ok then
      LogError("[Act Vec Break] stage squad buff fix error: ".. errorInfo);
      self:_BuffItemClick(stageId);
    end
  end)
end

return ActVecBreakV2SquadBuffSelectStateHotfixer;