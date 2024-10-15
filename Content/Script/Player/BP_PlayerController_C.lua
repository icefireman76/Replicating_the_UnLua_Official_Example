---@type BP_PlayerController_C
local M = UnLua.Class()

-- -- 重写UserConstructionScript函数
-- function M:UserConstructionScript()
--     self.ForwardVec = UE.FVector()  -- 前向向量置空
--     self.RightVec = UE.FVector()    -- 右向向量置空
--     self.ControlRot = UE.FRotator() -- 旋转向量置空

--     self.BaseTurnRate = 45.0 -- 相机偏航角Yaw速度
--     self.BaseLookUpRate = 45.0 -- 相机俯仰角Pitch速度
-- end

-- 重写ReceiveBeginPlay函数
function M:ReceiveBeginPlay()
    -- 为本地玩家控制器才执行
    if self:IsLocalPlayerController() then
        -- 添加UI到屏幕上
        local Widget = UE.UWidgetBlueprintLibrary.Create(self, UE.UClass.Load("/Game/Core/UI/UMG_Main.UMG_Main_C"))
        Widget:AddToViewport()
    end

    -- 调用父类的ReceiveBeginPlay
    self.Overridden.ReceiveBeginPlay(self)
end

-- -- 
-- function M:Turn(AxisValue)
--     self:AddYawInput(AxisValue)
-- end

-- -- 设置相机偏航角Yaw
-- function M:TurnRate(AxisValue)
--     local DeltaSeconds = UE.UGameplayStatics.GetWorldDeltaSeconds(self)
--     local Value = AxisValue * DeltaSeconds * self.BaseTurnRate
--     self:AddYawInput(Value)
-- end

-- -- 
-- function M:LookUp(AxisValue)
-- 	self:AddPitchInput(AxisValue)
-- end

-- -- 设置相机俯仰角Pitch
-- function M:LookUpRate(AxisValue)
-- 	local DeltaSeconds = UE.UGameplayStatics.GetWorldDeltaSeconds(self)
-- 	local Value = AxisValue * DeltaSeconds * self.BaseLookUpRate
-- 	self:AddPitchInput(Value)
-- end

-- -- 设置角色的前后移动
-- function M:MoveForward(AxisValue)
-- 	if self.Pawn then
-- 		local Rotation = self:GetControlRotation(self.ControlRot) -- 获取控制器，此处也即相机的旋转
-- 		Rotation:Set(0, Rotation.Yaw, 0) -- 获取角色的偏航角Yaw的旋转
-- 		local Direction = Rotation:ToVector(self.ForwardVec) -- 获取旋转的向前向量
-- 		self.Pawn:AddMovementInput(Direction, AxisValue)
-- 	end
-- end

-- -- 设置角色的左右移动
-- function M:MoveRight(AxisValue)
-- 	if self.Pawn then
-- 		local Rotation = self:GetControlRotation(self.ControlRot) -- 获取控制器，此处也即相机的旋转
-- 		Rotation:Set(0, Rotation.Yaw, 0) -- 获取角色的偏航角Yaw的旋转
-- 		local Direction = Rotation:GetRightVector(self.RightVec) -- 获取旋转的向右向量
-- 		self.Pawn:AddMovementInput(Direction, AxisValue)
-- 	end
-- end

-- -- 按下开火按键
-- function M:Fire_Pressed()
--    if self.Pawn then
--       self.Pawn:StartFire_Server()
--    else
--       UE.UKismetSystemLibrary.ExecuteConsoleCommand(self, "RestartLevel")
--    end
-- end

-- -- 松开开火按键
-- function M:Fire_Released()
-- 	if self.Pawn then
-- 		self.Pawn:StopFire_Server()
-- 	end
-- end

-- -- 按下瞄准按键
-- function M:Aim_Pressed()
-- 	if self.Pawn then
-- 		local BPI_Interfaces = UE.UClass.Load("/Game/Core/Blueprints/BPI_Interfaces.BPI_Interfaces_C")
-- 		BPI_Interfaces.UpdateAiming(self.Pawn, true)
-- 	end
-- end

-- -- 松开瞄准按键
-- function M:Aim_Released()
-- 	if self.Pawn then
-- 		local BPI_Interfaces = UE.UClass.Load("/Game/Core/Blueprints/BPI_Interfaces.BPI_Interfaces_C")
-- 		BPI_Interfaces.UpdateAiming(self.Pawn, false)
-- 	end
-- end

return M