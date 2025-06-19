
local RoguelikeMenuZoneViewModelHotfixer = Class("RoguelikeMenuZoneViewModelHotfixer", HotfixBase)

local function _LoadDataFix(self, topicId)
  if self == nil or self.fusionModel == nil then
    return;
  end
  self.fusionModel.fusionId = nil;
  self:LoadData(topicId);
end

function RoguelikeMenuZoneViewModelHotfixer:OnInit()
  xlua.private_accessible(typeof(CS.Torappu.UI.Roguelike.RoguelikeMenuZoneViewModel));
  self:Fix_ex(CS.Torappu.UI.Roguelike.RoguelikeMenuZoneViewModel, "LoadData", function(self, topicId)
    local ok, errorInfo = xpcall(_LoadDataFix, debug.traceback, self, topicId);
    if not ok then
      LogError("[Roguelike Menu] RoguelikeMenuZoneViewModel fix error: " .. errorInfo)
      self:LoadData(topicId)
    end
  end)
end

return RoguelikeMenuZoneViewModelHotfixer