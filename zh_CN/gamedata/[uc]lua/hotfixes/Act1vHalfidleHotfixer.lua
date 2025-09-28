
local Act1vHalfidleHotfixer = Class("Act1vHalfidleHotfixer", HotfixBase)
local parentClassPath = CS.Torappu.UI.TemplateCharSelect.Common.CommonCharSelectPoolViewModel
local childClassPath = CS.Torappu.Activity.Act1VHalfIdle.Act1VHalfIdleCharSelectPoolViewModel
local viewModelPath = CS.Torappu.Activity.Act1VHalfIdle.Act1VHalfIdleCharUpgradeViewModel
local function _ResumeFix(self)
  if self:GetType() ~= typeof(childClassPath) then
    self:Resume()
    return
  end
  if self.m_cacheInput == nil or not self.m_cacheInput.synCharWithPlayerData or self.charList == nil then
    return
  end
  for step = 1, self.charList.Count do
    local index = step - 1
    local charViewModel = self.charList[index]
    if charViewModel ~= nil then
      charViewModel:SynWithPlayerData(self.m_cacheInput)
    end
  end
end

local function _LoadDataFix(self, actId, charInstId)
  self:LoadData(actId, charInstId)
  if self.useUpgradeSkillLevelDiscount and self.selectedNormalizedSkillRank >= self.discountNormalizedSkillRank then
    local discountRankItemCostBefore = 0
    local res = false
    res, discountRankItemCostBefore = self:_GetSkillExpToSkillRank(self.discountNormalizedSkillRank)
    local discountRankItemCostAfter = CS.Torappu.Activity.Act1VHalfIdle.Act1VHalfIdleUtil.GetDiscountItemNum(actId, discountRankItemCostBefore)
    local diff = discountRankItemCostBefore - discountRankItemCostAfter
    self.selectedSkillItemCostDiscount = self.selectedSkillItemCost - diff
  elseif self.useUpgradeSkillLevelDiscount then
    self.selectedSkillItemCostDiscount = CS.Torappu.Activity.Act1VHalfIdle.Act1VHalfIdleUtil.GetDiscountItemNum(actId, self.selectedSkillItemCost)
  end
end

local function _SetSelectedNormalizedSkillRankFix(self, targetNormalizedSkillRank)
  local res, itemCost = self:_GetSkillExpToSkillRank(targetNormalizedSkillRank)
  local discountItemCost = itemCost
  if self.useUpgradeSkillLevelDiscount and targetNormalizedSkillRank >= self.discountNormalizedSkillRank then
    local discountRankItemCostBefore = 0
    local res = false
    res, discountRankItemCostBefore = self:_GetSkillExpToSkillRank(self.discountNormalizedSkillRank)
    local discountRankItemCostAfter = CS.Torappu.Activity.Act1VHalfIdle.Act1VHalfIdleUtil.GetDiscountItemNum(self.actId, discountRankItemCostBefore)
    local diff = discountRankItemCostBefore - discountRankItemCostAfter
    discountItemCost = itemCost - diff
  elseif self.useUpgradeSkillLevelDiscount then
    discountItemCost = CS.Torappu.Activity.Act1VHalfIdle.Act1VHalfIdleUtil.GetDiscountItemNum(self.actId, itemCost)
  end
  if targetNormalizedSkillRank <= self.currNormalizedSkillRank or targetNormalizedSkillRank > self.maxNormalizedSkillRank then
    return false
  end
  if self.currSkillExpItemCount < discountItemCost then
    return false
  end
  self.selectedNormalizedSkillRank = targetNormalizedSkillRank
  self.selectedSkillItemCost = itemCost
  self.selectedSkillItemCostDiscount = discountItemCost
  return true
end

local function _SetSelectedNormalizedSkillRankToMaxFix(self)
  if not self.hasSkill then
    return self:SetSelectedNormalizedSkillRank(0)
  end
  local startNormalizedSkillRank = math.min(self.currNormalizedSkillRank + 1, self.maxNormalizedSkillRank)
  local normalizedSkillRank = startNormalizedSkillRank;
  while normalizedSkillRank <= self.maxNormalizedSkillRank do
    local res, itemCost = self:_GetSkillExpToSkillRank(normalizedSkillRank)
    local discountItemCost = itemCost
    if self.useUpgradeSkillLevelDiscount and normalizedSkillRank >= self.discountNormalizedSkillRank then
      local discountRankItemCostBefore = 0
      local res = false
      res, discountRankItemCostBefore = self:_GetSkillExpToSkillRank(self.discountNormalizedSkillRank)
      local discountRankItemCostAfter = CS.Torappu.Activity.Act1VHalfIdle.Act1VHalfIdleUtil.GetDiscountItemNum(self.actId, discountRankItemCostBefore)
      local diff = discountRankItemCostBefore - discountRankItemCostAfter
      discountItemCost = itemCost - diff
    elseif self.useUpgradeSkillLevelDiscount then
      discountItemCost = CS.Torappu.Activity.Act1VHalfIdle.Act1VHalfIdleUtil.GetDiscountItemNum(self.actId, itemCost)
    end
    if self.currSkillExpItemCount < discountItemCost then
      break
    end
    normalizedSkillRank = normalizedSkillRank + 1
  end
  local targetNormalizedSkillRank = math.max(normalizedSkillRank - 1, startNormalizedSkillRank)
  return self:SetSelectedNormalizedSkillRank(targetNormalizedSkillRank)
end

function Act1vHalfidleHotfixer:OnInit()
  xlua.private_accessible(parentClassPath)
  self:Fix_ex(parentClassPath, "Resume", function(self)
    local ok, res = xpcall(_ResumeFix, debug.traceback, self)
    if not ok then
      LogError("[Act1vHalfidleHotfixer] fix fail " .. res)
    end
  end)
  xlua.private_accessible(viewModelPath)
  self:Fix_ex(viewModelPath, "LoadData", function(self, actId, charInstId)
    local ok, res = xpcall(_LoadDataFix, debug.traceback, self, actId, charInstId)
    if not ok then
      LogError("[Act1vHalfidleHotfixer] fix fail " .. res)
    end
  end)
  self:Fix_ex(viewModelPath, "SetSelectedNormalizedSkillRank", function(self, targetNormalizedSkillRank)
    local ok, res = xpcall(_SetSelectedNormalizedSkillRankFix, debug.traceback, self, targetNormalizedSkillRank)
    if not ok then
      LogError("[Act1vHalfidleHotfixer] fix fail " .. res)
      return false
    end
    return res
  end)
  self:Fix_ex(viewModelPath, "SetSelectedNormalizedSkillRankToMax", function(self)
    local ok, res = xpcall(_SetSelectedNormalizedSkillRankToMaxFix, debug.traceback, self)
    if not ok then
      LogError("[Act1vHalfidleHotfixer] fix fail " .. res)
      return false
    end
    return res
  end)
end

function Act1vHalfidleHotfixer:OnDispose()
end

return Act1vHalfidleHotfixer
