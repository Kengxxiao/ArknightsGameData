

local xutil = require('xlua.util')



local V057Hotfixer = Class("V057Hotfixer", HotfixBase)

local function Fix_Act1VAutoChessShopQuickAssist_TryRefreshNormalItemView(self, arg1)
  if self.view == nil then
    return;
  end
  self.view:Render(arg1);
end

local function Fix_Act1VAutoChessShopQuickAssist_TryRefreshTitleItemView(self, arg1)
  if self.view == nil then
    return;
  end
  self.view:Render(arg1);
end

function V057Hotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Activity.Act1VAutoChess.Act1VAutoChessChessShopQuickAssistOnlyItemView.VirtualView)
  self:Fix_ex(CS.Torappu.Activity.Act1VAutoChess.Act1VAutoChessChessShopQuickAssistOnlyItemView.VirtualView, "TryRefreshAssistItemView", function(self, arg1)
    local ok, errorInfo = xpcall(Fix_Act1VAutoChessShopQuickAssist_TryRefreshNormalItemView, debug.traceback, self, arg1)
      if not ok then
         LogError("fix Act1VAutoChessChessShopQuickAssistOnlyItemView virtualView error" .. errorInfo)
      end
  end)
  xlua.private_accessible(CS.Torappu.Activity.Act1VAutoChess.Act1VAutoChessChessShopQuickAssistTitleWithItemView.VirtualView)
  self:Fix_ex(CS.Torappu.Activity.Act1VAutoChess.Act1VAutoChessChessShopQuickAssistTitleWithItemView.VirtualView, "TryRefreshAssistItemView", function(self, arg1)
    local ok, errorInfo = xpcall(Fix_Act1VAutoChessShopQuickAssist_TryRefreshTitleItemView, debug.traceback, self, arg1)
      if not ok then
         LogError("fix Act1VAutoChessChessShopQuickAssistTitleWithItemView virtualView error" .. errorInfo)
      end
  end)
end

return V057Hotfixer