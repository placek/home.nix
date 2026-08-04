" Tertius plugin for Vim
" This plugin provides utilities for working with version control systems (Git).
" It utilizes the LLM capabilities to assist with repository workflow over
" the feature branch.
" Author: Paweł Placzyński
" License: MIT License
" Version: 0.2.0

if exists('g:loaded_tertius')
  finish
endif
let g:loaded_tertius = 1

let g:tertius_config = {
  \ 'gitExec': 'git',
  \ 'curlExec': 'curl',
  \ 'defaultBranch': 'origin/master',
  \ 'userStoryIdPattern': '\[\([^\]]\+\)\]',
  \ 'maxToolCallDepth': 10,
  \ 'tools': [
  \   { 'type': 'function', 'function': {
  \       'name': 'list_commits',
  \       'description': 'List commits on current feature branch',
  \       'parameters': { 'type': 'object', 'properties': {}, 'required': [] }
  \   } },
  \   { 'type': 'function', 'function': {
  \       'name': 'get_commit_message',
  \       'description': 'Get feature context from the commit with a given hash',
  \       'parameters': { 'type': 'object', 'properties': { 'hash': { 'type': 'string', 'description': 'The SHA of the commit' } }, 'required': ['hash'] }
  \   } }
  \ ],
  \ 'prompts': {
\   'commit_message': "You are assisting with writing a Git commit message. Your entire output is used verbatim as the message passed to git commit, so it must contain the commit message and nothing else.\nFetch the list of commits and analyze their details in order to understand the context of the changes you describe. The commits to analyze contain context info: (1) business context — a user story, ticket, or problem description explaining why the change is needed; (2) implementation context — previous commit messages and relevant details about what has already been done. Additionally, the input you receive contains a diff — the code changes introduced in this commit together with an optional comment from the user. Using this information, write a Git commit message that follows these principles:\n- Start with a concise, imperative title summarizing what this commit does (ideally 50 characters or less), with no trailing period.\n- Optionally follow with one blank line and one short paragraph (1–2 sentences) explaining why this change is needed or valuable, focusing on the reasoning rather than detailed code descriptions.\n- Follow conventional commit best practices (clarity, conciseness, focus on intent and value).\nStrict output format — this is mandatory:\n- Output ONLY the raw commit message text, ready to be committed as-is.\n- Do NOT use Markdown or any formatting: no code fences, no backticks, no headers, no bold, no italics, no bullet-point markup.\n- Do NOT include labels such as 'Title:', 'Summary:' or 'Commit message:'.\n- Do NOT include any analysis, reasoning, notes, or commentary about the changes or about your process.\n- Do NOT add any preamble or closing remark such as 'Here is the commit message'. Begin your response directly with the title line.",
  \  'user_story': 'Compose a user story, by reviewing the context in which the problem occurs. This should include a brief explanation of the problem and any relevant background information. Your task is to ensure that there is a clear connection between the problem and the context in which it occurs. The objective is to create a concise and informative user story that effectively communicates the problem and its context. The user story should have a title, a paragraph with a user story formatted scenario (As <actor>, I want to <action>, so <outcome>.), a "Summary" paragraph explaining the problem, and an "Acceptance criteria" paragraph with the tasks that has to be done to solve problem.',
  \  'pull_request': 'Compose a pull request description by analyzing any given commit messages. Ensure a thorough understanding of the changes and the context in which they occur. The goal is to generate a clear, concise pull request description that provides all the necessary information to understand the changes and their context. The pull request description should have a paragraph explaining the business purpose of the changes, and a paragraph explaining the outcome of the changes themselves - each such component has to be separated by two newlines and have no header.',
  \  'todo_list': 'Compose a todo list for the software developer to complete. To draft a todo list, review the context in which the tasks have to be done and the proposed main goals. This should include a brief explanation of the tasks and any relevant background information. Ensure that there is a clear connection between the tasks and the context in which they occur. The objective is to create a concise and informative todo list that effectively communicates the tasks and their context. The todo list should be formatted in the xit format. Where necessary, use paragraphs to split relevant sections of the todo list.',
  \  'code_review': 'Review the feature branch. To draft a review, analyze the context in which the changes have been made. This should include a brief explanation of the changes and any relevant background information. Ensure that there is a clear connection between the changes and the context in which they occur.  The objective is to create a concise yet comprehensive review that effectively communicates the doubts and questions about the changes. Focus on the implementation details, and the connection between the user story: is the implementation correct, does it cover all the edge cases, is it full in terms of the user story, is it well tested, etc. The review should be formatted in the markdown format.',
  \  'merge_message': "Compose a merge commit message summarizing the feature branch. Fetch the list of commits and analyze their details to understand the full scope of changes. The merge message should:\n- Start with a concise title summarizing what this feature branch accomplishes.\n- Follow with a brief paragraph explaining the business purpose and outcome of the changes.\n- Do not include any headers like 'Title:' or 'Summary:'.\n- Maintain an imperative tone.\n- Be concise but comprehensive enough to serve as a historical record of the merged feature."
  \   }
  \ }

"""""""""""""""""""" VCS utility functions for Tertius plugin """"""""""""""""""

" curl command wrapper
function! s:_tertius_curl(cmd) abort
  if !executable(g:tertius_config.curlExec)
    echoerr 'Tertius: curl executable not found: ' . g:tertius_config.curlExec
    return ''
  endif
  return system(g:tertius_config.curlExec . ' ' . a:cmd)
endfunction

" git command wrapper
function! s:_tertius_git(cmd, ...) abort
  if !executable(g:tertius_config.gitExec)
    echoerr 'Tertius: git executable not found: ' . g:tertius_config.gitExec
    return ''
  endif
  if a:0 > 0
    return system(g:tertius_config.gitExec . ' ' . a:cmd, a:1)
  else
    return system(g:tertius_config.gitExec . ' ' . a:cmd)
  endif
endfunction

" check the exit status of the last shell command
function! s:_tertius_git_ok() abort
  return v:shell_error == 0
endfunction

" open a new buffer for intermediate operations
function! s:_tertius_open_intermediate_buffer(type) abort
  wincmd n
  setlocal buftype=nofile
  setlocal bufhidden=delete
  setlocal noswapfile
  setlocal syntax=markdown
  execute 'file /tmp/tertius_' . a:type
  execute 'setlocal filetype=' . a:type
endfunction

" get the default branch of the current git repository
function! s:_tertius_git_default_branch() abort
  let l:result = trim(<sid>_tertius_git("config --get core.defaultBranch"))
  if empty(l:result)
    return g:tertius_config.defaultBranch
  else
    return l:result
  endif
endfunction

" get the current branch of the current repository
function! s:_tertius_git_current_branch() abort
  return trim(<sid>_tertius_git("rev-parse --abbrev-ref HEAD"))
endfunction

" get the branch-off commit of the current branch
function! s:_tertius_git_branchoff_commit() abort
  return trim(<sid>_tertius_git("merge-base " . <sid>_tertius_git_default_branch() . " HEAD"))
endfunction

" get commits from the current branch
function! s:_tertius_git_current_branch_commits() abort
  return split(<sid>_tertius_git("log --format=%H " . <sid>_tertius_git_branchoff_commit() . "..HEAD"), "\n")
endfunction

" check if commit is empty (has no file changes)
function! s:_tertius_git_commit_is_empty(commit) abort
  if empty(a:commit)
    echoerr 'Tertius: commit is not specified'
    return -1
  endif
  return empty(trim(<sid>_tertius_git("show --pretty=format: --name-only " . a:commit)))
endfunction

" extract commit message
function! s:_tertius_git_commit_message(commit) abort
  let l:empty = <sid>_tertius_git_commit_is_empty(a:commit)
  if l:empty == -1
    return ''
  elseif l:empty
    let l:msg = "Business context:\n"
  else
    let l:msg = "Implementation context:\n"
  endif
  let l:msg = l:msg . <sid>_tertius_git("show --pretty=format:%H\\n%B --name-only " . a:commit)
  return trim(l:msg)
endfunction

" get the branch name from the buffer text
function! s:_tertius_git_branch_name_from_buffer_text() abort
  return substitute(trim(substitute(tolower(getline(1)), '[^a-z0-9-]', ' ', 'g')), '\s\+', '-', 'g')
endfunction

" extract user story id from text
function! s:_tertius_git_user_story_id(text) abort
  let l:matches = matchlist(a:text, g:tertius_config.userStoryIdPattern)
  if len(l:matches) > 1
    return l:matches[1]
  endif
  return ""
endfunction

" checks if a buffer is empty, but contains comments
function! s:_tertius_is_buffer_empty_but_comments() abort
  for i in range(1, line('$'))
    let line = substitute(getline(i), '^\s*', '', '')
    if line != '' && line[0] != '#'
      return 0
    endif
  endfor
  return 1
endfunction

" initialize feature branch
function! s:_tertius_git_init_feature_branch() abort
  if <sid>_tertius_is_buffer_empty_but_comments()
    return
  endif
  let l:branch = <sid>_tertius_git_branch_name_from_buffer_text()
  let l:has_changes = !empty(trim(<sid>_tertius_git('status --porcelain')))
  if l:has_changes
    call <sid>_tertius_git('add .')
    call <sid>_tertius_git('stash')
  endif
  call <sid>_tertius_git('fetch --all')
  call <sid>_tertius_git('checkout ' . <sid>_tertius_git_default_branch())
  call <sid>_tertius_git('checkout -B ' . l:branch)
  call <sid>_tertius_git('commit --no-verify --allow-empty --file -', getline(1, '$'))
  if !<sid>_tertius_git_ok()
    echoerr 'Tertius: failed to create initial commit on branch ' . l:branch
    return
  endif
  if l:has_changes
    call <sid>_tertius_git('stash pop')
  endif
  echom "Tertius: feature branch " . l:branch . " initialized"
endfunction

"""""""""""""""""""""""""""""""""""" LLM tools """""""""""""""""""""""""""""""""""""
" prepare the LLM settings
function! s:_tertius_llm_init() abort
  let g:tertius_config.llmBaseUrl = !empty($LLAMA_CPP_BASE_URL) ? $LLAMA_CPP_BASE_URL : 'http://localhost:8088/v1'
  let g:tertius_config.llmEndpoint = '/chat/completions'
endfunction

" request LLM body
function! s:_tertius_llm_request_body(messages) abort
  let l:body = { 'messages': a:messages,
               \ 'tools': g:tertius_config.tools,
               \ 'tool_choice': 'auto'
               \ }
  return json_encode(l:body)
endfunction

" process LLM request
function! s:_tertius_request(messages) abort
  let l:body = <sid>_tertius_llm_request_body(a:messages)
  let l:cmd = '--silent --fail ' .
            \ '--request POST ' .
            \ '--header "Content-Type: application/json" ' .
            \ '--data ' . shellescape(l:body) . ' ' .
            \ '"' . g:tertius_config.llmBaseUrl . g:tertius_config.llmEndpoint . '"'

  let l:response = <sid>_tertius_curl(l:cmd)
  if empty(l:response)
    echoerr 'Tertius: empty response from LLM'
    return v:null
  endif
  try
    return json_decode(l:response)
  catch
    echoerr 'Tertius: failed to parse LLM response: ' . v:exception
    return v:null
  endtry
endfunction

" call LLM tools
function! s:_tertius_tool_caller(tool_call, previous_messages) abort
  let fname = a:tool_call.function.name
  let l:raw_args = get(a:tool_call.function, 'arguments', '')
  
  if empty(l:raw_args)
    let args = {}
  elseif type(l:raw_args) == type('')
    let args = json_decode(l:raw_args)
  else
    let args = l:raw_args
  endif

  " Detect if the LLM is stuck in a loop (calling the same tool with the exact same args)
  let l:is_loop = 0
  for msg in a:previous_messages
    if get(msg, 'role', '') ==# 'assistant' && has_key(msg, 'tool_calls') && type(msg.tool_calls) == type([])
      for prev_tc in msg.tool_calls
        if type(prev_tc) == type({}) && has_key(prev_tc, 'function')
          if prev_tc.function.name ==# fname && get(prev_tc.function, 'arguments', '') ==# l:raw_args
            let l:is_loop = 1
            break
          endif
        endif
      endfor
    endif
  endfor

  if l:is_loop
    echom "Tertius: Detected tool loop for " . fname . ". Forcing continuation."
    let result = "System notice: You already called this tool with these exact arguments. Do not call it again. Generate your final response using the context you have."
  elseif fname ==# 'list_commits'
    echom "Tertius: listing commits on current feature branch"
    let result = <sid>_tertius_git_current_branch_commits()
  elseif fname ==# 'get_commit_message'
    let l:hash = get(args, 'hash', '')
    echom "Tertius: getting commit message for commit " . l:hash
    let result = <sid>_tertius_git_commit_message(l:hash)
  else
    echoerr "Tertius: unknown tool function: " . fname
    let result = 'unknown tool'
  endif

  let l:content = type(result) == type([]) || type(result) == type({}) ? json_encode(result) : result
  
  " Prevent silent failures causing loops
  if empty(l:content)
    let l:content = "No output or empty result."
  endif

  " OpenAI spec requires 'name' (not 'tool_name') and 'tool_call_id'
  let l:tool_message = { 'role': 'tool',
                       \ 'name': fname,
                       \ 'content': l:content
                       \ }
                       
  if has_key(a:tool_call, 'id')
    let l:tool_message.tool_call_id = a:tool_call.id
  else
    " Fallback in case local LLM generated a tool call without an ID
    let l:tool_message.tool_call_id = 'call_' . fname
  endif

  return l:tool_message
endfunction

function! s:_tertius_handle_response(messages, ...) abort
  let l:depth = a:0 > 0 ? a:1 : 0
  if l:depth >= g:tertius_config.maxToolCallDepth
    echoerr 'Tertius: maximum tool call depth reached (' . g:tertius_config.maxToolCallDepth . ')'
    return
  endif

  let l:response = <sid>_tertius_request(a:messages)

  if l:response is v:null
    return
  endif

  if type(l:response) == type({}) && has_key(l:response, 'error')
    echoerr 'Tertius: ' . get(l:response.error, 'message', 'unknown error')
    return
  endif

  " Fix: OpenAI-compatible APIs return data inside a 'choices' array.
  if !has_key(l:response, 'choices') || empty(l:response.choices)
    echoerr 'Tertius: invalid response format (missing choices array)'
    return
  endif

  " Extract the actual message object from the first choice
  let l:message = l:response.choices[0].message

  if has_key(l:message, 'tool_calls') && type(l:message.tool_calls) == type([]) && !empty(l:message.tool_calls)
    let l:result = deepcopy(a:messages)
    call add(l:result, l:message)
    for tool_call in l:message.tool_calls
      call add(l:result, <sid>_tertius_tool_caller(tool_call))
    endfor
    return <sid>_tertius_handle_response(l:result, l:depth + 1)
  endif

  if has_key(l:message, 'content') && type(l:message.content) == type('')
    call setline(1, split(l:message.content, "\n"))
  else
    echoerr "Tertius: no content in response message"
  endif
endfunction

" generic Tertius function to handle commands
function! Tertius(cmd, content) abort
  call <sid>_tertius_llm_init()
  let l:system = g:tertius_config.prompts[a:cmd]
  let l:user = type(a:content) == type([]) ? join(a:content, "\n") : a:content
  let l:messages = [ { 'role': 'system', 'content': l:system },
                   \ { 'role': 'user', 'content': l:user }
                   \ ]
  call <sid>_tertius_handle_response(l:messages)
endfunction

""""""""""""""""""""""""" TERTIUS commands and mappings """""""""""""""""""""""""
function! TertiusOpenUserStoryWindow() abort
  call <sid>_tertius_open_intermediate_buffer('user_story')
endfunction
nnoremap <plug>(TertiusOpenUserStoryWindow) :call TertiusOpenUserStoryWindow()<cr>

function! TertiusUserStory() abort
  call Tertius('user_story', getline(1, '$'))
endfunction
nnoremap <plug>(TertiusUserStory) :call TertiusUserStory()<cr>

function! TertiusOpenPullRequestWindow() abort
  call <sid>_tertius_open_intermediate_buffer('pull_request')
endfunction
nnoremap <plug>(TertiusOpenPullRequestWindow) :call TertiusOpenPullRequestWindow()<cr>

function! TertiusPullRequest() abort
  call Tertius('pull_request', getline(1, '$'))
endfunction
nnoremap <plug>(TertiusPullRequest) :call TertiusPullRequest()<cr>

function! TertiusOpenCodeReviewWindow() abort
  call <sid>_tertius_open_intermediate_buffer('code_review')
  call Tertius('code_review', '')
endfunction
nnoremap <plug>(TertiusOpenCodeReviewWindow) :call TertiusOpenCodeReviewWindow()<cr>

function! TertiusCommitMessage() abort
  call Tertius('commit_message', getline(1, '$'))
endfunction
nnoremap <plug>(TertiusCommitMessage) :call TertiusCommitMessage()<cr>

function! TertiusOpenTodoListWindow() abort
  call <sid>_tertius_open_intermediate_buffer('todo_list')
endfunction
nnoremap <plug>(TertiusOpenTodoListWindow) :call TertiusOpenTodoListWindow()<cr>

function! TertiusTodoList() abort
  call Tertius('todo_list', getline(1, '$'))
endfunction
nnoremap <plug>(TertiusTodoList) :call TertiusTodoList()<cr>

function! TertiusMergeMessage() abort
  call Tertius('merge_message', '')
endfunction
nnoremap <plug>(TertiusMergeMessage) :call TertiusMergeMessage()<cr>

let s:tertius_merge_branch = ''

function! TertiusMergeFeatureBranch() abort
  let l:status = trim(<sid>_tertius_git('status --porcelain'))
  if !empty(l:status)
    echoerr 'Tertius: there are uncommitted changes on the branch'
    return
  endif
  let l:current = <sid>_tertius_git_current_branch()
  let l:default = substitute(<sid>_tertius_git_default_branch(), '^origin/', '', '')
  if l:current ==# l:default
    echoerr 'Tertius: already on the main branch'
    return
  endif
  let s:tertius_merge_branch = l:current
  call <sid>_tertius_open_intermediate_buffer('merge_message')
  call Tertius('merge_message', '')
endfunction
nnoremap <plug>(TertiusMergeFeatureBranch) :call TertiusMergeFeatureBranch()<cr>

function! s:_tertius_git_merge_feature_branch() abort
  if <sid>_tertius_is_buffer_empty_but_comments()
    return
  endif
  if empty(s:tertius_merge_branch)
    echoerr 'Tertius: no feature branch to merge'
    return
  endif
  let l:branch = s:tertius_merge_branch
  let s:tertius_merge_branch = ''
  let l:default = substitute(<sid>_tertius_git_default_branch(), '^origin/', '', '')
  call <sid>_tertius_git('checkout ' . l:default)
  if !<sid>_tertius_git_ok()
    echoerr 'Tertius: failed to checkout ' . l:default
    return
  endif
  call <sid>_tertius_git('merge --no-ff --no-commit ' . l:branch)
  if !<sid>_tertius_git_ok()
    call <sid>_tertius_git('merge --abort')
    call <sid>_tertius_git('checkout ' . l:branch)
    echoerr 'Tertius: merge failed (conflicts?), returned to ' . l:branch
    return
  endif
  call <sid>_tertius_git('commit --file -', getline(1, '$'))
  if !<sid>_tertius_git_ok()
    echoerr 'Tertius: failed to create merge commit'
    return
  endif
  echom "Tertius: feature branch " . l:branch . " merged into " . l:default
endfunction

"""""""""""""""""""""""""""""""""" AUTOCMDs """"""""""""""""""""""""""""""""""""""

augroup Tertius
  autocmd!
  autocmd FileType  gitcommit                  nnoremap <buffer> <cr> <Plug>(TertiusCommitMessage)<cr>
  autocmd FileType  tertius_user_story         nnoremap <buffer> <cr> <Plug>(TertiusUserStory)<cr>
  autocmd FileType  tertius_merge_message      nnoremap <buffer> <cr> <Plug>(TertiusMergeMessage)<cr>
  autocmd FileType  tertius_todo_list          nnoremap <buffer> <cr> <Plug>(TertiusTodoList)<cr>
  autocmd BufUnload /tmp/tertius_user_story    call <sid>_tertius_git_init_feature_branch()
  autocmd BufUnload /tmp/tertius_merge_message call <sid>_tertius_git_merge_feature_branch()
augroup END
