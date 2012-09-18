let TasksBufferName = "__taskpacifist__"

fun! TPSetUpTasksBuffer()

    "check if the tasks buffer exists
    if bufnr(g:TasksBufferName) == -1
        "if not create it
        execute "edit " . g:TasksBufferName 
    else
        "if it's already there select it
        execute "buffer ". g:TasksBufferName
    endif

    "don't write the tasks buffer to disk
    setlocal buftype=nofile

    "delete the tasks buffer when we delete it's window
    setlocal bufhidden=delete 
    "the task descriptions can be very long, turn of line wraping
    setlocal nowrap

    setlocal nonumber
    setlocal cursorline
    execute "hi CursorLine   cterm=NONE ctermbg=darkred ctermfg=white guibg=darkred guifg=white"


    
    "setlocal noswapfile
    "setlocal buflisted

    "delete the current contents of the tasks buffer 
    call TPClearTasksBuffer()

endf

fun! TPGetTasksWithCurrentFilter()

    return TPGetTasks(g:TPCurrentFilter)
endf

fun! TPGetTasks(filter)
    let cmd = 'task rc.verbose:nothing ' . a:filter . ' export'
    let tasksblob = system(cmd)
    let tasks = []
    let lines = split(tasksblob, '\n')
    for line in lines
        "get rid of any trailing comma 
        let task = eval(matchstr(line, '{.\+}'))

        if !has_key(task, "priority")
            let task["priority"] = ""
        endif

        if !has_key(task, "project")
            let task["project"] = ""
        endif

        if !has_key(task, "tags")
            let task["tags"] = []
        endif

        call add(tasks,task)
    endfor

    return tasks

endf!

fun! TPTruncateString(str, len)
   if strlen(a:str) > a:len
      let result = strpart(a:str, 0, a:len)
   else
      let result = a:str
   end
   return result

endf

fun! TPStrLen(str)
    return len(split(a:str, '.\zs'))
endf

fun! TPStrPart(str, start, stop)
    return join(split(a:str, '.\zs')[a:start : a:stop],"")
endf


fun! TPTruncateAndPadString(str, len, paddingchar)

    "strlen doesn't deal that well with unicode chars, so we need to 
    "run a substitue on the inputstr 
    "http://tech.groups.yahoo.com/group/vimdev/mege/47905s    
    "let lenOfInputString = strlen(substitute(a:str, '.\Z', 'x', 'g'))
    let lenOfInputString = TPStrLen(a:str)
    
    "the string is to long and gets truncated
    if lenOfInputString > a:len
        let result = TPStrPart(a:str,0, a:len - 1)

    "the string gets padded
    elseif lenOfInputString < a:len

        let padding = ""
        let l:count = 0
        let stop = a:len - lenOfInputString

        while l:count < stop
            let l:count = l:count + 1
            let padding .= a:paddingchar
        endwhile

        let result = a:str . padding
    "no action neccessary 
    else
        let result = a:str
    end
    return result

endf

fun! TPRemoveFromList(lst, element)
    return  filter(copy(a:lst), "v:val != a:element")
endf


fun! TPInputTags(msg)

    let done = 0
    let result = []
    while !done
   
        let newtag = input(a:msg, "", "custom,TPCustomCompleteTags")
        if newtag == ""
            let done = 1
        else
            call add(result, newtag)  
        endif
    endwhile

    return result
endf

fun! TPUpdateFilterRequiredTagsAdd()

    let tags = TPInputTags("add tag to require:")
     
    for tag in tags
        let g:TPCurrentFilter .= printf(" +%s", tag)
    endfor 

    call TPClearAndDisplayRetainPosition()    
endf


fun! TPUpdateFilterRequiredTagsRemove()

    let tags = TPInputTags("remove tag from required tags:")
   
    for tag in tags
        let string_to_remove = printf("+%s", tag)
        let g:TPCurrentFilter = substitute(g:TPCurrentFilter, string_to_remove, "", "g")
    endfor 

    call TPClearAndDisplayRetainPosition()    
endf

fun! TPUpdateFilterExcludedTagsAdd()


    let tags = TPInputTags("add tag to exclude:")
     
    for tag in tags
        let g:TPCurrentFilter .= printf(" -%s", tag)
    endfor 

    call TPClearAndDisplayRetainPosition()    
    
endf


fun! TPUpdateFilterExcludedTagsRemove()

    let tags = TPInputTags("remove tag from excluded tags: ")
  
    for tag in tags
        let string_to_remove = printf("-%s", tag)
        let g:TPCurrentFilter = substitute(g:TPCurrentFilter, string_to_remove, "", "g")
    endfor 

    call TPClearAndDisplayRetainPosition()
endf


fun! TPDisplayTasks(...)
   
    if a:0 == 0
        let filter = g:TPCurrentFilter
    else
        let filter = a:1
    endif

    let tasks = TPGetTasks(filter)
    let lines = []
    for task in tasks

        let tagsrep = join(task["tags"], " ") 
        let line = printf("%04s | %1s | %s | %.80s", 
                          \ task["id"], 
                          \ task["priority"],
                          \ TPTruncateAndPadString(tagsrep, 20, " ") , 
                          \ task["description"]) 
        call add(lines, line)
    endfor
    call append(0,lines)

    let g:TasksBufferNr = bufnr(g:TasksBufferName)
    
    "is this the simplest way to get the beginning of the buffer
    execute "normal! goto 0"
endf

fun! TPUnmapDefaultKeyMaps()

    "How do I unset ALL key events, even the basic motion ones
    "so that I can redefine only those that I want in this context
    "mapclear does not do the trick
    "because it will also clear the mappings in other buffers
    "
    "mapclear <buffer> will not do the trick either because it
    "it will only unmap the mappings that are specific the current buffer

    "as long as we can't unset all key mappings there will be two character
    "key mappings and the vim will wait 1000 milliseconds after we enter the
    "first character in  a key mapping to figure out if we actually want
    "another mapping (containing more then on character). One way to disable
    "this behavior is to set timeoutlen to 0
    "
    "but setting timeoutlen=0 affects the entire window, not the buffer only
    "setlocal timeoutlen=500
    setlocal timeoutlen=500


    "I need to capture the output of an ex command. is this really the
    "simplest way to do it
    redir => mapblob
       silent execute 'map'
    redir END

    let lines = split(mapblob, '\n')

    let keys = map(lines, 'split( strpart(v:val, 1) )[0]')
    "strpart is in there to get out the first pesky char that will sometimes
    "be there and sometimes be whitespace
    
    "loop over all keys and map them to Nop
    for key in keys
        "let cmd = 'unmap <buffer> ' . key
        let cmd = 'map <buffer> ' . key . ' <Nop>'
        execute cmd
    endfor
endf

fun! TPUnmapDefaultKeyCodes()
    "I want to restrict the available key maps
    "this was the only way I could figure out 
    map <buffer> a <Nop>
    map <buffer> b <Nop>
    map <buffer> c <Nop>
    map <buffer> d <Nop>
    map <buffer> e <Nop>
    map <buffer> f <Nop>
    map <buffer> h <Nop>
    map <buffer> i <Nop>
    "map <buffer> j <Nop>
    "map <buffer> k <Nop>
    map <buffer> l <Nop>
    map <buffer> m <Nop>
    map <buffer> n <Nop>
    map <buffer> o <Nop>
    map <buffer> p <Nop>
    map <buffer> r <Nop>
    map <buffer> s <Nop>
    map <buffer> t <Nop>
    map <buffer> u <Nop>
    map <buffer> w <Nop>
    map <buffer> x <Nop>
    map <buffer> y <Nop>
    map <buffer> z <Nop>
    map <buffer> A <Nop>
    map <buffer> B <Nop>
    map <buffer> C <Nop>
    map <buffer> D <Nop>
    map <buffer> E <Nop>
    map <buffer> F <Nop>
    map <buffer> G <Nop>
    map <buffer> H <Nop>
    map <buffer> I <Nop>
    map <buffer> J <Nop>
    map <buffer> L <Nop>
    map <buffer> M <Nop>
    map <buffer> N <Nop>
    map <buffer> O <Nop>
    map <buffer> P <Nop>
    map <buffer> Q <Nop>
    map <buffer> R <Nop>
    map <buffer> S <Nop>
    map <buffer> T <Nop>
    map <buffer> U <Nop>
    map <buffer> W <Nop>
    map <buffer> X <Nop>
    map <buffer> Y <Nop>
    map <buffer> Z <Nop>
    map <buffer> 0 <Nop>
    map <buffer> !   <Nop>
    map <buffer> @   <Nop>
    map <buffer> $   <Nop>
    map <buffer> %   <Nop>
    map <buffer> ^   <Nop>
    map <buffer> &   <Nop>
    map <buffer> (   <Nop>
    map <buffer> )   <Nop>
    "map <buffer> |   <Nop>
    map <buffer> -   <Nop>
    map <buffer> _   <Nop>
    map <buffer> +   <Nop>
    map <buffer> [   <Nop>
    map <buffer> ]   <Nop>
    map <buffer> {   <Nop>
    map <buffer> }   <Nop>
    map <buffer> ;   <Nop>
    map <buffer> '   <Nop>
    map <buffer> `   <Nop>
    "map <buffer> :   <Nop>
    map <buffer> "   <Nop>
    map <buffer> ~   <Nop>
    map <buffer> ,   <Nop>
    map <buffer> .   <Nop>
    "map <buffer> /   <Nop>
    map <buffer> <   <Nop>
    map <buffer> >   <Nop>
    map <buffer> ?   <Nop>
    "map <buffer> ^B  <Nop>
    "map <buffer> ^D  <Nop>
    "map <buffer> ^E  <Nop>
    "map <buffer> ^F  <Nop>
    map <buffer> ^G  <Nop>
    map <buffer> ^H  <Nop>
    "map <buffer> ^J  <Nop>
    "map <buffer> ^L  <Nop>
    map <buffer> ^M  <Nop>
    "map <buffer> ^N  <Nop>
    "map <buffer> ^P  <Nop>
    map <buffer> ^Q  <Nop>
    map <buffer> ^R  <Nop>
    map <buffer> ^S  <Nop>
    map <buffer> ^T  <Nop>
    "map <buffer> ^U  <Nop>
    "map <buffer> ^Y  <Nop>
    map <buffer> ^Z  <Nop>
    map <buffer> ^[  <Nop>
    map <buffer> ^\  <Nop>
    map <buffer> ^]  <Nop>
    map <buffer> ^^  <Nop>
endf


fun! TPClearTasksBuffer()
    execute '1,$d'
endf

fun! TPClearAndDisplay()
    call TPClearTasksBuffer()
    call TPDisplayTasks()
endf 

fun! TPClearAndDisplayRetainPosition()
    let posline = line('.')
    call TPClearAndDisplay()
    "execute "normal! " . posline . "j"
endf

"this and most other functions only make sense when in the context of this
"script but when this file gets loaded it will pollute the users namespace
"anyway. Is there a way of making functions 'private' to a script?
fun! TPGetIDOfTaskOnCurrentLine()
    return matchstr(getline('.'), '[1-9]\d*')
endf

fun! TPIssueCommandAtCurrentLineAndRedisplay(template)
    
    let g:lastcommand = a:template
    "save our original location
    let posline = line('.')

    "get the id of the task on the current line
    let id = TPGetIDOfTaskOnCurrentLine()
    "clear and redisplay our task
    call TPClearTasksBuffer()
    let cmd = printf(a:template, id)
    
    "I couldn't figure out how to run a shell command without capturing the
    "output 
    let waste = system(cmd)
    call TPDisplayTasks()
    
    let posline = posline - 1
    execute  "normal! " . posline . "j"

    "silent execute cmd
endf

fun! TPRepeatLastLineCommand()
    call TPIssueCommandAtCurrentLineAndRedisplay(g:lastcommand)
endf

"most of these could be done as a mapping instead, this is more verbose and
"repetitive but also more readable
fun! TPSetPriorityHigh()
    let template =  "task %s modify priority:H"
    call TPIssueCommandAtCurrentLineAndRedisplay(template)
endf

fun! TPSetPriorityMedium()
    let template =  "task %s modify priority:M"
    call TPIssueCommandAtCurrentLineAndRedisplay(template)
endf

fun! TPSetPriorityLow()
    let template =  "task %s modify priority:L"
    call TPIssueCommandAtCurrentLineAndRedisplay(template)
endf

fun! TPSetPriorityNone()
    let template =  "task %s modify priority:"
    call TPIssueCommandAtCurrentLineAndRedisplay(template)
endf

fun! TPCompleteTask()
    let template =  "task %s done"
    call TPIssueCommandAtCurrentLineAndRedisplay(template)
endf

fun! TPDeleteTask()
    let template =  "task rc.confirmation=no %s delete"
    call TPIssueCommandAtCurrentLineAndRedisplay(template)
endf

fun! TPCustomCompleteTags(A, L, P)
    let tagsblob = system("task _tags")
    return tagsblob 
endf

fun! TPUpdateFilter()
    let g:TPCurrentFilter = input("new filter: ", g:TPCurrentFilter)
    call TPClearAndDisplayRetainPosition()
endf

fun! TPDisplayTasksEnteredToday()
    let g:TPCurrentFilter = "entry.after:today"
    call TPClearAndDisplay()
endf 

fun! TPRemoveTagsWithPrompts()
    let id = TPGetIDOfTaskOnCurrentLine()

    let donewithtags = 0
    let tags = []
    while !donewithtags
    
        "TODO the completion function here should really use the list of tags 
        "TODO there's a lot of redundancy in these functions, refactor
        let newtag = input("tag to remove: ", "", "custom,TPCustomCompleteTags")
        if newtag == ""
            let donewithtags = 1
        else
            call add(tags, newtag)  
        endif
    endwhile
   
    let tagrep = ""
    for tag in tags
        let tagrep .= " -" . tag
    endfor 

    let cmdtemplate = "task %s modify " . tagrep
    "let g:lastcommand = cmdtemplate
    call TPIssueCommandAtCurrentLineAndRedisplay(cmdtemplate) 
endf

fun! TPAddTagsWithPrompts()

    let id = TPGetIDOfTaskOnCurrentLine()

    let donewithtags = 0
    let tags = []
    while !donewithtags
   
        let newtag = input("tag to add: ", "", "custom,TPCustomCompleteTags")
        if newtag == ""
            let donewithtags = 1
        else
            call add(tags, newtag)  
        endif
    endwhile
   
    let tagrep = ""
    for tag in tags
        let tagrep .= " +" . tag
    endfor 

    let cmdtemplate = "task %s modify " . tagrep
    "let g:lastcommand = cmdtemplate
    call TPIssueCommandAtCurrentLineAndRedisplay(cmdtemplate) 
     
endf


fun! TPRepeatLastCommand()
    call TPIssueCommandAtCurrentLineAndRedisplay(g:lastcommand)
endf

fun! TPEscapeQuotes(str)
    return substitute(a:str, '"', '\\"', "g") 
endf

fun! TPInputTaskUntilEmpty()

    let result = []

    "get tags keep asking until we return empty string
    let donewithtags = 0
    while !donewithtags
        let newtag = input("tag: ", "", "custom,TPCustomCompleteTags")
        if newtag == ""
            let donewithtags = 1
        else
            call add(result, newtag)  
        endif
    endwhile

    return result
endf

fun! TPGetTagRepresentation(tags)

    let result = ""
    for tag in a:tags
        let result .= " +" . tag
    endfor 
    
    return result 
endf

fun! TPAddTaskWithPrompts()
    
    let tags = []

    "get the description
    let description = input("description:")
    let description = TPEscapeQuotes(description)
    
    "get tags keep asking until we return empty string
    let tags = TPInputTaskUntilEmpty()
  
    let tagreprentation = TPGetTagRepresentation(tags)

    
    let repr = printf("add this task? '%s' | %s",  description, tagreprentation)
    
    let choice = confirm(repr, "yes\nabort", 1 )
    if choice == 1
        let cmd = printf("task add \"%s\" %s", description, tagreprentation)
        let waste = system(cmd)
    endif

    call TPClearAndDisplay()
endf



fun! TPUndo()
    let template = "task rc.confirmation=no %s undo"
    "the %s shouldn't really be there 
    call TPIssueCommandAtCurrentLineAndRedisplay(template)
endf

fun! TPGetCurrentlyRunningTask()
    "Get ONE currently running task
    "We should not allow for more then one task to be running at the same time
    "but that isn't controlled here

    let tasks = TPGetTasks("start.any:")
    if len(tasks) == 0
        let task = {}
    else
        let task = tasks[0]
    endif

    return task 
endf

fun! TPStatusLine()
    
    let runningtaskstring="[No task running at the moment]"
    
    let g:TPCurrentlyRunningTask = TPGetCurrentlyRunningTask()

    if g:TPCurrentlyRunningTask != {}
        let runningtaskstring=printf("[*running task* %s]", g:TPCurrentlyRunningTask["description"])
    endif
    return printf("[*filter* %s]%s[%s]",  g:TPCurrentFilter, runningtaskstring,  g:TPLastMessage)
endf

fun! TPStopAllRunningTasks()
    "Indisriminately stop all active task, (shouldn't be more then one)
    let task = TPGetCurrentlyRunningTask()
    while task != {}
        let cmd = "task " . task["uuid"] . " stop"
        let waste = system(cmd)
        let task = TPGetCurrentlyRunningTask()
    endwhile

endf

fun! TPStartTask()
    "stop any other running tasks
    call TPStopAllRunningTasks()

    "And start the task on the current line
    let id = TPGetIDOfTaskOnCurrentLine()
    let cmd  =  "task " . id . " start"
    let waste = system(cmd)
endf


fun! TPSetupFilterDefault()
    let g:TPCurrentFilter = "status:pending -somedaymaybe -notthisweek"
endf


fun! TPSetupFilterTodoToday()
    let g:TPCurrentFilter = "status:pending -somedaymaybe -notthisweek +todotoday"
endf


fun! TPSetupFilterGTD()
    let g:TPCurrentFilter = "status:pending due:today "
endf

fun! TPInitialize(filter)
    "save the incoming filter to our global filter variable so that we 
    "can reapply it later
    "
    "append incoming filter to our default global filter

    call TPSetupFilterDefault()

    let g:TPLastMessage = "Welcome to Taskpacifist"
    let g:TPCurrentlyRunningTask = TPGetCurrentlyRunningTask()
    call TPSetUpTasksBuffer()
    call TPSetupKeyMappings()    
    call TPDisplayTasks(g:TPCurrentFilter)

    setlocal laststatus=2
    setlocal statusline=%{TPStatusLine()}
    
    silent echom g:TPLastMessage
endf

fun! TPSetGTDFilterAndRedisplay()
    call TPSetupFilterGTD()
    call TPClearAndDisplayRetainPosition()
endf

fun! TPSetDefaultFilterAndRedisplay()
    call TPSetupFilterDefault()
    call TPClearAndDisplayRetainPosition()
endf



fun! TPSetTodoTodayFilterAndRedisplay()
    call TPSetupFilterTodoToday()
    call TPClearAndDisplayRetainPosition()
endf

fun! TPSetupKeyMappings()
    call TPUnmapDefaultKeyMaps()
    call TPUnmapDefaultKeyCodes()
    
    nmap <buffer> c   :call TPCompleteTask()<CR>
  
    nmap <buffer> u   :call TPUndo()<CR>
    nmap <buffer> d   :call TPDeleteTask()<CR>
    nmap <buffer> .  :call TPRepeatLastLineCommand()<CR>  

    "Tag manipulations
    nmap <buffer> t+  :call TPAddTagsWithPrompts()<CR>
    nmap <buffer> t-  :call TPRemoveTagsWithPrompts()<CR>

    
    "Adding new tasks
    nmap <buffer> +   :call TPAddTaskWithPrompts()<CR> 
    nmap <buffer> ap   :call TPAddTaskWithPrompts()<CR> 
    
    "Filter maps
    "nmap <buffer> ft   :call TPDisplayTasksEnteredToday()<CR> 
    nmap <buffer> ft   :call TPSetTodoTodayFilterAndRedisplay()<CR>

     
    nmap <buffer> fe+  :call TPUpdateFilterExcludedTagsAdd()<CR>
    nmap <buffer> fe-  :call TPUpdateFilterExcludedTagsRemove()<CR>

    nmap <buffer> fr+  :call TPUpdateFilterRequiredTagsAdd()<CR>
    nmap <buffer> fr-  :call TPUpdateFilterRequiredTagsRemove()<CR>
    
    nmap <buffer> fd   :call TPSetDefaultFilterAndRedisplay()<CR>
    nmap <buffer> fg   :call TPSetGTDFilterAndRedisplay()<CR>

    "nmap <buffer> fu   :call TPUpdateFilter()<CR>              
    
    nmap <buffer> ph   :call TPSetPriorityHigh()<CR>
    nmap <buffer> pm   :call TPSetPriorityMedium()<CR>
    nmap <buffer> pl   :call TPSetPriorityLow()<CR>
    nmap <buffer> pn   :call TPSetPriorityNone()<CR>
   
    "punch in
    nmap <buffer> pi :call TPStartTask()<CR>
    
    "punch out
    nmap <buffer> po :call TPStopAllRunningTasks()<CR>


    "The only key map that is not buffer specific


endf


"let g:TPDefaultFilter = "status:pending -somedaymaybe"

nmap TP :execute TPInitialize("")<CR>
