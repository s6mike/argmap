#!/usr/bin/env lua

-- a pipe that parses a yaml argument map and generates a JSON encoded mindmup map.

-- Sets up shared 'environment' variables:
local config_argmap = require 'config_argmap'

-- uses pl.app.parse_args() to parse cli options
local pl = require 'pl.import_into' ()

-- uses lyaml to parse yaml
local lyaml = require 'lyaml'
local json  = require 'rxi-json-lua'

-- initialize the output map
local output = { ["ideas"] = {} }

-- initialize a global counter for providing unique ids
local gn = 0

-- default options
local gdrive_id = nil
local gdriveFolder = nil
-- the google ID of the default folder to upload to:
--local gdriveFolder = "1cSnE4jv5f1InNVgYg354xRwVPY6CvD0x" -- 'GDrive/_1. Shared/Personal Admin/Personal Projects/ArguMend GDrive/Mindmup/argmap_uploads'
local name = nil
local upload = false
local public = ""

-- a long string containing all the styling needed for argument maps
-- TODO: move this yaml template into a file and load the file. Will make code more readable and better for version control.
local template = lyaml.load([=[
---
formatVersion: 3
id: root
attr:
  theme: argMappingSimple
theme:
  name: 'MindMup Top Down Argument Mapping'
  connectorEditingContext:
    name: argument-mapping
    allowed:
      - width
      - label
    defaults:
      width: 3
  blockThemeOverrides: true
  layout:
    orientation: top-down
    spacing:
      h: 20
      v: 60
  node:
    -
      name: default
      cornerRadius: 5
      backgroundColor: '#ffffff'
      border:
        type: surround
        line:
          color: '#707070'
          width: 1
      shadow:
        -
          color: '#070707'
          opacity: 0.3
          offset:
            width: 2
            height: 2
          radius: 2
      text:
        margin: 5
        alignment: start
        maxWidth: 146
        color: '#4F4F4F'
        lightColor: '#EEEEEE'
        darkColor: '#000000'
        font:
          lineSpacing: 2
          lineSpacingPx: 2.6
          size: 10
          sizePx: 13.3
          weight: light
      connections:
        default:
          h: center-separated
          v: base
        from:
          horizontal:
            h: center-separated
            v: base
        to:
          h: center
          v: top
      decorations:
        height: 16
        edge: top
        overlap: true
        position: end
    -
      name: attr_implicit_claim
      border:
        type: surround
        line:
          color: '#707070'
          width: 1
          style: dashed
    -
      name: activated
      border:
        type: surround
        line:
          color: '#22AAE0'
          width: 3
          style: dotted
    -
      name: activated.attr_implicit_claim
      border:
        type: surround
        line:
          color: '#22AAE0'
          width: 3
          style: dashed
    -
      name: selected
      shadow:
        -
          color: '#000000'
          opacity: 0.9
          offset:
            width: 2
            height: 2
          radius: 2
    -
      name: collapsed
      shadow:
        -
          color: '#888888'
          offset:
            width: 0
            height: 1
          radius: 0
        -
          color: '#FFFFFF'
          offset:
            width: 0
            height: 3
          radius: 0
        -
          color: '#888888'
          offset:
            width: 0
            height: 4
          radius: 0
        -
          color: '#FFFFFF'
          offset:
            width: 0
            height: 6
          radius: 0
        -
          color: '#888888'
          offset:
            width: 0
            height: 7
          radius: 0
    -
      name: collapsed.selected
      shadow:
        -
          color: '#FFFFFF'
          offset:
            width: 0
            height: 1
          radius: 0
        -
          color: '#888888'
          offset:
            width: 0
            height: 3
          radius: 0
        -
          color: '#FFFFFF'
          offset:
            width: 0
            height: 6
          radius: 0
        -
          color: '#555555'
          offset:
            width: 0
            height: 7
          radius: 0
        -
          color: '#FFFFFF'
          offset:
            width: 0
            height: 10
          radius: 0
        -
          color: '#333333'
          offset:
            width: 0
            height: 11
          radius: 0
    -
      name: attr_group
      cornerRadius: 10
      backgroundColor: transparent
      border:
        type: overline
      shadow:
        -
          color: transparent
      text:
        margin: 0
        alignment: center
        color: '#4F4F4F'
        lightColor: '#EEEEEE'
        darkColor: '#000000'
        font:
          lineSpacing: 2.5
          lineSpacingPx: 3.25
          size: 9
          sizePx: 12
          weight: bold
      connections:
        style: supporting-group
        childstyle: no-connector
        default:
          h: center
          v: base
        from:
          below:
            h: center
            v: base
        to:
          h: center
          v: top
    -
      name: attr_group_supporting
      connections:
        style: supporting-group
        childstyle: no-connector
        default:
          h: center
          v: base
        from:
          below:
            h: center
            v: base
        to:
          h: center
          v: top
    -
      name: attr_group_supporting.level_1
      backgroundColor: 'rgba(0, 255, 0, 0.2)'
      border:
        type: surround
        line:
          color: transparent
          width: 2
          style: solid
    -
      name: attr_group_supporting.activated
      backgroundColor: 'rgba(0, 255, 0, 0.2)'
      border:
        type: surround
        line:
          color: '#00FF00'
          width: 3
          style: dotted
    -
      name: attr_group_opposing
      connections:
        style: opposing-group
        childstyle: no-connector
        default:
          h: center
          v: base
        from:
          below:
            h: center
            v: base
        to:
          h: center
          v: top
    -
      name: attr_group_opposing.level_1
      backgroundColor: 'rgba(255, 0, 0, 0.2)'
      border:
        type: surround
        line:
          color: transparent
          width: 2
          style: solid
    -
      name: attr_group_opposing.activated
      backgroundColor: 'rgba(255, 0, 0, 0.2)'
      border:
        type: surround
        line:
          color: '#FF0000'
          width: 3
          style: dotted
    -
      name: attr_group_supporting.droppable
      backgroundColor: 'rgba(0, 255, 0, 0.6)'
      border:
        type: surround
        line:
          color: '#00FF00'
          width: 3
          style: dashed
    -
      name: attr_group_opposing.droppable
      backgroundColor: 'rgba(255, 0, 0, 0.6)'
      border:
        type: surround
        line:
          color: '#FF0000'
          width: 3
          style: dashed
  connector:
    default:
      type: vertical-quadratic-s-curve
      line:
        color: '#707070'
        width: 1
      label:
        position:
          aboveEnd: 15
          ratio: 0.8
        backgroundColor: white
        borderColor: white
        text:
          color: '#4F4F4F'
          font:
            size: 9
            sizePx: 12
            weight: normal
    no-connector:
      type: no-connector
      line:
        color: '#707070'
        width: 0
    supporting-group:
      type: vertical-quadratic-s-curve
      line:
        color: '#339966'
        width: 3
      label:
        position:
          aboveEnd: 15
          ratio: 0.8
        backgroundColor: white
        borderColor: white
        text:
          color: '#339966'
          font:
            size: 9
            sizePx: 12
            weight: normal
    opposing-group:
      type: vertical-quadratic-s-curve
      line:
        color: '#FF0000'
        width: 3
      label:
        position:
          aboveEnd: 15
          ratio: 0.8
        backgroundColor: white
        borderColor: white
        text:
          color: '#FF0000'
          font:
            size: 9
            sizePx: 12
            weight: normal
    no-connector.supporting-group:
      type: no-connector
      line:
        color: '#339966'
        width: 4
      label:
        position:
          ratio: 0.5
        backgroundColor: transparent
        borderColor: transparent
        text:
          color: '#339966'
          font:
            size: 6
            sizePx: 9
            weight: normal
    no-connector.opposing-group:
      type: no-connector
      line:
        color: '#FF0000'
        width: 4
      label:
        position:
          ratio: 0.5
        backgroundColor: transparent
        borderColor: transparent
        text:
          color: '#4F4F4F'
          font:
            size: 6
            sizePx: 9gg
            weight: normal
...
]=])

function pipe_in_out(cmd, s)
  -- a function for piping through unix commands
  local tmp = os.tmpname()
  local tmpout = os.tmpname()
  local f = assert(io.open(tmp, 'w'))
  f:write(s)
  f:close()
  local fout = assert(io.popen(cmd .. " " .. tmp))
  local o = fout:read("*all")
  fout:close()
  os.remove(tmp)
  os.remove(tmpout)

  Logger:debug("pipe_in_out (cmd, input, output): " .. cmd .. ", " .. s .. ", " .. o)

  return o
end

local function trim(s)
  -- trim trailing newlines
  return (s:gsub("\n", ""))
end

function markdown_to_plain(s)
  return trim(pipe_in_out("pandoc --wrap=none -t plain -f markdown", s))
end

function parse_special(t, s)
  -- a function for parsing notes, labels, and strengths
  for i, v in pairs(t) do
    if string.match(i, "^" .. s .. "$") then
      return v
    end
  end
  return nil
end

function parse_claims(t)
  -- initialize the output table
  local o = {}
  -- initialize a local counter for ids
  local n = 0
  for i, v in pairs(t) do
    if not string.match(i, "^label$") and not string.match(i, "^strength$") then
      -- manage counters
      n = n + 1
      gn = gn + 1
      local id = tostring(n)
      local gid = tostring(gn)
      -- the key is the claim
      local claim = i
      -- if we haven't set a name for our map yet, use the claim as the name.
      if not name then
        name = claim
      end
      local attr = {}
      -- claims that begin with a '-' are styled as implicit premises
      if string.match(claim, "^-.*") then
        claim = string.sub(claim, 2, -1)
        attr = {
          ["styleNames"] = { "attr_implicit_claim" }
        }
      end
      claim = markdown_to_plain(claim)
      local note = parse_special(v, "note")
      if note then
        note = markdown_to_plain(note)
        gn = gn + 1
        attr["note"] = {
          ["index"] = gn,
          ["text"] = note
        }
      end
      o[id] = {
        ["title"] = claim,
        ["id"] = gid,
        ["attr"] = attr,
        ["ideas"] = parse_reasons(v)
      }
    end
  end
  return o
end

function parse_reasons(t)
  local o = {}
  local n = 0
  for i, v in pairs(t) do
    if not string.match(i, "^note$") then
      n = n + 1
      gn = gn + 1
      local id = tostring(n)
      local gid = tostring(gn)
      local group = "supporting"
      if string.match(i, "^[-o].*") then
        group = "opposing"
      end
      local label = parse_special(v, "label")
      local strength = parse_special(v, "strength")
      local ideas = parse_claims(v)
      local attr = { ["contentLocked"] = "true",
        ["group"] = group,
        ["parentConnector"] = { ["width"] = strength, ["label"] = label }
      }
      o[id] = { ["title"] = "group", ["id"] = gid, ["attr"] = attr, ["ideas"] = ideas }
    end
  end
  return o
end

function help()
  return [[argmap2mup <options> <file>
   -u, --upload           :  upload to Google Drive
   -g ID, --gdrive_id ID  :  update file with ID on Google Drive
   -f ID, --folder ID     :  upload to Google Drive folder with ID
   -p, --public           :  mark uploaded file as public
   -n NAME, --name NAME   :  set the name of the map to NAME        
   -h, --help]]
end

function parse_options(a)
  local opts        = {}
  local flags, args = pl.app.parse_args(a, { g = true, gdrive_id = true, n = true, name = true, f = true, folder = true })

  opts["upload"] = flags["u"] or flags["upload"] or
      -- Make uploads more explicit:
      -- flags["p"] or flags["public"] or
      flags["g"] or flags["gdrive"] or
      flags["f"] or flags["folder"]
  opts["help"]   = flags["h"] or flags["help"]
  if flags["p"] or flags["public"] then
    opts["public"] = "--share"
  else
    opts["public"] = ""
  end
  opts["gdrive_id"] = flags["g"]
  if not opts["gdrive_id"] then
    opts["gdrive_id"] = flags["gdrive_id"]
  end
  gdriveFolder = flags["f"]
  if not gdriveFolder then
    gdriveFolder = flags["folder"]
  end
  name = flags["n"]
  if not name then
    name = flags["name"]
  end
  if #args > 0 then
    opts["file"] = args[1]
  end
  return opts
end

function main()
  Logger:debug("arg: ")
  Logger:debug(arg)

  -- print(args) -- What is this line for? Debugging? In which case, is there a log function?
  local opts = parse_options(arg)

  if opts["help"] then
    return help()
  else
    local input = ""
    if opts["file"] then
      Logger:debug("opts[\"file\"]: ")
      Logger:debug(opts)
      local f = assert(io.open(opts["file"], 'r'))
      input = f:read("*all")
      f:close()
    else
      input = io.read("*all")
      Logger:debug("input = io.read(\" * all \"), input: " .. input)
    end
    local argmap = lyaml.load(input)
    output = template
    output["ideas"] = parse_claims(argmap)
    output["title"] = name
    local mup = json.encode(output)

    local folderopt = ""

    --  TODO: remove Temp code:
    Logger:debug("opts: ")
    Logger:debug(opts)

    if opts["upload"] and opts["gdrive_id"] then
      pipe_in_out("gdrive update " ..
        "--no-progress " ..
        "--name \"" .. name .. "\" " ..
        "--mime \"application/vnd.mindmup\" ..\" " ..
        opts["gdrive_id"] .. "\"",
        mup)
      return opts["gdrive_id"]
    elseif opts["upload"] then
      if gdriveFolder then
        folderopt = "-p \"" .. gdriveFolder .. "\" "
      else
        gdriveFolder = nil
      end
      local gdriveoutput = pipe_in_out(
        "gdrive upload --delete " ..
        opts["public"] .. " " ..
        "--no-progress " ..
        folderopt ..
        "--name \"" .. name .. "\" " ..
        "--mime \"application/vnd.mindmup\"",
        mup)
      local gdrive_id = string.match(gdriveoutput, "Uploaded ([^%s]*) at")
      return gdrive_id
    else
      Logger:debug("return mup: " .. mup)
      return mup
    end
  end
end

print(main())
