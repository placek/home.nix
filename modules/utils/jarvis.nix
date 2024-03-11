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
# instructions="Compose a pull request description by analyzing a user story, and additionally, any commit message that follows. Ensure a thorough understanding of the changes and the context in which they occur. The goal is to generate a clear, concise pull request description that provides all the necessary information to understand the changes and their context. The pull request description should have a paragraph explaining the purpose of the changes, and a paragraph explaining the outome of the changes themselves - each such component has to be separated by two newlines."

  case $command in
  ask )
    data=$(${pkgs.jq}/bin/jq -n --arg question "$(cat)" '[ { role: "user", content: $question } ]')
    ;;

  commit-message )
    instructions="Compose a Git commit message by analyzing, at first, a short description explaining why the changes have been made, and additionally, a commit diff, which details what changes have been made. Ensure a thorough understanding of the relationship between the requirements stated in the description and the actual changes implemented in the commit. The goal is to generate meaningful, informative commit messages that clearly explain both the rationale behind the changes and the specifics of what has been altered. The commit message should have a short title, a paragraph explaining the purpose of the changes, and a paragraph explaining the changes themselves - each such component has to be separated by two newlines."

    issue=$(${pkgs.git}/bin/git rev-parse --abbrev-ref HEAD | ${pkgs.gnused}/bin/sed -n 's@.*/\([[:digit:]]\+\).*@\1@p')

    if [ -n "$issue" ]; then
      context=$(${pkgs.gh}/bin/gh issue view --json title,body $issue | ${pkgs.jq}/bin/jq  "\"This is a problem description:\n\(.title)\n\n\(.body)\"")
      data=$(${pkgs.jq}/bin/jq -n --arg question "$(cat)" --arg instructions "$instructions" --arg context "$context" '[ { role: "system", content: $instructions }, { role: "user", content: $context }, { role: "user", content: $question } ]')
    else
      data=$(${pkgs.jq}/bin/jq -n --arg question "$(cat)" --arg instructions "$instructions" '[ { role: "system", content: $instructions }, { role: "user", content: $question } ]')
    fi
    ;;

  story )
    instructions="Compose a problem description by analyzing a short explanation of the problem, and additionally, any relevant context or background information. Ensure a thorough understanding of the problem and the context in which it occurs. The goal is to generate a clear, concise problem description that provides all the necessary information to understand the problem and its context. The problem description should have a short title and a paragraph with user story formatted scenario (As <actor>, I want to <action>, so <outcome>.), a 'Summary' paragraph explaining the problem, and an 'Acceptance criteria' paragraph with the tasks that has to be done to solve problem."

    data=$(${pkgs.jq}/bin/jq -n --arg question "$(cat)" --arg instructions "$instructions" '[ { role: "system", content: $instructions }, { role: "user", content: $question } ]')
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
    commit-message ) echo "[#$issue] $response" ;;
    esac
    exit 0
  fi
  echo "$response"
''
