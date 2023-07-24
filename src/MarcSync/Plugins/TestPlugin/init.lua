
local MarcSync = script.Parent.Parent.Parent
type MarcSyncClient = typeof(require(MarcSync.Types.MARCSYNC_CLIENT))

local TestPlugin = {}

TestPlugin.Config = {
    Name = "TestPlugin",
    Description = "A Test Plugin",
    Author = "Marc",
    Version = "0.0.1",
    Support = {
        URL = "https://marcsync.dev",
        Email = "test@example.com"
    },
    Setup = {
        MarcSyncVersions = { "0.5.0" },
        SetupAPIVersion = "v1",
        Variables = {
            TestVariable = {
                Type = "string",
                Required = true,
                Default = "Hello World!",
                Description = "A Test Variable"
            },
            TestVariable2 = {
                Type = "number",
                Required = false,
                Description = "A Test Variable"
            }
        }
    }
}

function TestPlugin.init(client: MarcSyncClient)

end

return TestPlugin