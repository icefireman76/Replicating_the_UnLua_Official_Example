---@type BP_DefaultProjectile_C
local M = UnLua.Class("Weapon.BP_ProjectileBase_C")

-- 构造函数
function M:Initialize(Initializer)
    if Initializer then
        self.BaseColor = Initializer[0]
    end
end

-- 重写UserConstructionScript函数
function M:UserConstructionScript()
    self.Super.UserConstructionScript(self) -- 调用父类UserConstructionScript函数
    self.DamageType = UE.UClass.Load("/Game/Core/Blueprints/BP_DamageType.BP_DamageType_C")

    self.ProjectileMovement.InitialSpeed = 3000
    self.ProjectileMovement.MaxSpeed = 3000
end

-- 重写ReceiveBeginPlay函数
function M:ReceiveBeginPlay()
    self.Super.ReceiveBeginPlay(self)

    -- 给子弹设置材质，改变子弹颜色
    local MID = self.StaticMesh:CreateDynamicMaterialInstance(0)
    if MID then
        MID:SetVectorParameterValue("BaseColor", self.BaseColor)
    end
end

return M