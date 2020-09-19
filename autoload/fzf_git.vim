" git status
function! s:sink_git_status(selected) abort
  if len(a:selected) == 0
    return
  endif

  let l:key=a:selected[0]

  if l:key == 'ctrl-p'
    execute('!git commit')
    return
  endif

  let l:file=split(a:selected[1])[1]
  if l:key == 'ctrl-m'
    execute('edit ' . l:file)
  elseif l:key == 'ctrl-x'
    execute('split ' . l:file)
  elseif l:key == 'ctrl-v'
    execute('vsplit ' . l:file)
  endif

  return
endfunction

function! fzf_git#status() abort
  let l:cmd = 'git -c color.status=always -c status.relativePaths=true status --short'
  let l:spec = {
  \ 'source': l:cmd,
  \ 'sink*': function('s:sink_git_status'),
  \ 'options': [
  \   '--ansi',
  \   '--multi',
  \   '--expect=ctrl-m,ctrl-x,ctrl-v,ctrl-p',
  \   '--preview', 'git diff --color=always -- {-1} | delta',
  \   '--bind', 'ctrl-d:preview-page-down,ctrl-u:preview-page-up',
  \   '--bind', 'ctrl-f:preview-page-down,ctrl-b:preview-page-up',
  \   '--bind', 'alt-j:preview-down,alt-k:preview-up',
  \   '--bind', 'alt-s:toggle-sort',
  \   '--bind', '?:toggle-preview',
  \   '--bind', 'space:execute-silent(git add {+-1})+down+reload:' . l:cmd,
  \   '--bind', 'bspace:execute-silent(git reset -q HEAD {+-1})+down+reload:' . l:cmd,
  \ ],
  \ }
  call fzf#run(fzf#wrap(l:spec))
endfunction

" git log
function! s:sink_git_log(selected) abort
  if len(a:selected) == 0
    return
  endif

  let l:key = a:selected[0]

  let l:tmp = split(a:selected[1])
  let l:id = l:tmp[match(l:tmp, '[a-f0-9]\{7}')]

  let l:term_cmd = [
  \ &shell,
  \ &shellcmdflag,
  \ 'git --no-pager show --color=always ' . l:id
  \ ]
  let l:term_opt = {}
  if l:key == 'ctrl-v'
    let l:term_opt.vertical = v:true
  elseif l:key == 'ctrl-m'
    let l:term_opt.curwin = v:true
  endif

  call term_start(l:term_cmd, l:term_opt)
  return
endfunction

function! fzf_git#log(...) abort
  let l:cmd = '
  \ git log
  \ --graph
  \ --color=always
  \ --format="%C(auto)%h%d %s %C(blue)%C(yellow)%cr"
  \ '

  if a:0 >= 1
    let l:cmd = l:cmd . a:1
  endif

  let l:preview_cmd = '
  \ echo {} |
  \ grep -Eo "[a-f0-9]+"  |
  \ head -1 |
  \ xargs -I% git show --color=always % $* |
  \ delta
  \'

  let l:spec = {
  \ 'source': l:cmd,
  \ 'sink*': function('s:sink_git_log'),
  \ 'options': [
  \   '--ansi',
  \   '--exit-0',
  \   '--no-sort',
  \   '--tiebreak=index',
  \   '--preview', l:preview_cmd,
  \   '--expect=ctrl-x,ctrl-v',
  \   '--bind', 'ctrl-d:preview-page-down,ctrl-u:preview-page-up',
  \   '--bind', 'ctrl-f:preview-page-down,ctrl-b:preview-page-up',
  \   '--bind', 'alt-j:preview-down,alt-k:preview-up',
  \   '--bind', 'alt-s:toggle-sort',
  \   '--bind', '?:toggle-preview',
  \   '--bind', 'ctrl-y:execute-silent(echo {} | grep -Eo "[a-f0-9]+" | head -1 | tr -d \\n | pbcopy)',
  \ ],
  \ }
  call fzf#run(fzf#wrap(l:spec))
endfunction
