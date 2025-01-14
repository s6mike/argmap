#!/usr/bin/env lua
-- A pipe that reads mindmup `mup` files and outputs `yaml` argument maps.

-- Sets up shared 'environment' variables:
local config_argmap = require 'config_argmap'

-- uses pl.app.parse_args() to parse cli options
local pl      = require 'pl.import_into' ()
-- uses lyaml to parse yaml
local lyaml   = require 'lyaml'
local json    = require 'rxi-json-lua'
local logging = require 'logging'

-- [LuaLogging: A simple API to use logging features in Lua](https://neopallium.github.io/lualogging/manual.html#introduction)
local logger = logging.new(function(self, level, message)
    io.stderr:write(message)
    io.stderr:write("\n")
    return true
end)

-- Set to .DEBUG to activate logging
-- TODO set this with a command line argument, then use in launch.json
--   Try this approach: lua -e'a=1' -e 'print(a)' script.lua
--   https://www.lua.org/manual/5.3/manual.html#6.10
logger:setLevel(logging.ERROR)

function dig_in(table, fields)
    local t = table
    local result = true
    for _, f in pairs(fields) do
        if t[f] then
            t = t[f]
        else
            result = false
            break
        end
    end
    if result then
        return t
    else
        return nil
    end
end

function parse_claims(claims, strength, label)
    local argmap = {}
    if strength then
        argmap["strength"] = strength
    end
    if label then
        argmap["label"] = label
    end
    for _, items in pairs(claims) do
        local key = items["title"]
        local styles = dig_in(items, { "attr", "styleNames" })
        if styles and styles[1] == "attr_implicit_claim" then
            key = "-" .. key
        end
        local note = dig_in(items, { "attr", "note", "text" })
        local reasons = {}
        if items["ideas"] then
            reasons = parse_reasons(items["ideas"], note)
        elseif note then
            reasons = reasons["note"]
        end
        argmap[key] = reasons
    end
    return argmap
end

function parse_reasons(reasons, note)
    local argmap = {}
    argmap["note"] = note
    for index, items in pairs(reasons) do
        local key = ""
        local type = items["attr"]["group"]
        if type == "opposing" then
            key = "o" .. index
        else
            key = "r" .. index
        end
        local strength = dig_in(items, { "attr", "parentConnector", "width" })
        local label = dig_in(items, { "attr", "parentConnector", "label" })
        logger:debug('reasons, index, items["ideas"], strength, label: ')
        logger:debug(reasons, index, items["ideas"], strength, label)
        logger:debug('')
        local claims = parse_claims(items["ideas"], strength, label)
        argmap[key] = claims
    end
    return argmap
end

function help()
    return [[mup2argmap <options> <file>
  -e, --embed:      wrap in code block for embedding in pandoc markdown 
  -g, --gdrive_id:  parse mup file with corresponding Google Drive ID
  -h:               show this help]]
end

function parse_options(a)
    local opts = {}
    local flags, args = pl.app.parse_args(a, { g = true, gdrive_id = true })
    opts["help"] = flags["h"] or flags["help"]
    opts["wrap"] = flags["e"] or flags["embed"]
    opts["gdrive_id"] = flags["g"]
    if not opts["gdrive_id"] then
        opts["gdrive_id"] = flags["gdrive_id"]
    end
    if #args > 0 then
        opts["file"] = args[1]
    end
    return opts
end

function main()
    local opts = parse_options(arg)
    if opts["help"] then
        return help()
    else
        local input = ""
        if opts["gdrive_id"] then
            local f = assert(io.popen("gdrive download --stdout --no-progress " .. " " .. opts["gdrive_id"]))
            input = f:read("*all")
            f:close()
        elseif opts["file"] then
            local f = assert(io.open(opts["file"], 'r'))
            input = f:read("*all")
            f:close()
        else
            input = io.read("*all")
        end
        local mup = json.decode(input)
        local argmap = parse_claims(mup["ideas"], nil, nil)
        local name = mup["title"]
        local yml = lyaml.dump({ argmap })
        if opts["wrap"] then
            local attr = ""
            if name then
                attr = " name=\"" .. name .. "\""
            end
            if opts["gdrive_id"] then
                attr = attr .. " gid=\"" .. opts["gdrive_id"] .. "\""
            end
            return "```{.argmap " .. attr .. "}\n" .. yml .. "```\n"
        else
            return yml
        end
    end
end

-- TODO is print best practice for this purpose?
print(main())
