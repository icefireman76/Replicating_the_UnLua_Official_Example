---@type ABP_PlayerCharacter_C
local M = UnLua.Class()

-- 重写BlueprintBeginPlay函数，即C++中动画蓝图的BeingPlay函数
function M:BlueprintBeginPlay()
    self.Velocity = UE.FVector()
	self.ForwardVec = UE.FVector()
	self.RightVec = UE.FVector()
	self.ControlRot = UE.FRotator()
	self.Pawn = self:TryGetPawnOwner()
end

-- 重写BlueprintUpdateAnimation函数
function M:BlueprintUpdateAnimation(DeltaTimeX)
    -- 获取动画蓝图控制的Pawn
    -- TryGetPawnOwner原型函数并无参数，此处传入self.Pawn
    -- 相当于实现C++写法：APawn* Pawn = Pawn == nullptr ? TryGetPawnOwner() : Pawn;
    local Pawn = self:TryGetPawnOwner(self.Pawn)
	if not Pawn then return end

    -- 获取Pawn的速度向量
    local Vel = Pawn:GetVelocity(self.Velocity)
    if not Vel then return end

    -- 将Pawn转换成规定的类型
    local BP_CharacterBase = UE.UClass.Load("/Game/Core/Blueprints/BP_CharacterBase.BP_CharacterBase_C")
    local Character = Pawn:Cast(BP_CharacterBase)

    if Character then
        -- 角色已死亡，同步死亡状态到动画蓝图
        if Character.IsDead and not self.IsDead then
            self.IsDead = true
            self.DeathAnimIndex = UE.UKismetMathLibrary.RandomIntegerInRange(0, 2) -- 随机播放一个死亡动画
        end
    end

    -- 获得速度大小
    local Speed = Vel:Size()
    self.Speed = Speed

    if Speed > 0.0 then
        Vel:Normalize()

        -- 获取控制器即视角的旋转向量
        local Rot = Pawn:GetControlRotation(self.ControlRot)

        -- 只关心偏航角Yaw
        Rot:Set(0, Rot.Yaw, 0)

        -- 获取旋转向量的向前向量和向右向量
        local ForwardVec = Rot:GetForwardVector(self.ForwardVec)
		local RightVec = Rot:GetRightVector(self.RightVec)

        -- 计算速度向量和向右向量、向前向量的点积，即速度向量在两个方向上的投影
		local DP0 = Vel:Dot(RightVec)
		local DP1 = Vel:Dot(ForwardVec)

        -- 计算DP1的arccos值，并将角度从弧度制转换为角度制
		local Angle = UE.UKismetMathLibrary.Acos(DP1)
        Angle = Angle * 180 / 3.14159265358979323846

        -- 速度向量在向右向量的投影大于0，即角色在往右走；反之角色在往左走
		if DP0 > 0.0 then
			self.Direction = Angle
		else
			self.Direction = -Angle
		end
    end
end

-- 动画通知，调用角色的接口，改变角色的刚体状态
function M:AnimNotify_NotifyPhysics()
	local BPI_Interfaces = UE.UClass.Load("/Game/Core/Blueprints/BPI_Interfaces.BPI_Interfaces_C")
	BPI_Interfaces.ChangeToRagdoll(self.Pawn)
end

return M