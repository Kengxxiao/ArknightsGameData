
local UniEquipSingleEquipViewHotfixer = Class("UniEquipSingleEquipViewHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util

local function RenderFix(self, viewModel, needShining)
  self:Render(viewModel, needShining)
  local avgControllerInst = CS.Torappu.AVG.AVGController.instance
  local isAdvancedEquip = viewModel.data.type == CS.Torappu.UniEquipType.ADVANCED
  local isUnlock = viewModel.isUnlock
  local isNotMax = CS.Torappu.UI.UniEquip.UniEquipUtil.GetEquipMaxLevel() ~= viewModel.equipLevel
  if avgControllerInst.isRunning and isAdvancedEquip and isUnlock and isNotMax then
    avgControllerInst:RegisterExtraGameObject(CS.Torappu.AVG.Consts.KEY_UNIEQUIP_LVL_UP_HOTSPOT, self._hotSpotPart)
  end
end

local function CalcStatusToLevel(self, level)
  local status = self:_CalcStatusToLevel(level)
  
  local targetExp = status.levelInfo.additionExp

  local expItems = self.itemCollectionViewModel.expItems
  local expItemsLength = expItems.Length
  local maxExp = 0
  for i = 0,expItemsLength-1 do
    local expViewModel = expItems[i]
    local gainExp = expViewModel.gainExp
    maxExp = maxExp + gainExp * expViewModel.itemViewModel.itemCount
  end
  
  if maxExp < targetExp then
    return status
  end

  local tempExp = targetExp
  for j = 0,expItemsLength-1 do
    local expViewModel = expItems[j]
    local gainExp = expViewModel.gainExp
    local count = math.floor(tempExp / gainExp)
    local realCount = math.min(count, expViewModel.itemViewModel.itemCount)
    status.expCountArray[j] = realCount
    tempExp = tempExp - realCount * gainExp
  end
  if tempExp == 0 then
    return status
  end

  for k = expItemsLength-1,0,-1 do
    local expViewModel = expItems[k]
    local gainExp = expViewModel.gainExp
    if (status.expCountArray[k] < expViewModel.itemViewModel.itemCount) then
      tempExp = tempExp - gainExp
      status.expCountArray[k] = status.expCountArray[k]+1
      break
    end
  end
  targetExp = targetExp - tempExp
  local levelInfo = self:_CalcTargetLevel(targetExp)
  status.levelInfo = levelInfo
  return status
end

function UniEquipSingleEquipViewHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.UniEquip.UniEquipSingleEquipView)
  xlua.private_accessible(CS.Torappu.UI.CharacterInfo.CharacterLvlupViewModel)

  self:Fix_ex(CS.Torappu.UI.UniEquip.UniEquipSingleEquipView, "Render", function(self, viewModel, needShining)
    local ok, errorInfo = xpcall(RenderFix, debug.traceback, self, viewModel, needShining)
    if not ok then
      eutil.LogError("[UniEquipSingleEquipViewHotfixer] fix" .. errorInfo)
    end
  end)
  self:Fix_ex(CS.Torappu.UI.CharacterInfo.CharacterLvlupViewModel, "_CalcStatusToLevel", function(self, level)
    return CalcStatusToLevel(self, level)
  end)
end

function UniEquipSingleEquipViewHotfixer:OnDispose()
end

return UniEquipSingleEquipViewHotfixer