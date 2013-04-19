" Vim global plugin for automating various operations on C files
" Last change 2001 Nov 26
" Maintainer: George Nachman <george@llamas.org>

function! s:InitCFile(desc)
  let mybufname = substitute(bufname("%"), ".*/", "", "")
  execute "normal mz1GO/\<Esc>76a*\<Esc>a\<Esc>C * " . mybufname . "* * \<Esc>mya" . a:desc . "\<Esc>gq'yo*\<Esc>75a*\<Esc>a/static const char cvsid[] = \"@(#)$Header: filename.c,v 1.0 2000/01/01 12:00:00 gnachman Exp $\" ;#include \"" . substitute(mybufname, "\\.c", ".h", "") . "\"/*\<Esc>i * Local types*//*\<Esc>i * Local functions*//*\<Esc>i * Local vars*/\<Esc>`z" 
endfunc

function! s:InitHFile2(desc)
  let hconst = substitute(bufname("%"), "\\.",    "_",     "g")
  let hconst = substitute(hconst, ".*/", "", "g")
  let hconst = toupper(hconst)
  execute "normal mz1GO/\<Esc>76a*\<Esc>a\<Esc>C * " . substitute(bufname("%"), ".*/", "", "g") . "* \<Esc>myi  " . a:desc . "\<Esc>gq'yk0ldwj0i *\<Esc>75a*\<Esc>a/#ifndef " . hconst . "#define " . hconst . "\<Esc>Go#endif\<Esc>`z"
endfunc

function! s:InitHFile(desc)
  let hconst = substitute(bufname("%"), "\\.", "_", "g")
  let hconst = substitute(hconst, ".*/", "", "g")
  let hconst = toupper(hconst)
  execute "normal mz1GO/\<Esc>76a*\<Esc>a\<Esc>C * " . bufname("%") . "* * \<Esc>mya" . a:desc . "\<Esc>gq'yo*\<Esc>75a*\<Esc>a/#ifndef " . hconst . "#define " . hconst . "\<Esc>Go#endif\<Esc>`z"
endfunc

function! s:InsertCFunction()
  let b:ftype = input("Function type: ")
  let b:fname = input("Function name: ")
  let b:fdesc = input("Description: ")
  let cmd = "mzO/\<Esc>76a*\<Esc>a\<Esc>0C * " . b:fname . " --** " . b:fdesc . "*/\<Esc>gq'zo" . b:ftype . "". b:fname . "(\<Esc>"
  let decl = b:ftype . "" . b:fname . "("
  let l = input("Param: ")
  let comma = ""
  let maxstars = 0
  let maxtypelen = 0

  if l == ""
    let l = "void"
  endif

  while l != ""
    let l = substitute(l, "\\(.*\\)  *\\(\\**\\)\\([^ ]*\\)", "|PARAM>\\1|STARS>\\2|NAME>\\3|END>", "")

    let paramtype = substitute(l, "|STARS>.*", "", "")
    let paramtypelen = strlen(paramtype) - 7
    if paramtypelen > maxtypelen
      echo "param " . paramtype . " sets new type len to " . paramtypelen
      let maxtypelen = paramtypelen
    endif

    let starpos = match(l, "*")
    while starpos > 0
      let maxstars=maxstars+1
      let starpos = match(l, "*", starpos+1)
    endwhile

    let cmd = cmd . "a" . comma . l . "\<Esc>"
    let decl = decl . comma . l

    if l != "void"
      let l = input("Param: ")
    else
      let l=""
    endif

    let comma = ","
  endwhile

  let paramstart=match(cmd, "|PARAM>")
  while paramstart >= 0
    let starsstart=match(cmd, "|STARS>", paramstart)
    let typelen=starsstart-paramstart-7
    let namestart=match(cmd, "|NAME>", starsstart)
    let numstars=namestart-starsstart-7
    let numspaces=maxtypelen+maxstars-numstars-typelen

    let tabularasa="                                                                                "
    let spaces=strpart(tabularasa, 0, numspaces+1)
    if spaces > 79
      let spaces=79
    endif
    let cmd=substitute(cmd, "|PARAM>\\([^|]*\\)|STARS>\\([^|]*\\)|NAME>\\([^|]*\\)|END>", "\\1".spaces."\\2\\3", "")
    let decl=substitute(decl, "|PARAM>\\([^|]*\\)|STARS>\\([^|]*\\)|NAME>\\([^|]*\\)|END>", "\\1".spaces."\\2\\3", "")

    let paramstart=match(cmd, "|PARAM>")
  endwhile

  let decl = decl . ");"
  let cmd = cmd . "a){}\<Esc>kkkmz"
  w
  let cfile = bufname("%")
  if exists("b:hfile") == 0
    let b:hfile = substitute(cfile, "c$", "h", "")
  endif
  let hfile = b:hfile
  let doit = 1
  let inithfile = 0
  if b:ftype !~ "static"
    if filereadable(hfile) == 0
      let yn2 = "n"
      while (yn2 == "n")
        let doit = 0
        let yn = inputdialog("No file " . hfile . ". Create [y/n]? ", "y")
        if yn == "y"
          let doit = 1
          let hdir = inputdialog("Directory: ", "")
          if hdir == ""
            let hdir = "."
          endif
          let b:hfile = hdir . "/" . hfile   
          let hfile = b:hfile
          if (filereadable(hfile)) != 0
            let yn2 = inputdialog("File already exists. Use anyway [y/n]?", "y")
          else
            let yn2 = "y"
            execute "normal 4Gwy/^ \*\*``"
            execute "w"
            execute "e " . hfile
            call s:InitHFile2(@w)
            execute "w"
            execute "e #"
          endif
        else
          let b:hfile = inputdialog("Locate header file: ", "")
          if b:hfile != ""
            let doit = 1
            let hfile = b:hfile
          endif
        endif
      endwhile
    endif 
  else
    execute "normal mzgg/Local functions\<CR>jjo" . decl . "\<Esc>`z"
  endif
  execute "normal " . cmd
  if b:ftype !~ "static"
    execute "w"
    execute "e " . hfile
    execute "normal G{O" . decl . "\<Esc>"
    w
    e #
  endif
endfunction

function! s:InsertInclude()
  let filename = input("Quoted filename? ")
  execute "normal mzgg}}o#include " . filename . "\<Esc>`z"
endfunction

function! s:InsertLocalVar()
  let type = input("Type? ")
  let name = input("Name? ")
  let comm = input("Comment? ")
  if strlen("  " . type . "  " . name . ";") > 40
    echo "\nType + name is too long"
    return
  endif
  if strlen(comm) > 33
    echo "\nComment is too long"
    return
  endif
  let nl = 1
  execute "normal mz[[myo" . type . "\<Esc>"
  " Need to figure out the longest existing type, then either move everyone
  " out or just the new line
  let maxcol = 0
  let mycol = col(".")
  execute "normal j$F;F "
  if col(".") > 2
    let nl = 0
    execute "normal ?[^ ]\<CR>l"
  endif
  while col(".") > 2
    if col(".") > maxcol
      let maxcol = col(".") - 1
    endif
    execute "normal j$F;F "
    if col(".") > 2
      execute "normal ?[^ ]\<CR>l"
    endif
  endwhile
  let maxcol = maxcol+1
  let mycol = mycol+1
  execute "normal 'yj$"
  if mycol > maxcol
    execute "normal j$F;F ?[^ ]\<CR>l"
    " Indent everyone else
    while col(".") > 2
      let cmd = 2 + (mycol - col(".")) . "i \<Esc>"
      let cmd1 = "normal dw" . cmd
      execute cmd1
      execute "normal 039ldw"
      execute "normal j$F;F ?[^ ]\<CR>l"
    endwhile
    execute "normal 'yj$"
    let maxcol = mycol
  endif
  let maxcol = maxcol + 2
  exec "normal " . (maxcol - mycol) . "a \<Esc>a" . name . ";\<Esc>"
  while col(".") < 40 
    exec "normal A \<Esc>"
  endwhile
  exec "normal i/* " . comm . "\<Esc>"
  while col(".") < 78
    exec "normal A \<Esc>"
  endwhile
  exec "normal A*/\<Esc>"
  if nl == 1
    exec "normal o\<Esc>"
  endif
  exec "normal `z"
endfunction

function! s:ReAlignLocalVars() range
  let max_name_length=0
  let max_asterisks_length=0
  let max_type_length=0

  let n = a:firstline
  let max = a:lastline
  while n <= max
    let full_line=getline(n)

    if stridx(full_line, ";") == -1
      echo "Line " . n . " does not have a semicolon"
      return
    endif
    let line=substitute(full_line, ";.*", "", "")
    let line_without_initializer = substitute(line, " *=.*", "", "")
    let name=substitute(line_without_initializer, ".*  *\\**\\(..*\\)", "\\1", "")
    "echo "PRE: name is " .name
    let asterisks=substitute(line_without_initializer, ".*  *\\(\\**\\).*", "\\1", "")
    let type=substitute(line_without_initializer, "\\(.*\\) .*", "\\1", "")
    let type=substitute(type, " *$", "", "")

    let name_length = strlen(name)
    let asterisks_length = strlen(asterisks)
    let type_length = strlen(type)

    if name_length > max_name_length
      let max_name_length = name_length
    endif
    if type_length > max_type_length
      let max_type_length = type_length
    endif
    if asterisks_length > max_asterisks_length
      let max_asterisks_length = asterisks_length
    endif

    let n = n + 1
  endwhile

  let n = a:firstline
  let spaces = "                                                                                                                        "
  let max = a:lastline

  while n <= max
    let full_line=getline(n)

    let comment=substitute(full_line, ".*\\(;.*\\)$", "\\1", "")
    let line=substitute(full_line, ";.*", "", "")
    let line_without_initializer = substitute(line, " *=.*", "", "")
    let name=substitute(line_without_initializer, ".*  *\\**\\(..*\\)", "\\1", "")
    "echo "name is " . name
    if stridx(line, "=") >= 0
      let initializer=substitute(line, ".*= *\\(.*\\)", " = \\1", "")
      let initializer=substitute(initializer, " *$", "", "")
    else
      let initializer=""
    endif
    "echo "line=".line." and intializer=".initializer
    let asterisks=substitute(line_without_initializer, ".*  *\\(\\**\\).*", "\\1", "")
    let type=substitute(line_without_initializer, "\\(.*\\) .*", "\\1", "")
    let type=substitute(type, " *$", "", "")

    let name_length = strlen(name)
    let asterisks_length = strlen(asterisks)
    let type_length = strlen(type)

    "echo "type=".type.";ast=".asterisks.";name=".name.";init=".initializer.";comm=".comment
    let output = type . strpart(spaces, 0, max_type_length - type_length + max_asterisks_length - asterisks_length) . " " .  asterisks .  name . initializer . comment
    call setline(n, output)

    let n = n + 1
  endwhile
endfunc
nmap <unique> <script> <Plug>ReAlignLocalVarsPlug <SID>ReAlignLocalVars
nmap <SID>ReAlignLocalVars :call <SID>ReAlignLocalVars()<CR>
nmap [j <Plug>ReAlignLocalVarsPlug

vmap <unique> <script> <Plug>ReAlignLocalVarsPlug <SID>ReAlignLocalVars
vmap <SID>ReAlignLocalVars :call <SID>ReAlignLocalVars()<CR>
vmap [j <Plug>ReAlignLocalVarsPlug

nmap <unique> <script> <Plug>CInsertFunc <SID>InsertCFunction
nmap <SID>InsertCFunction :call <SID>InsertCFunction()<CR>
nmap [f <Plug>CInsertFunc

nmap <unique> <script> <Plug>InsertHFilePlug <SID>InitHFile
nmap <SID>InitHFile :call <SID>InitHFile(input("Description? "))<CR>
nmap [h <Plug>InsertHFilePlug

nmap <unique> <script> <Plug>InsertCFilePlug <SID>InitCFile
nmap <SID>InitCFile :call <SID>InitCFile(input("Description? "))<CR>
nmap [c <Plug>InsertCFilePlug

nmap <unique> <script> <Plug>InsertLocalVar <SID>InsertLocalVar
nmap <SID>InsertLocalVar :call <SID>InsertLocalVar()<CR>
nmap [v <Plug>InsertLocalVar

nmap <unique> <script> <Plug>InsertInclude <SID>InsertInclude
nmap <SID>InsertInclude :call <SID>InsertInclude()<CR>
nmap [i <Plug>InsertInclude

"map <unique> <script> <Plug>InsertStaticVar <SID>InsertStaticVar
"map <SID>InsertStaticVar :call <SID>InsertStaticVar()
"map [v <Plug>InsertStaticVar


