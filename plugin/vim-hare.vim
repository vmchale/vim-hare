if exists("g:__HARE_VIM__")
    finish
endif
let g:__HARE_VIM__ = 1

function! s:warn(message)
  echohl WarningMsg
  echo a:message
  echohl None
endfunction

function! s:info(message)
  echo a:message
endfunction

function! s:setup_preview()
  30wincmd _
  set buftype=nofile
  set bufhidden=wipe
  set nobuflisted
  set noswapfile
  set readonly
endfunction

" Sample output from ghc-hare exectuable: /home/vanessa/work/haskell/eTeak/teak/src/Language/Teak/Iso.hs
" Basically, we want to parse this into a list of files :)
function! s:parse_hare(source)

  let ok = 1
  let error = 0
  let trimmed = substitute(substitute(substitute(
        \ tr(a:source, '()', '[]')
        \ , '\n', '', 'e')
        \ , '" "', '","', 'eg')
        \ , '\(\a\) \([["]\)', '\1,\2', 'eg')
  return eval(trimmed)

endfunction

" Run ghc-hare with the given commands and arguments.
function! s:hare(command, ...) abort

  let file = expand('%')

  let l:cmd = join(['ghc-hare', a:command, file] + a:000, ' ')

  " Run the command
  silent let result = system(l:cmd)

  if v:shell_error > 0
    throw 'HaRe: error running command'
  endif

  return s:parse_hare(l:result)

endfunction

function! s:refactored_filename(oldfile)
  return substitute(a:oldfile, '\.hs', '.refactored.hs', '')
endfunction

function! s:diff_command(before, after)
  return 'diff -u ' . a:before . ' ' . a:after
endfunction

function! s:preview_diff(touched_files)

  let current_file = expand('%:p')
  let current_buf = bufname('%')

  " Set up preview window
  pedit
  wincmd P
  enew
  set filetype=diff
  let b:target_file = current_file
  let b:target_buf = current_buf
  let b:touched_files = a:touched_files

  " Read diff into window
  try

    for touched in a:touched_files
      let cmd = s:diff_command(touched, s:refactored_filename(touched))
      execute 'silent read !' . cmd
      norm Go
    endfor

  finally

    norm gg
    norm OPress <enter> to apply refactor, 'q' to abort
    call s:setup_preview()
    nnoremap <buffer> <CR> :silent execute <SID>ApplyChanges()<CR>
    nnoremap <buffer> q :silent execute <SID>StopHare()<CR>
    augroup harediff
      autocmd!
      autocmd BufLeave * silent execute <SID>StopHare() | autocmd! harediff
    augroup END

  endtry

endfunction

function! s:ApplyChanges()

  " Switch to original window
  let l:touched_files = b:touched_files
  let l:target_file = b:target_file
  let l:target_buf = b:target_buf
  autocmd! harediff
  execute bufwinnr(b:target_buf) . 'wincmd w'
  wincmd z

  try
    " Apply diff to all files
    for tgt in l:touched_files
      execute 'edit ' . tgt
      %delete
      let newfile = s:refactored_filename(tgt)
      execute 'silent read' newfile
      1delete

      call system('rm -f ' . newfile)
    endfor
  finally
    execute 'buffer' l:target_buf
    redraw
  endtry

endfunction

function! s:StopHare()

  let l:touched_files = b:touched_files
  for tgt in l:touched_files
    call system('rm -f ' . s:refactored_filename(tgt))
  endfor

  execute bufwinnr(b:target_buf) . 'wincmd w'
  wincmd z
  redraw

endfunction

function! s:Lift()

    normal w!
    normal b

    let line = line('.')
    let col = col('.')

    call s:info("Lifting definition to top-level...")
    let result = s:hare('liftToTopLevel',
        \ line, col)

    if v:shell_error ==? 0 && result[0] ==? 1
        call s:preview_diff(result[1])
    elseif result[0] ==? 0
        call s:warn(result[1])
        call cursor(line, col)
    endif

    execute 'checkt'

endfunction

function! s:FunctionReplace(name)

    normal w!
    normal b

    let line = line('.')
    let col = col('.')

    call s:info("Renaming identifier...")
    let result = s:hare('rename',
        \ a:name, line, col)

    if v:shell_error ==? 0 && result[0] ==? 1
        call s:preview_diff(result[1])
    elseif result[0] ==? 0
        call s:warn(result[1])
        call cursor(line, col)
    endif

    execute 'checkt'

endfunction

function! s:Generalize()

    normal w!
    normal b

    let line = line('.')
    let col = col('.')

    let name = expand("<cword>")

    call s:info("Generalizing to applicative...")
    let result = s:hare('genApplicative',
        \ name, line, col)

    if v:shell_error ==? 0 && result[0] ==? 1
        call s:preview_diff(result[1])
    elseif result[0] ==? 0
        call s:warn(result[1])
        call cursor(line, col)
    endif

    execute 'checkt'

endfunction

command!          Happlicative execute s:Generalize() 
command!          Hlift        execute s:Lift()
command! -nargs=1 Hreplace     execute s:FunctionReplace(<f-args>)

nnoremap <silent> <Plug>LiftHare :Hlift<CR>
nnoremap <silent> <Plug>ToApplicative :Happlicative<CR>
