






local SwitchOnlyItemViewModel = Class("SwitchOnlyItemViewModel");

function SwitchOnlyItemViewModel:ctor()
  self.isUnlocked = false;
  self.isReceived = false;
end

return SwitchOnlyItemViewModel;