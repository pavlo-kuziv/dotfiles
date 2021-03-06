
function! fold#FoldText()
    let l:line = getline(v:foldstart)

    let l:nucolwidth = &foldcolumn + &number * &numberwidth
    let l:windowwidth = winwidth(0) - l:nucolwidth - 1
    let l:foldedlinecount = v:foldend - v:foldstart

    " expand tabs into spaces
    let l:onetab = strpart('          ', 0, &tabstop)
    let l:line = substitute(l:line, '\t', l:onetab, 'g')
    let l:line = substitute(l:line, '^\s*', repeat(' ',indent(v:foldstart)), '')
    let l:line = substitute(l:line, '|[^=]* =', '=', '')
    let l:line = substitute(l:line, '@[^=]* =', '=', '')
    let l:line = substitute(l:line, ' @[A-Za-z0-9]\+', '', '')

    let l:line = strpart(l:line, 0, l:windowwidth - 2 -len(l:foldedlinecount))

    let [l:added, l:modified, l:removed] = sy#repo#get_stats()
    if l:added > 0 || l:modified > 0 || l:removed > 0 || len(getqflist()) > 0 || len(signature#mark#GetList('used', 'buf_all')) > 0
        let l:fillcharcount = l:windowwidth - len(l:line) - len(l:foldedlinecount) - 2
    else
        let l:fillcharcount = l:windowwidth - len(l:line) - len(l:foldedlinecount)
    endif

    return l:line . repeat(' ',l:fillcharcount) . l:foldedlinecount . ' >-'
endfunction

function! fold#NextClosedFold(dir)
    let l:cmd = 'norm!z' . a:dir
    let l:view = winsaveview()
    let [l:l0, l:l, l:open] = [0, l:view.lnum, 1]
    while l:l != l:l0 && l:open
        exe l:cmd
        let [l:l0, l:l] = [l:l, line('.')]
        let l:open = foldclosed(l:l) < 0
    endwhile
    if l:open
        call winrestview(l:view)
    endif
endfunction

function! fold#CloseAll()
    if &diff && winnr('$') > 1
        let l:view = winsaveview()
        let l:currentWindow=winnr()
        windo execute 'call fold#Close()'
        execute l:currentWindow . 'wincmd w'
        call winrestview(l:view)
    endif
endfunction

function! fold#Close()
    if &diff
        execute 'normal! zm'
    endif
endfunction

