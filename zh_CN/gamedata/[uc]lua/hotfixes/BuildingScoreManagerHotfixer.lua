

local BuildingScoreManagerHotfixer = Class("BuildingScoreManagerHotfixer", HotfixBase)

local BSM = CS.Torappu.Battle.BuildingScoreManager
local BBT = CS.Torappu.SandboxV3BaseBuildType
local Map = CS.Torappu.Battle.Map
local BPS = CS.Torappu.Battle.SandboxV3.BuildPlaceTypeScore
local BT = BSM.BuildingType
local SandboxV3BuildUtils = CS.Torappu.Battle.SandboxV3.SandboxV3BuildUtils
local SandboxV3BuildScoreType = CS.Torappu.SandboxV3BuildScoreType
local BlackboardKeys = CS.Torappu.BlackboardKeys
local SandboxConstsEnemy = CS.Torappu.Battle.Sandbox.SandboxConsts.ENEMY
local BattleInOut = CS.Torappu.Battle.BattleInOut
local RuneTable = CS.Torappu.RuneTable




local function toEnumInt(f)
  if type(f) == "number" then
    return f
  end
  local n = tonumber(f)
  if n then
    return n
  end
  if CS and CS.System and CS.System.Convert then
    local ok, v = pcall(function()
      return CS.System.Convert.ToInt32(f)
    end)
    if ok then
      return v
    end
  end
  return 0
end

local function hasTypeFlag(flags, bitMask)
  local f = toEnumInt(flags)
  local b = toEnumInt(bitMask)
  if b == 0 then
    return false
  end
  return (f & b) ~= 0
end



local function zoneRootRowCol(gridPos)
  local ok, zoneTile = Map.instance:TryGetTile(gridPos)
  if not ok or zoneTile == nil then
    return gridPos.row, gridPos.col
  end
  local zoneChar = zoneTile:GetCharacter()
  if zoneChar ~= nil and zoneChar.alive and zoneChar.rootTile ~= nil then
    local rp = zoneChar.rootTile.gridPosition
    return rp.row, rp.col
  end
  return gridPos.row, gridPos.col
end





local function tryMarkSeenPos(seen, r, c)
  local t = seen[r]
  if not t then
    t = {}
    seen[r] = t
  end
  if t[c] then
    return false
  end
  t[c] = true
  return true
end



local function CountUniqueZoneRoots(list)
  if list == nil or list.Count == 0 then
    return 0
  end
  local seen = {}
  local n = 0
  for i = 0, list.Count - 1 do
    local g = list[i]
    if g == nil then
      if not seen._nilListPos then
        seen._nilListPos = true
        n = n + 1
      end
    else
      local r, c = zoneRootRowCol(g)
      if tryMarkSeenPos(seen, r, c) then
        n = n + 1
      end
    end
  end
  return n
end

local function sumDictIntVals(dict)
  if dict == nil then
    return 0
  end
  local s = 0
  local iter = dict:GetEnumerator()
  while iter:MoveNext() do
    s = s + iter.Current.Value
  end
  return s
end

local function _searchTileNeighborsImpl(self, row, col)
  local map2 = self.m_tileScoreMap
  local p = map2:GetValue(row, col)
  p = self:_CalculateNeighborCount(row + 1, col, p)
  p = self:_CalculateNeighborCount(row - 1, col, p)
  p = self:_CalculateNeighborCount(row, col + 1, p)
  p = self:_CalculateNeighborCount(row, col - 1, p)
  map2:SetValue(p, row, col)
  self:_RefreshNeighborTile(row + 1, col)
  self:_RefreshNeighborTile(row - 1, col)
  self:_RefreshNeighborTile(row, col + 1)
  self:_RefreshNeighborTile(row, col - 1)
  self:_RefreshNeighborTile(row + 1, col + 1)
  self:_RefreshNeighborTile(row - 1, col - 1)
  self:_RefreshNeighborTile(row - 1, col + 1)
  self:_RefreshNeighborTile(row + 1, col - 1)
end

local function _SearchTileNeighborsHotfix(self, row, col)
  local ok, err = pcall(_searchTileNeighborsImpl, self, row, col)
  if not ok and LogError then
    LogError("[BuildingScoreManagerHotfixer] _SearchTileNeighbors: " .. tostring(err))
  end
end

local function _refreshTileScoreRecordImpl(self, character, buildingType)
  local r, c = character.row, character.col
  local b = buildingType
  local isCross = false
  if hasTypeFlag(b, BT.Road) then
    self:_RefreshTileRoadCross(r, c)
    self:_RefreshTileRoadCross(r + 1, c)
    self:_RefreshTileRoadCross(r - 1, c)
    self:_RefreshTileRoadCross(r, c + 1)
    self:_RefreshTileRoadCross(r, c - 1)
    self:_RefreshTileRoadCross(r + 2, c)
    self:_RefreshTileRoadCross(r - 2, c)
    self:_RefreshTileRoadCross(r, c + 2)
    self:_RefreshTileRoadCross(r, c - 2)
    self:_RefreshTileRoadCross(r + 1, c + 1)
    self:_RefreshTileRoadCross(r - 1, c - 1)
    self:_RefreshTileRoadCross(r - 1, c + 1)
    self:_RefreshTileRoadCross(r + 1, c - 1)
    isCross = true
  end
  if hasTypeFlag(b, BT.Canal) then
    self:_RefreshTileCanalCross(r, c)
    self:_RefreshTileCanalCross(r + 1, c)
    self:_RefreshTileCanalCross(r - 1, c)
    self:_RefreshTileCanalCross(r, c + 1)
    self:_RefreshTileCanalCross(r, c - 1)
    isCross = true
  end
  if hasTypeFlag(b, BT.Railway) then
    isCross = true
  end
  if isCross then
    self:_RefreshZone(r + 1, c)
    self:_RefreshZone(r - 1, c)
    self:_RefreshZone(r, c + 1)
    self:_RefreshZone(r, c - 1)
    self:_RefreshZone(r + 1, c + 1)
    self:_RefreshZone(r - 1, c - 1)
    self:_RefreshZone(r - 1, c + 1)
    self:_RefreshZone(r + 1, c - 1)
  else
    self:_RefreshZone(r + 1, c)
    self:_RefreshZone(r - 1, c)
    self:_RefreshZone(r, c + 1)
    self:_RefreshZone(r, c - 1)
    self:_RefreshZone(r + 1, c + 1)
    self:_RefreshZone(r - 1, c - 1)
    self:_RefreshZone(r - 1, c + 1)
    self:_RefreshZone(r + 1, c - 1)
  end
  self:_RefreshZone(r, c)
end

local function _RefreshTileScoreRecordHotfix(self, character, buildingType)
  local ok, err = pcall(_refreshTileScoreRecordImpl, self, character, buildingType)
  if not ok and LogError then
    LogError("[BuildingScoreManagerHotfixer] _RefreshTileScoreRecord: " .. tostring(err))
  end
end

local function _GetBuildPlaceScoreHotfix(self, scoreInfo)
  local roadScore = self.scoreRecord.roadCross.Count * self.ROAD_SCORE
  if roadScore ~= 0 then
    scoreInfo.placeScore:Add(BBT.ROAD:ToString(), roadScore)
  end
  local canalScore = self.scoreRecord.canalCross.Count * self.CANAL_SCORE
  if canalScore ~= 0 then
    scoreInfo.placeScore:Add(BBT.CANAL:ToString(), canalScore)
  end
  local railwayScore = self.railWayCount * self.RAILWAY_SCORE
  if railwayScore ~= 0 then
    scoreInfo.placeScore:Add(BBT.RAILWAY:ToString(), railwayScore)
  end
  local agCount = CountUniqueZoneRoots(self.scoreRecord.agriculturalZones)
  local productionScore = agCount * self.PRODUCTION_SCORE
  if productionScore ~= 0 then
    scoreInfo.placeScore:Add(BBT.PRODUCTION:ToString(), productionScore)
  end
  local houseScore = self.scoreRecord.residentialZones.Count * self.HOUSE_SCORE
  if houseScore ~= 0 then
    scoreInfo.placeScore:Add(BBT.HOUSE:ToString(), houseScore)
  end
  local indCount = CountUniqueZoneRoots(self.scoreRecord.industrialZones)
  local powerScore = indCount * self.POWER_SCORE
  if powerScore ~= 0 then
    scoreInfo.placeScore:Add(BBT.POWER:ToString(), powerScore)
  end
  local beautyScore = self.scoreRecord.decorations.Count * self.BEAUTY_SCORE
  if beautyScore ~= 0 then
    scoreInfo.placeScore:Add(BBT.BEAUTY:ToString(), beautyScore)
  end
  return scoreInfo
end

local function _GetBuildPlaceScoreListHotfix(self, scoreList)
  local b = self.m_buildManager
  local rd = b.BuildRuleData
  local a = BPS()
  a.count = self.scoreRecord.roadCross.Count
  a.score = self.scoreRecord.roadCross.Count * self.ROAD_SCORE
  a.sortId = rd[BBT.ROAD].sortId
  a.txt = rd[BBT.ROAD].extraScoreDesc
  scoreList:Add(a)
  a = BPS()
  a.count = self.scoreRecord.canalCross.Count
  a.score = self.scoreRecord.canalCross.Count * self.CANAL_SCORE
  a.sortId = rd[BBT.CANAL].sortId
  a.txt = rd[BBT.CANAL].extraScoreDesc
  scoreList:Add(a)
  a = BPS()
  a.count = self.railWayCount
  a.score = self.railWayCount * self.RAILWAY_SCORE
  a.sortId = rd[BBT.RAILWAY].sortId
  a.txt = rd[BBT.RAILWAY].extraScoreDesc
  scoreList:Add(a)
  local agC = CountUniqueZoneRoots(self.scoreRecord.agriculturalZones)
  a = BPS()
  a.count = agC
  a.score = agC * self.PRODUCTION_SCORE
  a.sortId = rd[BBT.PRODUCTION].sortId
  a.txt = rd[BBT.PRODUCTION].extraScoreDesc
  scoreList:Add(a)
  a = BPS()
  a.count = self.scoreRecord.residentialZones.Count
  a.score = self.scoreRecord.residentialZones.Count * self.HOUSE_SCORE
  a.sortId = rd[BBT.HOUSE].sortId
  a.txt = rd[BBT.HOUSE].extraScoreDesc
  scoreList:Add(a)
  local indC2 = CountUniqueZoneRoots(self.scoreRecord.industrialZones)
  a = BPS()
  a.count = indC2
  a.score = indC2 * self.POWER_SCORE
  a.sortId = rd[BBT.POWER].sortId
  a.txt = rd[BBT.POWER].extraScoreDesc
  scoreList:Add(a)
  a = BPS()
  a.count = self.scoreRecord.decorations.Count
  a.score = self.scoreRecord.decorations.Count * self.BEAUTY_SCORE
  a.sortId = rd[BBT.BEAUTY].sortId
  a.txt = rd[BBT.BEAUTY].extraScoreDesc
  scoreList:Add(a)
  return scoreList
end

local function _CalculateScoreHotfix(self)
  local score = 0
  score = score + sumDictIntVals(self.scoreRecord.wonders)
  score = score + sumDictIntVals(self.scoreRecord.npcs)
  score = score + self.scoreRecord.debris.Count * self.DEBRIS_SCORE
  do
    local iterB = self.scoreRecord.buildingScores:GetEnumerator()
    while iterB:MoveNext() do
      score = score + iterB.Current.Value
    end
  end
  score = score + self.scoreRecord.roadCross.Count * self.ROAD_SCORE
  score = score + self.scoreRecord.canalCross.Count * self.CANAL_SCORE
  score = score + self.railWayCount * self.RAILWAY_SCORE
  local agC = CountUniqueZoneRoots(self.scoreRecord.agriculturalZones)
  score = score + agC * self.PRODUCTION_SCORE
  local indC = CountUniqueZoneRoots(self.scoreRecord.industrialZones)
  score = score + indC * self.POWER_SCORE
  score = score + self.scoreRecord.residentialZones.Count * self.HOUSE_SCORE
  score = score + self.scoreRecord.decorations.Count * self.BEAUTY_SCORE
  return score
end

local function dictTryAddStringInt(dict, key, val)
  if dict == nil or key == nil then
    return
  end
  if dict:ContainsKey(key) then
    return
  end
  dict:Add(key, val)
end

local function _onGameStartImpl(self, arg)
  local scoreRecord = self.scoreRecord
  local bm = self.m_buildManager
  scoreRecord.wonders:Clear()
  local inputWonders = bm.input.wonder
  local buildScoreData = bm.dataV3.buildScoreData
  if buildScoreData ~= nil then
    local iter = buildScoreData:GetEnumerator()
    while iter:MoveNext() do
      local kv = iter.Current
      local key = kv.Key
      local scoreData = kv.Value
      if scoreData ~= nil and scoreData.paramType == SandboxV3BuildScoreType.LEVEL then
        local score = 0
        if inputWonders ~= nil and inputWonders:Contains(key) then
          score = scoreData.buildScore
        end
        scoreRecord.wonders:Add(key, score)
      end
    end
  end
  scoreRecord.debris:Clear()
  local battleSaves = bm.input.battleSaves
  if battleSaves ~= nil and battleSaves.debris ~= nil then
    local debrisList = battleSaves.debris
    for i = 0, debrisList.Count - 1 do
      scoreRecord.debris:Add(debrisList[i])
    end
  end
  scoreRecord.npcs:Clear()
  local extraNpcs = bm.input.npcInputs
  if extraNpcs ~= nil then
    for i = 0, extraNpcs.Count - 1 do
      local npcTrap = extraNpcs[i]
      local npcCfgId = npcTrap.npcCfgId
      if npcCfgId ~= nil and npcCfgId ~= "" then
        local ok, npcScore = SandboxV3BuildUtils.GetNpcScore(npcCfgId, bm.dataV3)
        if ok then
          dictTryAddStringInt(scoreRecord.npcs, npcTrap.trapId, npcScore)
        end
      end
    end
  end
  local runes = BattleInOut.instance.input.runeInput
  if runes == nil then
    self:_RefreshScore()
    return
  end
  local packList = runes.runes
  if packList == nil and xlua and xlua.cast then
    pcall(function()
      xlua.cast(runes, RuneTable.PackedRuneInput)
      packList = runes.runes
    end)
  end
  if packList ~= nil then
    for pi = 0, packList.Count - 1 do
      local pack = packList[pi]
      if pack ~= nil and pack.runes ~= nil then
        for ri = 0, pack.runes.Count - 1 do
          local rune = pack.runes[ri]
          if rune ~= nil then
            local okTag, runeTag = rune.blackboard:TryGetString(BlackboardKeys.RUNE_TAG)
            if okTag and runeTag == SandboxConstsEnemy then
              local okNpc, npcId = rune.blackboard:TryGetString(SandboxConstsEnemy)
              if okNpc and npcId ~= nil and npcId ~= "" then
                local okScore, npcScore = SandboxV3BuildUtils.GetNpcScore(npcId, bm.dataV3)
                if okScore then
                  dictTryAddStringInt(scoreRecord.npcs, npcId, npcScore)
                end
              end
            end
          end
        end
      end
    end
  end
  self:_RefreshScore()
end

local function _OnGameStartHotfix(self, arg)
  local ok, err = pcall(_onGameStartImpl, self, arg)
  if not ok and LogError then
    LogError("[BuildingScoreManagerHotfixer] _OnGameStart: " .. tostring(err))
  end
end

function BuildingScoreManagerHotfixer:OnInit()
  if HOTFIX_ENABLE then
    if xlua and xlua.private_accessible then
      xlua.private_accessible(BSM)
    end
    self:Fix_ex(BSM, "_SearchTileNeighbors", _SearchTileNeighborsHotfix)
    self:Fix_ex(BSM, "_RefreshTileScoreRecord", _RefreshTileScoreRecordHotfix)
    self:Fix_ex(BSM, "GetBuildPlaceScore", _GetBuildPlaceScoreHotfix)
    self:Fix_ex(BSM, "_GetBuildPlaceScore", _GetBuildPlaceScoreListHotfix)
    self:Fix_ex(BSM, "_CalculateScore", _CalculateScoreHotfix)
    self:Fix_ex(BSM, "_OnGameStart", _OnGameStartHotfix)
  end
end

function BuildingScoreManagerHotfixer:OnDispose()
end

return BuildingScoreManagerHotfixer
