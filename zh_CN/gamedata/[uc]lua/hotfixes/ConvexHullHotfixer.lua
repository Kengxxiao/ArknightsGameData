


local ConvexHullHotfixer = Class("ConvexHullHotfixer", HotfixBase)

local Vector2 = CS.UnityEngine.Vector2
local LARGE_EPS = 1e-5

local function _GT(a, b) return a > b + LARGE_EPS end
local function _LT(a, b) return a < b - LARGE_EPS end
local function _Equals(a, b) return math.abs(a - b) <= LARGE_EPS end
local function _GE(a, b) return a >= b - LARGE_EPS end

local function _SignedAngle(fromX, fromY, toX, toY)
  local cross = fromX * toY - fromY * toX
  local dot = fromX * toX + fromY * toY
  return math.atan(cross, dot) * (180 / math.pi)
end


local function _Swap(list, i, j)
  local tmp = list[i]
  list[i] = list[j]
  list[j] = tmp
end

local function _QSort(list, low, high, comparison)
  if low >= high then return end
  local l = low
  local h = high
  local mid = low + math.floor((high - low) / 2)
  local pivot = list[mid]
  while true do
    while l < high and comparison(list[l], pivot) < 0 do l = l + 1 end
    while h > low and comparison(pivot, list[h]) < 0 do h = h - 1 end
    if l <= h then
      _Swap(list, l, h)
      l = l + 1
      h = h - 1
    else
      break
    end
  end
  if low < h then _QSort(list, low, h, comparison) end
  if l < high then _QSort(list, l, high, comparison) end
end

local function _LegacySort(list, comparison)
  if list.Count <= 1 then return end
  _QSort(list, 0, list.Count - 1, comparison)
end

local function _Cross(a, b, c)
  return (b.x - a.x) * (c.y - a.y) - (c.x - a.x) * (b.y - a.y)
end

local function _DoCalculateHull(self, input, resizeRatio, result)
  result:AddRange(input)

  
  local originI = 0
  for vertI = 1, result.Count - 1 do
    local vi = result[vertI]
    local oi = result[originI]
    if _LT(vi.x, oi.x) then
      originI = vertI
    elseif _Equals(vi.x, oi.x) and _GE(vi.y, oi.y) then
      originI = vertI
    end
  end

  local origin = result[originI]
  local originX = origin.x
  local originY = origin.y
  result:RemoveAt(originI)

  
  local axisX = -0.001
  local axisY = -1

  _LegacySort(result, function(lhs, rhs)
    
    local ldx = lhs.x - originX
    local ldy = lhs.y - originY
    local lmag = math.sqrt(ldx * ldx + ldy * ldy)
    if lmag > 1e-10 then ldx = ldx / lmag; ldy = ldy / lmag end

    local rdx = rhs.x - originX
    local rdy = rhs.y - originY
    local rmag = math.sqrt(rdx * rdx + rdy * rdy)
    if rmag > 1e-10 then rdx = rdx / rmag; rdy = rdy / rmag end

    local lAngle = _SignedAngle(ldx, ldy, axisX, axisY)
    local rAngle = _SignedAngle(rdx, rdy, axisX, axisY)

    
    if _GT(rAngle, lAngle) then return 1 end
    if _LT(rAngle, lAngle) then return -1 end

    
    local lDist = (lhs.x - originX) * (lhs.x - originX) + (lhs.y - originY) * (lhs.y - originY)
    local rDist = (rhs.x - originX) * (rhs.x - originX) + (rhs.y - originY) * (rhs.y - originY)
    if _LT(lDist, rDist) then return -1 end
    if _GT(lDist, rDist) then return 1 end
    return 0
  end)

  result:Insert(0, origin)

  
  local maxW = 0
  local maxH = 0
  local baseX = result[0].x
  local baseY = result[0].y
  for vertI = 1, result.Count - 1 do
    local vi = result[vertI]
    local dx = math.abs(vi.x - baseX)
    local dy = math.abs(vi.y - baseY)
    if dx > maxW then maxW = dx end
    if dy > maxH then maxH = dy end
  end

  local resizeScaleX, resizeScaleY
  if maxW - resizeRatio.x < 0 then
    resizeScaleX = 0.1
  else
    resizeScaleX = resizeRatio.x / maxW
  end
  if maxH - resizeRatio.y < 0 then
    resizeScaleY = 0.1
  else
    resizeScaleY = resizeRatio.y / maxH
  end

  
  local vertStack = { result[0], result[1], result[2] }
  for vertI = 3, result.Count - 1 do
    while #vertStack > 2 and _Cross(vertStack[#vertStack - 1], vertStack[#vertStack], result[vertI]) <= 0 do
      table.remove(vertStack)
    end
    vertStack[#vertStack + 1] = result[vertI]
  end

  result:Clear()
  for _, v in ipairs(vertStack) do
    result:Add(v)
  end

  return result, Vector2(resizeScaleX, resizeScaleY)
end

function ConvexHullHotfixer:OnInit()
  if HOTFIX_ENABLE then
    if xlua and xlua.private_accessible then
      xlua.private_accessible(CS.Torappu.ConvexHull)
    end

    self:Fix_ex(CS.Torappu.ConvexHull, "_DoCalculateHull", _DoCalculateHull)
  end
end

function ConvexHullHotfixer:OnDispose()
end

return ConvexHullHotfixer
