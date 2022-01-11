 local xutil = require('xlua.util')
 local eutil = CS.Torappu.Lua.Util


local CharacterTransHotfixer = Class("CharacterTransHotfixer", HotfixBase)

local Mathf = CS.UnityEngine.Mathf

local function _LoadShader()
  local prefab = CS.Torappu.UI.UIAssetLoader.LoadPrefab("CharacterTransHotfix/image_ui_rtps")
  if prefab == nil then
    return nil
  end
  local image = prefab:GetComponent("UnityEngine.UI.Image")
  if image == nil then
    return nil
  end
  local mat = image.material
  if mat == nil then
    return nil
  end
  return mat.shader
end

local function _SetupLayer(layer)
  if layer == nil or layer._layerImage == nil then
    return
  end
  if layer.m_rt ~= nil then
    return
  end
  local layerImage = layer._layerImage
  local rect = layerImage.transform.rect
  local rtWidth = rect.width
  local rtHeight = rect.height
  local rtMaxSize = layer._renderTextureMaxSize
  if rtWidth > rtMaxSize or rtHeight > rtMaxSize then
    local ratio = rtWidth / rtHeight
    if ratio > 1 then
      rtWidth = rtMaxSize
      rtHeight = rtWidth / ratio
    else
      rtHeight = rtMaxSize
      rtWidth = rtHeight * ratio
    end
  end
  local rt = CS.UnityEngine.RenderTexture(Mathf.RoundToInt(rtWidth), Mathf.RoundToInt(rtHeight), 24)
  layer.m_rt = rt
  local camera = layer._layerCamera
  camera.targetTexture = rt
  camera.enabled = true
  layerImage.texture = rt
  layerImage.enabled = true

  local mt = nil
  local shader = _LoadShader()
  if shader ~= nil then
    mt = CS.UnityEngine.Material(shader)
    mt:SetInt("_SrcBlend", layer._srcBlend:GetHashCode())
    mt:SetInt("_DstBlend", layer._dstBlend:GetHashCode())
  end

  layer.m_mt = mt
  layerImage.material = mt

end

local function _SetupEffectLayers(self)
  for i=0, self._effectLayers.Length - 1 do 
    _SetupLayer(self._effectLayers[i])
  end
end

local function Awake(self)
  local ok, error = xpcall(_SetupEffectLayers, debug.traceback, self)
  if not ok then
    CS.Torappu.Lua.Util.LogHotfixError(error)
  end

  self:Awake()
end

local function _CheckIfMemberChanged(self, prevMember)
  local ret = self:CheckIfMemberChanged(prevMember)
  if ret then
    return true
  end
  if prevMember == nil or prevMember.charInstId ~= 1 then
    return ret
  end
  if self.m_editModel == nil or self.m_editModel.charInstId ~= 1 then
    return ret
  end
  local curCount = 0
  local prevCount = 0
  local curTmpls = self.m_editModel.m_tmpls
  if curTmpls ~= nil then
    curCount = curTmpls.Count
  end
  if prevMember.tmpl ~= nil then
    prevCount = prevMember.tmpl.Count
  end
  if curCount ~= prevCount then
    return true
  end

  return ret
end

local function _InitMedalBtn(self)
  self:_InitIfNot()
  if self._countPart ~= nil then
    self._countPart.horizontalOverflow = CS.UnityEngine.HorizontalWrapMode.Overflow
  end
end

function CharacterTransHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.UI.CharacterInfo.CharacterTransView)
    xlua.private_accessible(CS.Torappu.UI.CharacterInfo.CharacterTransView.EffectLayer)
    self:Fix_ex(CS.Torappu.UI.CharacterInfo.CharacterTransView, "Awake", Awake)

    xlua.private_accessible(CS.Torappu.UI.Squad.SquadItemStruct)
    xlua.private_accessible(CS.Torappu.UI.UISquadEditCharModel)
    self:Fix_ex(CS.Torappu.UI.Squad.SquadItemStruct, "CheckIfMemberChanged", _CheckIfMemberChanged)

    xlua.private_accessible(CS.Torappu.UI.Medal.MedalEntryListBtn)
    self:Fix_ex(CS.Torappu.UI.Medal.MedalEntryListBtn, "_InitIfNot", _InitMedalBtn)
end

function CharacterTransHotfixer:OnDispose()
end

return CharacterTransHotfixer