-- Calls argmap2mup, created for use as client side script

-- print("package: ")
-- print(package) -- separate statement because tables can't be concatenated. Try using json.encode and then print that
-- print("package.path: " .. package.path)

package.path = "/lua_modules/share/lua/5.3/?.lua;" ..
    "/lua/?.lua;" .. "/lua_modules/share/lua/5.3/?/init.lua;" .. package.path

local logging = require "logging"
Logger = logging.new(function(self, level, message)
  -- Might be able to instead use: `window.console:log(x)`
  print(message)
  print("\n")
  return true
end)

-- Set to .DEBUG to activate logging
Logger:setLevel(logging.DEBUG)

Logger:debug("Hello a2m test debug!")

local a2m = require 'argmap2mup'
