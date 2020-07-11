-- // Mouse press events

_G.lockedOn = nil;
local Mouse = game.Players.LocalPlayer:GetMouse();

Mouse.Button2Down:Connect(function()
	_G.lockedOn = true;
end)

Mouse.Button2Up:Connect(function()
    _G.lockedOn = false;
end)

--[[
    Only change fovSize, friendlyFire & aimbotToggle.
]]

-- // Basic vars

local fovEnabled = true;
local fovSize = 80; -- players inside of this area will be locked onto
local fovSides = 50; 
local fovColor = Color3.fromRGB(127, 0, 255);
local friendlyFire = true; -- >>bool<< [true - lock-on teammates], [false - avoid locking on teammates]
local aimbotToggle = "F1";
local aimbotToggled;

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
end)

warn('Aimbot script loaded...');
