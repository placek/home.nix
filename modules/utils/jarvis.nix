{ pkgs
}:
pkgs.writeShellScriptBin "jarvis" ''
  set -e

  if [ -z "$OPENAI_API_KEY" ]; then
    >&2 echo "jarvis: please set the OPENAI_API_KEY environment variable"
    exit 1
  fi

  model="''${model:-gpt-3.5-turbo}"
  payload_template='{ model: $model, temperature: 1, max_tokens: 4096, top_p: 1, frequency_penalty: 0, presence_penalty: 0, messages: $data }'
  data=""

  usage() {
    >&2 echo "Usage: jarvis [-m \"model\"] ask"
    >&2 echo "       jarvis [-m \"model\"] story"
    >&2 echo "       jarvis [-m \"model\"] commit-message"
    >&2 echo "       jarvis [-m \"model\"] pull-request"
  }

  while getopts ":m:" arg; do
    case $arg in
    m )
      model=$OPTARG
      ;;
    \? )
      >&2 echo "jarvis: invalid option: -$OPTARG."
      usage
      exit 1
      ;;
    : )
      >&2 echo "jarvis: option -$OPTARG requires an argument."
      usage
      exit 1
      ;;
    esac
  done
  shift $((OPTIND -1))

  if [ $# -eq 0 ]; then
    >&2 echo "jarvis: no command provided."
    usage
    exit 1
  fi

  command=$1

  case $command in
  ask )
    data=$(${pkgs.jq}/bin/jq -n --arg question "$(cat)" '[ { role: "user", content: $question } ]')
    ;;

  commit-message )
    default_branch=$(${pkgs.git}/bin/git config --get core.default)
    branchoff_commit=$(${pkgs.git}/bin/git merge-base $default_branch HEAD)
    branch_commits=$(${pkgs.git}/bin/git log --format=format:"%H" $branchoff_commit..HEAD)
    issue=$(${pkgs.git}/bin/git rev-parse --abbrev-ref HEAD | ${pkgs.gnused}/bin/sed -n 's@.*/\([[:digit:]]\+\).*@\1@p')

    if [ -n "$issue" ]; then
      instructions="Compose a Git commit message. To draft a Git commit message, first analyze the user story to understand why changes were needed. Next, review the series of commit messages to see what modifications have been made. Concentrate on the last item, considering it the commit candidate. This should include a brief explanation of the changes and a diff that showcases these modifications. Your task is to ensure that there is a clear connection between the requirements specified in the user story and the changes made in the commit. The objective is to create a concise and informative commit message that effectively communicates the reasoning behind the changes and details the specific alterations. The message should comprise a succinct title, followed by two paragraphs: one explaining the reason for the changes and another describing the changes themselves. Each section should be separated by a blank line, without any headings."
      context=$(${pkgs.gh}/bin/gh issue view --json title,body $issue | ${pkgs.jq}/bin/jq  "\"\(.title)\n\n\(.body)\"")
      data=$(${pkgs.jq}/bin/jq -n --arg instructions "$instructions" --arg context "This is the user story:\n$context" '[ { role: "system", content: $instructions }, { role: "user", content: $context } ]')
    else
      instructions="Compose a Git commit message. To draft a Git commit message, review the series of commit messages to see what modifications have been made.  Concentrate on the last item, considering it the commit candidate. This should include a brief explanation of the changes and a diff that showcases these modifications. Your task is to ensure that there is a clear connection between the changes made in the commits. The objective is to create a concise and informative commit message that effectively communicates the reasoning behind the changes and details the specific alterations. The message should comprise a succinct title, followed by two paragraphs: one explaining the reason for the changes and another describing the changes themselves. Each section should be separated by a blank line, without any headings."
      data=$(${pkgs.jq}/bin/jq -n --arg instructions "$instructions" '[ { role: "system", content: $instructions } ]')
    fi

    for hash in $branch_commits; do
      commit_message=$(${pkgs.git}/bin/git show -s --format=%B $hash)
      data=$(${pkgs.jq}/bin/jq -n --arg commit_message "This is a change already implemented in scope of the user story:\n$commit_message" --argjson data "$data" '$data + [ { role: "user", content: $commit_message } ]')
    done

    data=$(${pkgs.jq}/bin/jq -n --arg question "This is the commit candidate with short explanation:\n$(cat)" --argjson data "$data" '$data + [ { role: "user", content: $question } ]')
    ;;

  story )
    instructions="Compose a problem description by analyzing a short explanation of the problem, and additionally, any relevant context or background information. Ensure a thorough understanding of the problem and the context in which it occurs. The goal is to generate a clear, concise problem description that provides all the necessary information to understand the problem and its context. The problem description should have a short title, a paragraph with user story formatted scenario (As <actor>, I want to <action>, so <outcome>.), a 'Summary' paragraph explaining the problem, and an 'Acceptance criteria' paragraph with the tasks that has to be done to solve problem."

    data=$(${pkgs.jq}/bin/jq -n --arg question "$(cat)" --arg instructions "$instructions" '[ { role: "system", content: $instructions }, { role: "user", content: $question } ]')
    ;;

  pull-request )
    instructions="Compose a pull request description by analyzing a user story, and additionally, any commit message that follows. Ensure a thorough understanding of the changes and the context in which they occur. The goal is to generate a clear, concise pull request description that provides all the necessary information to understand the changes and their context. The pull request description should have a paragraph explaining the purpose of the changes, and a paragraph explaining the outome of the changes themselves - each such component has to be separated by two newlines and have no header."

    default_branch=$(${pkgs.git}/bin/git config --get core.default)
    branchoff_commit=$(${pkgs.git}/bin/git merge-base $default_branch HEAD)
    branch_commits=$(${pkgs.git}/bin/git log --format=format:"%H" $branchoff_commit..HEAD)
    issue=$(${pkgs.git}/bin/git rev-parse --abbrev-ref HEAD | ${pkgs.gnused}/bin/sed -n 's@.*/\([[:digit:]]\+\).*@\1@p')

    if [ -n "$issue" ]; then
      context=$(${pkgs.gh}/bin/gh issue view --json title,body $issue | ${pkgs.jq}/bin/jq  "\"This is a problem description:\n\(.title)\n\n\(.body)\"")
      data=$(${pkgs.jq}/bin/jq -n --arg instructions "$instructions" --arg context "$context" '[ { role: "system", content: $instructions }, { role: "user", content: $context } ]')
    else
      data=$(${pkgs.jq}/bin/jq -n --arg instructions "$instructions" '[ { role: "system", content: $instructions } ]')
    fi

    for hash in $branch_commits; do
      commit_message=$(${pkgs.git}/bin/git show -s --format=%B $hash)
      data=$(${pkgs.jq}/bin/jq -n --arg commit_message "$commit_message" --argjson data "$data" '$data + [ { role: "user", content: $commit_message } ]')
    done
    ;;
  * )
    >&2 echo "jarvis: unknown command $command"
    usage
    exit 1
    ;;
  esac

  payload=$(${pkgs.jq}/bin/jq -n --arg model "$model" --argjson data "$data" "$payload_template")

  response=$(${pkgs.curl}/bin/curl -s -X POST https://api.openai.com/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d "$payload" | ${pkgs.jq}/bin/jq -M -r '.choices[0].message.content')

  if [ -n "$issue" ]; then
    case $command in
    commit-message ) echo -ne "[#$issue] "; echo "$response" ;;
    pull-request ) echo -e "Closes #$issue."; echo; echo "$response" ;;
    esac
    exit 0
  fi
  echo "$response"
''
