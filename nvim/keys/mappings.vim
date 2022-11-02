" Move to word
map  <C-f> <Plug>(easymotion-bd-w)
map  <Leader>fw <Plug>(easymotion-bd-w)
nmap <C-f> <Plug>(easymotion-overwin-w)
nmap <Leader>fw <Plug>(easymotion-overwin-w)

" Stay centered
nnoremap m zz

" Terminal mappings
nnoremap <C-t> :FloatermToggle<CR>
tnoremap <C-t> <C-\><C-n>:FloatermToggle<CR>
nnoremap <Leader>; :FloatermNew bash<CR>
tnoremap <C-;> <C-\><C-n>:FloatermToggle<CR>
nnoremap <Leader>0 :FloatermNew tt -t 25<CR>

" Horizontal line movement
nnoremap <S-h> g^
nnoremap <S-l> g$
vnoremap <S-h> g^
vnoremap <S-l> g$

" Kill search on escape
nnoremap <esc> :noh<return><esc>

" Use alt + hjkl to resize windows
nnoremap <M-j>    :resize -2<CR>
nnoremap <M-k>    :resize +2<CR>
nnoremap <M-h>    :vertical resize -2<CR>
nnoremap <M-l>    :vertical resize +2<CR>

" I hate escape more than anything else
inoremap jk <Esc>
" inoremap kj <Esc>

" Display line movements
nnoremap <S-k> gk
nnoremap <S-j> gj
vnoremap <S-k> gk
vnoremap <S-j> gj

" Easy CAPS
inoremap <c-u> <ESC>viwUi
nnoremap <c-u> viwU<Esc>

" TAB in general mode will move to text buffer
nnoremap <TAB> :bnext<CR>
" SHIFT-TAB will go back
nnoremap <S-TAB> :bprevious<CR>

" Alternate way to save
nnoremap <C-s> :w<CR>

" Alternate way to quit
nnoremap <C-Q> :wq!<CR>
nnoremap <Leader>q :wq!<CR>
" Use control-c instead of escape
nnoremap <C-c> <Esc>
" <TAB>: completion.
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

" Better tabbing
vnoremap < <gv
vnoremap > >gv

" Better window navigation
nnoremap <C-h> <C-w>h
"nnoremap <C-j> <C-w>j
"nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <Leader>wh <C-w>h
nnoremap <Leader>wj <C-w>j
nnoremap <Leader>wk <C-w>k
nnoremap <Leader>wl <C-w>l

" Drag lines
vnoremap <M-j> :m'>+<CR>gv
vnoremap <M-k> :m-2<CR>gv
nnoremap <M-j> ddp
nnoremap <M-k> ddkP
inoremap <M-j> <esc>ddp
inoremap <M-k> <esc>ddkP

" Comment out line
nnoremap <C-\> :Commentary<CR>
vnoremap <C-\> :Commentary<CR>
nnoremap <Leader>\ :Commentary<CR>
vnoremap <Leader>\ :Commentary<CR>

" nnoremap <Leader>o o<Esc>
" nnoremap <Leader>O O<Esc>

nnoremap <Leader>v :vsplit<CR>
nnoremap <Leader>h :split<CR>

nnoremap <Leader>q :q<CR>

nnoremap <Leader>ft :NERDTreeToggle<CR>
nnoremap <Leader>ff :Files<CR>
nmap <Leader>e <Cmd>CocCommand explorer<CR>

" Open Manual for word
nnoremap <M-m> :execute "help " . expand("<cword>")<cr>

" Goto code definition.
nmap <silent> gd <Plug>(coc-definition)

" Better nav for omnicomplete
noremap <expr> <c-j> ("\<C-n>")
inoremap <expr> <c-k> ("\<C-p>")
inoremap <expr> <TAB> pumvisible() ? "\<C-y>" : "\<CR>"
inoremap <expr> <Esc> pumvisible() ? "\<C-e>" : "\<Esc>"
inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<Down>"
inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<Up>"
