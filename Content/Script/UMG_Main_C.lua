---@type UMG_Main_C
local M = UnLua.Class()

function M:Construct()
    self.ExitButton.OnClicked:Add(self, M.OnClicked_ExitButton)
end

function M:OnClicked_ExitButton()
    UE.UKismetSystemLibrary.ExecuteConsoleCommand(self, "exit")
end

return M