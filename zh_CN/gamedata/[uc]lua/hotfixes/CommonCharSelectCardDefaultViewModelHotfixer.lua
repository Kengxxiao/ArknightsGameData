

local CommonCharSelectCardDefaultViewModelHotfixer = Class("CommonCharSelectCardDefaultViewModelHotfixer", HotfixBase)

local function OnEquipChangedFix(self, newEquipId)
  
  local charQuery = CS.Torappu.CharQuery.TemplateChar(self.m_basicInfo.charId, self.m_basicInfo.tmplId);

  local evolvePhase = self.m_basicInfo.evolvePhase;
  local potentialRank = self.m_basicInfo.potentialRank;
  local level = self.m_basicInfo.level;
  local favorPoint = self.m_basicInfo.favorPoint;

  local equipQueries = nil;
  if not string.isNullOrEmpty(newEquipId) then
    local suc, playerEquip = self.equips:TryGetValue(newEquipId)
    if suc then
      equipQueries = {
        CS.Torappu.CharacterData.UniqueEquipPair(newEquipId, playerEquip.level),
      };
    end
  end

  local attrData = CS.Torappu.DataConvertUtil.AchieveCharAttributes(
      charQuery, evolvePhase, potentialRank, level, favorPoint, equipQueries);
  if attrData ~= nil then
    local patchBuilder = CS.Torappu.UI.BasicCharInfoModel.PatchBuilder();
    patchBuilder.attrData = attrData;
    patchBuilder:BuildTo(self.m_basicInfo);

    local advancedCharInst = CS.Torappu.AdvancedCharacterInst(
        charQuery, level, evolvePhase, potentialRank, equipQueries);
    self.m_attackRange = CS.Torappu.DataConvertUtil.AchieveCharacterAttackRange(advancedCharInst);
  end
end
function  CommonCharSelectCardDefaultViewModelHotfixer:OnInit()
  xlua.private_accessible(typeof(CS.Torappu.UI.TemplateCharSelect.Common.CommonCharSelectCardDefaultViewModel))
  self:Fix_ex(typeof(CS.Torappu.UI.TemplateCharSelect.Common.CommonCharSelectCardDefaultViewModel), "OnEquipChanged", function(self, newEquipId)
    local ok, errorInfo = xpcall(OnEquipChangedFix, debug.traceback, self, newEquipId)
    if not ok then
      LogError("[hotfix] CommonCharSelectCardDefaultViewModel:OnEquipChanged fix error: ".. errorInfo);
      self:OnEquipChanged(newEquipId);
    end
  end);
end

return CommonCharSelectCardDefaultViewModelHotfixer;