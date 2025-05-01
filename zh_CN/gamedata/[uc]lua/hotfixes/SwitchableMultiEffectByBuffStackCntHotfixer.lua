local MathUtil = CS.Torappu.MathUtil
local FP = CS.Torappu.FP
local BattleController = CS.Torappu.Battle.BattleController
local Vector3 = CS.UnityEngine.Vector3
local ObjectPtrWrap = nil


local SwitchableMultiEffectByBuffStackCntHotfixer = Class("SwitchableMultiEffectByBuffStackCntHotfixer", HotfixBase)

local function EnsureObjectPtrWrap()
  if ObjectPtrWrap == nil then
    local genericMethod = xlua.get_generic_method(CS.Torappu.ObjectPtr, "Wrap")
    ObjectPtrWrap = genericMethod(CS.Torappu.Battle.Effects.Effect)
  end
end
function SwitchableMultiEffectByBuffStackCntHotfixer:OnInit()
  xlua.private_accessible(typeof(CS.Torappu.Battle.Effects.SwitchableMultiEffectByBuffStackCnt))
  self:Fix(typeof(CS.Torappu.Battle.Effects.SwitchableMultiEffectByBuffStackCnt), "_UpdateEffectWithBuffCnt", function(inst)
    local owner = inst.owner:Lock()
    if owner == nil then
      return
    end

    local stackCnt = owner:GetBuffStackCount(inst._buffKey)
    local validIdx = -1
    for i = 1, inst._effects.Count do
      local effectData = inst._effects[i-1]
      local lhs = FP(stackCnt)
      local rhs = FP(effectData.stackCnt)
      if MathUtil.CompareFP(lhs, rhs, effectData.compareType) then
        validIdx = i-1
        break
      end
    end

    EnsureObjectPtrWrap()

    if validIdx >= 0 then
      local newEffect = nil
      local effectData = inst._effects[validIdx]
      if inst.m_stackEffects == nil then
        inst.m_stackEffects = {}
        newEffect = BattleController.instance:CreateEffect(effectData.effect, owner, owner, Vector3(owner.faceVector.x, owner.faceVector.y, 0))
        local effectPtr = ObjectPtrWrap(newEffect)
        inst.m_stackEffects[validIdx] = effectPtr
      else
        local flag, _ = inst.m_stackEffects:TryGetValue(validIdx)
        if not flag then
          newEffect = BattleController.instance:CreateEffect(effectData.effect, owner, owner, Vector3(owner.faceVector.x, owner.faceVector.y, 0))
          local effectPtr = ObjectPtrWrap(newEffect)
          inst.m_stackEffects[validIdx] = effectPtr
        end
      end

      for idx, ptr in pairs(inst.m_stackEffects) do
        if ptr.isValid then
          ptr:Lock():SetPausedByOthers(idx ~= validIdx)
        end
      end

      inst.effect:SetPausedByOthers(true)
    else
      if inst.m_stackEffects ~= nil then
        for idx, ptr in pairs(inst.m_stackEffects) do
          if ptr.isValid then
            ptr:Lock():SetPausedByOthers(true)
          end
        end
      end
      inst.effect:SetPausedByOthers(false)
    end
  end)
end

return SwitchableMultiEffectByBuffStackCntHotfixer