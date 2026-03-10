



local ReturnMissionGroupViewBase = Class("ReturnMissionGroupViewBase", UIWidget);

function ReturnMissionGroupViewBase:OnInitialize()
  if self.OnInit ~= nil then
    self:OnInit();
  end
end


function ReturnMissionGroupViewBase:Render(viewModel)
  if viewModel == nil then
    return;
  end
  self:OnRender(viewModel);
end



function ReturnMissionGroupViewBase:OnRender(viewModel)
end


function ReturnMissionGroupViewBase:OnInit()
end





function ReturnMissionGroupViewBase:LoadSprite(hubPath, spriteName)
  if self.loadFunc == nil then
    return nil;
  end
  return self.loadFunc(hubPath, spriteName);
end






function ReturnMissionGroupViewBase:CreateWidgetByGO(widgetCls, layout)
  if self.createWidgetByGO == nil then
    return nil;
  end
  return self.createWidgetByGO(widgetCls, layout);
end







function ReturnMissionGroupViewBase:CreateWidgetByPrefab(widgetCls, layout, parent)
  if self.createWidgetByPrefab == nil then
    return nil;
  end
  return self.createWidgetByPrefab(widgetCls, layout, parent);
end

return ReturnMissionGroupViewBase;