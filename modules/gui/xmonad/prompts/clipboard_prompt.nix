{ pkgs
, ...
}:
let
  clipcatctl = "${pkgs.clipcat}/bin/clipcatctl";
in
pkgs.writeText "ClipboardPrompt.hs" ''
  module ClipboardPrompt (clipboardPrompt) where

  import           XMonad.Core
  import           XMonad.Prompt
  import           XMonad.Util.Run (runProcessWithInput)

  data Clipboard = Clipboard XPConfig

  instance XPrompt Clipboard where
    showXPrompt (Clipboard _) = "Clipboard"

    commandToComplete _ c = c

    nextCompletion _ = getNextCompletion

    completionFunction (Clipboard c) s = do
      clips <- runProcessWithInput "${clipcatctl}" ["list", "--no-id"] []
      return $ filter ((searchPredicate c) s) (lines clips)

    modeAction _ a _ = io . spawn $ "${clipcatctl} insert \"" ++ escapeQuote a ++ "\""

  clipboardPrompt :: XPConfig -> X ()
  clipboardPrompt xpconfig = mkXPromptWithModes [XPT $ Clipboard xpconfig] xpconfig

  escapeQuote :: String -> String
  escapeQuote = concatMap escape
    where escape :: Char -> String
          escape '"'  = "\\\""
          escape '\\' = "\\\\"
          escape '$'  = "\\$"
          escape x    = [x]
''
