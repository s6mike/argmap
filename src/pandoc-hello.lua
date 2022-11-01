return {
  {
    CodeBlock = function(block)
      if block.classes[1] == "argmap" then
        return pandoc.Emph { pandoc.block.Str "Hello World" }
      end
    end

    --   Str = function(elem)
    --     if elem.text == "is" then
    --       return pandoc.Emph { pandoc.Str "Hello World" }
    --     else
    --       return elem
    --     end
    --   end,
    -- }
  }
}
