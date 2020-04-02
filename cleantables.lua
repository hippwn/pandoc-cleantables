--[[---------------------------------------------------------------------------
Pandoc LaTeX cleantable filter

Copyright 2020 hippwn -- see LICENCE for more informations.
]]-----------------------------------------------------------------------------


--[[---------------------------------------------------------------------------
This filter overrides the way Pandoc writes LaTeX tables, especially their
alignment string which contains @-expressions to reduce the table's width.

Usage:
    $ pandoc -s example.md -o example.tex --lua-filter cleantable.lua

TODO:
    - implement table width
    - add caption
]]-----------------------------------------------------------------------------


-- Only run for LaTeX output
if FORMAT:match "latex" then

    local build_table_row = function (list)
        
        local row = pandoc.List()
        for i, v in ipairs(list) do -- iterate through the table based on index
            row:extend(pandoc.utils.blocks_to_inlines(v)) -- get cell content
            if list[i+1] then
                -- insert '&' between cells
                row:insert(pandoc.RawInline('latex', ' & '))
            end
        end
        row:insert(pandoc.RawInline('latex', '\\tabularnewline\n'))
        return row
        
    end
    
    local build_align_str = function (alignments)
        
        local aligns = {
            AlignLeft = 'l',
            AlignRight = 'r'
        }
        local str = ""
        for _, al in pairs(alignments) do
            if aligns[al] then
                str = str .. aligns[al]
            else
                str = str .. 'c'
            end
        end
        return str
        
    end
    
    local Table = function (elem)
        
        local inlines = pandoc.List()
        inlines:insert(pandoc.RawInline('latex', string.format(
            '\\begin{longtable}[]{%s}\n',
            build_align_str(elem.aligns)
        )))
        inlines:insert(pandoc.RawInline('latex', '\\toprule\n'))
        -- Add headers line
        inlines:extend(build_table_row(elem.headers))
        inlines:insert(pandoc.RawInline('latex', '\\midrule\n'))
        inlines:insert(pandoc.RawInline('latex', '\\endhead\n'))
        -- Add rows
        for i, v in ipairs(elem.rows) do
            inlines:extend(build_table_row(v))
        end
        inlines:insert(pandoc.RawInline('latex', '\\bottomrule\n'))
        inlines:insert(pandoc.RawInline('latex', '\\end{longtable}\n'))
        -- inlines:extend(elem.caption)
        
        return pandoc.Plain(inlines)
    end
    
    local Meta = function (meta)
        -- Set to 'true' to keep compatibility with classic templates
        meta.tables = true
        
        return meta
    end
    
    return {
        {Table = Table},
        {Meta = Meta},
    }
end
