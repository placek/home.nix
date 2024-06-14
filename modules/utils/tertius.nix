{ pkgs
, browserExec
}:
pkgs.writeShellScriptBin "tertius" ''
  set -e

  if [ -z "$OPENAI_API_KEY" ]; then
    >&2 echo "tertius: please set the OPENAI_API_KEY environment variable"
    exit 1
  fi

  model="''${OPENAI_MODEL:-gpt-3.5-turbo}"
  language="''${OPENAI_LANGUAGE:-english}"
  issue_tracker="''${OPENAI_ISSUE_TRACKER:-github}"
  duration="''${OPENAI_DURATION:-24 hours}"
  payload_template='{ model: $model, temperature: 1, max_tokens: 4095, top_p: 1, frequency_penalty: 0, presence_penalty: 0, messages: $data }'
  data="[]"

  usage() {
    >&2 echo "Usage: tertius ask"
    >&2 echo "       tertius grammar"
    >&2 echo "       tertius story get"
    >&2 echo "       tertius story write"
    >&2 echo "       tertius story publish TYPE"
    >&2 echo "       tertius commit write-message"
    >&2 echo "       tertius pull-request write"
    >&2 echo "       tertius pull-request publish"
    >&2 echo "       tertius report"
    >&2 echo "       tertius code fix FILE"
    >&2 echo "       tertius code explain"
  }

  current_branch_commits() {
    default_branch=$(${pkgs.git}/bin/git config --get core.default)
    branchoff_commit=$(${pkgs.git}/bin/git merge-base $default_branch HEAD 2>/dev/null)
    if [ -n "$branchoff_commit" ]; then
      ${pkgs.git}/bin/git log --format=format:"%H" $branchoff_commit..HEAD
    fi
  }

  user_story_id_from_branch() {
    git rev-parse --abbrev-ref HEAD | sed -n 's@.*/\([[:digit:]]\+\).*@\1@p'
  }

  user_story_title() {
    user_story_id=$(user_story_id_from_branch)
    if [ -n "$user_story_id" ]; then
      case $issue_tracker in
      github )
        ${pkgs.gh}/bin/gh issue view --json title $user_story_id | ${pkgs.jq}/bin/jq -r "\"[#$user_story_id] \(.title)\""
        ;;
      esac
    fi
  }

  user_story_content() {
    user_story_id=$(user_story_id_from_branch)
    if [ -n "$user_story_id" ]; then
      case $issue_tracker in
      github )
        ${pkgs.gh}/bin/gh issue view --json title,body $user_story_id | ${pkgs.jq}/bin/jq -r "\"\(.title)\n\n\(.body)\""
        ;;
      esac
    fi
  }

  publish_user_story() {
    user_story_type=$1
    body=$(cat)
    user_story_title=$(echo "$body" | head -n 1)
    user_story_body=$(echo "$body" | tail -n +2)
    default_branch=$(${pkgs.git}/bin/git config --get core.default)
    base=$(echo $default_branch | ${pkgs.gnused}/bin/sed 's@.*/@@')
    branch_descr=$(echo $user_story_title | ${pkgs.gnused}/bin/sed -E 's/.*/\L&/; s/[^a-z0-9]+/-/g; s/-$//; s/^-//;')
    case $issue_tracker in
    github )
      user_story_url=$(echo "$user_story_body" | ${pkgs.gh}/bin/gh issue create -t "$user_story_title" -a "@me" -F -)
      user_story_id=$(echo $user_story_url | ${pkgs.gnused}/bin/sed -n 's@.*github.com/[^/]\+/[^/]\+/issues/\([[:digit:]]\+\).*@\1@p')
      branch_name="$user_story_type/$user_story_id-$branch_descr"
      ${pkgs.gh}/bin/gh issue develop --base "$base" --name "$branch_name" "$user_story_id"
      ${browserExec} "$user_story_url"
      ;;
    esac
  }

  publish_pull_request() {
    body=$(cat)
    case $issue_tracker in
    github )
      user_story_title=$(user_story_title)
      pull_request_url=$(echo $body | ${pkgs.gh}/bin/gh pr create -t "$user_story_title" -F -)
      ${browserExec} "$pull_request_url"
      ;;
    esac
  }

  apply_instruction() {
    data=$(${pkgs.jq}/bin/jq -n --arg instructions "$1" --argjson data "$data" '$data + [ { role: "system", content: $instructions } ]')
  }

  apply_user_story() {
    user_story=$(user_story_content)
    if [ -n "$user_story" ]; then
      data=$(${pkgs.jq}/bin/jq -n --arg user_story "Analyze this user story as a context of the problem:\n$user_story" --argjson data "$data" '$data + [ { role: "user", content: $user_story } ]')
    fi
  }

  apply_commit_messages() {
    branch_commits=$(current_branch_commits)
    for hash in $branch_commits; do
      commit_message=$(${pkgs.git}/bin/git show -s --format=%B $hash)
      data=$(${pkgs.jq}/bin/jq -n --arg commit_message "This is a change already implemented as a step towards solution of the problem:\n$commit_message" --argjson data "$data" '$data + [ { role: "user", content: $commit_message } ]')
    done
  }

  apply_commit_messages_from() {
    author=$(${pkgs.git}/bin/git config --get user.email)
    commits=$(${pkgs.git}/bin/git log --since="$1" --author=$author --format=format:"%H" --reverse)
    for hash in $commits; do
      commit_message=$(${pkgs.git}/bin/git show -s --format=%B $hash)
      data=$(${pkgs.jq}/bin/jq -n --arg commit_message "$commit_message" --argjson data "$data" '$data + [ { role: "user", content: $commit_message } ]')
    done
  }

  apply_question_from_stdin() {
    data=$(${pkgs.jq}/bin/jq -n --arg question "$1$(cat)" --argjson data "$data" '$data + [ { role: "user", content: $question } ]')
  }

  apply_file() {
    file=$1
    data=$(${pkgs.jq}/bin/jq -n --arg file "$(cat $file)" --argjson data "$data" '$data + [ { role: "user", content: $file } ]')
  }

  openai_response() {
    payload=$(${pkgs.jq}/bin/jq -n --arg model "$model" --argjson data "$data" "$payload_template")
    response=$(${pkgs.curl}/bin/curl -s -X POST https://api.openai.com/v1/chat/completions \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -d "$payload")
    if [ $? -ne 0 ]; then
      >&2 echo "tertius: failed to get response from OpenAI API"
      exit 1
    fi
    echo "$response" | ${pkgs.jq}/bin/jq -M -r '.choices[0].message.content'
  }

  user_story_header() {
    if [ -n "$user_story_id" ]; then
      case $command in
      commit-message )
        echo -ne "[#$user_story_id] "
        ;;
      pull-request )
        echo -e "Closes #$user_story_id."; echo
        ;;
      esac
    fi
  }

  while getopts ":" arg; do
    case $arg in
    \? )
      >&2 echo "tertius: invalid option: -$OPTARG."
      usage
      exit 1
      ;;
    : )
      >&2 echo "tertius: option -$OPTARG requires an argument."
      usage
      exit 1
      ;;
    esac
  done
  shift $((OPTIND -1))

  if [ $# -eq 0 ]; then
    >&2 echo "tertius: no command provided."
    usage
    exit 1
  fi
  command=$1

  apply_instruction "Formulate all answers in $language."

  case $command in
  ask )
    apply_question_from_stdin
    user_story_header
    openai_response
    ;;

  grammar )
    apply_instruction "Correct the following text. Ensure that the text is free of spelling, grammatical and language errors. If the text is already correct, just output it."
    apply_question_from_stdin
    user_story_header
    openai_response
    ;;

  commit )
    case $2 in
    write-message )
      apply_instruction "Compose a Git commit message. To draft a Git commit message review the context in which the modifications have been made. This should include a brief explanation of the changes and a diff that showcases these modifications. Your task is to ensure that there is a clear connection between the requirements specified in the user story and the changes made in the commit. The objective is to create a concise and informative commit message that effectively communicates the reasoning behind the changes and high-level explanation of the alterations. The message should comprise a succinct title, followed by a paragraph explaining the reason for the changes. The title and the following paragraph should be separated by a blank line. Avoid using 'Title:' or similar headers."
      apply_user_story
      apply_commit_messages
      apply_question_from_stdin
      user_story_header
      openai_response
      ;;
    esac
    ;;

  story )
    case $2 in
    get )
      user_story_content
      ;;
    write )
      apply_instruction "Compose a problem description by analyzing a short explanation of the problem, and additionally, any relevant context or background information. Ensure a thorough understanding of the problem and the context in which it occurs. The goal is to generate a clear, concise problem description that provides all the necessary information to understand the problem and its context. The problem description should have a title, a paragraph with user story formatted scenario (As <actor>, I want to <action>, so <outcome>.), a 'Summary' paragraph explaining the problem, and an 'Acceptance criteria' paragraph with the tasks that has to be done to solve problem."
      apply_question_from_stdin
      user_story_header
      openai_response
      ;;
    publish )
      if [ -z "$3" ]; then
        >&2 echo "tertius: story publish requires a story type as an argument."
        usage
        exit 1
      fi
      publish_user_story $3
      ;;
    esac
    ;; # story

  pull-request )
    case $2 in
    write )
      apply_instruction "Compose a pull request description by analyzing any given commit messages. Ensure a thorough understanding of the changes and the context in which they occur. The goal is to generate a clear, concise pull request description that provides all the necessary information to understand the changes and their context. The pull request description should have a paragraph explaining the purpose of the changes, and a paragraph explaining the outcome of the changes themselves - each such component has to be separated by two newlines and have no header."
      apply_user_story
      apply_commit_messages
      user_story_header
      openai_response
      ;;
    publish )
      publish_pull_request
      ;;
    esac
    ;; # pull-request

  report )
    apply_instruction "Compose a brief report on work progress by analyzing git commits from the last $duration. Ensure a thorough understanding of the changes and the context in which they occur. The goal is to generate a clear, concise report that provides all the necessary information to understand the progress and the context of the changes. The report should be in a form of a list of bullet points, one sentence per bullet point, no headers, no nested lists, each bullet point per task, including the task ID if available. Collect all the git commit messages for a given task in a single bullet. Don't mention the commits, only the progress. "
    apply_commit_messages_from "$duration ago"
    user_story_header
    openai_response
    ;;

  code )
    case $2 in
    fix )
      if [ -z "$3" ]; then
        >&2 echo "tertius: code fix requires a file path as an argument."
        usage
        exit 1
      fi
      apply_instruction "Correct the following code. Ensure that the code is free of syntax errors and that it adheres to the best practices of the language. If the code is already correct, just output it. Do not change anything in the parts not affected by the error. Show only the code you changed. The solution should be a minimal change with one sentence of explanation."
      apply_file $3
      apply_question_from_stdin
      openai_response
      ;;

    explain )
      apply_instruction "Explain the following code. Ensure that the explanation is clear, concise and to the point, providing only the necessary information to understand the code. If it's possible, provide references (links) to the documentation or other resources. The explanation should be in a form of a bullet list."
      apply_question_from_stdin "This is a code snippet:\n"
      openai_response
      ;;
    esac
    ;;

  * )
    >&2 echo "tertius: unknown command $command"
    usage
    exit 1
    ;;
  esac

  exit 0
''
