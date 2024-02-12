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
      rev = "21a81af6b2c46be91203f12128d1bd6be8d3abe3";
      sha256 = "sha256-iJ08IKJNWFpaBMUxne0QR8y5fP6KWog7+dqQAKOYorI=";
    };
  }
]
