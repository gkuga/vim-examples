let s:sep = fnamemodify('.', ':p')[-1:]

function! session#create_session(file) abort
  execute 'mksession!' join([g:session_path, a:file], s:sep)
  redraw
  echo 'session.vim: created'
endfunction

function! session#load_session(file) abort
  execute 'source' join([g:session_path, a:file], s:sep)
endfunction

function! s:echo_err(msg) abort
  echohl ErrorMsg
  echomsg 'session.vim: ' a:msg
  echohl None
endfunction

if exists('*readdir')
  let s:readdir = function('readdir')
else
  function! s:readdir(dir) abort
    return map(glob(a:dir . s:sep . '*', 1, 1), 'fnamemodify(v:val, ":t")')
  endfunction
endif

function! s:files() abort
  let session_path = get(g:, 'session_path', '')
  if session_path is# ''
    call s:echo_err('session_path is empty')
    return []
  endif

  let session_path = expand(session_path)
  let Filter = { file -> !isdirectory(session_path . s:sep . file) }
  return filter(s:readdir(session_path), Filter)
endfunction

let s:session_list_buffer = 'session://list'

function! session#open_list() abort
  if bufexists(s:session_list_buffer)
    let winid = bufwinid(s:session_list_buffer)
    if winid isnot# -1
      call win_gotoid(winid)
    else
      execute 'sbuffer' s:session_list_buffer
    endif
  else
    execute 'new' s:session_list_buffer
  endif
endfunction

function! session#on_bufread_list() abort
  set buftype=nofile

	nnoremap <silent> <buffer>
				\   <Plug>(session-close)
				\   :<C-u>bwipeout!<CR>
	nnoremap <silent> <buffer>
				\   <Plug>(session-open)
				\   :<C-u>call session#load_session(trim(getline('.')))<CR>

	nmap <buffer> q <Plug>(session-close)
	nmap <buffer> <CR> <Plug>(session-open)

  let files = s:files()
  if empty(files)
    call setline(1, '--- no session exist ---')
    return
  endif

  %delete _
  call setline(1, files)
endfunction
