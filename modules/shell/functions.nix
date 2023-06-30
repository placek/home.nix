{
  fish_greeting = {
    description = "Greeting to show when starting a fish shell.";
    body = "";
  };

  fish_right_prompt = {
    description = "Right prompt.";
    body = ''
      printf "%s%s %s" (_pure_set_color $pure_color_git_branch) $pure_symbol_reverse_prompt $IN_NIX_SHELL
    '';
  };
}
