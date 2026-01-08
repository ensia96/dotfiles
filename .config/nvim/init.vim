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
" Enter           => 저장
" Alt + Enter     => 저장하고 종료
" Alt + w         => 현재 버퍼 닫기
" Alt + q         => 현재 버퍼 강제 닫기
" Alt + d         => 버퍼 나누기 (왼쪽/오른쪽)
" Alt + Shift + d => 버퍼 나누기 (위/아래)
" Alt + h         => 버퍼 이동 (왼쪽)
" Alt + j         => 버퍼 이동 (아래)
" Alt + k         => 버퍼 이동 (위)
" Alt + l         => 버퍼 이동 (오른쪽)
" Alt + [         => 들여쓰기
" Alt + ]         => 내어쓰기
" Ctrl + h        => 왼쪽 버퍼로 이동
" Ctrl + j        => 아래 버퍼로 이동
" Ctrl + k        => 위 버퍼로 이동
" Ctrl + l        => 오른쪽 버퍼로 이동
" Ctrl + t        => 현재 버퍼에 터미널 열기
" ------------------------------------
map <CR> :w<cr>
map <A-CR> :wq<cr>
map <A-w> :q<cr>
map <A-q> :q!<cr>
map <A-d> :wincmd v<cr>
map <A-S-d> :wincmd s<cr>
map <A-h> :wincmd H<cr>
map <A-j> :wincmd J<cr>
map <A-k> :wincmd K<cr>
map <A-l> :wincmd L<cr>
map <A-]> >>
map <A-[> <<
map <C-T> :term<cr>

" ------------------------------------
" 자동완성
" ------------------------------------
" Alt + a => 정의로 이동
" Alt + e => 리팩토링 액션
" Alt + z => 코드 수정 액션
" Alt + s => 오류 탐색
" Alt + v => 변수 이름 변경
" K       => 설명 표시
" ------------------------------------
nmap <silent> <A-a> <Plug>(coc-definition)
nmap <silent> <A-e> <Plug>(coc-codeaction-refactor)
nmap <silent> <A-z> <Plug>(coc-codeaction-source)
nmap <silent> <A-s> <Plug>(coc-diagnostic-next)
nmap <A-v> <Plug>(coc-rename)
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
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" Add (Neo)Vim's native statusline support
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
