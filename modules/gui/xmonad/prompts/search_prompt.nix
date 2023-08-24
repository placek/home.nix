{ pkgs
, browserExec
, searchEngines
, ...
}:
let
  engines = builtins.filter (k: k != "DEFAULT") (builtins.attrNames searchEngines);
  capitalize = text: let
    list = pkgs.lib.strings.stringToCharacters text;
    first = builtins.head list;
    rest = builtins.tail list;
    concat = [ (pkgs.lib.strings.toUpper first) ] ++ rest;
  in pkgs.lib.strings.concatStrings concat;
  types = builtins.map capitalize engines;
in
pkgs.writeText "SearchPrompt.hs" ''
  module SearchPrompt (searchPrompt) where

  import           Data.Char                       (toLower)
  import           XMonad                   hiding (config)
  import           XMonad.Prompt
  import           XMonad.Util.Run                 (safeSpawn)

  data SearchType = ${pkgs.lib.strings.concatStringsSep " | " types} deriving Show

  data Search = Search SearchType XPConfig

  instance XPrompt Search where
    showXPrompt (Search t _) = "Search " ++ show t

    nextCompletion _ = getNextCompletion

    completionFunction _ _ = return []

    modeAction (Search t _) a _ = safeSpawn "${browserExec}" ["--target", "tab", (toLower <$> show t) ++ " " ++ a]

  searchPrompt :: XPConfig -> X ()
  searchPrompt xpconfig = mkXPromptWithModes (fmap toXPT symbols) xpconfig
    where symbols = [${pkgs.lib.strings.concatStringsSep ", " types}]
          toXPT a = XPT $ Search a xpconfig
''
