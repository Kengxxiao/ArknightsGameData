
local RoguelikeTopicHotfixer = Class("RoguelikeTopicHotfixer", HotfixBase)


local function _RenderInitSquadWithDifficultyFix(self, viewModel)
  repeat
    if viewModel == nil or viewModel.initialRelic == nil or viewModel.initialRelic.topicId == nil then
      break;
    end
    local topicId = viewModel.initialRelic.topicId;
    if topicId ~= "rogue_4" then
      break;
    end

    local finder = CS.Torappu.UI.UIPageFinder();
    if finder == nil then
      LogError("[RoguelikeTopicHotfixer] fix _RenderInitSquadWithDifficulty error: cannot get page finder.");
      break;
    end
    local pageInterface = finder:Current(self);
    if pageInterface == nil then
      LogError("[RoguelikeTopicHotfixer] fix _RenderInitSquadWithDifficulty error: cannot find interface.");
      break;
    end
    
    local page = pageInterface:GetAssetLoader();
    if page == nil then
      LogError("[RoguelikeTopicHotfixer] fix _RenderInitSquadWithDifficulty error: cannot get assetloader.");
      break;
    end
    local atlasObject = page:LoadAsset(CS.Torappu.ResourceUrls.GetRL04DifficultyIconAtlasPath(topicId));
    if atlasObject == nil then
      LogError("[RoguelikeTopicHotfixer] fix _RenderInitSquadWithDifficulty error: cannot find atlas object.");
      break;
    end
    if atlasObject:GetType() ~= typeof(CS.Torappu.UI.UIAtlasObject) then
      LogError("[RoguelikeTopicHotfixer] fix _RenderInitSquadWithDifficulty error: atlas object type error.");
      break;
    end

    self._bandRankAtlasObject = atlasObject;
  until(true);

  self:_RenderInitSquadWithDifficulty(viewModel);
end

function RoguelikeTopicHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.Roguelike.RoguelikeMenuInitSquadWithDifficultyObject);
  self:Fix_ex(CS.Torappu.UI.Roguelike.RoguelikeMenuInitSquadWithDifficultyObject, "_RenderInitSquadWithDifficulty", function(self, viewModel)
    local ok, errorInfo = xpcall(_RenderInitSquadWithDifficultyFix, debug.traceback, self, viewModel)
    if not ok then
      LogError("[RoguelikeTopicHotfixer] fix _RenderInitSquadWithDifficulty error: " .. errorInfo)
    end
  end)
end

function RoguelikeTopicHotfixer:OnDispose()
end

return RoguelikeTopicHotfixer;