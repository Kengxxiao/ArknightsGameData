


local OpenServerV3PanelView = Class("OpenServerV3PanelView", UIPanel);

function OpenServerV3PanelView:OnInit()
  self.m_tabEntryViews = {};
  self.m_contentViews = {};
end


function OpenServerV3PanelView:SetTabEntryViews(tabEntryViews)
  self.m_tabEntryViews = tabEntryViews or {};
end


function OpenServerV3PanelView:SetContentViews(contentViews)
  self.m_contentViews = contentViews or {};
  for _, contentView in pairs(self.m_contentViews) do
    if contentView ~= nil then
      SetGameObjectActive(contentView.m_root, false);
    end
  end
end


function OpenServerV3PanelView:OnViewModelUpdate(data)
  if data == nil then
    return;
  end
  for _, entryView in ipairs(self.m_tabEntryViews) do
    local model = data:GetTabEntryModel(entryView:GetTabState());
    entryView:Render(model);
  end

  for tabState, contentView in pairs(self.m_contentViews) do
    if contentView ~= nil then
      SetGameObjectActive(contentView.m_root, data.tabState == tabState);
    end
  end
end

return OpenServerV3PanelView;
