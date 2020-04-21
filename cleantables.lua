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

    
    local build_align_str = function (alignments)
        
        local aligns = {
            AlignLeft = 'l',
            AlignRight = 'r',
            AlignCenter = 'c',
            AlignDefault = 'l'
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
    
    local Cell = function (elem, width, align, isheader)
        local adjust = (isheader and 'b' or 't')
        local aligns = {
            AlignLeft = '\\raggedright',
            AlignRight = '\\raggedleft',
            AlignCenter = '\\centering',
            AlignDefault = '\\raggedright'
        }
        al = aligns[align]

        inlines = pandoc.List()
        inlines:extend(pandoc.utils.blocks_to_inlines(elem))
        if (width ~= 0.0) then
            inlines:insert(1, pandoc.RawInline('latex', string.format(
                '\\begin{minipage}[%s]{%.2f\\columnwidth}%s\n',
                adjust, 0.9*width, al
            )))
            inlines:insert(pandoc.RawInline('latex', '\\strut\n\\end{minipage}'))
        end
        return inlines
    end
    
    local build_table_row = function (list, widths, aligns, isheader)
        local isheader = isheader or false


        local row = pandoc.List()
        for i = 1, #list do -- iterate through the table based on index
            row:extend(Cell(list[i], widths[i], aligns[i], isheader)) -- get cell content
            if i ~= #list then
                -- insert '&' between cells
                row:insert(pandoc.RawInline('latex', ' & '))
            end
        end
        row:insert(pandoc.RawInline('latex', '\\tabularnewline\n'))
        return row
        
    end
    
    local Table = function (elem)        
        local inlines = pandoc.List()
        inlines:insert(pandoc.RawInline('latex', string.format(
            '{\\centering\n\\begin{longtable}[]{%s}\n',
            build_align_str(elem.aligns)
        )))
        inlines:insert(pandoc.RawInline('latex', '\\toprule\n'))
        -- Add headers line
        inlines:extend(build_table_row(elem.headers, elem.widths, elem.aligns, true))
        inlines:insert(pandoc.RawInline('latex', '\\midrule\n'))
        inlines:insert(pandoc.RawInline('latex', '\\endhead\n'))
        -- Add rows
        for i, v in ipairs(elem.rows) do
            inlines:extend(build_table_row(v, elem.widths, elem.aligns))
        end
        inlines:insert(pandoc.RawInline('latex', '\\bottomrule\n'))
        inlines:insert(pandoc.RawInline('latex', '\\end{longtable}}\n'))
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
