vim9script

var loaded_global = 0

if loaded_global == 1
	finish
endif

loaded_global = 1

var global_command = 'global'

def GtagsUpdateHandler(job: job, status: number)
	if status == 0
		echo "Gtags Update!"
	endif
enddef

#function! GtagsShowHandler(job, msg)
#	let words = split(a:msg, ':')
#	call popup_atcursor(words[-1], {})	
#endfunction

def g:GtagsAutoUpdate()
    call job_start(global_command .. " -u --single-update=\"" .. expand("%") .. "\"", {'exit_cb': 'GtagsUpdateHandler'})
enddef

#function! s:GtagsShowName()
#	let result = expand("<cword>")
#	if filereadable("GPATH") == 1 && result =~# "\\<\\h\\w*\\>"
#		call job_start(s:global_command . " --result=grep " . result, {'out_cb': 'GtagsShowHandler'})
#	endif
#endfunction

def GtagsCscope_GtagsRoot()
    var cmd = global_command .. " -pq"
    var cmd_output = system(cmd)
    if v:shell_error != 0
        return ''
    endif
    return strpart(cmd_output, 0, strlen(cmd_output) - 1)
enddef

def g:GtagsCscope()
	var gtagsroot = GtagsCscope_GtagsRoot()
	if gtagsroot == ''
		return
	endif

	silent exe "cs add " .. gtagsroot .. "/GTAGS"
enddef

def GtagsReSetCscope()
    var cmd = "cd " .. fnamemodify(expand('%'), ":p:h") .. ";" .. s:global_command .. " -pq"
    var cmd_output = system(cmd)
    if v:shell_error != 0
        return
    endif

    var gtagsroot = strpart(cmd_output, 0, strlen(cmd_output) - 1)
	if gtagsroot == ''
		return
	endif

	silent exe "cs kill 0"
	call chdir(gtagsroot)
	silent exe "cs add GTAGS"
enddef

autocmd! BufWritePost * call GtagsAutoUpdate()
#autocmd! CursorHold *.c,*.h call s:GtagsShowName()
autocmd! VimEnter * call GtagsCscope()

nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-\>i :cs find i <C-R>=expand("<cfile>")<CR><CR>
nmap <C-\>a :cs find a <C-R>=expand("<cword>")<CR><CR>
nmap <silent> <C-\>r :call <SID>GtagsReSetCscope()<CR>
