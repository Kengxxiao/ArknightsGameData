
local SandboxV3BuildSaveManagerHotfixer = Class("SandboxV3BuildSaveManagerHotfixer", HotfixBase)
local SandboxV3BuildSaveManager = CS.Torappu.Battle.SandboxV3.SandboxV3BuildSaveManager
local Map = CS.Torappu.Battle.Map

local function _FinishOtherSlotChars(character, tile)
  local enumerator = tile.slotEnumerator
  while enumerator:MoveNext() do
    local ptr = enumerator.Current
    if ptr.isValid then
      local c = ptr:Lock()
      if c ~= nil and c.alive and c ~= character and c.unfinished then
        c:FinishWithNoReason()
      end
    end
  end
  enumerator:Dispose()
end

local function _CleanupOverlapping()
  local map = Map.instance
  if map == nil then return end
  local h, w = map.height, map.width
  for row = 0, h - 1 do
    for col = 0, w - 1 do
      local tile = map:GetTile(row, col)
      if tile ~= nil and tile.buildSlotsOverlapped then
        local character = tile:GetCharacter()
        if character ~= nil then
          _FinishOtherSlotChars(character, tile)
        end
      end
    end
  end
end

local function _DoSyncHotfix(self)
  local bm = self.m_buildManager
  bm:BeginSyncing()
  self:_RefreshTrap()
  _CleanupOverlapping()
  self:_RefreshAnimal()
  self:_RefreshDeck()
  self:_RefreshRes()
  bm:EndSyncing()
end

function SandboxV3BuildSaveManagerHotfixer:OnInit()
  if HOTFIX_ENABLE then
    if xlua and xlua.private_accessible then
      xlua.private_accessible(SandboxV3BuildSaveManager)
    end
    self:Fix_ex(SandboxV3BuildSaveManager, "_DoSync", _DoSyncHotfix)
  end
end

return SandboxV3BuildSaveManagerHotfixer
