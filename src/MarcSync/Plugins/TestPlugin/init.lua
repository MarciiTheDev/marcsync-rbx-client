
local MarcSync = script.Parent.Parent.Parent
type MarcSyncClient = typeof(require(MarcSync.Types.MARCSYNC_CLIENT))

local TestPlugin = {}

function TestPlugin.init(client: MarcSyncClient)
        
end

return TestPlugin