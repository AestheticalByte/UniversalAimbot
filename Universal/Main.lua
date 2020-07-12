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
local fovEnabled = true;
local fovSides = 50; 
local aimbotToggled;
local headToggled = true;

-- // Aimbot library
local EzAimbot = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/AestheticalByte/UniversalAimbot/master/Universal/AimbotLibrary.lua"))();

-- // Toggle Aimbot
local UserInputService = game:GetService("UserInputService");

UserInputService.InputBegan:Connect(function(key)
    if key.KeyCode == Enum.KeyCode[aimSettings['aimToggle']] and not aimbotToggled then
        warn("Aimbot Enabled");
        EzAimbot.Enable(fovEnabled, {["Size"]= aimSettings['fovSize'], ["Sides"]= aimSettings['fovSides'], ["Color"]= aimSettings['fovColor']}, aimSettings['friendlyFire']);
        aimbotToggled = true;
    elseif key.KeyCode == Enum.KeyCode[aimSettings['aimToggle']] and aimbotToggled then
        warn("Aimbot Disabled");
        EzAimbot.Disable();
        aimbotToggled = false;
    end

    if key.KeyCode == Enum.KeyCode[aimSettings['togglePart']] and headToggled then
        warn("Target Set : Torso")
        headToggled = false;
        _G.partTarget = 'Torso';
    elseif key.KeyCode == Enum.KeyCode[aimSettings['togglePart']] and not headToggled then
        warn("Target Set : Head")
        headToggled = true;
        _G.partTarget = 'Head';
    end
end)

warn('Aimbot script loaded...');
