-- Copyright 2022 Michael Hayes and the argmap contributors
-- SPDX-License-Identifier: MIT

-- Configures global variables for lua files.

-- If this file showing up as not found, then in calling file add:
-- package.path = "/home/s6mike/git_projects/argmap/src/lua/?.lua;" .. package.path

-- Use to add breakpoint:
-- if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
--     require("lldebugger").start()
-- end

local config = {}

-- QUESTION: Use PANDOC_SCRIPT_FILE instead?
config.project_folder = os.getenv("WORKSPACE") or "/home/s6mike/git_projects/argmap"
-- QUESTION: Should I changes this from a global variable to part of config?
PATH_DIR_ARGMAP_LUA = os.getenv("PATH_DIR_ARGMAP_LUA") or config.project_folder .. "/src/lua"

-- Didn't work from extension:
package.path = os.getenv("LUA_PATH") or
    PATH_DIR_ARGMAP_LUA .. "?.lua;" ..
    config.project_folder ..
    "/lua_modules/share/lua/5.3/?/init.lua;" ..
    config.project_folder ..
    "/lua_modules/share/lua/5.3/?.lua;"
    .. package.path

-- Currently using lua-debugger, see: https://workflowy.com/#/8b71cb424dda
-- If lldebugger showing up as not found, then add:
-- package.path = "/home/s6mike/.vscode/extensions/tomblind.local-lua-debugger-vscode-0.3.3/debugger/?.lua;" .. package.path

package.cpath = os.getenv("LUA_CPATH") or
    config.project_folder ..
    "/lua_modules/lib/lua/5.3/?.so;" .. "/opt/miniconda3/envs/argmap/lib/lua/5.3/?.so;"
    .. package.cpath

-- LuaLogging: A simple API to use logging features in Lua: https://neopallium.github.io/lualogging/manual.html#introduction

-- For html links, use relative paths (to test/output folder) - more portable
DIR_MJS_JSON = os.getenv("DIR_MJS_JSON") or "mapjs-json"

-- QUESTION: Should I be using a path join function?
DIR_PUBLIC_OUTPUT = os.getenv("DIR_PUBLIC_OUTPUT") or (config.project_folder .. "/test/output")
PATH_DIR_PUBLIC_MJS_JSON = os.getenv("PATH_DIR_PUBLIC_MJS_JSON") or (DIR_PUBLIC_OUTPUT .. "/" .. DIR_MJS_JSON)
DIR_HTML_SERVER_OUTPUT = os.getenv("DIR_HTML_SERVER_OUTPUT") or "output"

PATH_DIR_LAYOUTS = os.getenv("PATH_DIR_LAYOUTS") or config.project_folder .. "/src/layouts" -- Reads the container and controls html
PATH_DIR_TEMPLATES = os.getenv("PATH_DIR_TEMPLATES") or PATH_DIR_LAYOUTS .. "/templates" -- Reads the container and controls html
PATH_DIR_INCLUDES = os.getenv("PATH_DIR_INCLUDES") or PATH_DIR_LAYOUTS .. "/includes" -- Reads the container and controls html

PATH_INCLUDES_ARGMAP_CONTROLS = os.getenv("PATH_INCLUDES_ARGMAP_CONTROLS") or
    PATH_DIR_INCLUDES .. "/mapjs-widget-controls.html"

-- Reads the container and controls html
PATH_INCLUDES_ARGMAP_CONTAINER = os.getenv("PATH_INCLUDES_ARGMAP_CONTAINER") or
    PATH_DIR_INCLUDES .. "/mapjs-map-container.html"

local logging = require 'logging'
Logger = logging.new(function(self, level, message)
    io.stderr:write(message)
    io.stderr:write("\n")
    return true
end)

-- TODO set this with a command line argument, then use in launch.json
--   Try this approach: lua -e'a=1' -e 'print(a)' script.lua
--   https://www.lua.org/manual/5.3/manual.html#6.10

-- Set to .DEBUG to activate logging
Logger:setLevel(logging.ERROR)
-- Logger:setLevel(logging.DEBUG)


-- os.getenv("LUA_PATH") returns nil when run with Markdown Preview Enhanced VSCode extension
Logger:debug("LUA_PATH: " .. (os.getenv("LUA_PATH") or ""))

-- Logger:debug("message: ".. message) -- tables can't be concatenated so use separate debug message.

return config