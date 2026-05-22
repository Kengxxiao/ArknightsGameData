


local VSandBoxFurnitureEntityHotfixer = Class("VSandBoxFurnitureEntityHotfixer", HotfixBase)

local function _OnInitFix(self)
  base(self):OnInit()
  local season = CS.Torappu.SandboxV2SeasonType.NONE
  local pd = CS.Torappu.PlayerData.instance

  if pd and pd.data and pd.data.sandboxPerm then
    local perm = pd.data.sandboxPerm
    local topicId = self._topicId

    if topicId and topicId ~= "" and perm.template and perm.template.sandboxV2TemplateData then
      local success, playerData = perm.template.sandboxV2TemplateData:TryGetValue(topicId)
      if success and playerData and playerData.main and playerData.main.map and playerData.main.map.season then
        season = playerData.main.map.season.type
      end
    end
  end


  if season == CS.Torappu.SandboxV2SeasonType.DRY then
    self.m_triggerName = "drySeason"
  elseif season == CS.Torappu.SandboxV2SeasonType.RAINY then
    self.m_triggerName = "rainySeason"
  else
    self.m_triggerName = "normalSeason"
  end
end

function VSandBoxFurnitureEntityHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Building.Vault.VFurnitureEntity)
  xlua.private_accessible(CS.Torappu.Building.Vault.VSandBoxFurnitureEntity)

  self:Fix_ex(CS.Torappu.Building.Vault.VSandBoxFurnitureEntity, "OnInit", function(self)
    local ok, errorInfo = xpcall(_OnInitFix, debug.traceback, self)
    if not ok then
      LogError("[VSandBoxFurnitureEntityHotfixer] _OnInitFix fix: " .. tostring(errorInfo))
    end
  end)
end

return VSandBoxFurnitureEntityHotfixer
