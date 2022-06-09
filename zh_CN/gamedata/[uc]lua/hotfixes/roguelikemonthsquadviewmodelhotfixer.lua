
local RoguelikeMonthSquadViewModelHotfixer = Class("RoguelikeMonthSquadViewModelHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util

local function LoadDataFix(self, topic, outerModel)
  self:LoadData(topic, outerModel)
  if self.monthSquadList == nil or self.monthSquadList.Count == 0 then
    return;
  end
  if self.selectedMonthSquad == nil or self.selectedMonthSquad == "" then
    return;
  end
  if not self.monthSquadList:ContainsKey(self.selectedMonthSquad) then
    self.selectedMonthSquad = self.monthSquadList[0].Key;
  end
end

function RoguelikeMonthSquadViewModelHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.RoguelikeTopic.RoguelikeTopicMonthSquadViewModel)

  self:Fix_ex(CS.Torappu.UI.RoguelikeTopic.RoguelikeTopicMonthSquadViewModel, "LoadData", function(self, topic, outerModel)
    local ok, errorInfo = xpcall(LoadDataFix, debug.traceback, self, topic, outerModel)
    if not ok then
      eutil.LogError("[RoguelikeMonthSquadViewModelHotfixer] fix" .. errorInfo)
    end
  end)
end

function RoguelikeMonthSquadViewModelHotfixer:OnDispose()
end

return RoguelikeMonthSquadViewModelHotfixer