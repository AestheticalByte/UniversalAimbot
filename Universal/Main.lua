-- // Mouse press events
_G.lockedOn = nil;
local Mouse = game.Players.LocalPlayer:GetMouse();

Mouse.Button2Down:Connect(function()
	_G.lockedOn = true;
end)

Mouse.Button2Up:Connect(function()
    _G.lockedOn = false;
end)

-- // Basic vars
_G.partTarget = 'Head'; -- Head, Torso
_G.wallOn = true;
local fovEnabled = true;
local fovSides = 50; 
local aimbotToggled = false;
local version = '1.1.2';

-- // Aimbot library
local EzAimbot = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/AestheticalByte/UniversalAimbot/master/Universal/AimbotLibrary.lua"))();

-- // Toggle Aimbot
local UserInputService = game:GetService("UserInputService");

UserInputService.InputBegan:Connect(function(key)
    if key.KeyCode == Enum.KeyCode[_G.aimSettings['aimbotToggle']] and not aimbotToggled then
        warn("Aimbot Enabled");
        EzAimbot.Enable(fovEnabled, {["Size"]= _G.aimSettings['fovSize'], ["Sides"]= fovSides, ["Color"]= _G.aimSettings['fovColor']}, _G.aimSettings['friendlyFire']);
        aimbotToggled = true;
    elseif key.KeyCode == Enum.KeyCode[_G.aimSettings['aimbotToggle']] and aimbotToggled then
        warn("Aimbot Disabled");
        EzAimbot.Disable();
        aimbotToggled = false;
    end

    if key.KeyCode == Enum.KeyCode[_G.aimSettings['togglePart']] and _G.partTarget == "Head" then
        warn("Target Set : Torso")
        _G.partTarget = 'Torso';
    elseif key.KeyCode == Enum.KeyCode[_G.aimSettings['togglePart']] and _G.partTarget == "Torso" then
        warn("Target Set : Head")
        _G.partTarget = 'Head';
    end

    if key.KeyCode == Enum.KeyCode[_G.aimSettings['wallDetection']] and _G.wallOn then
        warn("Wall detection turned off.")
        _G.wallOn = false;
    elseif if key.KeyCode == Enum.KeyCode[_G.aimSettings['togglePart']] and not _G.wallOn then
        warn("Wall detection turned on.");
        _G.wallOn = true;
    end
end)

warn('Aimbot script loaded...');
warn('version. '..version)
