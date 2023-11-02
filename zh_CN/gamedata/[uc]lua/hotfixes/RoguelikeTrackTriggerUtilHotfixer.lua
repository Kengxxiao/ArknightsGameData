local RoguelikeTrackTriggerUtilHotfixer = Class("RoguelikeTrackTriggerUtilHotfixer", HotfixBase)

local function _RecordChallengeStoryFix(prevOuterData, curOuterData, typeStr, topicId)
  for key, value in pairs(CS.Torappu.RoguelikeTopicDB.data.details) do
    if value ~= nil then
      for key1, value1 in pairs(value.challenges) do
        if value1 ~= nil and value1.challengeStoryId == nil then
          value1.challengeStoryId = ""
        end
      end
    end
  end
  CS.Torappu.UI.Roguelike.RoguelikeTrackTriggerUtil._RecordChallengeStory(prevOuterData, curOuterData, typeStr, topicId);
end

function RoguelikeTrackTriggerUtilHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.Roguelike.RoguelikeTrackTriggerUtil)

  self:Fix_ex(CS.Torappu.UI.Roguelike.RoguelikeTrackTriggerUtil, "_RecordChallengeStory", function(prevOuterData, curOuterData, typeStr, topicId)
    local ok, errorInfo = xpcall(_RecordChallengeStoryFix, debug.traceback, prevOuterData, curOuterData, typeStr, topicId)
    if not ok then
      LogError("[RoguelikeTrackTriggerUtilHotfixer] fix" .. errorInfo)
    end
  end)
end

function RoguelikeTrackTriggerUtilHotfixer:OnDispose()
end

return RoguelikeTrackTriggerUtilHotfixer