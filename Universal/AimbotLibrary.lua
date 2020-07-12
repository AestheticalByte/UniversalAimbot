--[[
    Credits : ToddDev on v3rm for hot library
]]

--// Container

local EzAimbot = {}

--// Internal

local aimPart;
local MainLoop;
local Camera = workspace.CurrentCamera
local Viewport = Camera.ViewportSize
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character
local Mouse = LocalPlayer:GetMouse()
local FOV;
local RunService = game:GetService("RunService")
local InputService = game:GetService("UserInputService")

local MousePosition = function()
    return Vector2.new(Mouse.X,Mouse.Y)
end

function HandleTeam(player)
    local Team = LocalPlayer.Team
    if player.Team == Team and friendlyfire then
        return true;
    elseif player.Team == Team and friendlyfire == false then
        return false;
    else
        return true;
    end
    return true;
end

local ClosestPlayer = function(friendlyfire)
    local MousePos = MousePosition()
    local Radius = FOV.Radius
    local Closest = math.huge
    local Target = nil
    for k, v in pairs(Players:GetPlayers()) do
        pcall(function()
            if HandleTeam(v) then
                if _G.partTarget == "Head" then
                    if v.Character:FindFirstChild("Head") and v ~= LocalPlayer then
                        aimPart = "Head";
                    else
                        aimPart = nil;
                    end
                elseif _G.partTarget == "Torso" then
                    if v.Character:FindFirstChild("Torso") and v ~= LocalPlayer then
                        aimPart = "Torso";
                    elseif v.Character:FindFirstChild("UpperTorso") and v ~= LocalPlayer then
                        aimPart = "UpperTorso";
                    else
                        aimPart = nil;
                    end
                end
        
                if aimPart then
                    local Point, OnScreen = Camera:WorldToScreenPoint(v.Character[aimPart].Position)
                    if OnScreen and #Camera:GetPartsObscuringTarget({Character[aimPart].Position, v.Character[aimPart].Position}, {Character, v.Character}) == 0 then
                        local Distance = (Vector2.new(Point.X, Point.Y) - MousePosition()).magnitude
                        if Distance < math.min(Radius,Closest) then
                            Closest = Distance
                            Target = v
                        end
                    end
                end
            end
        end)
    end
    return Target
end
local RefreshInternals = function()
    Camera = workspace.CurrentCamera
    LocalPlayer = Players.LocalPlayer
    Character = LocalPlayer.Character
end

--// Main functions

EzAimbot.Disable = function()
    if MainLoop then
        MainLoop:Disconnect()
        MainLoop = nil
    end
    if FOV then
        FOV:Remove()
    end
    RefreshInternals()
end

EzAimbot.Enable = function(showfov,fovconfig, friendlyfire)
    assert(typeof(showfov)=="boolean","EzAimbot.Enable | Expected Boolean as argument #1")
    assert(typeof(fovconfig)=="table","EzAimbot.Enable | Expected Table as argument #2")
    assert(fovconfig["Size"],"EzAimbot.Enable | Expected Size in argument #2")
    assert(fovconfig["Sides"],"EzAimbot.Enable | Expected Sides in argument #2")
    assert(fovconfig["Color"],"EzAimbot.Enable | Expected Color in argument #2")
    assert(type(fovconfig["Size"])=="number","EzAimbot.Enable | Expected Size in argument #2")
    assert(type(fovconfig["Sides"])=="number","EzAimbot.Enable | Expected Sides in argument #2")
    assert(typeof(fovconfig["Color"])=="Color3","EzAimbot.Enable | Expected Color in argument #2")
    assert(type(friendlyfire)=="boolean","EzAimbot.Enable | Expected Boolean as argument #3")
    local Size = fovconfig["Size"]
    local Sides = fovconfig["Sides"]
    local Color = fovconfig["Color"]
    if showfov then
        FOV = Drawing.new("Circle")
        local FOV = FOV
        FOV.NumSides = Sides
        FOV.Position = MousePosition()
        FOV.Radius = Size
        FOV.Thickness = 2
        FOV.Radius = Size
        FOV.Color = Color
        FOV.Visible = true
    end

    -- MainLoop = RunService.RenderStepped:Connect(function()
    --     if FOV then
    --         FOV.Position = MousePosition()
    --     end
    --     if _G.lockedOn then
    --         local ClosestPlayer = ClosestPlayer(friendlyfire)
    --         if ClosestPlayer then
    --             Camera.CFrame = CFrame.new(Camera.CFrame.p,ClosestPlayer.Character[aimPart].CFrame.p);
    --         end
    --         RefreshInternals()
    --     end
    -- end)

    local rate = 0.02; --(runs loop regardless of frames)
    local amount = 0;
    MainLoop = RunService.Heartbeat:Connect(function(dlTime)
        amount = amount + dlTime;
        while amount >= rate do
            amount = amount - rate
            if FOV then
                FOV.Position = MousePosition()
            end
            if _G.lockedOn then
                local ClosestPlayer = ClosestPlayer(friendlyfire)
                if ClosestPlayer then
                    Camera.CFrame = CFrame.new(Camera.CFrame.p,ClosestPlayer.Character[aimPart].CFrame.p);
                end
                RefreshInternals()
            end
        end
    end)
end

return EzAimbot