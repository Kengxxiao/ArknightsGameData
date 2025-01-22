
local ArchiveRelicModelHotfixer = Class("ArchiveRelicModelHotfixer", HotfixBase)

local FIX_RELIC_ID_MAP = {
  "rogue_4_relic_legacy_9_c",
  "rogue_4_relic_legacy_10_c",
  "rogue_4_relic_legacy_11_c",
  "rogue_4_relic_legacy_12_c",
  "rogue_4_relic_legacy_13_c",
  "rogue_4_relic_legacy_14_c",
  "rogue_4_relic_legacy_15_c",
  "rogue_4_relic_legacy_16_c",
  "rogue_4_relic_legacy_17_c",
  "rogue_4_relic_legacy_18_c",
  "rogue_4_relic_legacy_34_c",
  "rogue_4_relic_legacy_35_c",
  "rogue_4_relic_legacy_36_c",
  "rogue_4_relic_legacy_37_c",
  "rogue_4_relic_legacy_38_c",
  "rogue_4_relic_legacy_39_c",
  "rogue_4_relic_legacy_40_c",
  "rogue_4_relic_legacy_41_c",
  "rogue_4_relic_legacy_42_c",
  "rogue_4_relic_legacy_43_c",
}

local function CheckDifficultyHas18(topicDetail)
  local diffList = topicDetail.difficulties
  local max = 0
  for i = 0, diffList.Count - 1 do 
    local diff = diffList[i]
    if diff.modeDifficulty == CS.Torappu.RoguelikeTopicMode.NORMAL and max < diff.grade then
      max = diff.grade
    end
  end
  return max == 18
end

local function _Fix_ArchiveRelicModel_GenerateDifficultyItems(self, archiveId, topicDetail, playerdata)
  self:_GenerateDifficultyItems(archiveId, topicDetail, playerdata)

  if archiveId == "rogue_4" and CheckDifficultyHas18(topicDetail) then
    for itemId, relicList in pairs(self.m_difficultyRelics) do
      for i = 0, relicList.Count - 1 do
        local relic = relicList[i]
        for fixIndex = 1, #FIX_RELIC_ID_MAP do
          if relic.relicId == FIX_RELIC_ID_MAP[fixIndex] then
            relic.difficultyDesc = string.gsub(relic.difficultyDesc, "15", "18");
          end
        end
      end
    end
  end
end

function ArchiveRelicModelHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.ActArchive.ArchiveRelicModel)
  self:Fix_ex(CS.Torappu.UI.ActArchive.ArchiveRelicModel, "_GenerateDifficultyItems", function(self, archiveId, topicDetail, playerdata)
    local ok, errorInfo = xpcall(_Fix_ArchiveRelicModel_GenerateDifficultyItems, debug.traceback, self, archiveId, topicDetail, playerdata)
      if not ok then
        LogError("fix ArchiveRelicModel _GenerateDifficultyItems error" .. errorInfo)
      end
    end)

end

function ArchiveRelicModelHotfixer:OnDispose()

end

return ArchiveRelicModelHotfixer