-- =========================================================================
-- MODULE: Input Layout Automation
-- =========================================================================
local M = {}

-- map Application Names or Bundle IDs to Input Layouts
local targetApps = {
    ["CotEditor"]                  = "ABC",
    ["com.coteditor.CotEditor"]    = "ABC",

    ["Fork"]                       = "ABC",
    ["com.DanPristupov.Fork"]      = "ABC",

    ["Ghostty"]                    = "ABC",
    ["com.mitchellh.ghostty"]      = "ABC",

    ["Unity"]                      = "ABC",
    ["com.unity3d.UnityEditor5.x"] = "ABC",

    ["Visual Studio Code"]         = "ABC",
    ["com.microsoft.VSCode"]       = "ABC",

    ["Zed"]                        = "ABC",
    ["dev.zed.Zed"]                = "ABC"
}

-- keep a reference to the watcher inside the module to prevent garbage collection
M.watcher = nil

function M.start()
    M.watcher = hs.application.watcher.new(function(appName, eventType, app)
        if eventType == hs.application.watcher.activated then
            -- short-circuit evaluation: only queries the system bundleID if appName lookup fails
            local desiredLayout = targetApps[appName] or targetApps[app:bundleID()]

            if desiredLayout then
                -- get the currently active keyboard layout name
                local currentLayout = hs.keycodes.currentLayout()

                -- only trigger the switch if it's different from the desired layout
                if currentLayout ~= desiredLayout then
                    hs.keycodes.setLayout(desiredLayout)
                end
            end
        end
    end)

    M.watcher:start()
end

return M
