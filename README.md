# dots
Instructions not included.

I typically just keep this repo cloned at `~/Projects/dots/` and then use symlinks in
my home, `~/.config/`, and `~/.local/` folders, pointed at the appropriate resources.
Allows for easy "continuous development" of sorts.

The only exception to this approach, is the `emptty/` folder, which contains its own
README that explains what to do with it.

## Notes

I've tried to keep everything as "user agnostic" as possible, except for a couple
limitations:

- ~~`.config/aria2/aria2.conf` won't allow you to use `~`, `%h`, or `$HOME` to complete
a user's home directory. So unfortunately, download and session directories are
hardcoded.~~

As of `2024-08-23` the above is no longer the case. The offending lines have been removed
from the configuration file, and instead are set in the `start-aria2c` script as
command parameters.

- Some files in `.local/bin/` may have hardcoded paths, and would need a quick
glance over before you try to use them. I'd instead suggest just cherry picking files
in this directory to suit your needs.

---

I use `arandr` as an `xrandr` frontend to make my life easier, and it just so happens to save config scripts to the `.screenlayout/` dir by default.

After generating a config script for a specific arrangement of displays, I then manually
append an appropriate `xwallpaper` command for that specific configuration. This allows
my scripts (more specifically [`randr-layout-chooser`](.local/bin/randr-layout-chooser)) a fairly seamless way to switch display configurations on the fly.

## Tools expected

This isn't an exhaustive list, but here are some of the tools/apps/services employed by
or referenced within my dots:

- `amfora` - Gemini client
- `aria2c` - Download session manager
- `blueman` - Bluetooth manager
- `deluge` - Torrent client
- `dunst` - Notification service
- `emptty` - CLI-based desktop manager
- `erdtree` - Directory information app
- `fzf` - Fuzzy-searching selector
- `herbstluftwm` - Tiling windows manager
- `kitty` - Terminal
- `librewolf` - Security-hardened Firefox fork
- `mpd` - Music player daemon
- `mpv` - Media player
- `ncmpcpp` - Client for `mpd`
- `nmcli` - CLI client for Network Manager
- `oh-my-zsh`, `powerline10k` - Shell
- `phetch` - Gopher client
- `picom` - Compositor
- `polybar` - Task bar
- `rofi` - App/command Launcher
- `sabnzbd` - Usenet client
- `systemd` - *It's not that bad, really*
- `tupimage` - Terminal image service
- `webapp-manager` - Web app creator
- `weechat` - IRC client
- `wireguard` - VPN protocol
- `wmctrl` - Window manager tools
- `xsecurelock` - Secure screen locker
- `xss-lock` - Screen locking service
- `xwallpaper` - Wallpaper utility
- `yt-dlp` - **Fuck tha police**
