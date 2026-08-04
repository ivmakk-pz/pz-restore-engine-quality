# dev/ - local testing scaffolding

Not part of the mod. The Workshop upload packages `Contents/`, so nothing here ever ships. Kept in the repo so the test tooling survives between builds instead of living only in a staging folder.

## REQDebugTools

A throwaway mod that sets a vehicle's engine quality server-side, so a degraded engine can be set up for multiplayer testing.

### Why it is needed

Engine state is server-authoritative, and `BaseVehicle.transmitEngine()` is a no-op unless `GameServer.server`:

```java
public void transmitEngine() {
    if (GameServer.server) { this.updateFlags = (short)(this.updateFlags | 4); }
}
```

So the obvious client-side approach silently does nothing in MP - the value is written locally and then overwritten by the server's next engine sync:

```lua
-- works in single player only
local v = getPlayer():getNearVehicle()
v:setEngineFeature(30, v:getEngineLoudness(), v:getScript():getEngineForce() * 0.6)
v:transmitEngine()
```

This is not a 42.20 change; the guard is unchanged from 42.19 and earlier.

Engine quality also cannot be lowered through normal gameplay: it is set once when the vehicle is created (`Vehicles.Create.Engine`), and installing an engine part forces it back to 100 (`VehiclePart.java`). Admin-spawned vehicles therefore always start at 100% quality.

### Usage

1. Stage it: copy `dev/REQDebugTools` to `C:\Users\<user>\Zomboid\mods\REQDebugTools`. A directory symlink is nicer (edits apply without re-copying) but needs an elevated shell or Windows Developer Mode:
   ```powershell
   New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\Zomboid\mods\REQDebugTools" -Target "<repo>\dev\REQDebugTools"
   ```
2. Add `REQDebugTools` to the `Mods=` line in `Zomboid\Server\servertest.ini`.
3. Restart the server - server Lua does not hot-reload.
4. Stand next to the vehicle and run this in the client debug console:
   ```lua
   sendClientCommand(getPlayer(), "REQDebug", "setEngineQuality", { quality = 30 })
   ```

The server prints `[REQDebug] engine set: quality .., power .., loudness ..` to `Zomboid\Logs\<timestamp>_DebugLog-server.txt`.

Optional `power = <n>` overrides the derived value. Without it, power is computed with vanilla's own formula from `Vehicles.Create.Engine`, so a degraded engine matches what world generation would have produced.

### Two details worth preserving

- `setEngineFeature` divides loudness by 2.7 internally, so the helper passes `loudness * 2.7` to hold it steady. Passing `getEngineLoudness()` raw shrinks loudness 2.7x on every call, and after a few runs the vehicle goes near-silent - enough to corrupt loudness testing without being obvious.
- The command is unauthenticated: any connected client can call it. **Remove `REQDebugTools` from `Mods=` for any run whose results need to be trustworthy**, and never leave it enabled on a server that is not a local test.
