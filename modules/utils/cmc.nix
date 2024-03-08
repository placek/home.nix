{ pkgs
}:
pkgs.writeShellScriptBin "cmc" ''
  set -e

  if [ -z "$OPENAI_API_KEY" ]; then
    echo "Please set the OPENAI_API_KEY environment variable"
    exit 1
  fi

  while getopts ":m:" arg; do
    case $arg in
    m)
      model=$OPTARG
      ;;
    *)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    esac
  done

  model="''${model:-gpt-3.5-turbo}"

  instructions="Compose a Git commit message by analyzing, at first, a short description explaining why the changes have been made, and additionally, a commit diff, which details what changes have been made. Ensure a thorough understanding of the relationship between the requirements stated in the description and the actual changes implemented in the commit. The goal is to generate meaningful, informative commit messages that clearly explain both the rationale behind the changes and the specifics of what has been altered. The commit message should have a short title, a paragraph explaining the purpose of the changes, and a paragraph explaining the changes themselves - each such component has to be separated by two newlines."

  issue_no=$(${pkgs.git}/bin/git rev-parse --abbrev-ref HEAD | ${pkgs.gnused}/bin/sed -n 's@.*/\([[:digit:]]\+\).*@\1@p')
  issue=""

  template='{ model: $model, temperature: 1, max_tokens: 4096, top_p: 1, frequency_penalty: 0, presence_penalty: 0, messages: [ '
  template+='{ role: "system", content: $instructions }, '

  if [ -n "$issue_no" ]; then
    issue=$(${pkgs.gh}/bin/gh issue view --json title,body $issue_no | ${pkgs.jq}/bin/jq  "\"This is a problem description\n\(.title)\n\n\(.body)\"")
    template+='{ role: "user", content: $issue }, '
  fi

  template+='{ role: "user", content: $file_content } ] }'

  data=$(${pkgs.jq}/bin/jq -n \
    --arg model "$model" \
    --arg instructions "$instructions" \
    --arg file_content "$(cat)" \
    --arg issue "$issue" \
    "$template")

  response=$(${pkgs.curl}/bin/curl -s -X POST https://api.openai.com/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d "$data")

  if [ -n "$issue_no" ]; then
    echo "$response" | ${pkgs.jq}/bin/jq -M -r --arg issue_no "$issue_no" '"[#\($issue_no)] \(.choices[0].message.content)"'
  else
    echo "$response" | ${pkgs.jq}/bin/jq -M -r '.choices[0].message.content'
  fi
''
