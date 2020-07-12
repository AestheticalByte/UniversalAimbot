--[[
    Credits : ToddDev on v3rm for hot library
]]

-- // Container

local EzAimbot = {}

-- // Internal

local aimPart;
local MainLoop = nil
local Camera = workspace.CurrentCamera
local Viewport = Camera.ViewportSize
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character
local Mouse = LocalPlayer:GetMouse()
local FOV = nil
local RunService = game:GetService("RunService")
local InputService = game:GetService("UserInputService")

local MousePosition = function()
    return Vector2.new(Mouse.X,Mouse.Y)
end

function aimPart(bool)
    if bool then
        if v.Character:FindFirstChild("Head") and v ~= LocalPlayer then
            aimPart = 'Head';
        end
    elseif not bool then
        if v ~= LocalPlayer then
            if v.Character:FindFirstChild("Torso") then
                aimPart = 'Torso';
            elseif v.Character:FindFirstChild("UpperTorso") then
                aimPart = 'UpperTorso'
            end
        end
    end
end

local ClosestPlayer = function(friendlyFire)
    local MousePos = MousePosition()
    local Radius = FOV.Radius
    local Closest = math.huge
    local Target = nil
    local function HandleTeam(player)
        local Team = LocalPlayer.Team
        local Result = true
        if player.Team == Team and friendlyFire then
            Result = true
        elseif player.Team == Team and friendlyFire == false then
            Result = false
        else
            Result = true
        end
        return Result
    end
    for k,v in pairs(Players:GetPlayers()) do
        pcall(function()
            if HandleTeam(v) then
                aimPart(_G.headTarget);
                local Point, OnScreen = Camera:WorldToScreenPoint(v.Character.Head.Position);
                if OnScreen and #Camera:GetPartsObscuringTarget({Character[aimPart].Position, v.Character.Head.Position}, {Character, v.Character}) == 0 then
                    local Distance = (Vector2.new(Point.X, Point.Y) - MousePosition()).Magnitude;

                    if Distance < math.min(Radius, Closest) then
                        Closest = Distance;
                        Target = v;
                    end
                end
            end
        end)
    end
    return Target
end

local RefreshInternals = function()
    Camera = workspace.CurrentCamera;
    LocalPlayer = Players.LocalPlayer;
    Character = LocalPlayer.Character;
    aimPart(_G.headTarget);
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

EzAimbot.Enable = function(showFov, fovConfig, friendlyFire)
    assert(typeof(showFov)=="boolean","EzAimbot.Enable | Expected Boolean as argument #1")
    assert(typeof(fovConfig)=="table","EzAimbot.Enable | Expected Table as argument #2")
    assert(fovConfig["Size"],"EzAimbot.Enable | Expected Size in argument #2")
    assert(fovConfig["Sides"],"EzAimbot.Enable | Expected Sides in argument #2")
    assert(fovConfig["Color"],"EzAimbot.Enable | Expected Color in argument #2")
    assert(type(fovconfig["Size"])=="number","EzAimbot.Enable | Expected Size in argument #2")
    assert(type(fovconfig["Sides"])=="number","EzAimbot.Enable | Expected Sides in argument #2")
    assert(typeof(fovconfig["Color"])=="Color3","EzAimbot.Enable | Expected Color in argument #2")
    assert(type(friendlyFire)=="boolean","EzAimbot.Enable | Expected Boolean as argument #3")
    local Size = fovConfig["Size"]
    local Sides = fovConfig["Sides"]
    local Color = fovConfig["Color"]
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
    
    MainLoop = RunService.RenderStepped:Connect(function()
        if FOV then
            FOV.Position = MousePosition() + Vector2.new(0, 35)
        end

        if _G.lockedOn then
            local ClosestPlayer = ClosestPlayer(friendlyFire)
            if ClosestPlayer then
                Camera.CFrame = CFrame.new(Camera.CFrame.p, ClosestPlayer.Character[aimPart].CFrame.p)
            end
            RefreshInternals()
        end
    end)
end

return EzAimbot