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
_G.headTarget = true;
local fovEnabled = true;
local fovSides = 50; 
local aimbotToggled;
local headToggled = true;

-- // Editable vars
local fovSize = 80;
local friendlyFire = true;
local togglePart = "E"; -- Set to lock onto head by default
local aimbotToggle = "F1";
local fovColor = Color3.fromRGB(127, 0, 255);

-- // Aimbot library
local EzAimbot = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/AestheticalByte/UniversalAimbot/master/Universal/AimbotLibrary.lua"))();

-- // Toggle Aimbot
local UserInputService = game:GetService("UserInputService");

UserInputService.InputBegan:Connect(function(key)
    if key.KeyCode == Enum.KeyCode[aimbotToggle] and not aimbotToggled then
        warn("Aimbot Enabled");
        EzAimbot.Enable(fovEnabled, {["Size"]= fovSize, ["Sides"]= fovSides, ["Color"]= fovColor}, friendlyFire);
        aimbotToggled = true;
    elseif key.KeyCode == Enum.KeyCode[aimbotToggle] and aimbotToggled then
        warn("Aimbot Disabled");
        EzAimbot.Disable();
        aimbotToggled = false;
    end

    if key.KeyCode == Enum.KeyCode[togglePart] and headToggled then
        warn("Target Set : Torso")
        headToggled = false;
        _G.headTarget = false;
    elseif key.KeyCode == Enum.KeyCode[togglePart] and not headToggled then
        warn("Target Set : Head")
        headToggled = true;
        _G.headTarget = true;
    end
end)

warn('Aimbot script loaded...');
