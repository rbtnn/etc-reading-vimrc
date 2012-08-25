
scriptencoding utf-8

" Neobundleによってインストールされるプラグイン(そのほか諸々も)を有効にするかどうか
let s:enable_plugins_depend_on_neobundle = ! filereadable(expand('~/.vim/disable_plugins'))

let s:is_windows = has('win95') || has('win16') || has('win32') || has('win64') 
let s:is_unix = has('unix')

" ログファイルやキャッシュファイルの保存先
if isdirectory(expand('~/Dropbox'))
  let s:cache_path = expand('~/Dropbox/vim-caches/')
else
  let s:cache_path = expand('~/.vim/vim-caches/')
endif
if ! isdirectory(s:cache_path)
  call mkdir(s:cache_path)
endif

" Windowsの場合.vimが入っていないので追加する。
if s:is_windows
  set runtimepath+=~/.vim/
endif

" Windows path {{{
if s:is_windows
  let s:ghc_paths = sort(split(glob('C:\Program Files\Haskell Platform\*\bin\ghc.exe'),"\n"))
  if ! empty(s:ghc_paths)
    let s:latest_ghc_folder_path = s:ghc_paths[-1][:-9]
  endif
  let s:csc_paths = sort(split(glob('C:\Windows\Microsoft.NET\Framework\*\csc.exe'),"\n"))
  if ! empty(s:csc_paths)
    let s:latest_csc_folder_path = s:csc_paths[-1][:-9]
  endif

  let s:path_list = [ 'C:\Windows\System32' , expand('~\.windows') ]
  " Vim
  let s:path_list += [ 'C:\vim\src' , 'C:\vim\src\xxd' ]
  " VCS
  let s:path_list += [ 'C:\Git\bin' , 'C:\Program Files\TortoiseHg' ]
  " C++
  let s:path_list += [ 'C:\MinGW\bin' ]
  " Python
  let s:path_list += [ 'C:\Python27' , 'C:\Python27\Scripts' ]
  " C#
  let s:path_list += [ get(s:,'latest_csc_folder_path','') ]
  " Haskell
  let s:path_list += [ get(s:,'latest_ghc_folder_path','') , $USERPROFILE . '\AppData\Roaming\cabal\bin' ]

  let $PATH = join(filter( s:path_list, 'isdirectory(v:val)'),";")
endif
" }}}

"===========================================================================================
"$Neobundle.vim
"===========================================================================================

if s:enable_plugins_depend_on_neobundle
  "{{{
  set nocompatible
  filetype off
  filetype plugin indent off

  if has('vim_starting')
    if isdirectory(expand('~/.vim/bundle/neobundle.vim/'))
      set runtimepath+=~/.vim/bundle/neobundle.vim/
    else
      set runtimepath+=~/neobundle.vim/
    endif
  endif
  call neobundle#rc(expand('~/.vim/bundle'))

  NeoBundle 'Shougo/neobundle.vim.git'
  NeoBundle 'Shougo/vinarise'
  NeoBundle 't9md/vim-quickhl'
  NeoBundle 't9md/vim-textmanip'
  NeoBundle 'thinca/vim-fontzoom'
  NeoBundle 'thinca/vim-qfreplace'
  NeoBundle 'thinca/vim-prettyprint'
  NeoBundle 'thinca/vim-quickrun'
  NeoBundle 'tpope/vim-fugitive'
  NeoBundle 'tpope/vim-markdown'
  NeoBundle 'tyru/restart.vim'
  NeoBundle 'tyru/caw.vim'
  NeoBundle 'vim-jp/cpp-vim'
  NeoBundle 'vim-jp/vimdoc-ja'
  NeoBundle 'vim-jp/vital.vim'
  NeoBundle 'rbtnn/excite_trans.vim'

  " あまり使用していないのでコメントアウト。
  " NeoBundle 'vim-scripts/sudo.vim'
  " NeoBundle 'ujihisa/unite-colorscheme'
  " NeoBundle 'ujihisa/unite-font'
  " NeoBundle 'vim-scripts/taglist.vim'
  " NeoBundle 'vim-scripts/gtags.vim'
  " NeoBundle 'thinca/vim-localrc'
  " NeoBundle 'mattn/zencoding-vim.git'

  NeoBundle 'rbtnn/vital_member_complete.vim'
        \ , { 'depends' :
        \       [ 'Shougo/neocomplcache'
        \       ]
        \   }
  NeoBundle 'rbtnn/sign.vim'
        \ , { 'depends' :
        \       [ 'Shougo/unite.vim'
        \       , 'Shougo/vimproc'
        \       ]
        \   }
  NeoBundle 'Shougo/vimfiler'
        \ , { 'depends' :
        \       [ 'Shougo/unite.vim'
        \       ]
        \   }
  NeoBundle 'Shougo/neocomplcache-snippets-complete'
        \ , { 'depends' :
        \       [ 'Shougo/neocomplcache'
        \       ]
        \   }
  NeoBundle 'Shougo/vimshell'
        \ , { 'depends' :
        \       [ 'Shougo/vimproc'
        \       ]
        \   }
  NeoBundle 'basyura/TweetVim'
        \ , { 'depends' :
        \       [ 'basyura/bitly.vim'
        \       , 'basyura/twibill.vim'
        \       , 'mattn/webapi-vim'
        \       , 'tyru/open-browser.vim'
        \       , 'Shougo/unite.vim'
        \       , 'h1mesuke/unite-outline'
        \       ]
        \   }
  "}}}
endif

filetype plugin on
filetype indent on

"===========================================================================================
"$Colorscheme
"===========================================================================================
" {{{
syntax enable
if has("gui")
  if s:is_unix
    if filereadable(expand('~/.vim/colors/candy.vim'))
      colorscheme candy
    endif
  elseif s:is_windows
    if filereadable(expand('~/.vim/colors/rdark.vim'))
      colorscheme rdark
    endif
  endif

  " カレント行を下線のみする。（ハイライトはそのまま）
  set cursorline
  highlight CursorLine cterm=underline ctermfg=NONE ctermbg=NONE
  highlight CursorLine gui=underline guifg=NONE guibg=NONE
  " カーソルの色を変更。
  highlight Cursor cterm=underline guifg=#000000 guibg=#dddddd
  " 同じ配色にしておく。
  highlight! link SignColumn Normal
  highlight! link TabLineFill StatusLine
endif
" }}}

"===========================================================================================
"$TabLine & StatusLine
"===========================================================================================

function! s:list2bracket_string(lst) "{{{
  return "[" . join(a:lst,"|") . "]"
endfunction "}}}
function! g:tabline_string() "{{{
  " {{{
  " 全バッファナンバーのリスト(hidden-bufferは含まれない)
  let bufnums = filter(range(1, bufnr("$")),"bufexists(v:val) && buflisted(v:val)")

  " 現在のバッファナンバー
  let curr_num = index(bufnums,bufnr("%"))

  " 現在のバッファを先頭に持ってくる。 0もしくは-1(隠れバッファなので)なら変更する必要がない。
  " よって、0より大きければ変更する。 ローテートしている。単純に現在のバッファを先頭に持ってきているわけではない。
  if 0 < curr_num
    let bufnums = bufnums[(curr_num):] + bufnums[0:(curr_num-1)]
  endif
  " バッファナンバーからバッファネームを求める。
  let bufnames = map(bufnums,"fnamemodify(bufname(v:val),':t') . '(' . v:val . ')'")
  let bufnames = map(bufnames,"(v:val =~ 'vimfiler') ? '+vimfiler+' : v:val ")
  let bufnames = map(bufnames,"(v:val =~ 'vimshell') ? '+vimshell+' : v:val ")

  " 現在のバッファが隠れバッファの場合（:helpなど）。
  if -1 == curr_num
    let bufnames = ["+hidden-buffer+"] + bufnames
  endif
  " }}}
  " タブラインに表示される文字列
  let tabline_str = s:list2bracket_string(
  \ [
  \ ("Tab:" . tabpagenr() . "/" . tabpagenr('$'))
  \ ,&filetype
  \ ,&fileencoding
  \ ,&fileformat
  \ ])
  " \  (fnamemodify(getcwd() , ":t"))
  let tabline_str .= s:list2bracket_string(bufnames)
  return tabline_str
endfunction "}}}

" カーソル移動時にタブラインを更新しておく。
function! g:update_cursor_moved()" {{{
  set guioptions-=e
  " 「set showtabline=2」を設定するとタブラインが更新されるみたい。
  set showtabline=2
  set tabline=%{g:tabline_string()}
endfunction" }}}
autocmd CursorMoved,CursorMovedI * call g:update_cursor_moved()
call g:update_cursor_moved()

set laststatus=0
set statusline=

set ruler
set rulerformat=%m%r%=%l/%L

"===========================================================================================
" $Plugin Configs
"===========================================================================================

if s:enable_plugins_depend_on_neobundle
  " vital_member_complete.vimの設定 {{{
  let g:contain_vital_member_complete_libs =
  \ ["Prelude","Data.List","Data.OrderedSet","Data.String","System.Filepath"]
  " }}}
  " sign.vimの設定 {{{
  let g:sign_cache_dir =  expand(s:cache_path . '.sign_cache')
  " }}}
  "vimproc.vimの設定 {{{
  if s:is_windows
    command! -nargs=0 MakeVimproc  :make --directory=~/.vim/bundle/vimproc/ -f make_mingw32.mak
  elseif s:is_unix
    command! -nargs=0 MakeVimproc  :make --directory=~/.vim/bundle/vimproc/ -f make_unix.mak
  endif
  " }}}
  "unite.vimの設定 {{{
  " uniteをノーマルモードで始める
  let g:unite_enable_start_insert = 0
  " Windows でgrep -Rだとできなかったので。-R オプションがないとか...
  let g:unite_source_grep_recursive_opt = "-r"
  let g:unite_data_directory = s:cache_path . '.unite'
  " }}}
  "vimshell.vimの設定 {{{
  let g:vimshell_disable_escape_highlight = 1
  let g:vimshell_user_prompt = ' "(branch:" . fugitive#head(7).") ".getcwd()'
  let g:vimshell_temporary_directory = s:cache_path . '.vimshell'
  let g:vimshell_vimshrc_path = expand('~/.vim/.vimshrc')
  autocmd FileType vimshell  call vimshell#hook#add('preparse', 'my_preparse', 'g:my_preparse')
  function! g:my_preparse(cmdline,...) "{{{
    let g:vimshell_precmd = a:cmdline
    let @+ = a:cmdline
    return a:cmdline
  endfunction "}}}
  " }}}
  "vimfiler.vimの設定 {{{
  let g:vimfiler_edit_action = 'open'
  let g:vimfiler_enable_auto_cd = 1
  let g:vimfiler_safe_mode_by_default = 0
  if s:is_unix
    call vimfiler#set_execute_file('html,pdf', 'chromium')
    call vimfiler#set_execute_file('png,jpg', 'qiv')
  endif
  let s:vim_list = [
  \   'cs', 'rb', 'py', 'vim', 'cpp', 'txt', 'hs', 'sh', 'bat', 'md'
  \ , 'log', 'h', 'hpp', 'css', 'lisp', 'snip', 'vimrc'
  \]
  call vimfiler#set_execute_file(join(s:vim_list,','),'vim')

  let g:vimfiler_data_directory = s:cache_path . '.vimfiler'
  " }}}
  "TweetVim.vimの設定 {{{
  let g:tweetvim_open_buffer_cmd = 'new!'
  let g:tweetvim_tweet_per_page = 50
  autocmd FileType tweetvim :setlocal wrap
  let g:tweetvim_config_dir = s:cache_path . '.tweetvim'
  " }}}
  "open-browser.vimの設定" {{{
  if s:is_unix
    let g:openbrowser_open_commands = ["chromium"]
    let g:openbrowser_open_rules = {'chromium': '{browser} {shellescape(uri)}'}
  endif
  " }}}
  "vim-quickrun.vimの設定 {{{
  " デフォルトキーマッピングを使用しない。
  let g:quickrun_no_default_key_mappings = 1

  let g:quickrun_config = {
  \   "*" : { 'split': '' }
  \ , "cpp" : { "type" : "cpp/g++" }
  \ , "lisp" : { 'split': '' , 'command' : 'clisp' , 'cmdopt' : ' -E &fileencoding ' }
  \ }
  if s:is_windows
    let g:quickrun_config["cs"]  = {
    \     'split' : ''
    \   , 'command' : 'csc'
    \   , 'runmode' : 'simple'
    \   , 'exec' : ['%c /nologo %s:gs?/?\\? > /dev/null', '"%S:p:r:gs?/?\\?.exe" %a', ':call delete("%s:gs?/?\\?.exe")']
    \   , 'tempfile' : '{tempname()}.cs'
    \   }
  else
    let g:quickrun_config["cs"]  = {
    \     'split' : ''
    \   , 'command' : 'dmcs'
    \   , 'runmode' : 'simple'
    \   , 'exec' : ['%c %s', 'mono %s:gs?.cs?.exe?:gs?\?/?', ':call delete("%s:gs?.exe?.cs?:gs?\?/?")']
    \   , 'tempfile' : '{tempname()}.cs'
    \   }
    " :gs?.cs?.exe?などの記法は :h filename-modifiers を参照
  endif
  " }}}
  "neocomplcache.vimの設定 {{{
  " Vimの起動時にneocomplcacheを有効する。
  let g:neocomplcache_enable_at_startup = 1
  "
  let g:neocomplcache_enable_auto_delimiter = 1
  "
  " let g:neocomplcache_disable_auto_complete = 1
  " 大文字、小文字を無視する
  let g:neocomplcache_enable_ignore_case=0
  "入力に大文字が含まれている場合は、大文字・小文字を無視する
  let g:neocomplcache_enable_smart_case=0
  "大文字を入力したときに、それを単語の区切りとしてあいまい検索を行う
  let g:neocomplcache_enable_camel_case_completion=1
  "_を入力したときに、それを単語の区切りとしてあいまい検索を行う
  let g:neocomplcache_enable_underbar_completion=1
  "
  if !exists('g:neocomplcache_keyword_patterns')
    let g:neocomplcache_keyword_patterns = {}
  endif
  let g:neocomplcache_keyword_patterns['default'] = '[0-9a-zA-Z:#_]\+'

  let g:neocomplcache_temporary_dir = s:cache_path . '.neocon'
  " }}}
  "neocomplcache_snippets.vimの設定 {{{
  let g:neocomplcache_snippets_dir = expand("~/.vim/snippets/")
  " }}}
endif

"===========================================================================================
"$Key mappings
"===========================================================================================

" リーダーはスペース
let mapleader = ' '

if s:enable_plugins_depend_on_neobundle
  "{{{
  function! g:put_vim_modeline() " {{{
    if  &commentstring =~ "%s"
      let cs = &commentstring
    else
      let cs = '// %s'
    endif
    let cs_str = printf(cs, join([
    \   'vim:'
    \ , 'set'
    \ , 'ft=' . &ft
    \ , 'fdm=' . &fdm
    \ , 'ff=' . &ff
    \ , 'fileencoding=' . &fileencoding
    \ , ':'
    \ ], " "))

    if getline("$") =~ '.*vim:'
      call setline("$",cs_str)
    else
      call append("$",[cs_str])
    endif
  endfunction "}}}
  function! g:cursor_string() "{{{
    " カーソル下のあるpatternにマッチするワードと始まりから終わりまでの位置をリストで返す。
    " もしマッチしなければ空文字となる。
    " 例えばカーソル行が「  ret*rn 9」の場合(*がカーソル位置)
    "   :echo g:cursor_string()  " pattern ==# '[a-zA-Z0-9]'
    "   ['return',2,7]
    " となる。
    let pattern = get(g:,'search_pattern',"[a-zA-Z0-9:#_]")

    let line = getline(".")
    let pos = getpos(".")

    " パターンにマッチする先頭に移動する
    let s = pos[2] + pos[3] - 1
    while line[s] =~ pattern
      if s < 0
        break
      else
        let s = s - 1
      endif
    endwhile
    let s = s + 1

    " パターンにマッチする後尾まで移動する
    let e = pos[2] + pos[3] - 1
    while line[e] =~ pattern
      if e < 0
        break
      else
        let e = e + 1
      endif
    endwhile
    let e = e - 1

    if s > e
      return ["",(pos[2]+pos[3]-1),(pos[2]+pos[3]-1)]
    else
      return [(line[(s):(e)]),(s),(e)]
    endif
  endfunction "}}}

  " unite-shortcut {{{
  let s:commands = {}
  function s:commands.map(key, value)
    return { 'word' : a:key, 'kind' : 'command', 'action__command' : a:value }
  endfunction
  let s:commands.candidates = {
  \   "0:.vimrc" : "e ~/.vimrc"
  \ , "1:source %" : "source %"
  \ , "2:help functions" : "help functions"
  \ , "2:help [cursor-word]" : "exec 'help ' . g:cursor_string()[0]" 
  \ , "3:U-sign_all" : "Unite sign_all"
  \ , "3:U-sign_cachefiles" : "Unite sign_cachefiles"
  \ , "6:QuickRun" : "QuickRun"
  \ , "7:VimShell" : "VimShellBufferDir"
  \ , "7:VimFiler" : "VimFilerBufferDir"
  \ , "9:NeoBundleUpdate" : "NeoBundleUpdate"
  \ , "@:ExAutoTrans" : "ExAutoTrans"
  \ , "@:TV-Say" : "TweetVimSay"
  \ , "@:git diff" : "Gdiff"
  \ , "@:put_vim_modeline" : "call g:put_vim_modeline()" 
  \ , "@:U-buffer & file_mru" : "Unite buffer file_mru"
  \ , "@:U-register" : "Unite register"
  \ , "@:U-tweetvim" : "Unite tweetvim"
  \ , "@:U-outline" : "Unite outline"
  \ , "@:Vinarise" : "Vinarise"
  \ , "@:remove-signs" : "call sign#remove_signs()"
  \ , "@:NeoComplCacheToggle" : "NeoComplCacheToggle"
  \}


  let g:unite_source_menu_menus = { "shortcut" : deepcopy(s:commands) }
  " }}}
  nnoremap <leader>u :Unite menu:shortcut<CR>

  function! s:insert_a_space_on_popupmenu() "{{{
    if pumvisible()
      call neocomplcache#close_popup()
    endif
    return " "
  endfunction "}}}
  inoremap <expr><space>  <SID>insert_a_space_on_popupmenu()

  nmap     <silent> <leader>z <Plug>(quickhl-toggle)
  nmap     <silent> <leader>Z <Plug>(quickhl-reset)
  nmap     <silent> <leader>w <Plug>(openbrowser-smart-search)
  "vim-textmanip
  vmap <C-j> <Plug>(textmanip-move-down)
  vmap <C-k> <Plug>(textmanip-move-up)
  vmap <C-h> <Plug>(textmanip-move-left)
  vmap <C-l> <Plug>(textmanip-move-right)
  " neocomplcache_snippets
  imap <C-s>     <Plug>(neocomplcache_snippets_expand)
  smap <C-s>     <Plug>(neocomplcache_snippets_expand)
  " caw.vim
  nmap "" <Plug>(caw:i:toggle)
  vmap "" <Plug>(caw:i:toggle)
  " sign.vim
  nnoremap <leader>s  :SignToggle<CR>
  nnoremap <C-s>      :SignNext<CR>
  " nnoremap <C-s>    :SignPrevious<CR>
  "}}}
endif
"{{{

nnoremap <C-j>  :bnext<CR>
inoremap <C-j>  <ESC>:bnext<CR>
nnoremap <C-k>  :bprevious<CR>
inoremap <C-k>  <ESC>:bprevious<CR>
nnoremap <C-h>  :tabnext<CR>
inoremap <C-h>  <ESC>:tabnext<CR>
nnoremap <C-l>  :tabprevious<CR>
inoremap <C-l>  <ESC>:tabprevious<CR>

if s:enable_plugins_depend_on_neobundle
  autocmd FileType vimfiler nnoremap <buffer> <C-j>  :bnext<CR>
  autocmd FileType vimfiler inoremap <buffer> <C-j>  <ESC>:bnext<CR>
  autocmd FileType vimfiler nnoremap <buffer> <C-l>  :tabprevious<CR>
  autocmd FileType vimfiler inoremap <buffer> <C-l>  <ESC>:tabprevious<CR>
endif

if s:enable_plugins_depend_on_neobundle
  function! s:DoGrep(word) "{{{
    exe 'vimgrep "' . escape(a:word,'"')  . '" ' . "%" | cw
    setlocal modifiable
  endfunction "}}}
  nnoremap * :call <SID>DoGrep(g:cursor_string()[0])<CR>
endif

nnoremap Q :bdelete!<CR>
nnoremap C :close!<CR>
nnoremap W :tabclose!<CR>
nnoremap T :tabnew!<CR>

" 挿入モードを抜けた時、日本語入力モードをオフにする。
inoremap <ESC> <ESC>
inoremap <C-[> <ESC>

nnoremap <leader><space>  za
inoremap <C-@> <ESC>
nnoremap s i<space><ESC>l
nnoremap cc cc<ESC>
nnoremap o o<ESC>
nnoremap O O<ESC>
nnoremap V 0v$h
nnoremap >  >>
nnoremap <  <<

" 現在の行の頭(0)と中央と末尾($)を行き来する。
function! <SID>move_left_center_right(...) "{{{
  let curr_pos = getpos('.')
  let curr_line_len = len(getline('.'))
  let curr_pos[3] = 0
  let c = curr_pos[2]
  if 0 <= c && c < (curr_line_len / 3 * 1)
    if a:0 > 0
      let curr_pos[2] = curr_line_len
    else
      let curr_pos[2] = curr_line_len / 2
    endif
  elseif (curr_line_len / 3 * 1) <= c && c < (curr_line_len / 3 * 2)
    if a:0 > 0
      let curr_pos[2] = 0
    else
      let curr_pos[2] = curr_line_len
    endif
  else
    if a:0 > 0
      let curr_pos[2] = curr_line_len / 2
    else
      let curr_pos[2] = 0
    endif
  endif
  call setpos('.',curr_pos)
endfunction "}}}
nnoremap <silent><tab> :call <SID>move_left_center_right()<CR>
nnoremap <silent><s-tab> :call <SID>move_left_center_right(1)<CR>

cnoremap <C-h>  <Left>
cnoremap <C-l>  <Right>
cnoremap <C-j>  <Down>
cnoremap <C-k>  <Up>

nnoremap <Down>  <C-w>-
nnoremap <Up>    <C-w>+
nnoremap <Left>  <C-w><
nnoremap <Right> <C-w>>

"}}}
"===========================================================================================
"$Settings
"===========================================================================================
"{{{

" help以外、基本的に英語インターフェースで行う。
let $LANG = "C"
set helplang=ja,en

if s:is_windows
  language message en
else
  language mes C
endif

if s:is_windows
  set encoding=cp932
  set termencoding=cp932
  set fileformats=unix,dos,mac
elseif s:is_unix
  set encoding=utf-8
  set termencoding=utf-8
  set fileformats=unix,dos,mac
endif

set fileencodings=utf-8,cp932,euc-jp,default,latin

" 基本的に1にしておく。
if 1
  " スクロールバーのみ有効
  " set guioptions=rb

  " なにもいらない
  set guioptions=
else
  " デフォルト値で。
  if s:is_windows
    set guioptions=egmrLtT
  else
    set guioptions=aegimrLtT
  endif
endif

if s:is_windows
  set guifont=VL_ゴシック:h12:cSHIFTJIS
  set linespace=0
else
  set guifont=VL\ Gothic\ 14
  set linespace=0
endif

set clipboard=unnamed
if has('unnamedplus')
  set clipboard+=unnamedplus
endif

autocmd BufRead,BufNewFile *.markdown,*.md set filetype=markdown
autocmd BufRead,BufNewFile *.diag set filetype=blockdiag


let &grepformat="%f:%l:%m,%f:%l%m,%f  %l%m,%f"
let &grepprg="grep -nr"
" grepをvimgrep扱いにする。
set grepprg=internal

" 括弧類のマッチしているハイライトをオフにする。でもコメントアウト
" let loaded_matchparen = 0

" 検索コマンドを打ち込んでいる間にも、打ち込んだところまでのパターンがマッ
" チするテキストを、すぐに表示する。
set incsearch
" 前回の検索パターンが存在するとき、それにマッチするテキストを全て強調表示しない。
set nohlsearch

" Vimを起動した時、日本語入力モードをオフにする。
set iminsert=0
set imsearch=0

" Vim起動時、最大化にしない。
" autocmd GUIEnter * simalt ~x.

" カーソルを0x00の部分へも移動できるようにする。
set virtualedit=all

" アラート類の音をミュートにする。
set noerrorbells
set novisualbell
set visualbell t_vb=

" コマンドライン補完が拡張モードで行われる。
set wildmenu

" バックスペースで改行などを削除できるようにする。
set backspace=2

" オートインデント
set cindent
set autoindent
set smartindent

" スワップファイルとか作成しない
set nobackup
set noswapfile
set viminfo=
set nowrap

" 表示できない文字を可視化する
set list
set listchars=tab:>-,eol:~,trail:-

"起動時のメッセージを消す
set shortmess& shortmess+=I

set updatetime=1000
set mousehide
set showcmd
set modeline
set tags+=tags;
" set number
" set relativenumber
" set foldmethod=marker

" quickrun.vimするとエラーになるのでコメントアウトにしている。
" set shellslash

" \ を入れると勝手にインデントがされる対処
let g:vim_indent_cont = 0

" 80文字目にラインを引く。
set colorcolumn=80

" プレビューウィンドウの高さ
set previewheight=1

" プレビューウィンドウはオフにしておく
set completeopt=menuone


" 改行時、自動的にコメントモードになるのをオフにする。
autocmd!  CursorMoved,CursorMovedI  *  setlocal formatoptions=cql
" http://vimwiki.net/?%27formatoptions%27
" ↓だとvimrcをquickrunすると&formatoptionsがcqlからcroqlに変わってしまうためコメントアウト。
" autocmd! FileType * setlocal formatoptions-=ro
"}}}
"===========================================================================================
" vim: set ft=vim fdm=marker ff=unix fileencoding=utf-8 :
