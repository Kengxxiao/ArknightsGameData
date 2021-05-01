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

function CharacterTransHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.UI.CharacterInfo.CharacterTransView)
    xlua.private_accessible(CS.Torappu.UI.CharacterInfo.CharacterTransView.EffectLayer)
    self:Fix_ex(CS.Torappu.UI.CharacterInfo.CharacterTransView, "Awake", Awake)
end

function CharacterTransHotfixer:OnDispose()
end

return CharacterTransHotfixer