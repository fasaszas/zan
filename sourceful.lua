
if not LPH_OBFUSCATED then
    LPH_JIT_MAX = function(...)
        return (...)
    end
    LPH_NO_VIRTUALIZE = function(...)
        return (...)
    end
end

LPH_JIT_MAX(
    function()
        local Players, Client, Mouse, RS, Camera, r =
            game:GetService("Players"),
            game:GetService("Players").LocalPlayer,
            game:GetService("Players").LocalPlayer:GetMouse(),
            game:GetService("RunService"),
            game.Workspace.CurrentCamera,
            math.random

        local Circle = Drawing.new("Circle")
        Circle.Color = Color3.new(1, 1, 1)
        Circle.Thickness = 1.5


        local prey
        local prey2
        local On

        local Vec2 = function(property)
            return Vector2.new(property.X, property.Y + (game:GetService("GuiService"):GetGuiInset().Y))
        end

        local UpdateSilentFOV = function()
            if not Circle then
                return Circle
            end
            Circle.Visible = getgenv().Aiming.SilentAim.FOV["Showing"]
            Circle.Radius = getgenv().Aiming.SilentAim.FOV["Radius"] * 3.05
            Circle.Position = Vec2(Mouse)

            return Circle
        end

        game.RunService.RenderStepped:Connect(function ()
            UpdateSilentFOV()
        end)

        local WallCheck = function(destination, ignore)
            if getgenv().Aiming.Others.CheckForWalls then
                local Origin = Camera.CFrame.p
                local CheckRay = Ray.new(Origin, destination - Origin)
                local Hit = game.workspace:FindPartOnRayWithIgnoreList(CheckRay, ignore)
                return Hit == nil
            else
                return true
            end
        end

        local useVelocity = function (player) 
            player.Character.HumanoidRootPart.Velocity = Vector3.new(0.36, 0.21, 0.34) * 2
        end

        local checkVelocity = function (player, pos, neg)
            if player and player.Character:FindFirstChild("Humanoid") then
                local velocity = player.Character.HumanoidRootPart.Velocity
                if (velocity.Magnitude > neg or velocity.Magnitude < pos and
                (not player.Character.Humanoid.Jump == true)) then
                    useVelocity(player)
                end
            end
            return false
        end

        task.spawn(function () while task.wait() do if getgenv().Silent.Others.Resolver == true then checkVelocity(prey or prey2, 100, -50) end end end)

        GetClosestToMouse = function()
            local Target, Closest = nil, 1 / 0

            for _, v in pairs(Players:GetPlayers()) do
                if (v.Character and v ~= Client and v.Character:FindFirstChild("HumanoidRootPart")) then
                    local Position, OnScreen = Camera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
                    local Distance = (Vector2.new(Position.X, Position.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude

                    if
                        (Circle.Radius > Distance and Distance < Closest and OnScreen and
                            WallCheck(v.Character.HumanoidRootPart.Position, {Client, v.Character}))
                     then
                        Closest = Distance
                        Target = v
                    end
                end
            end
            return Target
        end

        function TargetChecks(Target)
            if getgenv().Aiming.Others.KoedCheck== true and Target.Character then
                return Target.Character.BodyEffects["K.O"].Value and true or false
            end
            return false
        end

        function predictTargets(Target, Value)
            return Target.Character[getgenv().Aiming.Silent.TargetPart].CFrame +
                (Target.Character[getgenv().Aiming.Silent.TargetPart].Velocity * Value)
        end

        local WTS = function(Object)
            local ObjectVector = Camera:WorldToScreenPoint(Object.Position)
            return Vector2.new(ObjectVector.X, ObjectVector.Y)
        end

        local IsOnScreen = function(Object)
            local IsOnScreen = Camera:WorldToScreenPoint(Object.Position)
            return IsOnScreen
        end

        local FilterObjs = function(Object)
            if string.find(Object.Name, "Gun") then
                return
            end
            if table.find({"Part", "MeshPart", "BasePart"}, Object.ClassName) then
                return true
            end
        end

        GetClosestBodyPart = function(character)
            local ClosestDistance = 1 / 0
            local BodyPart = nil
            if (character and character:GetChildren()) then
                for _, x in next, character:GetChildren() do
                    if FilterObjs(x) and IsOnScreen(x) then

                        local Distance = (WTS(x) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude

                        if (Distance < ClosestDistance) then
                            ClosestDistance = Distance
                            BodyPart = x
                        end
                    end
                end
            end
            return BodyPart
        end

        Mouse.KeyDown:Connect(
            function(Key)
                if (Key == getgenv().Aiming.Tracing.Toggle:lower()) then
                    if getgenv().Aiming.Tracing.Enabled == true then
                        On = not On
                        if On then
                            prey2 = GetClosestToMouse()
                        else
                            if prey2 ~= nil then
                                prey2 = nil
                            end
                        end
                    end
                end
            end
        )

        RS.RenderStepped:Connect(
            function()
                if prey then
                    if prey ~= nil and getgenv().Aiming.Silent.Enabled and getgenv().Aiming.Silent.ClosestPart == true then
                        getgenv().Aiming.Silent["Part"] = tostring(GetClosestBodyPart(prey.Character))
                    end
                end
            end
        )

        local TracingPrediction = function(Target, Value)
            return Target.Character[getgenv().Aiming.Tracing.AimPart].Position +
                (Target.Character[getgenv().Aiming.Tracing.AimPart].Velocity / Value)
        end

        RS.RenderStepped:Connect(
            function()
                if
                    prey2 ~= nil and getgenv().Aiming.Tracing.Enabled and
                        getgenv().Aiming.Tracing.EnableSmoothness == true
                 then
                    local Main = CFrame.new(Camera.CFrame.p, TracingPrediction(prey2, getgenv().Aiming.Tracing.PredictionValue))
                    Camera.CFrame =
                        Camera.CFrame:Lerp(
                        Main,
                        getgenv().Aiming.Tracing.SmoothnessValue,
                        Enum.EasingStyle.Elastic,
                        Enum.EasingDirection.InOut,
                        Enum.EasingStyle.Sine
                    )
                elseif prey2 ~= nil and getgenv().Aiming.Tracing.Enabled and getgenv().Aiming.Tracing.EnableSmoothness == false then
                    Camera.CFrame =
                        CFrame.new(Camera.CFrame.Position, TracingPrediction(prey2, getgenv().Aiming.Tracing.PredictionValue))
                end
            end
        )

        local grmt = getrawmetatable(game)
        local index = grmt.__index
        local properties = {
            "Hit" -- Ill Add more Mouse properties soon,
        }
        setreadonly(grmt, false)

        grmt.__index =
            newcclosure(
            function(self, v)
                if Mouse and (table.find(properties, v)) then
                    prey = GetClosestToMouse()
                    if prey ~= nil  then
                        local endpoint = predictTargets(prey, getgenv().Aiming.Silent.Pred)

                        return (table.find(properties, tostring(v)) and endpoint)
                    end
                end
                return index(self, v)
            end
        )
    end
)()