# Changes to the **pkserver** Linux binary by XDavidXtreme

- gamespy.com was replaced with openspy.net.
- Fixed the "%s" symbols vulnerability that could crash the server.
- "+map" (sets the initial map) and "+port" options now correcly override config.ini parameters.
- Added "-cfg" option like in the "Painkiller.exe" Windows binary to indicate a custom config.ini file.
- Added "-lscripts" option like in the "Painkiller.exe" Windows binary to indicate a custom LScripts.pak.
- Cfg.ServerMaps now update properly during the server initiation (Cfg:Load and Tweak:Load were removed from the binary). You no longer need to indicate a maplist in both Cfg.ServerMaps{Gamemode} (for example, Cfg.ServerMapsCTF) and Cfg.ServerMaps. Only indicating maplist in Cfg.ServerMaps{Gamemode} will be enough.

---

Notes:

The binary accepts the "+" plus and the "-" minus options. The order of options is important.

The "+" plus options can be in any order but before the "-" minus options.

The "-" minus options depend on the order which Linux server reads them and they have to be in specific order.

"-lscripts" is the first one read, so it is always at the end.

Example:

```
pkserver +interface 192.168.0.106 +private +port 3456 +map DM_Sacred -cfg conf12.ini -lscripts PKPlus12.pak
```

# Known bugs in the original **LScripts**

- Cfg.StopMatchOnTeamQuit is "true" by default when no config.ini is provided (PK++ has this option "true" by default too). This option prevents a player to play a team game on the server without warmup.
- Cfg.PublicServer parameter does not work though you can use the "+private" command line instead to make your server private.
