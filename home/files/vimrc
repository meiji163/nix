" Modified from @vilmibm's conf

" This file assumes installation of:
" - FZF -- specifically, a clone of junegunn/fzf at ~/src/fzf as well as the fzf binary
" - ag -- silversearch-ag package on debian

" Environment overrides

let $FZF_DEFAULT_COMMAND = 'ag -l --ignore=vendor --ignore=__pycache__ -g ""'

" Plugin setup

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plug')

set rtp+=~/src/fzf
Plug '~/src/fzf'
Plug 'junegunn/fzf.vim'
Plug 'flazz/vim-colorschemes'
Plug 'preservim/nerdcommenter'
" Plug 'vimwiki/vimwiki'
Plug 'tpope/vim-fugitive'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

call plug#end()

" Settings

set cursorline
set cursorcolumn
syntax on
filetype plugin indent on

let g:go_highlight_types=1
let g:go_highlight_fields=1
let g:go_highlight_functions=1
let g:go_highlight_function_calls=1

" use soft wrapping
" https://vim.fandom.com/wiki/Word_wrap_without_line_breaks
set textwidth=0
set wrapmargin=0
set wrap
set linebreak

set shiftwidth=2
set tabstop=2
set relativenumber
set backspace=indent,eol,start
set gfn=Fantasque\ Sans\ Mono\ 12

set shiftround
set autoindent
set expandtab
set wildmode=longest,list
set number
set incsearch
" set list listchars=tab:>-,trail:.,extends:>
"

" COLORS
set t_Co=256
set background=dark
colorscheme papercolor
highlight Normal guibg=black guifg=white

" STATUSLINE

function! GitBranch()
  " This is too slow in github/github.
  return system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
endfunction

function! StatuslineGit()
  let l:branchname = GitBranch()
  return strlen(l:branchname) > 0?'  '.l:branchname.' ':''
endfunction

command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>, '--path-to-ignore ~/.ignore --hidden', <bang>0)

set laststatus=2 " always show statusline
set statusline=
set statusline+=%#PmenuSel#
"set statusline+=%{StatuslineGit()}
set statusline+=%{fugitive#statusline()}
set statusline+=%#LineNr#
set statusline+=\ %f
set statusline+=%m
set statusline+=%=
set statusline+=%#CursorColumn#
set statusline+=\ %y
set statusline+=\ %{&fileencoding?&fileencoding:&encoding}
set statusline+=\[%{&fileformat}\]
set statusline+=\ %p%%
set statusline+=\ %l:%c
set statusline+=\

" BINDINGS
"
let mapleader = " "

nnoremap q <Esc>
noremap <F1> <Esc>
" preferred uparrow/downarrow with wrapped lines
nmap j gj
nmap k gk

nmap <Leader>f :Files<Return>
nmap <Leader><Tab> :b#<Return>
nmap <Leader>/ :Ag<Return>
nmap <Leader>b :Buffers<Return>
nmap <Leader>s :w<Return>
nmap <Leader>w <C-w>
nmap <Leader>wm <C-w>o
nmap <Leader>. :source%<Return>
nmap <Leader>ed :e~/.vimrc<Return>

" Go stuff
nmap <Leader>gr :!go run %<Return>
nmap <Leader>gt :GoTest<Return>
nmap <Leader>gd :GoDef<Return>
nmap <Leader>gi :GoImports<Return>
nmap <Leader>gb :wa<Return>:GoBuild<Return>
nmap <Leader>gR :wa<Return>:GoBuild<Return>:GoRename<Return>

iab ife if err != nil {<CR>return err<CR>}
iab ifne if err != nil {<CR>return nil, err<CR>}
iab dbg fmt.Printf("DBG %#v\n",
iab ref return fmt.Errorf("
iab ae assert.Equal
iab tss tests := []struct {<CR>name string<CR>}{}<CR><CR>for _, tt := range tests {<CR>t.Run(tt.name, func(t *testing.T) {<CR>})<CR>}

nnoremap <leader>d "_d
xnoremap <leader>d "_d
xnoremap <leader>p "_dP

nmap <C-g> :GoDecls<cr>
imap <C-g> <esc>:<C-u>GoDecls<cr>
