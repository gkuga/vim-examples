augroup plugin-session
  autocmd!
  autocmd BufReadCmd session://list call session#on_bufread_list()
augroup END

if exists('g:loaded_session')
  finish
endif
let g:loaded_session = 1

command! SessionList call session#on_bufread_list()
command! -nargs=1 SessionCreate call session#create_session(<q-args>)
