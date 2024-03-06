{ pkgs
}:
pkgs.writeShellScriptBin "cmc" ''
  #!${pkgs.stdenv.shell}

  set -e

  instructions="Compose a commit message by analyzing at first a short description explaining why the changes has been made, and additionaly a commit diff, which details what changes have been made. Ensure a thorough understanding of the relationship between the requirements stated in the description and the actual changes implemented in the commit. The goal is to generate meaningful, informative commit message that clearly explain both the rationale behind the changes and the specifics of what has been altered. The commit message should have a short title and up to two paragraphs of description."

  data=$(jq -n \
    --arg model "gpt-3.5-turbo" \
    --arg instructions "$instructions" \
    --arg file_content "$(cat)" \
   '{ model: $model, messages: [ { role: "system", content: $instructions }, { role: "user", content: $file_content } ], temperature: 1, max_tokens: 4096, top_p: 1, frequency_penalty: 0, presence_penalty: 0 }')

  response=$(curl -s -X POST https://api.openai.com/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d "$data")

  echo $response | ${pkgs.jq}/bin/jq -M -r '.choices[0].message.content'
''
