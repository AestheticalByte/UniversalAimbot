--[[
    Credits : ToddDev on v3rm for hot library
]]

--// Container
local EzAimbot = {}

--// Internal
local buildID = "0.0.4"
warn('Build ID : '..buildID)

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


function aimingPart(plr)
    if _G.partTarget == "Head" then
        if plr.Character:FindFirstChild("Head") and plr ~= LocalPlayer then
            aimPart = "Head";
        else
            aimPart = nil;
        end
    elseif _G.partTarget == "Torso" then
        if plr.Character:FindFirstChild("Torso") and plr ~= LocalPlayer then
            aimPart = "Torso";
        elseif plr.Character:FindFirstChild("UpperTorso") and plr ~= LocalPlayer then
            aimPart = "UpperTorso";
        else
            aimPart = nil;
        end
    end
end

function healthCheck(plr)
    if plr.Character.Humanoid.Health > 0 then
        return true;
    elseif plr.Character.Humanoid.Health == 0 then
        return false;
    end
    return false;
end

function getAllParts(finalPoint, ignoreList)
    -- // create ray
    local plrCam = Camera.CFrame.p;
    local rayVector = Ray.new(plrCam, finalPoint - plrCam);

    -- // create a table of all parts between LocalPlayer and setTarget
    local partsList = {};

    for _, v in pairs(ignoreList) do
        table.insert(partsList, v)
    end

    local lastPart = true;
    
    while lastPart do
        lastPart = workspace:FindPartOnRayWithIgnoreList(rayVector, partsList)
        table.insert(partsList, lastPart)
    end
    
    for i, v in pairs(partsList) do
        if v == ignoreList[1] or v == ignoreList[2] then
            table.remove(partsList, i)
        end
    end

    -- // check if there are any non humanoid parts obscuring
    local checkHumanoid = true;
    if #partsList ~= 0 then
        for _, v in pairs(partsList) do
            local opt = {
                v.Parent:FindFirstChild('Humanoid');
                v:FindFirstChild('Humanoid');
                v.Parent.Parent:FindFirstChild('Humanoid');
                v:FindFirstChild('Handle');
            }

            if not opt[1] and not opt[2] and not opt[3] and not opt[4] and v.ClassName ~= 'Accessory' and v.Parent.ClassName ~= 'Accessory' then
                print('Obscuring part : ', v:GetFullName())
                checkHumanoid = false;
            end

            if not checkHumanoid then
                return false;
            end
        end
    end
    return true;
end

local setTarget;
local playerSet;

local lockPlayer = function(friendlyfire)
    local radius = FOV.Radius
    local closest = math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        pcall(function()
            if HandleTeam(plr) then
                if healthCheck(plr) then
                    aimingPart(plr);

                    if not setTarget and not playerSet then
                        if aimPart and _G.wallOn then
                            local point, onScreen = Camera:WorldToScreenPoint(plr.Character[aimPart].Position)
                            local distance = (Vector2.new(point.X, point.Y) - MousePosition()).magnitude
                            if distance < math.min(radius, closest) then
                                closest = distance
                                if onScreen and getAllParts(plr.Character[aimPart].Position, {Character, plr.Character}) then
                                    setTarget = plr;
                                end
                            end
                        elseif aimPart and not _G.wallOn then
                            local point = Camera:WorldToScreenPoint(plr.Character[aimPart].Position)
                            local distance = (Vector2.new(point.X, point.Y) - MousePosition()).magnitude
                            if distance < math.min(radius, closest) then
                                closest = distance
                                setTarget = plr;
                            end
                        end
                    end
                end
            end
        end)
    end
    if setTarget and playerSet then
        if healthCheck(setTarget) then

            aimingPart(setTarget);

            if aimPart and _G.wallOn then
                local onScreen = Camera:WorldToScreenPoint(setTarget.Character[aimPart].Position);
                if onScreen and getAllParts(setTarget.Character[aimPart].Position, {Character, setTarget.Character}) then
                    return setTarget;
                end
            elseif aimPart and not _G.wallOn then
                return setTarget;
            end
            warn("Issue encountered!")
            playerSet = false;
            setTarget = nil;
            return setTarget;
        elseif not healthCheck(setTarget) then
            playerSet = false;
            setTarget = nil;
            return setTarget;
        end
    end
    playerSet = true;
    return setTarget;
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

    rate = 0.0025; --(runs loop regardless of frames)
    local amount = 0;
    MainLoop = RunService.Heartbeat:Connect(function(dlTime)
        amount = amount + dlTime;
        while amount >= rate do
            amount = amount - rate
            if FOV then
                FOV.Position = MousePosition() + Vector2.new(0, 35);
            end

            if not _G.lockedOn then
                playerSet = nil;
                setTarget = nil;
            end

            if _G.lockedOn then
                local lockPlayer = lockPlayer(friendlyfire)
                if lockPlayer then
                    Camera.CFrame = CFrame.new(Camera.CFrame.p, lockPlayer.Character[aimPart].CFrame.p);
                end
                RefreshInternals()
            end
        end
    end)
end

return EzAimbot;