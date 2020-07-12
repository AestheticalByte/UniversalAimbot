--[[
    Credits : ToddDev on v3rm for hot library
]]

-- // Container

local EzAimbot = {}

-- // Internal

local aimPart;
local MainLoop;
local Camera = workspace.CurrentCamera;
local Viewport = Camera.ViewportSize;
local Players = game:GetService("Players");
local LocalPlayer = Players.LocalPlayer;
local Character = LocalPlayer.Character;
local Mouse = LocalPlayer:GetMouse();
local FOV;
local RunService = game:GetService("RunService");
local InputService = game:GetService("UserInputService");

local MousePosition = function()
    return Vector2.new(Mouse.X,Mouse.Y);
end

function aimPart(target, plr)
    print(target)
    if target == "Head" then
        if plr.Character:FindFirstChild("Head") and v ~= LocalPlayer then
            aimPart = 'Head';
            return true;
        elseif not plr.Character:FindFirstChild("Head") or v == LocalPlayer then
            return false;
        end
    elseif target == "Torso" then
        if v ~= LocalPlayer then
            if plr.Character:FindFirstChild("Torso") then
                aimPart = 'Torso';
                return true;
            elseif plr.Character:FindFirstChild("UpperTorso") then
                aimPart = 'UpperTorso'
                return true;
            end
        elseif v == LocalPlayer or not (plr.Character:FindFirstChild("UpperTorso") or plr.Character:FindFirstChild("Torso")) then
            return false;
        end
    end
    print("This line of code shouldn't print!")
end

function HandleTeam(player)
    local Team = LocalPlayer.Team;
    if player.Team == Team and friendlyfire then
        return true;
    elseif player.Team == Team and friendlyfire == false then
        return false;
    else
        return true;
    end
    return true;
end

local closestPlayer = function(friendlyfire)
    local MousePos = MousePosition();
    local Radius = FOV.Radius;
    local closest = math.huge;
    local target;
    for k, v in pairs(Players:GetPlayers()) do
        pcall(function()
            if HandleTeam(v) then
                if aimPart(_G.partTarget, v) then
                    print("---")
                    print("Player detected : "..v);
                    local Point, OnScreen = Camera:WorldToScreenPoint(v.Character[aimPart].Position);
                    if OnScreen and #Camera:GetPartsObscuringTarget({Character[aimPart].Position, v.Character[aimPart].Position}, {Character, v.Character}) == 0 then
                        local distance = (Vector2.new(Point.X, Point.Y) - MousePosition()).magnitude;
                        if distance < math.min(Radius, closest) then
                            closest = distance;
                            target = v;
                        end
                    end
                end
            end
        end)
    end
    return target
end

local RefreshInternals = function()
    Camera = workspace.CurrentCamera;
    LocalPlayer = Players.LocalPlayer;
    Character = LocalPlayer.Character;
end

--// Main functions

EzAimbot.Disable = function()
    if MainLoop then
        MainLoop:Disconnect();
        MainLoop = nil;
    end
    if FOV then
        FOV:Remove();
    end
    RefreshInternals();
end

EzAimbot.Enable = function(showfov, fovconfig, friendlyfire)
    assert(typeof(showfov)=="boolean","EzAimbot.Enable | Expected Boolean as argument #1");
    assert(typeof(fovconfig)=="table","EzAimbot.Enable | Expected Table as argument #2");
    assert(fovconfig["Size"],"EzAimbot.Enable | Expected Size in argument #2");
    assert(fovconfig["Sides"],"EzAimbot.Enable | Expected Sides in argument #2");
    assert(fovconfig["Color"],"EzAimbot.Enable | Expected Color in argument #2");
    assert(type(fovconfig["Size"])=="number","EzAimbot.Enable | Expected Size in argument #2");
    assert(type(fovconfig["Sides"])=="number","EzAimbot.Enable | Expected Sides in argument #2");
    assert(typeof(fovconfig["Color"])=="Color3","EzAimbot.Enable | Expected Color in argument #2");
    assert(type(friendlyfire)=="boolean","EzAimbot.Enable | Expected Boolean as argument #3");
    local Size = fovconfig["Size"];
    local Sides = fovconfig["Sides"];
    local Color = fovconfig["Color"];
    if showfov then
        FOV = Drawing.new("Circle");
        local FOV = FOV;
        FOV.NumSides = Sides;
        FOV.Position = MousePosition();
        FOV.Radius = Size;
        FOV.Thickness = 2;
        FOV.Radius = Size;
        FOV.Color = Color;
        FOV.Visible = true;
    end
    
    MainLoop = RunService.RenderStepped:Connect(function()
        if FOV then
            FOV.Position = MousePosition() + Vector2.new(0, 35);
        end

        if _G.lockedOn then
            local closestPlayer = closestPlayer(friendlyfire)
            if closestPlayer then
                print("Locked onto : "..aimPart)
                Camera.CFrame = CFrame.new(Camera.CFrame.p, closestPlayer.Character[aimPart].CFrame.p);
            end
            RefreshInternals()
        end
    end)
end

return EzAimbot