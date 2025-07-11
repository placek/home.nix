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

    model="''${OPENAI_MODEL:-o4-mini}"
    language="''${OPENAI_LANGUAGE:-english}"
    api_url="https://api.openai.com/v1"
    completions_endpoint="/chat/completions"
    data="[]"

##################################### GIT ######################################

    _git_default_branch() {
      ${config.vcsExec} config --get core.default
    }

    _git_branchoff_commit() {
      ${config.vcsExec} merge-base "$(_git_default_branch)" HEAD 2>/dev/null
    }

    _git_current_branch_commits() {
      branchoff_commit=$(_git_branchoff_commit)
      if [ -n "$branchoff_commit" ]; then
        ${config.vcsExec} log --reverse --format=format:"%H" "$branchoff_commit"..HEAD
      fi
    }

    _git_is_not_empty_commit() {
      ${config.vcsExec} show --stat --format="" "$1" | grep -q .
    }

################################### OPEN AI ####################################

    _ai_apply_instruction() {
      data="$(${pkgs.jq}/bin/jq -n --arg instructions "$1" --argjson data "$data" '$data + [ { role: "developer", content: [ { "type": "text", "text": $instructions } ] } ]')"
    }

    _ai_apply_context() {
      data="$(${pkgs.jq}/bin/jq -n --arg context "$1" --argjson data "$data" '$data + [ { role: "user", content: [ { "type": "text", "text": $context } ] } ]')"
    }

    _ai_apply_context_from_stdin() {
      _ai_apply_context "$1$(cat)"
    }

    _ai_apply_commit() {
      hash="$1"
      commit_message="$(${config.vcsExec} show -s --format=%B "$hash")"
      if _git_is_not_empty_commit "$hash"; then
        _ai_apply_context "This is a message of a commit $hash that introduces a part of implementation of the user story:\n$commit_message"
      else
        _ai_apply_context "This are the details of the task that is to be done:\n$commit_message"
      fi
    }

    _ai_apply_commits() {
      branch_commits="$(_git_current_branch_commits)"
      for hash in $branch_commits; do
        _ai_apply_commit "$hash"
      done
    }

    _ai_request() {
      ${pkgs.curl}/bin/curl \
        -s \
        -X POST \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d "$2" \
        "$api_url$1"
    }

    _ai_chat_request() {
      payload_template='{ model: $model, messages: $data, "response_format": { "type": "text" }, "reasoning_effort": "medium", "store": false }'
      payload=$(${pkgs.jq}/bin/jq -n --arg model "$model" --argjson data "$data" "$payload_template")
      for attempt in {1..3}; do
        response=$(_ai_request "$completions_endpoint" "$payload")
        if ! echo "$response" | jq -e '.error' > /dev/null; then
          break
        fi
        sleep 2
      done
      if [ $? -ne 0 ]; then
        >&2 echo "tertius: failed to get response from OpenAI API"
        exit 1
      fi
      echo "$response" | ${pkgs.jq}/bin/jq -M -r '.choices[0].message.content'
    }

################################### TERTIUS ####################################

    _tertius_print_info() {
      echo "+ model: $model"
      echo "+ language: $language"
      echo "+ branchoff commit: $(_git_branchoff_commit)"
    }

    _tertius_compose_commit_message() {
      _ai_apply_instruction "You are a Git repository maitenance assistant. Compose a Git commit message. To draft a Git commit message review the context in which the modifications have been made. This should include a brief explanation of the changes and a diff that showcases these modifications. Your task is to ensure that there is a clear connection between the requirements specified in the user story and the changes made in the commit. The objective is to create a concise and informative commit message that effectively communicates the reasoning behind the changes and high-level explanation of the alterations. The message should comprise a succinct title, followed by a paragraph explaining the reason for the changes. The title and the following paragraph should be separated by a blank line. Avoid using 'Title:' or similar headers."
      _ai_apply_commits
      _ai_apply_context_from_stdin
      _ai_chat_request
    }

    _tertius_compose_user_story() {
      _ai_apply_instruction "You are a project manager assistant. Compose a user story. To draft a user story, review the context in which the problem occurs. This should include a brief explanation of the problem and any relevant background information. Your task is to ensure that there is a clear connection between the problem and the context in which it occurs. The objective is to create a concise and informative user story that effectively communicates the problem and its context. The user story should have a title, a paragraph with a user story formatted scenario (As <actor>, I want to <action>, so <outcome>.), a 'Summary' paragraph explaining the problem, and an 'Acceptance criteria' paragraph with the tasks that has to be done to solve problem."
      _ai_apply_context_from_stdin
      _ai_chat_request
    }

    _tertius_compose_pull_request_description() {
      _ai_apply_instruction "You are a software developer assistant. Compose a pull request description by analyzing any given commit messages. Ensure a thorough understanding of the changes and the context in which they occur. The goal is to generate a clear, concise pull request description that provides all the necessary information to understand the changes and their context. The pull request description should have a paragraph explaining the purpose of the changes, and a paragraph explaining the outcome of the changes themselves - each such component has to be separated by two newlines and have no header."
      _ai_apply_commits
      _ai_chat_request
    }

    _tertius_compose_todo_list() {
      _ai_apply_instruction "You are a software developer assistant. Compose a todo list for the software developer to complete. To draft a todo list, review the context in which the tasks have to be done and the proposed main goals. This should include a brief explanation of the tasks and any relevant background information. Ensure that there is a clear connection between the tasks and the context in which they occur. The objective is to create a concise and informative todo list that effectively communicates the tasks and their context. The todo list should be formatted in the xit format. Where necessary, use paragraphs to split relevant sections of the todo list."
      _ai_apply_context_from_stdin
      _ai_chat_request
    }

    _tertius_review_feature_branch() {
      _ai_apply_instruction "You are a software developer assistant. Review the feature branch. To draft a review, analyze the context in which the changes have been made. This should include a brief explanation of the changes and any relevant background information. Ensure that there is a clear connection between the changes and the context in which they occur.  The objective is to create a concise yet comprehensive review that effectively communicates the doubts and questions about the changes. Focus on the implementation details, and the connection between the user story: is the implementation correct, does it cover all the edge cases, is it full in terms of the user story, is it well tested, etc. The review should be formatted in the markdown format."
      _ai_apply_commits
      _ai_chat_request
    }

##################################### MAIN #####################################
    command="$1"

    _ai_apply_instruction "Formulate all answers in $language."

    case "$command" in
    info ) _tertius_print_info ;;
    commit ) _tertius_compose_commit_message ;;
    story ) _tertius_compose_user_story ;;
    pull-request ) _tertius_compose_pull_request_description ;;
    todo ) _tertius_compose_todo_list ;;
    review ) _tertius_review_feature_branch ;;

    * )
      >&2 echo "tertius: unknown command $command"
      >&2 echo "Usage: tertius info"
      >&2 echo "       tertius commit"
      >&2 echo "       tertius pull-request"
      >&2 echo "       tertius story"
      >&2 echo "       tertius todo"
      >&2 echo "       tertius review"
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
