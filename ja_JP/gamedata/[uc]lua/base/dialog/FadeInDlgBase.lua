FadeInDlgBase = Class("FadeInDlgBase", UIPanel);
FadeInDlgBase.FADE_DURATION = 23
FadeInDlgBase.onFadeIn = false

function FadeInDlgBase:StartFadeIn()
  self.current_duration = 0
  self._timer = self:Interval(0.01, self.FADE_DURATION + 1, self.OnFadeIn);
  self._rootCanvas.alpha = 0
  FadeInDlgBase.onFadeIn = true
end

function FadeInDlgBase:OnFadeIn()
  self._rootCanvas.alpha = self.current_duration / self.FADE_DURATION
  if (self.current_duration >= self.FADE_DURATION) then
    FadeInDlgBase.onFadeIn = false
  end
  self.current_duration = self.current_duration + 1
end
