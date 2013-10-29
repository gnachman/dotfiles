let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"

vmap ,mc !boxes -d simple -p l2r2<CR>
nmap ,mc !!boxes -d simple -p l2r2<CR>

" Reduce timeout after <ESC> is recvd. This is only a good idea on fast links.
set ttimeout
set ttimeoutlen=20
set notimeout

" terminal mode stuff.
" Put the terminal back in the mode you found it upon exiting
set t_ti= t_te=

" use xterm/iterm's in 256 color mode
set t_Co=256

" For DOS (and GUIs). Make the cursor a block.
set guicursor=a:hor10-blinkon0

" Tabs are 2 spaces.
set tabstop=2

" Blink the screen instead of beeping
set vb

" Don't highlight search results (annoying)
set nohlsearch

" Make backups
set bk

" Put backups in this dir
set bdir=~/vimbackups

" Use color scheme for dark backgrounds
set background=dark
"set background=light

" Case-sensitive searches
map \ /\C

" Turn off calls to sync(). The machine is unlikely to crash before syncing
" itself.
set nofsync
set swapsync=

" Ask before doing anything destructive implicitly
set confirm

" Fold C code function bodies
"syn region myFold start="^{" end="^}" transparent fold 
"syn sync fromStart
"set foldmethod=syntax

" Spaces to use for autoindenting
set shiftwidth=2

" / searches are incremental (like emacs)
set incsearch

" When selecting a file, do filename completion like tcsh
set wildmode=list:longest
set wildignore=*.[oa]

" Searches are insensitive unless they contain an uppercase letter 
" (like emacs)
set ignorecase smartcase

" Always have a status line
set ls=2

" Status line height is 2 to make vim shut up
set ch=2

" Report every change
set report=0

" Show cursor position and location in file
set ruler

" Don't show the stupid informational message on startup
set shortmess=I

" Show partial commands in status line
"set showcmd

" Highlight matching parens, brackets, etc. (like emacs)
set showmatch

" If you're in insert mode, say so.
set showmode

" Ignore these files
set suffixes=.o,.a,CVS

" When moving around, don't move the cursor to the start of line
set nostartofline

" Makes some actions smoother (?)
set ttyfast

set statusline=%-30.50(%n\ %f\ %m%h%r%w%)%l/%L\ (%p%%),\ %c\ %<%=%(\(%{bufnr(\"#\")}\ %{bufname(\"#\")})%)

" For tmux, use 8 space tabs
set ts=8

" Syntax highlighting
filetype indent on
syntax on
if has("terminfo")
  set t_Co=8
  set t_Sf=[3%p1%dm
  set t_Sb=[4%p1%dm
else
  set t_Co=8
  set t_Sf=[3%dm
  set t_Sb=[4%dm
endif
"highlight Folded ctermfg=Yellow ctermbg=Black

" C Code folding. What to replace the code with:
"set foldtext=MyFoldText()
"function MyFoldText()
  "let diff = v:foldend - v:foldstart - 1
  "let p2 = "{ " . diff . " lines of function body folded }                                               "
  "return p2
"endfunction

" My commands for editing C code
"source /home/gnachman/.vim/cinsert.vim
set cinoptions=>s,e0,n0,f0,{0,}0,^0,:s,=s,l0,gs,hs,ps,ts,+s,c1,C1,(0,us,\U0,w0,m0,j0,)20,*30

" Enable emacs-style editing of command-line mode

cnoremap <C-A>      <Home>
cnoremap <C-B>      <Left>
cnoremap <C-E>      <End>
cnoremap <C-F>      <Right>
cnoremap <C-N>      <End>
cnoremap <C-P>      <Up>
cnoremap <C-D>      <Del>
cnoremap <ESC>b     <S-Left>
cnoremap <ESC><C-B> <S-Left>
cnoremap <ESC>f     <S-Right>
cnoremap <ESC><C-F> <S-Right>
cnoremap <ESC><C-H> <C-W>
cnoremap <ESC>d     <S-Right><Right><C-W>
cnoremap <C-U>      <C-E><C-U>
cnoremap <C-K>      <C-\>estrpart(getcmdline(),0,getcmdpos()-1)<CR>


"noremap OP 1<C-^>
"noremap OQ 2<C-^>
"noremap OR 3<C-^>
"noremap OS 4<C-^>
noremap [15~ 5<C-^>
noremap [17~ 6<C-^>
noremap [18~ 7<C-^>
noremap [19~ 8<C-^>
noremap [20~ 9<C-^>
noremap [21~ 10<C-^>
noremap [23~ 11<C-^>
noremap <PageUp> :cp<CR>zz:cc<CR>
noremap <PageDown> :cn<CR>zz:cc<CR>

"inoremap OM <CR>
"noremap OH :cc<CR>zz:cc<CR>

"map <Tab> ==
"imap <Tab> 
" Insert a tab if what preceeds the cursor is whitespace; otherwise do a
" completion.
function! CleverTab()
   if strpart( getline('.'), 0, col('.')-1 ) =~ '^\s*$'
      return "\<Tab>"
   else
      return "\<C-N>"
endfunction
inoremap <Tab> <C-R>=CleverTab()<CR>

" Highlight the current line when you do a search, and remove the highlight
" when the cursor moves.
hi CursorLine cterm=reverse
com! LINE :exe 'se cul'
au CursorMoved * :se nocul
au CursorMovedI * :se nocul
noremap n nzz:LINE<CR>
noremap N Nzz:LINE<CR>
noremap * *zz:LINE<CR>
noremap # #zz:LINE<CR>
" Removed this because it broke things like dG
"noremap G Gzz:LINE<CR>

" Load ctags. The syntax is:
" set tags=file1,file2,file3
set tags=~/tags

" Just to be sure this horrible thing is off (lets you have unsaved buffers)
set nohidden

set nofoldenable

" Allow backspacing over line breaks and start of insert.
set backspace=eol,start,indent


" textwidth is evil
autocmd BufNewFile,BufRead * set textwidth=0
" Show lines extending longer than 100 characters OR spaces at the end of the line.
autocmd BufNewFile,BufRead *.szl,BUILD,*.proto,*.c,*.cc,*.h,*.py,*.js  exec '2match Error /\(\%<103v.\%>101v\)\|\(  *$\)/'
autocmd BufNewFile,BufRead * set expandtab
autocmd BufNewFile,BufRead *.szl,*.c,*.vim,*.cpp,*.h,*.C,*.cc,*.py,*.js set nofoldenable
"autocmd BufRead            *.szl,*.c,*.vim,*.cpp,*.h,*.C,*.cc,*.py,*.js retab
"autocmd BufNewFile,BufRead Makefile* set noexpandtab
autocmd BufNewFile,BufRead Makefile* iunmap <Tab>
autocmd BufRead            *.szl,*.c,*.vim,*.cpp,*.h,*.C,*.cc,*.py,*.js syntax on
autocmd BufNewFile,BufRead * hi CursorLine term=none cterm=inverse

" Automatically save files on various activites (suspend, ^^, etc)
set autowrite
syntax on
set background=dark

" Setting textwidth is obnoxious because it breaks copy-paste.
set textwidth=0

set noshowmatch

" Switching windows and close window
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l
map <C-q> <C-W>q
map <C-s> :python SmartSplit()<CR>
" See: http://www.vim.org/scripts/script.php?script_id=1984
"noremap o :FuzzyFinderFile
"noremap s :FuzzyFinderAddBookmark
"noremap b :FuzzyFinderBookmark
"noremap x :FuzzyFinderBuffer

" Make paren-matching as you edit unobtrusive
hi MatchParen ctermfg=red ctermbg=black

" For HiCurLine module.
"hi HL_HiCurLine ctermbg=blue ctermfg=white

" My hacky make filters
set errorformat=%f:%l%m

" The default is: .,w,b,u,t,i
" but it's freaking slow over NFS.
" .: current buffer
" w: other windows
" b: loaded buffers
" u: unloaded buffers
" t: tag completion
" i: current and included files
set complete=.,w,b

set viminfo='20,<50,s10,h,n/Users/gnachman/.viminfo

function! Hex2Dec()
  let lstr = getline(".")
  let hexstr = matchstr(lstr, '0x[a-fA-F0-9]\+')
  while hexstr != ""
    let hexstr = hexstr + 0
    exe 's#0x[a-fA-F0-9]\+#'.hexstr."#"
    let lstr = substitute(lstr, '0x[a-fA-F0-9]\+', hexstr, "")
    let hexstr = matchstr(lstr, '0x[a-fA-F0-9]\+')
  endwhile
endfunction

" Turn off the bloody swap file warnings.
set noswapfile


