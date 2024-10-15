---@type BP_PlayerCharacter_C
local M = UnLua.Class("BP_CharacterBase_C")


-- 重写ReceiveBeginPlay函数
function M:ReceiveBeginPlay()
    -- 调用父类的ReceiveBeginPlay
    self.Super.ReceiveBeginPlay(self)

    -- 调用蓝图被覆盖的BeginPlay事件
    self.Overridden.ReceiveBeginPlay(self)

    -- 获取相机默认FOV
    self.DefaultFOV = self.Camera.FieldOfView

    -- 创建定时器句柄，每秒循环调用FallCheck
    self.TimerHandle = UE.UKismetSystemLibrary.K2_SetTimerDelegate({self, M.FallCheck}, 1, true)

    -- 获取蓝图中的时间轴，并将其和OnZoomInOutUpdate函数绑定
    local InterpFloats = self.ZoomInOut.TheTimeline.InterpFloats -- 获取时间轴中的浮点型轨道
    local FloatTrack = InterpFloats:GetRef(1) -- 获取浮点型轨道的第一个轨道
    FloatTrack.InterpFunc:Bind(self, M.OnZoomInOutUpdate) -- 将此轨道的曲线和OnZoomInOutUpdate函数绑定
end

-- 重写ReceiveDestroyed函数
function M:ReceiveDestroyed()
    -- 清除定时器句柄
    --UE.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.TimerHandle)
end

-- 每秒检测角色高度，若过低则认为角色死亡，重新开启关卡
function M:FallCheck()
    --local Location = self:K2_GetActorLocation()
    if self.IsDead then
        local co = coroutine.create(M.RestartLevel)
        coroutine.resume(co,self, 5.0)

        -- 清除定时器句柄
        UE.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.TimerHandle)
    end
end

function M:RestartLevel(DelayTime)
    UE.UKismetSystemLibrary.Delay(self, DelayTime)
    UE.UKismetSystemLibrary.ExecuteConsoleCommand(self, "RestartLevel")
end

---------------------------------------------------------------------------------------
-- 相机 -------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-- 利用插值实现摄像机平滑缩放
function M:OnZoomInOutUpdate(Alpha)
    local FOV = UE.UKismetMathLibrary.Lerp(self.DefaultFOV, self.Weapon.AimingFOV, Alpha)
    self.Camera:SetFieldOfView(FOV)
end

-- 瞄准时切换相机FOV
function M:UpdateAiming(IsAiming)
    if self.Weapon then
        if IsAiming then
            self.ZoomInOut:Play()
        else
            self.ZoomInOut:Reverse()
        end
    end
end
---------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------
-- 武器 -------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-- 创建武器
function M:SpawnWeapon()
    -- 获取世界对象
    local World = self:GetWorld()
    if not World then return end

    -- 获取武器类
    local WeaponClass = UE.UClass.Load("/Game/Core/Blueprints/Weapon/BP_DefaultWeapon.BP_DefaultWeapon_C")

    -- 设置创建Actor的参数
    local sp = UE.FActorSpawnParameters()
    sp.SpawnCollisionHandlingOverride = UE.ESpawnActorCollisionHandlingMethod.AlwaysSpawn
    sp.Owner = self
    sp.Instigator = self

    -- 创建武器Actor
    -- UnLua API: World:SpawnActorEx(WeaponClass, InitialTransform, WeaponColor, "Weapon.AK47_C", ActorSpawnParameters)
    local NewWeapon = World:SpawnActorEx(
        WeaponClass, self:GetTransform(), nil, "Weapon.BP_DefaultWeapon_C", sp)
    return NewWeapon
end

-- 获取武器瞄准线的信息
function M:GetWeaponTraceInfo()
    local TraceLocation = self.Camera:K2_GetComponentLocation()
    local TraceDirection = self.Camera:GetForwardVector()
    return TraceLocation, TraceDirection
end
---------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------
-- 增强输入 ----------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-- 引入绑定增强输入函数
local BindAction = UnLua.EnhancedInput.BindAction

-- 绑定视角旋转函数
local IA_Look = "/Game/Core/Input/IA_Look.IA_Look"
BindAction(M, IA_Look, "Triggered", function(self, ActionValue)
    self:AddControllerYawInput(ActionValue.X)
    self:AddControllerPitchInput(ActionValue.Y)
end)

-- 绑定移动函数
local IA_Move = "/Game/Core/Input/IA_Move.IA_Move"
BindAction(M, IA_Move, "Triggered", function(self, ActionValue)
    self:AddMovementInput(self.Camera:GetForwardVector(), ActionValue.Y)
    self:AddMovementInput(self.Camera:GetRightVector(), ActionValue.X)
end)

-- 绑定跳跃函数
local IA_Jump = "/Game/Core/Input/IA_Jump.IA_Jump"
BindAction(M, IA_Jump, "Triggered", function(self, ActionValue)
    self:Jump()
end)

-- 绑定瞄准函数
local IA_Aim = "/Game/Core/Input/IA_Aim.IA_Aim"
BindAction(M, IA_Aim, "Triggered", function(self, ActionValue, A)
    local BPI_Interfaces = UE.UClass.Load("/Game/Core/Blueprints/BPI_Interfaces.BPI_Interfaces_C")
    if A > 1 then BPI_Interfaces.UpdateAiming(self, true)
    else BPI_Interfaces.UpdateAiming(self, false) end
end)

-- 绑定开火函数
local IA_Fire = "/Game/Core/Input/IA_Fire.IA_Fire"
BindAction(M, IA_Fire, "Triggered", function(self, ActionValue, A)
    if A > 1 then self:StartFire_Server()
    else self:StopFire_Server() end
end)
---------------------------------------------------------------------------------------

return M