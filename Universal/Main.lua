-- // Mouse press events
_G.lockedOn = nil;
local Mouse = game.Players.LocalPlayer:GetMouse();

Mouse.Button2Down:Connect(function()
	_G.lockedOn = true;
end)

Mouse.Button2Up:Connect(function()
    _G.lockedOn = false;
end)

-- // Global GUI Vars
local screenGui = Instance.new('ScreenGui');
screenGui.Parent = game.StarterGui;

local aimbotToggle = Instance.new('TextLabel');
local aimbotTarget = Instance.new('TextLabel');
local aimbotWalls = Instance.new('TextLabel');

function createGUI()
    -- // textLabelParent
    aimbotToggle.Parent = screenGui;
    aimbotTarget.Parent = screenGui;
    aimbotWalls.Parent = screenGui;

    -- // textText
    aimbotToggle.Text = 'Aimbot : Disabled';
    aimbotTarget.Text = 'Target : Head';
    aimbotWalls.Text = 'WallLock : Enabled';

    -- // textTransparency
    aimbotToggle.BackgroundTransparency = 1;
    aimbotTarget.BackgroundTransparency = 1;
    aimbotWalls.BackgroundTransparency = 1;

    -- // textFont
    aimbotToggle.Font = 'Code';
    aimbotTarget.Font = 'Code';
    aimbotWalls.Font = 'Code';

    -- // textColor
    aimbotToggle.TextColor3 = Color3.new(255, 255, 255);
    aimbotTarget.TextColor3 = Color3.new(255, 255, 255);
    aimbotWalls.TextColor3 = Color3.new(255, 255, 255);

    -- // textBoxSize
    aimbotToggle.Size = UDim2.new(0, 131, 0, 20);
    aimbotTarget.Size = UDim2.new(0, 100, 0, 20);
    aimbotWalls.Size = UDim2.new(0, 131, 0, 20);

    -- // textSize
    aimbotToggle.TextSize = 14;
    aimbotTarget.TextSize = 14;
    aimbotWalls.TextSize = 14;

    -- // textAllignment
    aimbotToggle.TextXAlignment = 'Left';
    aimbotTarget.TextXAlignment = 'Left';
    aimbotWalls.TextXAlignment = 'Left';

    -- // textPosition
    aimbotToggle.Position = UDim2.new(0.005, 0, 0.911, 0);
    aimbotTarget.Position = UDim2.new(0.005, 0, 0.941, 0);
    aimbotWalls.Position = UDim2.new(0.005, 0, 0.97, 0);
end

createGUI()

-- // Basic vars
_G.partTarget = 'Head'; -- Head, Torso
_G.wallOn = true;
local fovEnabled = true;
local fovSides = 50; 
local aimbotToggled = false;
local version = '1.4.1';

-- // Aimbot library
local EzAimbot = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/AestheticalByte/UniversalAimbot/master/Universal/AimbotLibrary.lua"))();

-- // Toggle Aimbot
local UserInputService = game:GetService("UserInputService");

UserInputService.InputBegan:Connect(function(key)
    if key.KeyCode == Enum.KeyCode[_G.aimSettings['aimbotToggle']] and not aimbotToggled then
        aimbotToggle.Text = 'Aimbot : Enabled';
        EzAimbot.Enable(fovEnabled, {["Size"]= _G.aimSettings['fovSize'], ["Sides"]= fovSides, ["Color"]= _G.aimSettings['fovColor']}, _G.aimSettings['friendlyFire']);
        aimbotToggled = true;
    elseif key.KeyCode == Enum.KeyCode[_G.aimSettings['aimbotToggle']] and aimbotToggled then
        aimbotToggle.Text = 'Aimbot : Disabled';
        EzAimbot.Disable();
        aimbotToggled = false;
    end

    if key.KeyCode == Enum.KeyCode[_G.aimSettings['togglePart']] and _G.partTarget == "Head" then
        aimbotTarget.Text = 'Target : Torso';
        _G.partTarget = 'Torso';
    elseif key.KeyCode == Enum.KeyCode[_G.aimSettings['togglePart']] and _G.partTarget == "Torso" then
        aimbotTarget.Text = 'Target : Head';
        _G.partTarget = 'Head';
    end

    if key.KeyCode == Enum.KeyCode[_G.aimSettings['wallDetection']] and _G.wallOn then
        aimbotWalls.Text = 'WallLock : Disabled';
        _G.wallOn = false;
    elseif key.KeyCode == Enum.KeyCode[_G.aimSettings['wallDetection']] and not _G.wallOn then
        aimbotWalls.Text = 'WallLock : Enabled';
        _G.wallOn = true;
    end
end)

warn('Aimbot script loaded...');
warn('version. '..version)
