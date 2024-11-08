local SandboxPermTutorialHotfixer = Class("SandboxPermTutorialHotfixer", HotfixBase)
local SandboxV2GuideUtil = CS.Torappu.UI.SandboxPerm.SandboxV2.SandboxV2GuideUtil

local function _TriggerSandboxV2GuideQuestFixed(topicId, questIdList, isTutorial, onCompleted)
  if questIdList == nil then
    return false
  end
  if not isTutorial then
    return SandboxV2GuideUtil.TriggerSandboxV2GuideQuest(topicId, questIdList, isTutorial, onCompleted)
  end
  if questIdList:GetType() == CS.System.String then
    return SandboxV2GuideUtil.TriggerSandboxV2GuideQuest(topicId, questIdList, isTutorial, onCompleted)
  end
  local ok, topicDetailData = CS.Torappu.SandboxPermDB.data.detail.sandboxV2TemplateData:TryGetValue(topicId)
  if not ok then
    return false
  end
  local playerData = CS.Torappu.UI.SandboxPerm.SandboxV2.SandboxV2Util.GetPlayerSandboxV2TopicData(topicId)
  if playerData == nil then
    return false
  end
  local questCount = 0
  if questIdList ~= nil then
    questCount = questIdList.Count
  end
  local questGroupData = nil
  local questLineGroupData = nil
  if isTutorial then
    questGroupData = topicDetailData.tutorialData.questData
    questLineGroupData = topicDetailData.tutorialData.questLineData
  else
    questGroupData = topicDetailData.questData
    questLineGroupData = topicDetailData.questLineData
  end
  local playerQuestGroup = playerData.quest.quests
  local playerQuestGroupCount = 0
  if playerQuestGroup ~= nil then
    playerQuestGroupCount = playerQuestGroup.Count
  end
  for i = 0, questCount - 1 do
    for j = 0, playerQuestGroupCount - 1 do
      local playerQuest = playerQuestGroup[j]
      if not playerQuest.completed then
        local questDataOk, questData = questGroupData:TryGetValue(playerQuest.id)
        if questDataOk then
          if questData.questLineType == CS.Torappu.SandboxV2QuestLineType.TRAINING then
            local questId = playerQuest.id
            if questId == questIdList[i] then
              local questLineOk, questLineData = questLineGroupData:TryGetValue(questData.questLine)
              if questLineOk then
                if questLineData.questLineScopeType == CS.Torappu.SandboxV2QuestLineScopeType.MAIN and not playerData.status.isRift or questLineData.questLineScopeType == CS.Torappu.SandboxV2QuestLineScopeType.RIFT and playerData.status.isRift then
                  return SandboxV2GuideUtil._TriggerSandboxV2GuideQuest(topicDetailData, playerQuest.id, isTutorial, onCompleted)
                end
              end
            end
          end
        end
      end
    end
  end
  return false
end

function SandboxPermTutorialHotfixer:OnInit()
  xlua.private_accessible(SandboxV2GuideUtil)
  self:Fix_ex(SandboxV2GuideUtil, "TriggerSandboxV2GuideQuest", function(topicId, questIdList, isTutorial, onCompleted)
    local ok, result = xpcall(_TriggerSandboxV2GuideQuestFixed, debug.traceback, topicId, questIdList, isTutorial, onCompleted)
    if not ok then
      LogError("[SandboxPermTutorialHotfixer] fix" .. result)
      return false;
    else
      return result;
    end
  end)
end

function SandboxPermTutorialHotfixer:OnDispose()
end

return SandboxPermTutorialHotfixer