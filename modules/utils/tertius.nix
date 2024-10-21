{ config
, pkgs
, lib
, ...
}:
let
  tertius = pkgs.writeShellScriptBin "tertius" ''
    set -e
    if [ -n "$DEBUG" ]; then set -x; fi

    if [ -z "$OPENAI_API_KEY" ]; then
      >&2 echo "tertius: please set the OPENAI_API_KEY environment variable"
      exit 1
    fi

    model="''${OPENAI_MODEL:-gpt-4o-mini}"
    language="''${OPENAI_LANGUAGE:-english}"
    issue_tracker="''${OPENAI_ISSUE_TRACKER:-github}"
    issue_tracker_account="''${OPENAI_ISSUE_TRACKER_ACCOUNT:-}"
    repository_hub="''${OPENAI_REPOSITORY_HUB:-github}"
    repository_hub_account="''${OPENAI_REPOSITORY_HUB_ACCOUNT:-}"
    duration="''${OPENAI_DURATION:-24 hours}"
    payload_template='{ model: $model, temperature: 1, max_tokens: 4095, top_p: 1, frequency_penalty: 0, presence_penalty: 0, messages: $data }'
    data="[]"

    usage() {
      >&2 echo "Usage: tertius info"
      >&2 echo "       tertius ask"
      >&2 echo "       tertius grammar"
      >&2 echo "       tertius story id"
      >&2 echo "       tertius story get"
      >&2 echo "       tertius story begin STORY_ID"
      >&2 echo "       tertius story write"
      >&2 echo "       tertius story publish TYPE"
      >&2 echo "       tertius commit write-message"
      >&2 echo "       tertius pull-request write"
      >&2 echo "       tertius pull-request publish"
      >&2 echo "       tertius report"
      >&2 echo "       tertius code fix FILE"
      >&2 echo "       tertius code explain"
    }

    default_branch() {
      ${config.vcsExec} config --get core.default
    }

    branchoff_commit() {
      ${config.vcsExec} merge-base "$(default_branch)" HEAD 2>/dev/null
    }

    current_branch_name() {
      ${config.vcsExec} rev-parse --abbrev-ref HEAD
    }

    current_branch_commits() {
      branchoff_commit=$(branchoff_commit)
      if [ -n "$branchoff_commit" ]; then
        ${config.vcsExec} log --reverse --format=format:"%H" "$branchoff_commit"..HEAD
      fi
    }

    first_commit_in_current_branch() {
      current_branch_commits | ${pkgs.gnused}/bin/sed -n '1s/\([^ ]*\).*/\1/p'
    }

    user_story_id() {
      if [ -n "$(first_commit_in_current_branch)" ]; then
        ${config.vcsExec} log --format=%s -n 1 "$(first_commit_in_current_branch)" | ${pkgs.gnused}/bin/sed -n '1s/.*\[\([^]]*\)\].*/\1/p'
      fi
    }

    get_repository_hub_credentials() {
      ${config.programs.password-store.package}/bin/pass show "$repository_hub_account" 2>/dev/null
    }

    get_repository_hub_otp() {
      ${config.programs.password-store.package}/bin/pass otp "$repository_hub_account" 2>/dev/null
    }

    get_issue_tracker_credentials() {
      ${config.programs.password-store.package}/bin/pass show "$issue_tracker_account" 2>/dev/null
    }

    get_issue_tracker_otp() {
      ${config.programs.password-store.package}/bin/pass otp "$issue_tracker_account" 2>/dev/null
    }

    fetch_jira_user_story() {
      credentials=$(get_issue_tracker_credentials)
      if [ -z "$credentials" ]; then
        >&2 echo "tertius: missing Jira credentials"
        exit 1
      fi
      otp=$(get_issue_tracker_otp)
      if [ -z "$otp" ]; then
        >&2 echo "tertius: this account requires OTP"
        exit 1
      fi
      pass=$(echo "$credentials" | ${pkgs.gnused}/bin/sed -n '1s/\([^ ]*\).*/\1/p')
      login=$(echo "$credentials" | ${pkgs.gnugrep}/bin/grep "user: " | ${pkgs.gnused}/bin/sed 's/user: //g')
      base_url=$(echo "$credentials" | ${pkgs.gnugrep}/bin/grep "url: " | ${pkgs.gnused}/bin/sed 's/url: //g')

      ${pkgs.curl}/bin/curl --silent \
                            -H "Authorization: Basic $(printf "%s" "$login:$pass$otp" | ${pkgs.coreutils}/bin/base64)" \
                            -X GET \
                            -H "Content-Type: application/json" \
                            "$base_url/rest/api/latest/issue/$1"
    }

    create_jira_user_story() {
      credentials=$(get_issue_tracker_credentials)
      if [ -z "$credentials" ]; then
        >&2 echo "tertius: missing Jira credentials"
        exit 1
      fi
      otp=$(get_issue_tracker_otp)
      if [ -z "$otp" ]; then
        >&2 echo "tertius: this account requires OTP"
        exit 1
      fi
      title="$1"
      body="$2"
      pass=$(echo "$credentials" | ${pkgs.gnused}/bin/sed -n '1s/\([^ ]*\).*/\1/p')
      login=$(echo "$credentials" | ${pkgs.gnugrep}/bin/grep "user: " | ${pkgs.gnused}/bin/sed 's/user: //g')
      base_url=$(echo "$credentials" | ${pkgs.gnugrep}/bin/grep "url: " | ${pkgs.gnused}/bin/sed 's/url: //g')

      ${pkgs.curl}/bin/curl --silent \
                            -H "Authorization: Basic $(printf "%s" "$login:$pass$otp" | ${pkgs.coreutils}/bin/base64)" \
                            -X POST \
                            -H "Content-Type: application/json" \
                            -d "{\"fields\": {\"summary\": \"$title\", \"description\": \"$body\"}}" \
                            "$base_url/rest/api/latest/issue" | ${pkgs.jq}/bin/jq -r '.self'
    }

    fetch_github_user_story() {
      ${pkgs.gh}/bin/gh issue view --json title,body "$1"
    }

    user_story_title() {
      user_story_id="$(user_story_id)"
      if [ -n "$user_story_id" ]; then
        case "$issue_tracker" in
        github )
          fetch_github_user_story "$user_story_id" | ${pkgs.jq}/bin/jq -r "\"[#$user_story_id] \(.title)\""
          ;;
        jira )
          fetch_jira_user_story "$user_story_id" | ${pkgs.jq}/bin/jq -r '"\(.fields.summary)"'
          ;;
        esac
      fi
    }

    user_story_content() {
      user_story_id=$(user_story_id)
      if [ -n "$user_story_id" ]; then
        case $issue_tracker in
        github )
          fetch_github_user_story "$user_story_id" | ${pkgs.jq}/bin/jq -r "\"\(.title)\n\n\(.body)\""
          ;;
        jira )
          fetch_jira_user_story "$user_story_id" | ${pkgs.jq}/bin/jq -r '"\(.fields.summary)\n\n\(.fields.description)"'
          ;;
        esac
      fi
    }

    user_story_begin() {
      user_story_id="$1"
      branch_prefix="$2"
      case "$issue_tracker" in
      github )
        user_story=$(fetch_github_user_story "$user_story_id")
        user_story_title=$(echo "$user_story" | ${pkgs.jq}/bin/jq -r "\"\(.title)\"")
        user_story_content=$(echo "$user_story" | ${pkgs.jq}/bin/jq -r "\"\(.title)\n\n\(.body)\"")
        ;;
      jira )
        user_story=$(fetch_jira_user_story "$user_story_id")
        user_story_title=$(echo "$user_story" | ${pkgs.jq}/bin/jq -r '"\(.fields.summary)"')
        user_story_content=$(echo "$user_story" | ${pkgs.jq}/bin/jq -r '"\(.fields.summary)\n\n\(.fields.description)"')
        ;;
      esac
      branch_descr="$(echo $user_story_title | ${pkgs.gnused}/bin/sed -E 's/.*/\L&/; s/[^a-z0-9]+/-/g; s/-$//; s/^-//; s/\s+/-/g')"
      if [ -n "$branch_prefix" ]; then
        branch_name="$branch_prefix/$user_story_id"
      else
        branch_name="$user_story_id"
      fi
      if [ -n "$branch_descr" ]; then
        branch_name="$branch_name-$branch_descr"
      fi
      ${config.vcsExec} fetch
      ${config.vcsExec} checkout "$(default_branch)"
      ${config.vcsExec} checkout -B "$branch_name"
      ${config.vcsExec} commit --allow-empty -m "[$user_story_id] $user_story_content"
    }

    publish_user_story() {
      user_story_type=$1
      body=$(cat)
      user_story_title=$(echo "$body" | head -n 1)
      user_story_body=$(echo "$body" | tail -n +2)
      case $issue_tracker in
      github )
        user_story_url=$(echo "$user_story_body" | ${pkgs.gh}/bin/gh issue create -t "$user_story_title" -a "@me" -F -)
        user_story_id=$(echo $user_story_url | ${pkgs.gnused}/bin/sed -n 's@.*github.com/[^/]\+/[^/]\+/issues/\([[:digit:]]\+\).*@\1@p')
        ${config.browserExec} "$user_story_url"
        ;;
      jira )
        user_story_url="$(create_jira_user_story "$user_story_title" "$user_story_body")"
        ${config.browserExec} "$user_story_url"
      esac
    }

    publish_pull_request() {
      body=$(cat)
      case $repository_hub in
      github )
        user_story_title=$(user_story_title)
        pull_request_url=$(echo $body | ${pkgs.gh}/bin/gh pr create -t "$user_story_title" -F -)
        ${config.browserExec} "$pull_request_url"
        ;;
      esac
    }

    apply_instruction() {
      data="$(${pkgs.jq}/bin/jq -n --arg instructions "$1" --argjson data "$data" '$data + [ { role: "system", content: $instructions } ]')"
    }

    apply_context() {
      data="$(${pkgs.jq}/bin/jq -n --arg instructions "$1" --argjson data "$data" '$data + [ { role: "user", content: $instructions } ]')"
    }

    apply_user_story() {
      user_story="$(user_story_content)"
      if [ -n "$user_story" ]; then
        apply_context "Analyze this user story '$(user_story_id)' as a context of the problem:\n$user_story"
      fi
    }

    apply_commit_messages() {
      branch_commits="$(current_branch_commits)"
      for hash in $branch_commits; do
        commit_message="$(${config.vcsExec} show -s --format=%B "$hash")"
        apply_context "This is a message of a commit '$hash' that introduces a part of implementation of the user story:\n$commit_message"
      done
    }

    apply_commit_messages_from() {
      author=$(${config.vcsExec} config --get user.email)
      commits=$(${config.vcsExec} log --since="$1" --author=$author --format=format:"%H" --reverse)
      for hash in $commits; do
        commit_message=$(${config.vcsExec} show -s --format=%B $hash)
        apply_context "$commit_message"
      done
    }

    apply_question_from_stdin() {
      apply_context "$1$(cat)"
    }

    apply_file() {
      file=$1
      apply_context "$(cat $file)"
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
    command="$1"

    apply_instruction "Formulate all answers in $language."

    case "$command" in
    info )
      echo "Model: $model"
      echo "Language: $language"
      echo "Issue tracker: $issue_tracker"
      echo "Issue tracker account: $issue_tracker_account"
      echo "Repository hub: $repository_hub"
      echo "Repository hub account: $repository_hub_account"
      echo "Current branch: $(current_branch_name)"
      echo "Branchoff commit: $(branchoff_commit)"
      echo "Issue ID: $(user_story_id)"
      ;;

    ask )
      apply_question_from_stdin
      openai_response
      ;;

    grammar )
      apply_instruction "Correct the following text. Ensure that the text is free of spelling, grammatical and language errors. If the text is already correct, just output it."
      apply_question_from_stdin
      openai_response
      ;;

    commit )
      case "$2" in
      write-message )
        apply_instruction "Compose a Git commit message. To draft a Git commit message review the context in which the modifications have been made. This should include a brief explanation of the changes and a diff that showcases these modifications. Your task is to ensure that there is a clear connection between the requirements specified in the user story and the changes made in the commit. The objective is to create a concise and informative commit message that effectively communicates the reasoning behind the changes and high-level explanation of the alterations. The message should comprise a succinct title, followed by a paragraph explaining the reason for the changes. The title and the following paragraph should be separated by a blank line. Avoid using 'Title:' or similar headers."
        apply_user_story
        apply_commit_messages
        apply_question_from_stdin
        openai_response
        ;;
      esac
      ;;

    story )
      case "$2" in
      id )
        user_story_id
        ;;
      get )
        user_story_content
        ;;
      begin )
        if [ -z "$3" ]; then
          >&2 echo "tertius: story begin requires a story ID as an argument."
          usage
          exit 1
        fi
        user_story_begin "$3" "$4"
        ;;
      write )
        apply_instruction "Compose a problem description by analyzing a short explanation of the problem, and additionally, any relevant context or background information. Ensure a thorough understanding of the problem and the context in which it occurs. The goal is to generate a clear, concise problem description that provides all the necessary information to understand the problem and its context. The problem description should have a title, a paragraph with user story formatted scenario (As <actor>, I want to <action>, so <outcome>.), a 'Summary' paragraph explaining the problem, and an 'Acceptance criteria' paragraph with the tasks that has to be done to solve problem."
        apply_question_from_stdin
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
      case "$2" in
      write )
        apply_instruction "Compose a pull request description by analyzing any given commit messages. Ensure a thorough understanding of the changes and the context in which they occur. The goal is to generate a clear, concise pull request description that provides all the necessary information to understand the changes and their context. The pull request description should have a paragraph explaining the purpose of the changes, and a paragraph explaining the outcome of the changes themselves - each such component has to be separated by two newlines and have no header."
        apply_user_story
        apply_commit_messages
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
      openai_response
      ;;

    code )
      case "$2" in
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
  '';
in
{
  options = with lib; {
    tertiusExec = mkOption {
      type = types.str;
      default = "${tertius}/bin/tertius";
      description = "Path to the Tertius executable";
      readOnly = true;
    };
  };

  config = {
    home.packages = [ tertius ];
  };
}
