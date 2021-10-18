
 local xutil = require('xlua.util')
 local eutil = CS.Torappu.Lua.Util


local AdvancedSelectorHotfixer = Class("AdvancedSelectorHotfixer", HotfixBase)

local ShrinkEntity

local function CompareHatred(a, b)
    if a.hatred < b.hatred then
        return 1
    end

    if a.hatred > b.hatred then
        return -1
    end

    return 0
end

local function CompareMass(selector, a, b)
    local massLevelA = a.attributes:GetValueRoundToInt(CS.Torappu.AttributeType.MASS_LEVEL)
    local massLevelB = b.attributes:GetValueRoundToInt(CS.Torappu.AttributeType.MASS_LEVEL)

    if massLevelA < massLevelB then
        return 1
    end

    if massLevelA > massLevelB then
        return -1
    end

    return CompareHatred(a, b)
end

local function CompareTauntLevel(selector, a, b)
    if a.tauntLevel < b.tauntLevel then
        return 1
    end

    if a.tauntLevel > b.tauntLevel then
        return -1
    end

    return 0
end

local function CompareDistFromSource(selector, a, b)
    local disA = (selector.owner.mapPosition - a.mapPosition).sqrMagnitude
    local disB = (selector.owner.mapPosition - b.mapPosition).sqrMagnitude

    if CS.Torappu.MathUtil.GT(disA, disB) then
        return -1
    end
    
    if CS.Torappu.MathUtil.GT(disB, disA) then
        return 1
    end

    return CompareHatred(a, b)
end

local function CompareHpAsc(selector, a, b)
    local hpA = a.hp
    local hpB = b.hp

    if CS.Torappu.MathUtil.GT(hpB, hpA) then
        return -1
    end
    
    if CS.Torappu.MathUtil.GT(hpA, hpB) then
        return 1
    end

    return CompareHatred(a, b)
end

local function CompareHpDes(selector, a, b)
    local hpA = a.hp
    local hpB = b.hp

    if CS.Torappu.MathUtil.GT(hpB, hpA) then
        return 1
    end

    if CS.Torappu.MathUtil.GT(hpA, hpB) then
        return -1
    end

    return CompareHatred(a, b)
end

local function CompareMaxHpDes(selector, a, b)
    local hpA = a.maxHp
    local hpB = b.maxHp

    if CS.Torappu.MathUtil.GT(hpB, hpA) then
        return 1
    end

    if CS.Torappu.MathUtil.GT(hpA, hpB) then
        return -1
    end

    return CompareHatred(a, b)
end

local function CompareMaxHpAsc(selector, a, b)
    local hpA = a.maxHp
    local hpB = b.maxHp

    if CS.Torappu.MathUtil.GT(hpB, hpA) then
        return -1
    end
    
    if CS.Torappu.MathUtil.GT(hpA, hpB) then
        return 1
    end

    return CompareHatred(a, b)
end

local function CompareForwardFirstManhattanAsc(selector, a, b)
    local sourceDir = CS.Torappu.GridPosition.FromVectorPosition(CS.Torappu.SharedConsts.FOUR_WAYS[selector.owner.direction:GetHashCode()])
    local offsetA = selector.owner.gridPosition - a.gridPosition
    local offsetB = selector.owner.gridPosition - b.gridPosition

    local dirA = CS.Torappu.GridPosition.Cross(sourceDir, offsetA)
    local dirB = CS.Torappu.GridPosition.Cross(sourceDir, offsetB)
    
    local manhattanA = (selector.owner.gridPosition - a.gridPosition).manhattan
    local manhattanB = (selector.owner.gridPosition - b.gridPosition).manhattan

    local weightA
    local weightB

    if dirA == 0 and dirB == 0 then
        weightA = (selector.owner.gridPosition - a.gridPosition).manhattan - a.hatred:AsFloat() / 1000
        weightB = (selector.owner.gridPosition - b.gridPosition).manhattan - b.hatred:AsFloat() / 1000
        if weightA < weightB then
            return -1
        end
    
        if weightA > weightB then
            return 1
        end
        return 0
    end

    if dirA == 0 and dirB ~= 0 then
        return -1
    end

    if dirA ~= 0 and dirB == 0 then
        return 1
    end

    if manhattanA < manhattanB then
        return -1
    end

    if manhattanA > manhattanB then
        return 1
    end
    return CompareHatred(a, b)
end

local function BubbleSort(owner, A, compare)
    local n = A.Count
    local flag
    for i = 0, n - 1 do
        flag = true
        for j = 0, n - 2 - i do
            if compare(owner, A[j], A[j+1]) > 0 then
                A[j],A[j+1] = A[j+1],A[j]
                flag = false
            end
        end
        if flag == true then
            break
        end
    end
end

function OnPostFilterFix(self, candidates)
    if candidates ~= nil and candidates.Count > 0 and candidates[0]:GetType() == typeof(CS.Torappu.Battle.Tile) then
        self:OnPostFilter(candidates)
        return
    end
    
    if self._postFilter == CS.Torappu.Battle.FilterUtil.FilterType.MASS_DES then
        if self.isAlly == true and self._excludeOwner == true and self.owner ~= nil then
            candidates:Remove(self.owner)
        end
        BubbleSort(self, candidates, CompareMass)
        if self._sortByTauntAtLast == true then
            BubbleSort(self, candidates, CompareTauntLevel)
        end
        ShrinkEntity (candidates, self.maxTargetNum)
        return
    end

    
    if self._postFilter == CS.Torappu.Battle.FilterUtil.FilterType.HATRED_DES_DIST_FARTHER_FIRST then
        if self.isAlly == true and self._excludeOwner == true and self.owner ~= nil then
            candidates:Remove(self.owner)
        end
        BubbleSort(self, candidates, CompareDistFromSource)
        if self._sortByTauntAtLast == true then
            BubbleSort(self, candidates, CompareTaunt)
        end
        ShrinkEntity (candidates, self.maxTargetNum)
        return
    end

    
    if self._postFilter == CS.Torappu.Battle.FilterUtil.FilterType.HP_ASC then
        if self.isAlly == true and self._excludeOwner == true and self.owner ~= nil then
            candidates:Remove(self.owner)
        end
        BubbleSort(self, candidates, CompareHpAsc)
        if self._sortByTauntAtLast == true then
            BubbleSort(self, candidates, CompareTaunt)
        end
        ShrinkEntity (candidates, self.maxTargetNum)
        return
    end

    
    if self._postFilter == CS.Torappu.Battle.FilterUtil.FilterType.HP_DES then
        if self.isAlly == true and self._excludeOwner == true and self.owner ~= nil then
            candidates:Remove(self.owner)
        end
        BubbleSort(self, candidates, CompareHpDes)
        if self._sortByTauntAtLast == true then
            BubbleSort(self, candidates, CompareTaunt)
        end
        ShrinkEntity (candidates, self.maxTargetNum)
        return
    end
    
    
    if self._postFilter == CS.Torappu.Battle.FilterUtil.FilterType.MAX_HP_DES then
        if self.isAlly == true and self._excludeOwner == true and self.owner ~= nil then
            candidates:Remove(self.owner)
        end
        BubbleSort(self, candidates, CompareMaxHpDes)
        if self._sortByTauntAtLast == true then
            BubbleSort(self, candidates, CompareTaunt)
        end
        ShrinkEntity (candidates, self.maxTargetNum)
        return
    end

    
    if self._postFilter == CS.Torappu.Battle.FilterUtil.FilterType.MAX_HP_ASC then
        if self.isAlly == true and self._excludeOwner == true and self.owner ~= nil then
            candidates:Remove(self.owner)
        end
        BubbleSort(self, candidates, CompareMaxHpAsc)
        if self._sortByTauntAtLast == true then
            BubbleSort(self, candidates, CompareTaunt)
        end
        ShrinkEntity (candidates, self.maxTargetNum)
        return
    end

    
    if self._postFilter == CS.Torappu.Battle.FilterUtil.FilterType.FORWARD_FIRST_MANHATTAN_ASC then
        if self.isAlly == true and self._excludeOwner == true and self.owner ~= nil then
            candidates:Remove(self.owner)
        end
        BubbleSort(self, candidates, CompareForwardFirstManhattanAsc)
        if self._sortByTauntAtLast == true then
            BubbleSort(self, candidates, CompareTaunt)
        end
        ShrinkEntity (candidates, self.maxTargetNum)
        return
    end
    self:OnPostFilter(candidates)
end

function AdvancedSelectorHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.AdvancedSelector)

    local Shrink = xlua.get_generic_method(CS.Torappu.CollectionExtensions, "Shrink")
    ShrinkEntity = Shrink(CS.Torappu.Battle.Entity)

    self:Fix_ex(CS.Torappu.Battle.AdvancedSelector, "OnPostFilter", function(self, candidates)
        local ok, errorInfo = xpcall(OnPostFilterFix,debug.traceback, self, candidates)
        if not ok then
            eutil.LogError("[AdvancedSelectorHotfixer] fix" .. errorInfo)
        end
    end)
end

function AdvancedSelectorHotfixer:OnDispose()
end

return AdvancedSelectorHotfixer