
local MultiV3Hotfixer = Class("MultiV3Hotfixer", HotfixBase)

local function ScanPhotoDictIfAllOtherChannel(photoDict)
  for key, photoInstance in pairs(photoDict) do
    if photoInstance ~= nil then
      local mate = photoInstance.players.mate
      if (not CS.System.String.IsNullOrEmpty(mate.uid)) and mate.sameChannel then
        return false
      end
    end
  end
  return true
end

local function OnClickPhotoFix(self, templateId, photoTypeIdx)
  if not self:_IsStateStable() then
    return
  end
  
  local playerActData = CS.Torappu.Activity.ActMultiV3.ActMultiV3Util.GetPlayerActData(self.m_actId)
  if playerActData == nil then
    return
  end
  local collection = playerActData.collection
  if collection == nil then
    return
  end
  local photo = collection.photo
  if photo == nil then
    return
  end
  local template = photo.template
  if template == nil then
    return
  end
  local ok, photoDict = template:TryGetValue(templateId)
  if (not ok) or photoDict == nil then
    return
  end

  if photoDict.Count == 0 then
    self:_OnClickPhoto(templateId, photoTypeIdx)
    return
  end

  local model = self.m_stateBean.property.Value
  if model == nil then
    return
  end
  
  local albumModel = model.albumModel
  if albumModel == nil then
    return
  end

  local activeAlbum = albumModel.activeAlbum
  if activeAlbum == nil then
    return
  end

  local allOtherChannel = ScanPhotoDictIfAllOtherChannel(photoDict)
  if allOtherChannel then
    self.m_stateBean.input.photoTemplateId = templateId
    self.m_stateBean.input.photoTypeIdx = photoTypeIdx
    self.m_stateBean.input.weekRewardId = activeAlbum.weekRewardId

    self:_AddPhotoSelectState()
  else
    self:_OnClickPhoto(templateId, photoTypeIdx)
  end
end

function MultiV3Hotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Activity.ActMultiV3.ActMultiV3ManualState)
  self:Fix_ex(CS.Torappu.Activity.ActMultiV3.ActMultiV3ManualState, "_OnClickPhoto", function(self, templateId, photoTypeIdx)
    local ok, result = xpcall(OnClickPhotoFix, debug.traceback, self, templateId, photoTypeIdx)
    if not ok then
      LogError("[MultiV3Hotfixer] fix" .. result)
    end
  end)
end

function MultiV3Hotfixer:OnDispose()
end

return MultiV3Hotfixer