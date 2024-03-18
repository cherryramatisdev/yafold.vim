set foldmethod=expr
set foldexpr=GetPotionFold(v:lnum)
set foldminlines=0
set foldopen=mark " what movements open folds

function! s:NextNonBlankLine(lnum)
    let numlines = line('$')
    let current = a:lnum + 1
    while current <= numlines
        if getline(current) =~? '\v\S'
            return current
        endif
        let current += 1
    endwhile
    return -2
endfunction

function! s:IndentLevel(lnum)
    if &ft == 'chaos'
        if (a:lnum == 1)
            return 0
        else
            return (getline(a:lnum)=~?'\v^::' ? 0 : indent(a:lnum) / &shiftwidth + 1)
        endif
    else
        return indent(a:lnum) / &shiftwidth + (getline(a:lnum)=~?'^\s*}' ? 1 : 0)
    endif
endfunction

function! GetPotionFold(lnum)
    if getline(a:lnum) =~? '\v^\s*$'
        return '-1'
    endif
    let this_indent = <SID>IndentLevel(a:lnum)
    let next_indent = <SID>IndentLevel(<SID>NextNonBlankLine(a:lnum))
    let prev_indent = <SID>IndentLevel(<SID>PrevNonBlankLine(a:lnum))
    if next_indent == this_indent
        return this_indent
    elseif next_indent < this_indent
        return this_indent
    elseif next_indent > this_indent
        return '>' . next_indent
    endif
endfunction

function! NeatFoldText()
    let line = getline(v:foldstart)
    let lines_count = v:foldend - v:foldstart + 1
    let lines_count_text = '| ' . printf("%10s", lines_count . ' lines') . ' |'
    let foldchar = ' '
    let foldtextstart = strpart(line, 0, (winwidth(0)*2)/3)
    let foldtextend = lines_count_text . repeat(foldchar, 6)
    let foldtextlength = strlen(substitute(foldtextstart . foldtextend, '.', 'x', 'g')) + &foldcolumn
    return foldtextstart . repeat(foldchar, winwidth(0)-foldtextlength) . foldtextend
    "return repeat('  ',v:foldlevel) . foldtextstart . repeat(foldchar, winwidth(0)-foldtextlength) . foldtextend
endfunction
set foldtext=NeatFoldText()

hi Folded ctermbg=231 ctermfg=2
hi FoldColumn ctermbg=white ctermfg=darkred
