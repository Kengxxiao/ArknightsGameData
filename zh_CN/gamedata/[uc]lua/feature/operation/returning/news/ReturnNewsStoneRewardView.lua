


local ReturnNewsStoneRewardView = Class("ReturnNewsStoneRewardView", UIPanel);


function ReturnNewsStoneRewardView:Render(total)
  self._textTotal.text = tostring(total);
end

return ReturnNewsStoneRewardView;
