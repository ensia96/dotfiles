" ========================================================================
"  플러그인 설치
" ========================================================================
call plug#begin()

" ------------------------------------
" 자동완성
" ------------------------------------
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" ------------------------------------
" 구문 강조
" ------------------------------------
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" ------------------------------------
" 파일 탐색기
" ------------------------------------
Plug 'preservim/nerdtree'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight' " 파일 탐색기 구문 강조
Plug 'Xuyuanp/nerdtree-git-plugin' " 파일 탐색기에 상태 표시

" ------------------------------------
" 버퍼 간 커서 이동
" ------------------------------------
Plug 'christoomey/vim-tmux-navigator'

" ------------------------------------
" 플로팅 탐색기
" ------------------------------------
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" ------------------------------------
" 플로팅 터미널
" ------------------------------------
Plug 'voldikss/vim-floaterm'

" ------------------------------------
" 색상 테마
" ------------------------------------
Plug 'morhetz/gruvbox'

" ------------------------------------
" 아이콘
" ------------------------------------
Plug 'ryanoasis/vim-devicons'

" ------------------------------------
" 상태바
" ------------------------------------
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" ------------------------------------
" 코파일럿
" ------------------------------------
Plug 'github/copilot.vim'

" ------------------------------------
" Git
" ------------------------------------
Plug 'tpope/vim-fugitive' " 플로팅 탐색기 변경사항 표시
Plug 'airblade/vim-gitgutter' " 변경사항 표시

" ------------------------------------
" 다중 커서
" ------------------------------------
Plug 'terryma/vim-multiple-cursors'

" ------------------------------------
" 마크다운 미리보기 (if not working, run ':call mkdp#util#install()')
" ------------------------------------
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npx --yes yarn install' }

call plug#end()

" ========================================================================
" 플러그인 설정
" ========================================================================

" ------------------------------------
" 기본
" ------------------------------------
" 줄 번호 표시
" 들여쓰기 전처리 구문 판단
" 자동 들여쓰기
" C 스타일 들여쓰기
" 탭, 백스페이스 동작 보조
" 탭을 스페이스로 대체
" 탭 너비를 4 로 설정
" 들여쓰기 너비를 4 로 설정
" 기본 인코딩을 UTF-8 로 설정
" 파일 인코딩을 UTF-8 로 설정
" 터미널 인코딩을 UTF-8 로 설정 > 인텔 맥에서는 오류 발생 > 애플 실리콘 맥에서도 오류 발생
" 검색 시, 결과 강조 설정
" 검색 시, 대소문자 무시
" 운영체제 기본 클립보드 연동
" 복사/붙여넣기를 위해 마우스 모드 수정
" ? 제목 표시줄에 현재 버퍼의 파일명 표시
" 긴 줄을 자동 줄바꿈
" 단어 단위로 줄바꿈 처리
" 매칭되는 괄호 표시
" 커서가 위치한 줄 강조
" 호환성 모드 비활성화 (화살표 키 버그 해결)
" ------------------------------------
set number
set smartindent
set autoindent
set cindent
set smarttab
set expandtab
set tabstop=4
set shiftwidth=4
set enc=utf-8
set fenc=utf-8
" set termencoding=utf-8
set hlsearch
set ignorecase
set clipboard=unnamed
set mouse=r
set title
set wrap
set linebreak
set showmatch
set cursorline
set nocompatible

" ------------------------------------
" 자동완성
" ------------------------------------
" 스왑 파일 생성 금지
" 백업 파일 생성 금지
" 업데이트 시간을 300ms 로 설정
" 줄 번호 옆에 상태 표시줄 표시
" 자동으로 활성화할 플로그인 설정
" 특정 상황에서 사용되는 함수 정의 : https://github.com/neoclide/coc.nvim
" 자동완성 플러그인 강조 설정
" 코파일럿과의 충돌을 방지하기 위한 커스텀 설정 : https://www.reddit.com/r/vim/comments/11fsc56/trying_to_add_github_copilot/
" ------------------------------------
set nobackup
set nowritebackup
set updatetime=300
set signcolumn=yes
let g:coc_global_extensions = [
            \ 'coc-eslint',
            \ 'coc-json',
            \ 'coc-pairs',
            \ 'coc-pyright',
            \ 'coc-prettier',
            \ 'coc-snippets',
            \ 'coc-tsserver',
            \ ]
imap <silent><script><expr> <CR> coc#pum#visible() ? coc#pum#cancel() : copilot#Accept("\<CR>")
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

" ------------------------------------
" 파일 탐색기
" ------------------------------------
" 자동 시작
" 탭이 하나만 남아 있을 때 자동 닫기
" 현재 열려있는 파일에 대한 강조
" ------------------------------------
autocmd VimEnter * NERDTree
autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
function! IsNERDTreeOpen()
    return exists("t:NERDTreeBufName") && (bufwinnr(t:NERDTreeBufName) != -1)
endfunction
function! SyncTree()
    if &modifiable && IsNERDTreeOpen() && strlen(expand('%')) > 0 && !&diff
        NERDTreeFind
        wincmd p
    endif
endfunction
autocmd BufEnter * call SyncTree()

" ------------------------------------
" 색상 테마
" ------------------------------------
" gruvbox 테마 설정
" ------------------------------------
colorscheme gruvbox

" ------------------------------------
" 상태바
" ------------------------------------
" 테마 설정 : https://github.com/vim-airline/vim-airline-themes/tree/master/autoload/airline/themes
" 기본 레이아웃 설정
" 상단 버퍼 목록 표시
" 상단 버퍼 목록에 파일명만 출력
" 상단 버퍼 목록에 버퍼 번호 출력
" 상단 버퍼 목록 구분자 지정
" 활성화된 버퍼 하단바에 닉네임 표시
" 활성화된 버퍼 하단바에 git branch 이름 표시
" ------------------------------------
let g:airline_theme = 'base16_gruvbox_dark_hard'
let g:airline#extensions#default#layout = [
            \ [ 'a', 'b', 'c'],
            \ [ 'z']
            \ ]
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#tabline#buffer_nr_format = '%s:'
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '>>>'
function! AccentDemo()
    let keys = ['춤','추','는','망','고']
    for k in keys
        call airline#parts#define_text(k, k)
    endfor
    call airline#parts#define_accent('춤', 'red')
    call airline#parts#define_accent('추', 'red')
    call airline#parts#define_accent('는', 'red')
    call airline#parts#define_accent('망', 'red')
    call airline#parts#define_accent('고', 'red')
    let g:airline_section_a = airline#section#create(keys)
endfunction
autocmd VimEnter * call AccentDemo()
let g:airline#extensions#branch#enabled = 1

" ------------------------------------
" 코파일럿
" ------------------------------------
" 탭 대신 엔터로 자동완성
" ------------------------------------
let g:copilot_no_tab_map = v:true

" ========================================================================
"  단축키 지정
"  n(normal mode) 명령 모드
"  v(visual, select mode) 비주얼 모드
"  x(visual mode only) 비주얼 모드
"  s(select mode only) 선택 모드
"  i(insert mode) 편집 모드
"  t(terminal mode) 편집 모드
"  c(commnad-line) 모드
"  re(recursive) 맵핑
"  nore(no recursive) 맵핑
" ========================================================================

" ------------------------------------
" 기본
" ------------------------------------
" jk              => ESC
" kj              => ESC
" Enter           => 저장
" Alt + Enter     => 저장하고 종료
" Alt + w         => 현재 버퍼 닫기
" Alt + q         => 현재 버퍼 강제 닫기
" Alt + Shift + t => 현재 버퍼에 터미널 열기
" Ctrl + h        => 왼쪽 버퍼로 이동
" Ctrl + j        => 아래 버퍼로 이동
" Ctrl + k        => 위 버퍼로 이동
" Ctrl + l        => 오른쪽 버퍼로 이동
" Alt + d         => 버퍼 나누기 (왼쪽/오른쪽)
" Alt + Shift + d => 버퍼 나누기 (위/아래)
" Alt + h         => 버퍼 이동 (왼쪽)
" Alt + j         => 버퍼 이동 (아래)
" Alt + k         => 버퍼 이동 (위)
" Alt + l         => 버퍼 이동 (오른쪽)
" Alt + [         => 들여쓰기
" Alt + ]         => 내어쓰기
" ------------------------------------
inoremap jk <ESC>
inoremap kj <ESC>
map <CR> :w<cr>
map <A-CR> :wq<cr>
map <A-w> :q<cr>
map <A-q> :q!<cr>
map <A-T> :term<cr>
map <A-d> :wincmd v<cr>
map <A-S-d> :wincmd s<cr>
map <A-h> :wincmd H<cr>
map <A-j> :wincmd J<cr>
map <A-k> :wincmd K<cr>
map <A-l> :wincmd L<cr>
map <A-]> >>
map <A-[> <<

" ------------------------------------
" 자동완성
" ------------------------------------
" Alt + v => 변수 이름 변경
" Alt + a => 정의로 이동
" Alt + s => 오류 탐색
" K       => 설명 표시
" ------------------------------------
nmap <A-v> <Plug>(coc-rename)
nmap <silent> <A-a> <Plug>(coc-definition)
nmap <silent> <A-s> <Plug>(coc-diagnostic-next)
function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction
nnoremap <silent> K :call ShowDocumentation()<CR>

" ------------------------------------
" 파일 탐색기
" ------------------------------------
" . => 파일 탐색기 토글
" ------------------------------------
map <silent> . :NERDTreeToggle<CR>

" ------------------------------------
" 플로팅 터미널
" ------------------------------------
" Alt + t => 플로팅 터미널 토글
" Alt + w => 터미널 또는 플로팅 터미널에서 비주얼 모드
" ------------------------------------
map <A-t> :FloatermToggle<cr>
tnoremap <A-t> <C-\><C-n>:FloatermHide!<cr>
tnoremap <A-w> <C-\><C-n>

" ------------------------------------
" 플로팅 탐색기
" ------------------------------------
" Alt + r => 버퍼 목록 탐색기
" Alt + f => 파일 탐색기
" Alt + c => 커밋 목록 탐색기
" Alt + b => 현재 버퍼 파일과 관련된 커밋 목록 탐색기
" ------------------------------------
map <A-r> :Buffers<cr>
map <A-f> :Ag<cr>
map <A-c> :Commits<cr>
map <A-b> :BCommits<cr>

" ------------------------------------
" 마크다운 미리보기
" ------------------------------------
" Alt + m => 마크다운 미리보기
" Alt + Shift + m => 마크다운 미리보기 중지
" ------------------------------------
map <A-m> :MarkdownPreview<cr>
map <A-S-m> :MarkdownPreviewStop<cr>

" 자동완성 관련 설정인데 잘 모르겠음

" Use tab for trigger completion with characters ahead and navigate
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" 자동완성 충돌을 위해 주석 처리
" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice
" inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
"                               \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" Formatting selected code
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s)
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying code actions to the selected code block
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying code actions at the cursor position
nmap <leader>ac  <Plug>(coc-codeaction-cursor)
" Remap keys for apply code actions affect whole buffer
nmap <leader>as  <Plug>(coc-codeaction-source)
" Apply the most preferred quickfix action to fix diagnostic on the current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Remap keys for applying refactor code actions
nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
xmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
nmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)

" Run the Code Lens action on the current line
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> to scroll float windows/popups
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges
" Requires 'textDocument/selectionRange' support of language server
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

" ========================================================================
" These might be useful
" ========================================================================

" For JavaScript
" Plug 'pangloss/vim-javascript'

" For TypeScript
" Plug 'HerringtonDarkholme/yats.vim'

" For Flutter, Dart => :CocInstall coc-flutter
" Plug 'dart-lang/dart-vim-plugin'

" Utility for Vim
" Plug 'Lokaltog/vim-easymotion'

" Plug 'jiangmiao/auto-pairs'
" Plug 'scrooloose/syntastic'

" ------------------------------------
" For Python => :CocInstall coc-python
" Plug 'davidhalter/jedi-vim', "{'do' : 'pip install jedi'}
" Plug 'zchee/deoplete-jedi'
" Auto Completion set-ups
" let g:deoplete#enable_at_startup = 1
" autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
" inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
" disable autocompletion, cause we use deoplete for completion
" let g:jedi#completions_enabled = 0
" open the go-to function in split, not another buffer
" let g:jedi#use_splits_not_buffers = "right"
" ------------------------------------

" ------------------------------------
" Plug 'Chiel92/vim-autoformat'
" au BufWrite *.py :Autoformat
" au BufWrite *.cpp :Autoformat
" au BufWrite *.dart :Autoformat
" let g:autoformat_verbosemode=1
" OR:
" let verbose=1
" ------------------------------------

" ------------------------------------
" Plug 'scrooloose/nerdcommenter'
" map <A-/> <plug>NERDCommenterToggle
" ------------------------------------

" ------------------------------------
" Alt + e => git 으로 추적되는 파일 목록 탐색기
" Alt + - => 이전 플로팅 터미널
" Alt + = => 다음 플로팅 터미널
" Alt + + => 새로운 플로팅 터미널
" Alt + _ => 플로팅 터미널 닫기
" map <A-e> :GFiles<cr>
" nnoremap <silent> <A--> :FloatermPrev<cr>
" nnoremap <silent> <A-_> :FloatermNext<cr>
" nnoremap <silent> <A-=> :FloatermNew<cr>
" nnoremap <silent> <A-+> :FloatermKill<cr>
" ------------------------------------

" ------------------------------------
" Open files => Alt + f
" map <A-S-f> :Files<cr>
" Open finder => Alt + g
" map <A-g> :Rg<cr>
" ------------------------------------

" ------------------------------------
" Fold codes => Alt + ', Alt + Shift + '
" map <A-'> zf
" map <A-"> zo
" ------------------------------------

" ------------------------------------
" And then focus on file
" autocmd VimEnter * wincmd p
" Open new tab in NERDTree's buffer
" autocmd BufWinEnter * NERDTreeMirror
" ------------------------------------

" ------------------------------------
" Plug 'junegunn/vim-easy-align'
" Start interactive EasyAlign in visual mode (e.g. vipga)
" xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
" nmap ga <Plug>(EasyAlign)
" ------------------------------------

" ------------------------------------
" Enables the status line at the bottom of Vim
" set laststatus=2
" Display only the current branch
" let g:git_branch_status_head_current=1
" ------------------------------------

" ------------------------------------
" let g:NERDTreeGitStatusWithFlags = 1
" let g:WebDevIconsUnicodeDecorateFolderNodes = 1
" let g:NERDTreeGitStatusNodeColorization = 1
" let g:NERDTreeColorMapCustom = {
"             \ "Staged"    : "#0ee375",
"             \ "Modified"  : "#d9bf91",
"             \ "Renamed"   : "#51C9FC",
"             \ "Untracked" : "#FCE77C",
"             \ "Unmerged"  : "#FC51E6",
"             \ "Dirty"     : "#FFBD61",
"             \ "Clean"     : "#87939A",
"             \ "Ignored"   : "#808080"
"             \ }
" let g:NERDTreeIgnore = ['^node_modules$','\.pyc$', '^__pycache__$', '\~$']
" let NERDTreeStatusline="%{exists('b:NERDTree')?fnamemodify(b:NERDTree.root.path.str(), ':~'):''}"
" ------------------------------------

" ------------------------------------
" Plug 'neomake/neomake'
" Vim Pylint set-ups
" let g:neomake_python_enabled_makers = ['pylint']
" call neomake#configure#automake('nrwi', 500)
" ------------------------------------

" ------------------------------------
" For GraphQL
" Plug 'jparise/vim-graphql'
" GraphQL Syntax
" au BufNewFile,BufRead *.prisma setfiletype graphql
" ------------------------------------

" ------------------------------------
" Plug 'ctrlpvim/ctrlp.vim' "
" let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']
" ------------------------------------

" ------------------------------------
" set listchars=tab:>·
" set listchars+=trail:·
" set listchars+=extends:»
" set listchars+=precedes:«
" set listchars+=nbsp:·
" set listchars+=space:·
" ------------------------------------

" ------------------------------------
" don't give |ins-completion-menu| messages.
" set shortmess+=c
" ------------------------------------

" ------------------------------------
" NERDTree not to display unnecessary files
" augroup nerdtree_open
"     autocmd!
"     autocmd VimEnter * NERDTree | wincmd p
" augroup END
" ------------------------------------
