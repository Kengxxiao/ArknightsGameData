local Act2VMultiBattleFinishNormalViewHotfixer = Class("Act2VMultiBattleFinishNormalViewHotfixer", HotfixBase)

local function GetMileStoneSeqFix(self)
 local ret = CS.DG.Tweening.DOTween.Sequence()
  if self.m_cachedViewModel == nil then
   return nil
  end
  if self.m_cachedViewModel.mileStoneFrom == nil or self.m_cachedViewModel.mileStoneTo == nil then
   return nil
  end
  local haveSeq = false
  if self.m_cachedViewModel.completeDaily then
   self._dailyAnim.animationWrapper:InitIfNot()
   self._dailyAnim.animationWrapper:SampleClipAtBegin(self._dailyAnim.animationName)
   local dailyTween = self._dailyAnim.animationWrapper:PlayWithTween(self._dailyAnim.animationName)
   ret:Insert(0, dailyTween)
   haveSeq = true
  end
  local mileStoneSeq = CS.DG.Tweening.DOTween.Sequence()
  local mileStoneFrom = self.m_cachedViewModel.mileStoneFrom
  local mileStoneTo = self.m_cachedViewModel.mileStoneTo
  self._mileStoneLv.text = tostring(mileStoneFrom.currentLv)
  self._mileStoneProgress.value = mileStoneFrom.expPercentage
  local fromLv = mileStoneFrom.currentLv
  local toLv = mileStoneTo.currentLv
  local fromPercent = mileStoneFrom.expPercentage
  local toPercent = mileStoneTo.expPercentage
  if fromLv == toLv then
   local duration = (toPercent - fromPercent) * self._mileStoneDuration;
   if not CS.Torappu.MathUtil.GE(duration, 0.0) then
    duration = 0
   end
   local oneTween = CS.DG.Tweening.DOTween:To(
    function() 
     return fromPercent
    end, 
    function(val)
     self._mileStoneProgress.value = val
    end, toPercent, duration)
    mileStoneSeq:Append(oneTween)
    haveSeq = true
  else 
   if fromLv < toLv then
    local frontDuration = (1 - fromPercent) * self._mileStoneDuration
    if not CS.Torappu.MathUtil.GE(frontDuration, 0.0) then
     frontDuration = 0
    end
    local frontTween = CS.DG.Tweening.DOTween.To(
    function() 
     return fromPercent
    end, 
    function(val)
     self._mileStoneProgress.value = val
    end, 1, frontDuration):OnComplete(
     function()
      self._mileStoneLv.text = tostring(fromLv + 1)
      self:_PlayLvUpTween()
     end)
    mileStoneSeq:Append(frontTween)
    local loopTweenIndex = 0
    while loopTweenIndex < toLv - fromLv - 1 do
     local midDuration = self._mileStoneDuration
     local toLevelNum = fromLv + loopTweenIndex + 2
     if not CS.Torappu.MathUtil.GE(midDuration, 0.0) then
      midDuration = 0
     end
     local loopTween = CS.DG.Tweening.DOTween.To(
      function()
       return 0
      end, 
      function(val)
       self._mileStoneProgress.value = val
      end, 1, midDuration):OnComplete(
      function()
       self._mileStoneLv.text = tostring(toLevelNum)
       self:_PlayLvUpTween()
      end)
     mileStoneSeq:Append(loopTween)
     loopTweenIndex = loopTweenIndex + 1
    end
    local lastDuration = toPercent * self._mileStoneDuration
    if not CS.Torappu.MathUtil.GE(lastDuration, 0.0) then
     lastDuration = 0
    end
    local lastTween = CS.DG.Tweening.DOTween.To(
    function()
     return 0
    end, 
    function(val)  
     self._mileStoneProgress.value = val
    end, toPercent, lastDuration)
    mileStoneSeq:Append(lastTween)
    haveSeq = true
   end
  end
  ret:Insert(0, mileStoneSeq)
  if not haveSeq then
   return nil
  end
  return ret
end

function Act2VMultiBattleFinishNormalViewHotfixer:OnInit()
 xlua.private_accessible(CS.Torappu.Activity.Act2VMulti.Act2VMultiBattleFinishNormalView)
  self:Fix_ex(CS.Torappu.Activity.Act2VMulti.Act2VMultiBattleFinishNormalView, "_GetMileStoneSeq", function(self)
   local ok, errorInfo = xpcall(GetMileStoneSeqFix, debug.traceback, self)
   if not ok then
    LogError("[Act2VMultiBattleFinishNormalViewHotfixer] fix" .. errorInfo)
   else
    return errorInfo
   end
  end)
end

function Act2VMultiBattleFinishNormalViewHotfixer:OnDispose()
end

return Act2VMultiBattleFinishNormalViewHotfixer