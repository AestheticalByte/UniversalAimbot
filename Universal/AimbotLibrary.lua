--[[
    Credits : ToddDev on v3rm for hot library
]]

--// Container
local EzAimbot = {}

--// Internal
local buildID = "0.0.5"
warn('Build ID : '..buildID)

local aimPart;
local MainLoop;
local FOV;
local Camera = workspace.CurrentCamera;
local Viewport = Camera.ViewportSize;
local Players = game:GetService("Players");
local LocalPlayer = Players.LocalPlayer;
local Character = LocalPlayer.Character;
local Mouse = LocalPlayer:GetMouse();
local RunService = game:GetService("RunService");
local InputService = game:GetService("UserInputService");

local function mousePosition()
    return Vector2.new(Mouse.X,Mouse.Y);
end

local function HandleTeam(player)
    local team = LocalPlayer.Team;
    if player.Team == team and friendlyfire then
        return true;
    elseif player.Team == team and friendlyfire == false then
        return false;
    else
        return true;
    end
    return true;
end


local function aimingPart(plr)
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
    return aimPart;
end

local function healthCheck(plr)
    if plr.Character.Humanoid.Health > 0 then
        return true;
    elseif plr.Character.Humanoid.Health == 0 then
        return false;
    end
    return false;
end

local function getAllParts(finalPoint)
    -- // create ray
    local plrCam = Camera.CFrame.p;
    local rayVector = Ray.new(plrCam, finalPoint - plrCam);

    -- // create a table of all parts between LocalPlayer and setTarget
    local partsList = {};

    local lastPart = true;
    
    while lastPart do
        lastPart = workspace:FindPartOnRayWithIgnoreList(rayVector, partsList);
        table.insert(partsList, lastPart);
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
                print('Obscuring part : ', v:GetFullName());
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

local function lockPlayer(friendlyfire)
    local radius = FOV.Radius;
    local closest = math.huge;
    if not setTarget then
        for _, plr in pairs(Players:GetPlayers()) do
            if HandleTeam(plr) then
                if healthCheck(plr) and aimingPart(plr) then
                    local point, onScreen = Camera:WorldToScreenPoint(plr.Character[aimPart].Position)
                    local distance = (Vector2.new(point.X, point.Y) - mousePosition()).magnitude
                    if _G.wallOn then
                        if distance < math.min(radius, closest) then
                            closest = distance;
                            if onScreen and getAllParts(plr.Character[aimPart].Position) then
                                setTarget = plr;
                            end
                        end
                    elseif not _G.wallOn then
                        if onScreen and distance < math.min(radius, closest) then
                            closest = distance;
                            setTarget = plr;
                        end
                    end
                end
            end
        end

        if setTarget then
            print("The target is : "..setTarget:GetFullName());
        end
        return setTarget;

    elseif setTarget then
        if healthCheck(setTarget) and aimingPart(setTarget) then
            if _G.wallOn then
                local onScreen = Camera:WorldToScreenPoint(setTarget.Character[aimPart].Position);
                if onScreen and getAllParts(setTarget.Character[aimPart].Position) then
                    return setTarget;
                end
            elseif not _G.wallOn then
                return setTarget;
            end
            -- // debugging purposes
            warn("Issue encountered!")
            setTarget = nil;
            return setTarget;
        elseif not healthCheck(setTarget) then
            warn("Target Died")
            setTarget = nil;
            return setTarget;
        end
    end
end
local function refreshVariables()
    Camera = workspace.CurrentCamera;
    LocalPlayer = Players.LocalPlayer;
    Character = LocalPlayer.Character;
end

--// Main functions
function EzAimbot.Disable()
    if mainLoop then
        mainLoop:Disconnect()
        mainLoop = nil
    end
    if FOV then
        FOV:Remove()
    end
    refreshVariables()
end

function EzAimbot.Enable(showfov,fovconfig, friendlyfire)
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
        FOV.Position = mousePosition()
        FOV.Radius = Size
        FOV.Thickness = 2
        FOV.Radius = Size
        FOV.Color = Color
        FOV.Visible = true
    end

    -- // Mouse functions
    local lockedOn = nil;

    Mouse.Button2Down:Connect(function()
        lockedOn = true;
    end)

    Mouse.Button2Up:Connect(function()
        lockedOn = false;
    end)

    -- // Camera functions
    function isThirdPerson()
        if (Character.Head.CFrame.p - Camera.CFrame.p).magnitude < 1 then
            return false;
        elseif (Character.Head.CFrame.p - Camera.CFrame.p).magnitude > 1 then
            return true;
        end
    end

    -- -- // runs loop regardless of frames without relying on wait()
    rate = 0.007;
    local amount = 0;
    mainLoop = RunService.Heartbeat:Connect(function(dlTime)
        amount = amount + dlTime;
        while amount >= rate do
            amount = amount - rate
            if FOV then
                FOV.Position = mousePosition() + Vector2.new(0, 35);
            end

            if lockedOn then
                if lockPlayer(friendlyFire) then
                        Camera.CFrame = CFrame.new(Camera.CFrame.p, setTarget.Character[aimPart].CFrame.p);
                end
            elseif not lockedOn then
                setTarget = nil;
            end
            refreshVariables()
        end
    end)
end

return EzAimbot;