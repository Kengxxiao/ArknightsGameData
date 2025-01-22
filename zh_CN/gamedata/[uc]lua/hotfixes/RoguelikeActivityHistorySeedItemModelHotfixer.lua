local luaUtils = CS.Torappu.Lua.Util;
local RoguelikeActivityHistorySeedItemModelHotfixer = Class("RoguelikeActivityHistorySeedItemModelHotfixer", HotfixBase)

local function Fix_LoadData(self, topicId, history)
  self:LoadData(topicId, history)
  local dateTime = luaUtils.ToDateTime(self.m_ts)
  self.endTime = luaUtils.Format(CS.Torappu.StringRes.DATE_FORMAT_YYYY_MM_DD_HH_MM, dateTime.Year, dateTime.Month, dateTime.Day, dateTime.Hour, dateTime.Minute)
end

function RoguelikeActivityHistorySeedItemModelHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.RoguelikeTopic.Activity.SeedMode.RoguelikeActivityHistorySeedItemModel)
  self:Fix_ex(CS.Torappu.UI.RoguelikeTopic.Activity.SeedMode.RoguelikeActivityHistorySeedItemModel, "LoadData", function(self, topicId, history)
    local ok, errorInfo = xpcall(Fix_LoadData, debug.traceback, self, topicId, history)
      if not ok then
        LogError("fix RoguelikeActivityHistorySeedItemModel LoadData error" .. errorInfo)
      end
    end)

end

function RoguelikeActivityHistorySeedItemModelHotfixer:OnDispose()

end

return RoguelikeActivityHistorySeedItemModelHotfixer