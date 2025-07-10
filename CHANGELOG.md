# Changes to the **pkserver** Linux binary by XDavidXtreme

- gamespy.com was replaced with openspy.net
- fixed the "%s" symbols vulnerability that could crash the server
- "+map" (sets the initial map) and "+port" options now correcly override config.ini parameters
- added "-cfg" option like in the "Painkiller.exe" Windows binary to indicate a custom config.ini file
- added "-lscripts" option like in the "Painkiller.exe" Windows binary to indicate a custom LScripts.pak

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
