
















Act7FunBattleFinishNewsView = Class("Act7FunBattleFinishNewsView", UIWidget)

local ANIM_KEY_NEWS = "act7fun_battle_finish_special_news";

function Act7FunBattleFinishNewsView:OnInit(dlg, viewModel)
  self.m_dlg = dlg;
  self.m_viewModel = viewModel;
end

function Act7FunBattleFinishNewsView:GenerateNewsSequence(callback)
  self._animWrapper:InitIfNot();
  self._animWrapper:SampleClipAtBegin(ANIM_KEY_NEWS);

  local seq = CS.DG.Tweening.DOTween.Sequence();

  seq:Append(self._animWrapper:PlayWithTween(ANIM_KEY_NEWS):SetEase(CS.DG.Tweening.Ease.Linear))
     :InsertCallback(self._animBeginDuration, function()
        self.m_loopSeq = self:_GenerateLoopSequence();
        self.m_loopSeq:InsertCallback(self._eggProtectDuration, callback);
     end)
     :SetAutoKill(true);
end

function Act7FunBattleFinishNewsView:GetLoopSequence()
  return self.m_loopSeq;
end

function Act7FunBattleFinishNewsView:_GenerateLoopSequence()
  local models = self.m_viewModel.easterEggModels
  local count = #models
  local seq = CS.DG.Tweening.DOTween.Sequence();
  local fade = self._iconFadeDuration;
  local display = tonumber(self._displayDuration);

  
  self.m_endPosX = 0;
  self._iconCanvasGroup.alpha = 0;
  self._contentCanvasGroup.alpha = 0;

  for i = 1, count do
    seq:AppendCallback(function()
      self:_RenderView(models[i]);
      self:_PlayTextAnim();
    end)
    
    seq:Append(self._iconCanvasGroup:DOFade(1, fade / 2):SetEase(CS.DG.Tweening.Ease.Linear));
    seq:Join(self._contentCanvasGroup:DOFade(1, fade / 2):SetEase(CS.DG.Tweening.Ease.Linear));
    
    seq:AppendInterval(display);
    
    seq:Append(self._iconCanvasGroup:DOFade(0, fade / 2):SetEase(CS.DG.Tweening.Ease.Linear));
    seq:Join(self._contentCanvasGroup:DOFade(0, fade / 2):SetEase(CS.DG.Tweening.Ease.Linear));
  end

  seq:SetLoops(-1, CS.DG.Tweening.LoopType.Restart);
  return seq;
end

function Act7FunBattleFinishNewsView:_RenderView(eggModel)
  local hubPath = CS.Torappu.ResourceUrls:GetAct7funNewsCharIconHubPath();
  self._imgCharIcon.sprite = self.m_dlg:LoadSpriteFromAutoPackHub(hubPath, eggModel.charIconId);
  self._txtContent.text = eggModel.content;
end

function Act7FunBattleFinishNewsView:_PlayTextAnim()
  if self.m_tween ~= nil and self.m_tween:IsPlaying() then
    self.m_tween:Kill();
    self.m_tween = nil;
  end

  local fade = self._iconFadeDuration;
  local display = tonumber(self._displayDuration);
  local width = self._carouselRectTransform.rect.width;

  CS.UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self._contentRectTransform);

  local contentWidth = self._contentRectTransform.rect.width;
  local startPosX = width * 0.5 + contentWidth * 0.5 + tonumber(self._newsOffset);
  local endPosX = -startPosX;

  self._contentRectTransform.anchoredPosition = CS.UnityEngine.Vector2(startPosX, self._contentRectTransform.anchoredPosition.y);
  self.m_tween = self._contentRectTransform:DOAnchorPosX(endPosX, display)
    :SetEase(CS.DG.Tweening.Ease.Linear)
    :SetDelay(fade / 2)
    :SetAutoKill(true);
end

return Act7FunBattleFinishNewsView