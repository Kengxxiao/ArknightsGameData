




CSJudgeDialogHandle = Class("CSJudgeDialogHandle");

function CSJudgeDialogHandle:Initialize()
  local showDialogGeneric = xlua.get_generic_method(CS.Torappu.UI.UIPopupWindow, "ShowDialog");
  self.m_showJudgeDialogFunc = showDialogGeneric(CS.Torappu.UI.UIJudgeDialog);
end

function CSJudgeDialogHandle:Dispose()
  self:_ClearDialog();
end

function CSJudgeDialogHandle:_ClearDialog()
  if self.m_csDlg then
    self.m_csDlg:ClearOption();
  end
end




function CSJudgeDialogHandle:ShowDialog(config)
  self:_ClearDialog();

  self.m_csDlg = self.m_showJudgeDialogFunc();
  local options = CS.Torappu.UI.UIJudgeDialog.Options();
  if config.descText then
    options.descText = config.descText;
  end
  if config.onPositive then
    options.onPositive = function()
      config.onPositive:Call();
    end
  end
  if config.onNegative then
    options.onNegative = function()
      config.onNegative:Call();
    end
  end
  if config.onBackPressed then
    options.onBackPressed = function()
      config.onBackPressed:Call();
    end
  end

  if config.positiveText then
    options.positiveText = config.positiveText;
  end
  if config.negativeText then
    options.negativeText = config.negativeText;
  end

  local this = self;
  options.onDismiss = function()
    this.m_csDlg = nil;
    if config.onDismiss then
      config.onDismiss:Call();
    end
  end

  if config.lineSpacing ~= nil then
    options.lineSpacing = config.lineSpacing;
  end

  self.m_csDlg.options = options;
end