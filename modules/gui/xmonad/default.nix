{ config
, lib
, pkgs
, ...
}:
let
  sshot = import ./sshot.nix { inherit config pkgs; };
  rotate-displays = import ./rotate-displays.nix { inherit config pkgs; };
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
      import           XMonad.Actions.KeyRemap              (KeymapTable(..), buildKeyRemapBindings, setDefaultKeyRemap, emptyKeyRemap)
      import           XMonad.Actions.RotSlaves             (rotAllUp, rotAllDown)
      import           XMonad.Actions.Submap                (submap, submapDefault)
      import           XMonad.Config.Desktop                (desktopConfig)
      import           XMonad.Hooks.DynamicLog              (PP(..), dynamicLogWithPP, xmobarPP, xmobarAction, xmobarColor, wrap, shorten)
      import           XMonad.Hooks.ManageDocks             (ToggleStruts(..), docks, avoidStruts, manageDocks)
      import           XMonad.Hooks.ManageHelpers           (isDialog, isFullscreen, doCenterFloat, doFullFloat)
      import           XMonad.Layout.NoBorders              (smartBorders)
      import           XMonad.Layout.Spacing                (Border(..), spacingRaw)
      import           XMonad.Prompt                        (XPConfig(..), XPPosition(..), vimLikeXPKeymap', deleteAllDuplicates)
      import           XMonad.Prompt.ConfirmPrompt          (confirmPrompt)
      import           XMonad.Prompt.FuzzyMatch             (fuzzyMatch, fuzzySort)
      import           XMonad.Util.Cursor                   (setDefaultCursor)
      import           XMonad.Util.NamedScratchpad
      import           XMonad.Util.Run                      (safeSpawn, spawnPipe, hPutStrLn)
      import           XMonad.Util.SpawnOnce                (spawnOnce)
      import           XMonad.StackSet                      (focusUp, focusDown, focusMaster, shift, sink, greedyView, view, shiftMaster, workspace, stack, integrate', current, RationalRect(..))

      import           ClipboardPrompt
      import           PhrasePrompt
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

      xF86XK_RotateDisplay = 0xff68

      myXPConfig :: XPConfig
      myXPConfig = def { font              = "xft:${config.gui.font.name}:size=${builtins.toString config.gui.font.size}:antialias=true:hinting=true"
                       , position          = Top
                       , height            = 24
                       , promptBorderWidth = 0
                       , completionKey     = (0, xK_Down)
                       , promptKeymap      = vimLikeXPKeymap' id (\prompt -> prompt ++ " \xe0b0 ") id Char.isSpace
                       , defaultPrompter   = \prompt -> prompt ++ " \xe0b1 "
                       , historyFilter     = deleteAllDuplicates
                       , searchPredicate   = fuzzyMatch
                       , sorter            = (\s -> if null s then id else fuzzySort s)
                       , maxComplRows      = Just 20
                       , alwaysHighlight   = True
                       , bgColor           = "${config.gui.theme.base00}"
                       , fgColor           = "${config.gui.theme.base0F}"
                       , bgHLight          = "${config.gui.theme.base0B}"
                       , fgHLight          = "${config.gui.theme.base00}"
                       , changeModeKey     = xK_Tab
                       }

      macMap :: KeymapTable
      macMap = KeymapTable [ ((myModMask, xK_x), (controlMask, xK_x))                                                                                          -- cut
                           , ((myModMask, xK_c), (controlMask, xK_c))                                                                                          -- copy
                           , ((myModMask, xK_v), (controlMask, xK_v))                                                                                          -- paste
                           ]

      myKeys :: XConfig Layout -> Map.Map (ButtonMask, KeySym) (X ())
      myKeys conf@XConfig {XMonad.modMask = modm} = Map.fromList $
          -- windows manipulation
          [ ((modm              , xK_Left      ), prevWS)                                                                                                      -- go to previous workspace
          , ((modm              , xK_Right     ), nextWS)                                                                                                      -- go to next workspace
          , ((modm .|. shiftMask, xK_Left      ), shiftToPrev)                                                                                                 -- move to previous workspace
          , ((modm .|. shiftMask, xK_Right     ), shiftToNext)                                                                                                 -- move to next workspace
          , ((modm .|. mod1Mask , xK_Left      ), prevScreen)                                                                                                  -- move to previous screen
          , ((modm .|. mod1Mask , xK_Right     ), nextScreen)                                                                                                  -- move to next screen
          , ((modm              , xK_k         ), windows focusUp  )                                                                                           -- move focus to the previous window
          , ((modm              , xK_j         ), windows focusDown)                                                                                           -- move focus to the next window
          , ((modm .|. shiftMask, xK_k         ), rotAllUp    )                                                                                                -- swap the focused window with the previous window
          , ((modm .|. shiftMask, xK_j         ), rotAllDown  )                                                                                                -- swap the focused window with the next window
          , ((modm              , xK_h         ), sendMessage Shrink)                                                                                          -- shrink the master area
          , ((modm              , xK_l         ), sendMessage Expand)                                                                                          -- expand the master area
          , ((modm .|. shiftMask, xK_h         ), sendMessage (IncMasterN 1))                                                                                  -- increment the number of windows in the master area
          , ((modm .|. shiftMask, xK_l         ), sendMessage (IncMasterN (-1)))                                                                               -- deincrement the number of windows in the master area
          , ((modm              , xK_m         ), windows focusMaster  )                                                                                       -- move focus to the master window
          , ((modm              , xK_n         ), sendMessage NextLayout)                                                                                      -- rotate through the available layouts
          , ((modm              , xK_b         ), sendMessage ToggleStruts)                                                                                    -- toggle the status bar gap
          , ((modm              , xK_f         ), withFocused $ windows . sink)                                                                                -- push window back into tiling
          , ((modm .|. shiftMask, xK_f         ), refresh)                                                                                                     -- resize viewed windows to the correct size
          -- utils submap
          , ((modm, xK_space                   ), submapDefault (runPrompt myXPConfig) . Map.fromList $                                                        -- run application prompt
            [ ((0,    xK_Return                ), spawn $ XMonad.terminal conf)                                                                                -- launch a terminal
            , ((0,    xK_c                     ), clipboardPrompt myXPConfig)                                                                                  -- clipboard history prompt
            , ((0,    xK_a                     ), phrasePrompt myXPConfig)                                                                                     -- abbreviations prompt
            , ((0,    xK_m                     ), udisksPrompt myXPConfig)                                                                                     -- udisks prompt
            ])
          -- quit submap
          , ((modm, xK_q                       ), submap . Map.fromList $
             [ ((modm, xK_q                    ), kill)                                                                                                        -- close focused window
             , ((modm, xK_x                    ), confirmPrompt myXPConfig "logout" $ io (exitWith ExitSuccess))                                               -- quit xmonad
             , ((0, xK_x                       ), spawn "xmonad --recompile; xmonad --restart")                                                                -- restart xmonad
             ])
          -- notifications submap
          , ((modm, xK_Escape                  ), submap . Map.fromList $
             [ ((modm, xK_w                    ), safeSpawn "${pkgs.dunst}/bin/dunstctl" ["close-all"])                                                        -- close all notifications
             , ((modm, xK_q                    ), safeSpawn "${pkgs.dunst}/bin/dunstctl" ["set-paused", "toggle"])                                             -- toggle notifications
             , ((modm, xK_Escape               ), safeSpawn "${pkgs.dunst}/bin/dunstctl" ["history-pop"])                                                      -- pop notification from history
             ])
          -- others
          , ((shiftMask, xK_Print              ), safeSpawn "${sshot}/bin/sshot" ["window"])
          , ((0, xK_Print                      ), safeSpawn "${sshot}/bin/sshot" ["selection"])
          , ((0, xF86XK_AudioPrev              ), safeSpawn "${pkgs.playerctl}/bin/playerctl" ["previous"])
          , ((0, xF86XK_AudioPlay              ), safeSpawn "${pkgs.playerctl}/bin/playerctl" ["play-pause"])
          , ((0, xF86XK_AudioNext              ), safeSpawn "${pkgs.playerctl}/bin/playerctl" ["next"])
          , ((0, xF86XK_AudioMute              ), safeSpawn "${pkgs.alsa-utils}/bin/amixer" ["set", "Master", "toggle"])
          , ((0, xF86XK_Calculator             ), safeSpawn "${pkgs.alsa-utils}/bin/amixer" ["set", "Capture", "toggle"])
          , ((0, xF86XK_AudioLowerVolume       ), safeSpawn "${pkgs.alsa-utils}/bin/amixer" ["set", "Master", "5%-", "unmute"])
          , ((0, xF86XK_AudioRaiseVolume       ), safeSpawn "${pkgs.alsa-utils}/bin/amixer" ["set", "Master", "5%+", "unmute"])
          , ((0, xF86XK_RotateDisplay          ), safeSpawn "${rotate-displays}/bin/rotate-displays" [])
          , ((0, xF86XK_MonBrightnessUp        ), safeSpawn "light" ["-A", "5.0"])
          , ((0, xF86XK_MonBrightnessDown      ), safeSpawn "light" ["-U", "5.0"])
          , ((0, xF86XK_Sleep                  ), safeSpawn "slock" [])
          , ((0, xF86XK_PowerOff               ), safeSpawn "slock" [])
          ]
          ++
          -- mod-[1..5], switch to workspace N
          -- mod-shift-[1..5], move client to workspace N
          [((m .|. modm, k), windows $ f i)
              | (i, k) <- zip (XMonad.workspaces conf) [xK_1..]
              , (f, m) <- [(greedyView, 0), (shift, shiftMask)]]
          ++
          -- remap for mac-like bindings
          buildKeyRemapBindings [macMap]

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
          border  = Border borderSize borderSize borderSize borderSize
          f       = Full
          m       = Mirror t
          t       = Tall 1 (3/100) (2/3)

      myManageHook = composeAll [ className =? "pinentry" --> doCenterFloat
                                , isDialog                --> doCenterFloat
                                , isFullscreen            --> doFullFloat
                                ]

      myLogHook xmproc = dynamicLogWithPP xmobarPP { ppOutput          = hPutStrLn xmproc
                                                   , ppHiddenNoWindows = xmobarColor "${config.gui.theme.base08}" "" . wrap " <fn=1>" "</fn> " . noNSP
                                                   , ppHidden          = xmobarColor "${config.gui.theme.base03}" "" . wrap " <fn=1>" "</fn> " . noNSP
                                                   , ppCurrent         = xmobarColor "${config.gui.theme.base0B}" "" . wrap " <fn=1>" "</fn> " . noNSP
                                                   , ppVisible         = xmobarColor "${config.gui.theme.base02}" "" . wrap " <fn=1>" "</fn> " . noNSP
                                                   , ppTitle           = xmobarColor "${config.gui.theme.base0C}" "" . shorten 20
                                                   , ppLayout          = layout
                                                   , ppUrgent          = xmobarColor "${config.gui.theme.base08}" "${config.gui.theme.base0F}"
                                                   , ppWsSep           = ""
                                                   , ppSep             = " \xE0B1 "
                                                   , ppExtras          = []
                                                   }
        where noNSP "NSP" = xmobarAction "${pkgs.xdotool}/bin/xdotool key super+BackSpace" "1" "\xF198"
              noNSP s     = s
              layout a    = xmobarAction "${pkgs.xdotool}/bin/xdotool key super+n" "1" $ icon a
              icon a      = case a of
                "Spacing Full"        -> "<fn=1>\xf31e</fn>"
                "Spacing Tall"        -> "<fn=1>\xf338</fn>"
                "Spacing Mirror Tall" -> "<fn=1>\xf337</fn>"

      myStartupHook :: X ()
      myStartupHook = do
        setDefaultCursor xC_left_ptr
        setDefaultKeyRemap macMap [macMap, emptyKeyRemap]
        spawnOnce "exec xsetroot -solid '${config.gui.theme.base00}' &"

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
