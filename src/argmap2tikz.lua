#!/usr/bin/env lua

-- a pipe that parses a yaml argument map and generates
-- a tikz argument map, styled to mimic the argument maps on mindmup.
--
-- TODO: better way to lay out the graph?
-- TODO:   covering line width
-- TODO:   top align claims
-- TODO: numbering, hierarchal labels
-- TODO: support for notes

-- Sets up shared 'environment' variables:
local config_argmap = require 'config_argmap'

-- uses pl.app.parse_args() to parse cli options
local pl    = require 'pl.import_into' ()
-- uses lyaml to parse yaml
local lyaml = require "lyaml"

-- initialize a global counter for providing unique ids for each node
local gn = 0
-- initialize an indent so our output is human readable
local indent = 0

-- boiler plate that needs to be added to the latex preamble
-- to process the tikz.
-- Adjust the definition of \argmapmaxnodewidth to control max width
-- of claim nodes.
local includes = [[
    \usepackage{tikz}
    \usetikzlibrary{graphs,graphdrawing}
    \usetikzlibrary{quotes}
    \usegdlibrary{trees}
    \usegdlibrary{layered}
    \definecolor{green}{HTML}{339966} 
    \usepackage{adjustbox}
    \usepackage{varwidth}
    \newcommand{\argmapmaxnodewidth}{15em}]]

-- the tikz styles used by the map
local styles = [=[
    umbrella/.style args={#1}{
        draw=none,
        rectangle,
        append after command={
            \pgfextra{%
                \pgfkeysgetvalue{/pgf/outer xsep}{\oxsep}
                \pgfkeysgetvalue{/pgf/outer ysep}{\oysep}
                \begin{pgfinterruptpath}
                    \ifx\\#1\\\else
                        \draw[draw,#1] 
                        ([xshift=-\pgflinewidth,yshift=-2mm]\tikzlastnode.north east) 
                        -- ([xshift=-\pgflinewidth,yshift=-\oysep]\tikzlastnode.north east) 
                        -- ([xshift=0,yshift=-\oysep]\tikzlastnode.north west) 
                        -- ([xshift=0,yshift=-2mm]\tikzlastnode.north west);
                    \fi
                \end{pgfinterruptpath}
            }
        }
    },
    claim/.style={draw, black, very thin,
       execute at begin node={\begin{varwidth}{\argmapmaxnodewidth}},
       execute at end node={\end{varwidth}}
    },
    supporting/.style args={#1}{umbrella={green,#1}},
    supportingedge/.style={green},
    opposing/.style args={#1}{umbrella={red,#1}},
    opposingedge/.style={red},
    implicit/.style={dashed}
]=]

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
    return o
end

local function trim(s)
    return (s:gsub("\n", ""))
end

function markdown_to_latex(s)
    return trim(pipe_in_out("pandoc --wrap=none -t latex -f markdown", s))
end

-- TODO: enable parsing of notes
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
    -- a function that parses claims
    local o = ""
    indent = indent + 2
    for i, v in pairs(t) do
        -- this for loop iterates over a list of claims:
        --    i is a claim, v is a table of reasons for or against i
        if not string.match(i, "^label$") and not string.match(i, "^strength$") then
            -- increment the global counter and make it available as a string
            gn = gn + 1
            local gid = tostring(gn)
            local claim = i
            -- attr controls the tikz styling for the claim
            local attr = "claim"
            if string.match(claim, "^-.*") then
                -- if the claim begins with a '-', strip it off and style as an implicit premise
                claim = string.sub(claim, 2, -1)
                attr = attr .. ", implicit"
            end
            claim = markdown_to_latex(claim)
            local note = parse_special(v, "note")
            if note then
                note = trim(markdown_to_latex(note))
                -- TODO: attach note to claim.
            end
            -- construct the claim in tikz, e.g,: c1/"Eating meat is morally acceptable"[claim, implicit]
            local claimline = string.rep(" ", indent) .. "c" .. gid .. "/\"" .. claim .. "\"[" .. attr .. "]"
            -- parse the reasons for the claim, and add the result to output.
            o = o .. parse_reasons(v, claimline)
        end
    end
    indent = indent - 2
    return o
end

function parse_reasons(t, claimline)
    -- function that parses reasons for a claim and returns the appropriate tikz
    -- initialize output string
    local o = ""
    indent = indent + 2
    if next(t) == nil then
        -- if no reasons are offered for the claim, then just return the claimline
        o = claimline .. ",\n"
    else
        for i, v in pairs(t) do
            -- this for loop iterates over reasons: i is the identifier, and v is a list of claims
            if not string.match(i, "^note$") then
                -- skip items labeled "note"
                gn = gn + 1
                local gid = tostring(gn)
                -- if the identifier begins with '-' or 'o' then the reason is an objection
                local type = "supporting"
                if string.match(i, "^[-o].*") then
                    type = "opposing"
                end
                local label = parse_special(v, "label")
                local labelnode = ""
                if label then
                    label = trim(markdown_to_latex(label))
                    label = string.gsub(label, ":", "{:}")
                    label = "\"{\\footnotesize " .. label .. "}\", "
                end
                local strength = parse_special(v, "strength")
                local width = "line width=1.2pt" -- "very thick"
                if strength == 1 then
                    width = "line width=0.6pt"
                elseif strength == 2 then
                    width = "line width=0.8pt"
                elseif strength == 3 then
                    width = "line width=1.2pt" -- "very thick"
                elseif strength == 4 then
                    width = "line width=1.6pt"
                elseif strength == 4 then
                    width = "line width=2pt"
                end


                -- construct the tikz, e.g.,
                --   c1/"Eating meat is morally acceptable"[claim, implicit]
                --     --[supportingedge]
                --     r2/""[supporting] // [ tree layout ] {
                --        ...
                --     }
                -- note the recursive call to parse_claims.
                o = o .. claimline .. "\n" ..
                    string.rep(" ", indent) .. "--[" .. width .. ", " .. labelnode .. type .. "edge] " ..
                    string.rep(" ", indent) ..
                    "r" .. gid .. "/\"\" [" .. type .. "={" .. width .. "}] // [ tree layout ] {\n"
                    .. parse_claims(v)
                    .. string.rep(" ", indent) .. "},\n"
            end
        end
    end
    indent = indent - 2
    return o
end

function create_graph(t)
    -- parse the map and generate the tikz \graph
    local o = string.rep(" ", indent) .. "\\graph [layered layout, " ..
        "grow down, " ..
        "level distance=5em, " ..
        "tail anchor=center, " ..
        "edge quotes={fill=yellow!25,inner sep=3pt}, " ..
        "head anchor=center]\n" ..
        string.rep(" ", indent) .. "{\n" ..
        parse_claims(t) ..
        string.rep(" ", indent) .. "};\n"
    return o
end

function create_tikzpicture(t)
    -- generate the tikz \graph and wrap in a tikzpicture environment
    -- TODO: is there more appropriate way to specify rounded corners other than calling pdfsetcornerarced?
    indent = indent + 2
    local o = "\\begin{tikzpicture}\n" ..
        string.rep(" ", indent) .. "[\n" ..
        styles ..
        string.rep(" ", indent) .. "]\n" ..
        string.rep(" ", indent) .. "\\pgfsetcornersarced{\\pgfpoint{.5mm}{.5mm}}" ..
        create_graph(t) ..
        "\\end{tikzpicture}"
    return o
end

function create_texdocument(t)
    -- generate a the tikzpicture and wrap it in a standalone tex document
    local documentclass = [[\documentclass[tikz]{standalone}]]
    return "\\documentclass[tikz]{standalone}\n" ..
        includes .. "\n" ..
        "\\begin{document}\n" ..
        create_tikzpicture(t) .. "\n" ..
        "\\end{document}"
end

function help()
    return [[argmap2tikz <options> <file>
   -s, --standalone: generate standalone tex file
   -i, --includes:   dump includes required for tex preamble
   -t, --template:   dump boilerplate for adding to preamble in a pandoc template
   -h, --help:       help]]
end

function parse_options(a)
    local opts = {}
    local flags, args = pl.app.parse_args(a)
    opts["standalone"] = flags["s"] or flags["standalone"]
    opts["includes"] = flags["i"] or flags["includes"]
    opts["template"] = flags["t"] or flags["template"]
    opts["help"] = flags["h"] or flags["help"]
    if #args > 0 then
        opts["file"] = args[1]
    end
    return opts
end

function main()
    local opts = parse_options(arg)
    if opts["help"] then
        return help()
    elseif opts["includes"] then
        return includes
    elseif opts["template"] then
        return "$if(argmaps)$\n" ..
            includes .. "\n" ..
            "$endif$"
    else
        local input = ""
        if opts["file"] then
            local f = assert(io.open(opts["file"], 'r'))
            input = f:read("*all")
            f:close()
        else
            input = io.read("*all")
        end
        local argmap = lyaml.load(input)
        if opts["standalone"] then
            return create_texdocument(argmap)
        else
            return create_tikzpicture(argmap)
        end
    end
end

print(main())
