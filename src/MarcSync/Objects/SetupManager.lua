
-- VARIABLES
local MarcSync = script.Parent.Parent

local SetupManager = {}

function SetupManager.checkInstallation()
    if not MarcSync:FindFirstChild("Plugins") or not MarcSync:FindFirstChild("Plugins"):IsA("Folder") then return end

end

function SetupManager._new()
    local self = setmetatable({}, SetupManager)
    return self
end

return SetupManager