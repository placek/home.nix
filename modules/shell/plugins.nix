{ fetchFromGitHub
}:
[
  {
    name = "z";
    src = fetchFromGitHub {
      owner = "jethrokuan";
      repo = "z";
      rev = "85f863f20f24faf675827fb00f3a4e15c7838d76";
      sha256 = "sha256-+FUBM7CodtZrYKqU542fQD+ZDGrd2438trKM0tIESs0=";
    };
  }

  {
    name = "pure";
    src = fetchFromGitHub {
      owner = "pure-fish";
      repo = "pure";
      rev = "1c1f5b4d1d3fa36162186aa0aac295f59efe22bc";
      sha256 = "sha256-ec1ZAjIGn6xYMh+3kyQP8HYUti8iFXsyzTJ19tU8T84=";
    };
  }
]
