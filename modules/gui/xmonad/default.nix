{ config
, lib
, pkgs
, ...
}:
let
  sshot = import ./sshot.nix { inherit config pkgs; };

  dunstTogglePause = pkgs.writeShellScriptBin "dunst-toggle-pause" ''
    if [ $(${pkgs.dunst}/bin/dunstctl is-paused) == "true" ]; then
      ${pkgs.dunst}/bin/dunstctl set-pause-level 0
    else
      ${pkgs.dunst}/bin/dunstctl set-pause-level 100
    fi
    exit 0
  '';
in
{
  imports = [
    ./prompts
  ];

  config = {
    xsession.windowManager.xmonad.enable = true;
    xsession.windowManager.xmonad.enableContribAndExtras = true;
    xsession.windowManager.xmonad.extraPackages = haskellPackages: with haskellPackages; [ alsa-core alsa-mixer ];
    xsession.windowManager.xmonad.config = pkgs.writeText "xmonad.hs" ''
      import qualified Data.Char                    as Char
      import qualified Data.Map                     as Map
      import           Graphics.X11.ExtraTypes.XF86
      import           System.Exit                          (ExitCode(ExitSuccess), exitWith)
      import           XMonad
      import           XMonad.Actions.CycleWS               (shiftToPrev, shiftToNext, nextWS, prevWS, nextScreen, prevScreen)
      import           XMonad.Actions.RotSlaves             (rotAllUp, rotAllDown)
      import           XMonad.Config.Desktop                (desktopConfig)
      import           XMonad.Hooks.DynamicLog              (PP(..), dynamicLogWithPP, xmobarPP, xmobarAction, xmobarColor, wrap)
      import           XMonad.Hooks.ManageDocks             (ToggleStruts(..), docks, avoidStruts, manageDocks)
      import           XMonad.Hooks.ManageHelpers           (isDialog, isFullscreen, doCenterFloat, doFullFloat)
      import           XMonad.Layout.NoBorders              (smartBorders)
      import           XMonad.Layout.Spacing                (Border(..), spacingRaw)
      import           XMonad.Prompt                        (XPConfig(..), XPPosition(..), deleteAllDuplicates)
      import           XMonad.Prompt.ConfirmPrompt          (confirmPrompt)
      import           XMonad.Prompt.FuzzyMatch             (fuzzyMatch, fuzzySort)
      import           XMonad.Util.Cursor                   (setDefaultCursor)
      import           XMonad.Util.Run                      (safeSpawn, spawnPipe, hPutStrLn)
      import           XMonad.Util.SpawnOnce                (spawnOnce)
      import           XMonad.StackSet                      (focusUp, focusDown, greedyView, sink, shiftMaster)

      import           ClipboardPrompt
      import           PassPrompt
      import           RunPrompt
      import           UDisksPrompt

      myBorderWidth        = ${builtins.toString config.gui.border.size}
      myClickJustFocuses   = False
      myEventHook          = mempty
      myFocusFollowsMouse  = True
      myFocusedBorderColor = "${config.gui.theme.base03}"
      myModMask            = mod4Mask
      myNormalBorderColor  = "${config.gui.theme.base00}"
      myTerminal           = "${config.terminalExec}"

      myXPConfig :: XPConfig
      myXPConfig = def { font              = "xft:${config.gui.font.name}:size=${builtins.toString config.gui.font.size}:antialias=true:hinting=true"
                       , position          = Top
                       , height            = 24
                       , promptBorderWidth = 0
                       , completionKey     = (0, xK_Down)
                       , defaultPrompter   = \prompt -> prompt ++ " \xe0b1 "
                       , historyFilter     = deleteAllDuplicates
                       , searchPredicate   = fuzzyMatch
                       , sorter            = (\s -> if null s then id else fuzzySort s)
                       , maxComplRows      = Just 10
                       , alwaysHighlight   = True
                       , bgColor           = "${config.gui.theme.base00}"
                       , fgColor           = "${config.gui.theme.base0F}"
                       , bgHLight          = "${config.gui.theme.base0B}"
                       , fgHLight          = "${config.gui.theme.base00}"
                       , changeModeKey     = xK_space
                       , autoComplete      = Just 2000
                       }

      myKeys :: XConfig Layout -> Map.Map (ButtonMask, KeySym) (X ())
      myKeys conf@XConfig {XMonad.modMask = modm} = Map.fromList $
          -- windows manipulation
          [ ((modm                , xK_h         ), prevWS)                                                                                                    -- go to previous workspace
          , ((modm                , xK_l         ), nextWS)                                                                                                    -- go to next workspace
          , ((modm .|. shiftMask  , xK_h         ), shiftToPrev)                                                                                               -- move to previous workspace
          , ((modm .|. shiftMask  , xK_l         ), shiftToNext)                                                                                               -- move to next workspace
          , ((modm .|. controlMask, xK_h         ), prevScreen)                                                                                                -- move to previous screen
          , ((modm .|. controlMask, xK_l         ), nextScreen)                                                                                                -- move to next screen
          , ((modm                , xK_k         ), windows focusUp  )                                                                                         -- move focus to the previous window
          , ((modm                , xK_j         ), windows focusDown)                                                                                         -- move focus to the next window
          , ((modm .|. shiftMask  , xK_k         ), rotAllUp    )                                                                                              -- swap the focused window with the previous window
          , ((modm .|. shiftMask  , xK_j         ), rotAllDown  )                                                                                              -- swap the focused window with the next window
          , ((modm .|. controlMask, xK_k         ), sendMessage Shrink)                                                                                        -- shrink the master area
          , ((modm .|. controlMask, xK_j         ), sendMessage Expand)                                                                                        -- expand the master area
          , ((modm                , xK_BackSpace ), sendMessage NextLayout)                                                                                    -- rotate through the available layouts
          , ((modm .|. controlMask, xK_BackSpace ), sendMessage ToggleStruts)                                                                                  -- toggle the status bar gap
          , ((modm .|. shiftMask  , xK_BackSpace ), withFocused $ windows . sink)                                                                              -- push window back into tiling
          , ((modm                , xK_q         ), kill)                                                                                                      -- close focused window
          , ((modm .|. shiftMask  , xK_q         ), confirmPrompt myXPConfig "logout" $ io (exitWith ExitSuccess))                                             -- quit xmonad
          -- utils
          , ((modm                , xK_Return    ), spawn $ XMonad.terminal conf)                                                                              -- launch a terminal
          , ((modm                , xK_space     ), runPrompt myXPConfig)                                                                                      -- run application prompt
          , ((modm                , xK_b         ), passPrompt myXPConfig)                                                                                     -- pass prompt
          , ((modm                , xK_n         ), clipboardPrompt myXPConfig)                                                                                -- clipboard history prompt
          , ((modm                , xK_m         ), udisksPrompt myXPConfig)                                                                                   -- udisks prompt
          -- notifications
          , ((modm                , xK_Escape    ), safeSpawn "${pkgs.dunst}/bin/dunstctl" ["history-pop"])                                                    -- pop notification from history
          , ((modm .|. controlMask, xK_Escape    ), safeSpawn "${dunstTogglePause}/bin/dunst-toggle-pause" [])                                                 -- pause all notifications
          -- multimedia
          , ((0, xK_Print                        ), safeSpawn "${sshot}/bin/sshot" ["window"])
          , ((controlMask, xK_Print              ), safeSpawn "${sshot}/bin/sshot" ["selection"])
          , ((0, xF86XK_AudioPrev                ), safeSpawn "${pkgs.playerctl}/bin/playerctl" ["previous"])
          , ((0, xF86XK_AudioPlay                ), safeSpawn "${pkgs.playerctl}/bin/playerctl" ["play-pause"])
          , ((0, xF86XK_AudioNext                ), safeSpawn "${pkgs.playerctl}/bin/playerctl" ["next"])
          , ((0, xF86XK_AudioMute                ), safeSpawn "${pkgs.alsa-utils}/bin/amixer" ["set", "Master", "toggle"])
          , ((0, xF86XK_Calculator               ), safeSpawn "${pkgs.alsa-utils}/bin/amixer" ["set", "Capture", "toggle"])
          , ((0, xF86XK_AudioLowerVolume         ), safeSpawn "${pkgs.alsa-utils}/bin/amixer" ["set", "Master", "5%-", "unmute"])
          , ((0, xF86XK_AudioRaiseVolume         ), safeSpawn "${pkgs.alsa-utils}/bin/amixer" ["set", "Master", "5%+", "unmute"])
          , ((0, xF86XK_MonBrightnessUp          ), safeSpawn "light" ["-A", "5.0"])
          , ((0, xF86XK_MonBrightnessDown        ), safeSpawn "light" ["-U", "5.0"])
          , ((0, xF86XK_Sleep                    ), safeSpawn "slock" [])
          , ((0, xF86XK_PowerOff                 ), safeSpawn "slock" [])
          ]
          ++
          -- mod-[1..5], switch to workspace N
          [((modm, k), windows $ greedyView i) | (i, k) <- zip (XMonad.workspaces conf) [xK_1..]]

      myMouseBindings :: XConfig Layout -> Map.Map (KeyMask, Button) (Window -> X ())
      myMouseBindings XConfig {XMonad.modMask = modm} = Map.fromList
          [ ((modm, button1), \w -> focus w >> mouseMoveWindow w     -- set the window to floating mode and move by dragging
                                            >> windows shiftMaster)
          , ((modm, button3), \w -> focus w >> mouseResizeWindow w   -- set the window to floating mode and resize by dragging
                                            >> windows shiftMaster)
          ]

      workspaceNames :: [String]
      workspaceNames = ["\xf43f", "\xf445", "\xf447", "\xf441", "\xf443"]

      myWorkspaces :: [String]
      myWorkspaces = fmap clickable (zip [1..] workspaceNames)
         where clickable (k, w) = xmobarAction ("${pkgs.xdotool}/bin/xdotool key super+" ++ show k) "1" w

      myLayout = avoidStruts . spacingRaw True border True border True . smartBorders $ t ||| m ||| f
        where
          borderSize = ${builtins.toString config.gui.border.size}
          border     = Border borderSize borderSize borderSize borderSize
          f          = Full
          m          = Mirror t
          t          = Tall 1 (3/100) (2/3)

      myManageHook = composeAll [ isDialog     --> doCenterFloat
                                , isFullscreen --> doFullFloat
                                ]

      myLogHook xmproc = dynamicLogWithPP xmobarPP { ppOutput          = hPutStrLn xmproc
                                                   , ppHiddenNoWindows = xmobarColor "${config.gui.theme.base08}" "" . wrap " <fn=1>" "</fn> "
                                                   , ppHidden          = xmobarColor "${config.gui.theme.base07}" "" . wrap " <fn=1>" "</fn> "
                                                   , ppCurrent         = xmobarColor "${config.gui.theme.base0B}" "" . wrap " <fn=1>" "</fn> "
                                                   , ppVisible         = xmobarColor "${config.gui.theme.base03}" "" . wrap " <fn=1>" "</fn> "
                                                   , ppTitle           = const ""
                                                   , ppLayout          = layout
                                                   , ppUrgent          = xmobarColor "${config.gui.theme.base08}" "${config.gui.theme.base0F}"
                                                   , ppWsSep           = ""
                                                   , ppSep             = " \xE0B1 "
                                                   , ppExtras          = []
                                                   }
        where layout a = case a of
                "Spacing Full"        -> "<fn=1>\xf31e</fn>"
                "Spacing Tall"        -> "<fn=1>\xf338</fn>"
                "Spacing Mirror Tall" -> "<fn=1>\xf337</fn>"

      myStartupHook :: X ()
      myStartupHook = do
        setDefaultCursor xC_left_ptr
        spawnOnce "exec wallpaper &"

      defaults xmproc = desktopConfig { terminal           = myTerminal
                                      , focusFollowsMouse  = myFocusFollowsMouse
                                      , clickJustFocuses   = myClickJustFocuses
                                      , borderWidth        = myBorderWidth
                                      , modMask            = myModMask
                                      , workspaces         = myWorkspaces
                                      , normalBorderColor  = myNormalBorderColor
                                      , focusedBorderColor = myFocusedBorderColor
                                      , keys               = myKeys
                                      , mouseBindings      = myMouseBindings
                                      , layoutHook         = myLayout
                                      , manageHook         = myManageHook <+> manageDocks <+> manageHook desktopConfig
                                      , handleEventHook    = myEventHook
                                      , logHook            = myLogHook xmproc
                                      , startupHook        = myStartupHook
                                      }

      main = do
        xmproc <- spawnPipe "xmobar"
        xmonad . docks . defaults $ xmproc
    '';
  };
}
