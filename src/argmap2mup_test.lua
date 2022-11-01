-- Calls argmap2mup, created for use as client side script

-- local config = {}

-- -- QUESTION: Use PANDOC_SCRIPT_FILE instead?

project_folder = "/home/s6mike/git_projects/argmap"

-- -- Didn't work from extension:
package.path = project_folder ..
    "/src/?.lua;" ..
    project_folder ..
    "/lua_modules/share/lua/5.3/?/init.lua;" ..
    project_folder ..
    "/lua_modules/share/lua/5.3/?.lua;" .. project_folder .. "/lua_modules/share/lua/5.3/?/init.lua;"
    .. package.path

package.path = "/home/s6mike/git_projects/argmap/lua_modules/share/lua/5.3/?.lua;../lua_modules/share/lua/5.3/?.lua;" ..
    package.path

print("package: ")
print(package) -- separate statement because tables can't be concatenated. Try using json.encode and then print that
print("package.path: " .. package.path)

-- package.path = "/lua/?.lua;" ..
--     "/lua_modules/share/lua/5.3/?/init.lua;" ..
--     "/lua_modules/share/lua/5.3/?.lua;" .. package.path

-- package.cpath = "/home/s6mike/git_projects/argmap/lua_modules/lib/lua/5.3/?.so;" -- /opt/miniconda3/envs/argumend/lib/lua/5.3/?.so;" .. package.cpath

-- /home/s6mike/git_projects/argmap/lua_modules/share/lua/5.3/?.lua
-- Or try: '../../lua_modules/share/lua/5.3/logging.lua'
-- Or try: '../../lua_modules/share/lua/5.3/?.lua'
-- local logging = require "/home/s6mike/git_projects/argmap/lua_modules/share/lua/5.3/logging.lua"
local logging = require "../lua_modules/share/lua/5.3/logging.lua"
-- local logging = require "logging"
Logger = logging.new(function(self, level, message)
  -- Might be able to instead use: `window.console:log(x)`
  print(message)
  print("\n")
  return true
end)

-- local yaml_path = "/home/s6mike/git_projects/argmap/lua_modules/lib/lua/5.3/yaml.so"
local yaml_path = "/lua_modules/lib/lua/5.3/yaml.so"
local lyaml_load = assert(package.loadlib(yaml_path, "load"))
local template = lyaml_load([=[
  weight: normal
  ...
  ]=])

-- Set to .DEBUG to activate logging
Logger:setLevel(logging.DEBUG)

Logger:debug("Hello a2m debug!")

-- Logger:debug("cpath: " .. package.cpath)

-- local a2m = require 'argmap2mup'
