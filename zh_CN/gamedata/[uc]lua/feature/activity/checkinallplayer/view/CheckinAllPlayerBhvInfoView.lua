


local CheckinAllPlayerBhvInfoLine = Class("CheckinAllPlayerBhvInfoLine", UIWidget);
CheckinAllPlayerBhvInfoLine.COLOR_NORMAL = {r=234/255, g=231/255, b = 212/255, a = 1};
CheckinAllPlayerBhvInfoLine.COLOR_REACH = {r=1, g=1, b = 1, a = 0.54};


function CheckinAllPlayerBhvInfoLine:Render(bhvModel)
  self._leftLabel.text = bhvModel.pubBhvData.allBehaviorDesc;

  local fmtStr = CS.Torappu.StringRes.ACT1CHECK_TIMES;
  local cntStr = tostring(bhvModel.pubBhvData.requiringValue); 
  self._rightLabel.text = CS.Torappu.Lua.Util.Format(fmtStr, cntStr);
  if bhvModel.num >= bhvModel.pubBhvData.requiringValue then
    self._rightLabel.color = self.COLOR_REACH;
  else
    self._rightLabel.color = self.COLOR_NORMAL;
  end
end


function CheckinAllPlayerBhvInfoLine:RenderPer(perBhvModel)
  self._leftLabel.text = perBhvModel.perBhvData.desc;

  self._rightLabel.color = self.COLOR_REACH;
  if perBhvModel.perBhvData.requireRepeatCompletion then
    local fmtStr = CS.Torappu.StringRes.ACT1CHECK_TIMES;
    local cntStr = tostring(perBhvModel.num);
    self._rightLabel.text = CS.Torappu.Lua.Util.Format(fmtStr, cntStr);
  else
    if perBhvModel.num > 0 then
      self._rightLabel.text = CS.Torappu.StringRes.ACT1CHECK_PASS;
    else
      self._rightLabel.text = CS.Torappu.StringRes.ACT1CHECK_NOPASS;
    end
  end
  
end












local CheckinAllPlayerBhvInfoView = Class("CheckinAllPlayerBhvInfoView", UIPanel);
CheckinAllPlayerBhvInfoView.ANIM_DUR = 0.1;

function CheckinAllPlayerBhvInfoView:OnInit()
  self:AddButtonClickListener(self._btnShow, self._EventShow);
  self:AddButtonClickListener(self._btnHide, self._EventHide);
  self:_ExpandContent(false);
end


function CheckinAllPlayerBhvInfoView:Render(model)
  self:_InitIfNot(model);
  SetGameObjectActive(self._normalBg, model.status ~= CheckinAllPlayerRewardStatus.RECEIVED);
  SetGameObjectActive(self._gotBg, model.status == CheckinAllPlayerRewardStatus.RECEIVED);

  for idx, line in ipairs(self.m_infoLines) do
    if idx == 1 then
      line:Render(model);
    else
      local perBhv = model.perBhvModels[idx-1];
      if perBhv then
        line:RenderPer(perBhv);
      end
    end
  end
end


function CheckinAllPlayerBhvInfoView:_InitIfNot(model)
  if self.m_infoLines then
    return;
  end
  self.m_infoLines = {};
  
  local pubLine = self:CreateWidgetByPrefab(CheckinAllPlayerBhvInfoLine, self._infoLinePrefab, self._lineContainer);
  table.insert(self.m_infoLines, pubLine);

  for idx, perBhv in ipairs(model.perBhvModels) do
    local perLine = self:CreateWidgetByPrefab(CheckinAllPlayerBhvInfoLine, self._infoLinePrefab, self._lineContainer);
    table.insert(self.m_infoLines, perLine);
  end
end

function CheckinAllPlayerBhvInfoView:_EventShow()
  self:_ExpandContent(true);
end

function CheckinAllPlayerBhvInfoView:_EventHide()
  self:_ExpandContent(false);
end

function CheckinAllPlayerBhvInfoView:_ExpandContent(expand)

  SetGameObjectActive(self._viewIcon, not expand);
  SetGameObjectActive(self._viewExpandIcon, expand);
  SetGameObjectActive(self._btnHide.gameObject, expand);
  SetGameObjectActive(self._btnShow.gameObject, not expand);

  local cnt = 1;
  if expand and self.m_infoLines then
    cnt = #self.m_infoLines;
  end
  local from = self._content.sizeDelta.y;
  local to =  16 + 28 * cnt;

  if self.m_tween then
    self:KillTween(self.m_tween);
    self.m_tween = nil;
  end
  
  local this = self;
  self.m_tween = self:PlayTween({
    setFunc = function(lerpValue)
      local height = lerpValue * to + (1-lerpValue) * from;
      local size = this._content.sizeDelta;
      size.y = height;
      this._content.sizeDelta = size;
    end,
    duration = self.ANIM_DUR,
    timeScaled = true,
    
    
    
    
  });
end

return CheckinAllPlayerBhvInfoView;