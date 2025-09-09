{ config
, lib
, pkgs
, ...
}:
let
  gpu_status = pkgs.writeScriptBin "gpu_status" ''
    #!${pkgs.python3}/bin/python3
    import subprocess, json

    def run(cmd):
        try:
            return subprocess.check_output(cmd, stderr=subprocess.DEVNULL).decode().strip()
        except subprocess.CalledProcessError:
            return None
        except FileNotFoundError:
            return None

    def main():
        util = run([
            "nvidia-smi", "--query-gpu=utilization.gpu",
            "--format=csv,noheader,nounits"
        ])
        mem_used = run([
            "nvidia-smi", "--query-gpu=memory.used",
            "--format=csv,noheader,nounits"
        ])
        mem_total = run([
            "nvidia-smi", "--query-gpu=memory.total",
            "--format=csv,noheader,nounits"
        ])

        if not util:
            print(json.dumps({"text": "?"}))
            return

        text = f"{util}%"

        if mem_used and mem_total:
            text_alt = f"{mem_used}/{mem_total} MiB"
        else:
            text_alt = "?"

        print(json.dumps({ "text": text, "alt": text_alt }))

    if __name__ == "__main__":
        main()
  '';
  player_status = pkgs.writeScriptBin "player_status" ''
    #!${pkgs.python3}/bin/python3
    import subprocess, json

    def run(cmd):
        try:
            return subprocess.check_output(cmd, stderr=subprocess.DEVNULL).decode().strip()
        except subprocess.CalledProcessError:
            return None

    def main():
        status = run(["${pkgs.playerctl}/bin/playerctl", "status"])
        artist = run(["${pkgs.playerctl}/bin/playerctl", "metadata", "artist"])
        title  = run(["${pkgs.playerctl}/bin/playerctl", "metadata", "title"])
        if not status or status == "Stopped":
            print(json.dumps({"text": ""}))
            return

        icon = {
            "Playing": "",
            "Paused":  "",
            "Stopped": "",
        }.get(status, "")

        text = f"{icon} {artist} - {title}"
        print(json.dumps({"text": text}))

    if __name__ == "__main__":
        main()
  '';
  mail_unread = pkgs.writeScriptBin "mail_unread" ''
    #!${pkgs.python3}/bin/python3
    import os, json, re, subprocess, sys

    def run_out(args):
        try:
            return subprocess.check_output(args, stderr=subprocess.DEVNULL).decode().strip()
        except (subprocess.CalledProcessError, FileNotFoundError):
            return None

    def nm_count(query):
        # --exclude=false counts even messages in excluded folders (if you use them)
        return run_out(["notmuch", "count", "--exclude=false", query])

    def auto_accounts_from_tags():
        tags_raw = run_out(["notmuch", "search", "--output=tags", "tag:unread"])
        if not tags_raw:
            return {}
        accounts = {}
        for line in tags_raw.splitlines():
            tag = line.strip()
            # Some notmuch versions just print the tag; be robust if it ever prints "tag:foo"
            tag = tag[4:] if tag.startswith("tag:") else tag
            m = re.match(r"account[:/](.+)$", tag)
            if m:
                name = m.group(1)
                accounts[name] = f'tag:"{tag}"'
        return accounts

    def load_account_queries():
        env = os.getenv("NOTMUCH_QUERIES")
        if env:
            try:
                obj = json.loads(env)
                # ensure values are strings
                return {str(k): str(v) for k, v in obj.items()}
            except Exception:
                pass
        # fallback to auto-detection from tags
        return auto_accounts_from_tags()

    def main():
        total_s = nm_count("tag:unread")
        if not total_s:
            print(json.dumps({"text": ""}))
            return
        try:
            total = int(total_s)
        except ValueError:
            total = 0

        accounts = load_account_queries()
        per = {}
        for name, q in accounts.items():
            c = nm_count(f"tag:unread and ({q})")
            try:
                per[name] = int(c) if c is not None else 0
            except ValueError:
                per[name] = 0

        # build tooltip
        if per:
            # sort by count desc, then name
            lines = [f"{name}: {cnt}" for name, cnt in sorted(per.items(), key=lambda kv: (-kv[1], kv[0])) if cnt > 0]
            if not lines:
                lines = [f"{name}: 0" for name in sorted(per)]
            tooltip = "\n".join(lines)
        else:
            tooltip = f"Unread: {total}"

        if total == 0:
            print(json.dumps({"text": ""}))
            return
        text = f"{total}"
        print(json.dumps({"text": text, "tooltip": tooltip}))

    if __name__ == "__main__":
        main()
  '';
in
{
  config = {
    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 30;
          spacing = 0;

          modules-left = [ "cpu" "custom/gpu" "memory" "disk" "network" "battery" ];
          modules-center = [ "hyprland/workspaces" ];
          modules-right = [ "custom/playnow" "pulseaudio" "custom/notmuch" "clock" ];

          "custom/notmuch" = {
            exec = "${mail_unread}/bin/mail_unread";
            interval = 60;
            hide-empty-text = true;
            format = "   {} ";
            tooltip = true;
            return-type = "json";
          };

          "hyprland/workspaces" = {
            format = "{windows}";
            format-window-separator = "  ";
            window-rewrite-default = "";
            window-rewrite = {
              "qutebrowser" = "";
              "kitty" = "";
              "slack" = "";
              "inkscape" = "";
              "gimp" = "";
              "cad" = "";
              "spotify" = "";
            };
            on-click = "activate";
            disable-scroll = false;
            all-outputs = false;
          };

          "custom/gpu" = {
            exec = "${gpu_status}/bin/gpu_status";
            format = "   {text} ";
            format-alt = "   {alt} ";
            interval = 1;
            tooltip = false;
            return-type = "json";
          };

          "custom/playnow" = {
            exec = "${player_status}/bin/player_status";
            format = " {} ";
            hide-empty-text = true;
            interval = 1;
            tooltip = false;
            return-type = "json";
            on-click = "${pkgs.playerctl}/bin/playerctl play-pause";
          };

          disk = {
            format = "   {percentage_used}% ";
            format-alt = "   {used}/{total} ";
            path = "/";
            interval = 60;
            tooltip = false;
          };

          network = {
            format-wifi = " 󰖩  {essid} ";
            format-ethernet = " 󱘖  {ifname} ";
            format-linked = " 󱘖  {ifname} (no IP) ";
            format-disconnected = "   disconnected ";
            format-alt = " 󰅧  {bandwidthUpBytes} 󰅢  {bandwidthDownBytes} ";
            interval = 1;
            tooltip = false;
          };

          battery = {
            states.warning = 30;
            states.critical = 15;
            format = " {icon}  {capacity}% ";
            format-discharging = " {icon}  {capacity}% ({time}) ";
            format-charging = " 󱐋 {capacity}% ";
            interval = 1;
            format-icons = ["" "" "" "" ""];
            tooltip = false;
          };

          pulseaudio = {
            format = "{icon} {volume}% ";
            format-muted = " 󰖁  {volume}% ";
            format-icons = {
              headphone = "  ";
              hands-free = "  ";
              headset = "  ";
              phone = "  ";
              portable = "  ";
              car = "  ";
              default = [ "  " "  " "  " ];
            };
            tooltip = true;
            on-click = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
          };

          memory = {
            format = "   {percentage}% ";
            format-alt = "   {used:0.1f}G/{total:0.1f}G ";
            tooltip = false;
            interval = 1;
          };

          cpu = {
            format = "   {usage}% ";
            format-alt = "   {load} ";
            tooltip = false;
            interval = 1;
          };

          clock = {
            interval = 1;
            timezone = "Europe/Warsaw";
            format = " {:L%A %Y-%m-%d %H:%M} ";
            tooltip = false;
          };
        };
      };

      style = ''
        * {
          font-family: "Iosevka Nerd Font", "Font Awesome 6 Free", "Font Awesome 6 Free Solid";
          font-weight: bold;
          font-size: 14px;
          color: ${config.gui.theme.base07};
        }

        window#waybar {
          background: rgba(0, 0, 0, 0.0);
          border: none;
        }

        #clock,
        #memory,
        #network,
        #disk,
        #pulseaudio,
        #battery,
        #backlight,
        #memory,
        #custom-playnow,
        #custom-notmuch,
        #custom-gpu,
        #cpu {
          background-color: ${config.gui.theme.base00};
          padding: 4px 6px;
          margin-top: 0px;
          margin-left: 6px;
          margin-right: 6px;
          border-width: 0px;
          border-radius: 0px 0px 10px 10px;
        }

        #custom-gpu,
        #memory {
          border-radius: 0px;
          margin: 0px;
        }

        #cpu,
        #custom-playnow {
          border-radius: 0px 0px 0px 10px;
          margin-right: 0px;
        }

        #disk,
        #pulseaudio {
          border-radius: 0px 0px 10px 0px;
          margin-left: 0px;
        }

        #network:hover,
        #disk:hover,
        #battery:hover,
        #pulseaudio:hover,
        #custom-temperature:hover,
        #memory:hover,
        #cpu:hover,
        #custom-playnow:hover,
        #custom-gpu:hover,
        #custom-notmuch:hover,
        #clock:hover {
          background-color: ${config.gui.theme.base08};
        }

        #workspaces button {
          background-color: ${config.gui.theme.base00};
          color: ${config.gui.theme.base03};
          padding: 6px 12px;
          margin-top: 0px;
          margin-left: 6px;
          margin-right: 6px;
          border-width: 0px;
          border-radius: 10px;
          border: 4px solid ${config.gui.theme.base00};
        }

        #workspaces button.visible {
          border: 4px solid ${config.gui.theme.base08};
        }

        #workspaces button.active {
          border: 4px solid ${config.gui.theme.base03};
        }

        window#waybar #workspaces button:hover,
        window#waybar #workspaces button:hover:active,
        window#waybar #workspaces button:hover:checked,
        window#waybar:backdrop #workspaces button:hover {
          background: ${config.gui.theme.base08};
          border: 4px solid ${config.gui.theme.base08};
          background-image: none;
          box-shadow: none;
        }

        window#waybar #workspaces button:hover > * {
          background: transparent;
        }
        tooltip {
          background: ${config.gui.theme.base00};
          border: 1px solid ${config.gui.theme.base03};
          border-radius: 6px;
          padding: 6px;
          font-size: 12px;
        }
      '';
    };
  };
}
