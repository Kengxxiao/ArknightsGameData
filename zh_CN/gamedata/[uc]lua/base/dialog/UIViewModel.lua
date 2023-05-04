

UIViewModel = Class("UIViewModel");

function UIViewModel:ctor(dlg)
  self.m_dlg = dlg;
end

function UIViewModel:NotifyUpdate()
  self.m_dlg:_UpdateViewModel(self);
end