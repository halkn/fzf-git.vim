if exists('g:loaded_fzf_git')
  finish
endif

let g:loaded_fzf_git = 1

command! -bang -nargs=* FzfGStatus call fzf_git#status()
command! FzfCommits call fzf_git#log()
command! FzfBCommits call fzf_git#log(expand('%'))
