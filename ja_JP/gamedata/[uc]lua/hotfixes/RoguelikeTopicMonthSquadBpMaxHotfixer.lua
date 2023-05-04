
local RoguelikeTopicMonthSquadBpMaxHotfixer = Class("RoguelikeTopicMonthSquadBpMaxHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util

function _RenderTopic_Fixed(self, topicId, input)
    self:_RenderTopic(topicId, input)
	local ok, topicData = CS.Torappu.RoguelikeTopicDB.data.details:TryGetValue(topicId)
	if ok then
		self._textBpMax.text = eutil.Format(CS.Torappu.I18N.StringMap.Get("ROGUELIKE_TOPIC_MONTH_SQUAD_BP_MAX"), topicData.detailConst.bpSystemName)
	end
end

function RoguelikeTopicMonthSquadBpMaxHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.UI.RoguelikeTopic.RoguelikeTopicMonthSquadRewardView)
    self:Fix_ex(CS.Torappu.UI.RoguelikeTopic.RoguelikeTopicMonthSquadRewardView, "_RenderTopic", function(self, topicId, input) 
        local ok, errorInfo = xpcall(_RenderTopic_Fixed, debug.traceback, self, topicId, input)
        if not ok then
          eutil.LogError("[RoguelikeTopicMonthSquadBpMaxHotfixer] _RenderTopic fix" .. errorInfo)
        end
    end)
end

function RoguelikeTopicMonthSquadBpMaxHotfixer:OnDispose()
end

return RoguelikeTopicMonthSquadBpMaxHotfixer