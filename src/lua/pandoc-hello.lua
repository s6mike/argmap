local config_argmap = require 'config_argmap'
local json = require 'rxi-json-lua'

return {
  {
    CodeBlock = function(block)
      local function eval(s)
        print(s)
      --  return assert(load(s))()
      end
      -- block.text="Hello World"
      -- print(pandoc.system.get_working_directory())
      -- local span = pandoc.Span('text', {id = 'boo!', class = 'a b'})
      -- print(span.classes[1])
      local atts_json = block.attributes[2][2]
      print(atts_json)
      -- print(pandoc.utils.stringify(atts_json))
      -- local testspan = pandoc.Span('text', atts_json)
      -- span.attr = atts_json
      -- local atts = load("return " .. atts_json)()
      local atts = load("return "..atts_json)()
      print(atts)
      -- local atts = pandoc.Attr(atts_json)
      -- local atts = json.decode(atts_json)
      -- print(block.classes[1])
      print("<br />")
      -- print(testspan.attr[2])
      print("<br />")
      -- print(block.text)
      -- print("<br />")
      -- local t = eval(atts)
      -- print(t)
      -- block.text=block.attributes
      -- if block.classes[1] == "text" then
      -- -- if block.classes[1] == "argmap" then
      --   block.text="Sorted"
      -- end
      return block
    end

      -- , Str = function(elem)
      --   if elem.text == "is" then
      --     return pandoc.Emph { pandoc.Str "Hello World" }
      --   else
      --     return elem
      --   end
      -- end
  }
}
