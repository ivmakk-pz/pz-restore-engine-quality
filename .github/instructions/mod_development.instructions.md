---
applyTo: '**/*.lua'
---

## Project Structure

This workspace contains multiple directory structures with different purposes:

### Main Development Directory
- **`Contents/mods/RestoreEngineQuality/`** - Our main code folder where all development work happens
  - Contains your mod files and all new features, modifications, and implementations

### Reference Directory (READ-ONLY)
- **`Contents_original_mod/mods/{REFERENCE_MOD}/`** - Original mod for reference only (if applicable)
  - Contains the complete original mod source code (if this is an extension mod)
  - Used as reference material to understand the base functionality you're extending
  - **DO NOT MODIFY** - This directory should remain unchanged to preserve the original implementation
  - Useful for understanding existing systems, APIs, and patterns used in the base mod

### Other Directories
- **`workshop_assets/`** - Steam Workshop assets and metadata
- **Root files** - Mod documentation and configuration (README.md, CHANGELOG.md, etc.)

When developing features, always work in the `Contents/mods/RestoreEngineQuality/` directory and reference any original mod code from `Contents_original_mod/` as needed (if applicable).

## Function Documentation Guidelines:
- Use LuaLS/EmmyLua type annotations for all functions (---@param, ---@return, ---@type).
- **Avoid verbose/redundant comments** - if the purpose is obvious from function/variable names, don't repeat it.
- **Don't duplicate information** between function description and @return annotation.
- **Common parameters** (character, searchManager, etc.) don't need explanations each time they're used.
- **Variable names should be self-explanatory** - avoid obvious descriptions like "The player character" for `player`.
- **Keep annotations minimal but accurate** - focus on types rather than redundant descriptions.
- If accurate types cannot be determined, use `unknown` as the type and notify about it.

### Good Example (Concise):
```lua
---Calculates vision bonus multiplier for foraging
---@param player IsoPlayer
---@param modifiers table
---@return number
local function calculateVisionBonus(player, modifiers)
```

### Bad Example (Verbose/Redundant):
```lua
---Get view distance for a specific item size using cached icons and vanilla calculation
---@param character IsoGameCharacter The player character
---@param itemSize number The item size to calculate view distance for
---@param searchManager ISSearchManager The search manager to use for vision calculation
---@return number viewDistance The calculated view distance in tiles
local function getViewDistance(character, itemSize, searchManager)
```

## Inline Commenting Guidelines:
- **Avoid obvious comments** - if the code is self-explanatory, don't comment it.
- **Comment complex logic** - explain non-trivial algorithms, calculations, or business rules.
- **Use comments to separate code blocks** in large functions for better readability.
- **Focus on "why" not "what"** - explain the reasoning behind code, not what it literally does.

### Good Examples:
```lua
-- Cache miss - calculate new view distance
local viewDistance = calculateDistance(player, itemSize)

-- Apply night vision penalty (reduced visibility in darkness)
if isNight then
    viewDistance = viewDistance * 0.7
end

-- === TOOLTIP GENERATION === --
local tooltipParts = {}
-- ... tooltip building code ...
```

### Bad Examples (Avoid):
```lua
-- Get the player
local player = getPlayer()

-- Set variable to true
local isVisible = true

-- Loop through items
for i = 1, #items do
    -- Get item at index i
    local item = items[i]
end
```

## Debugging and Error Handling Guidelines:
- **Balanced Approach**: Use defensive programming judiciously based on data certainty.
- **Core Game Singletons**: No fallbacks needed for guaranteed game objects (getPlayer(), ScriptManager.instance, etc.).
- **Optional/Unknown Data**: Use fallbacks for data that might genuinely be missing (mod configs, optional item properties, etc.).
- **Fail Fast for Guaranteed Data**: Let functions crash immediately when core game APIs are invalid.
- **Minimal pcall Usage**: Only use pcall() for the main tooltip override to fallback to original on complete failure.
- **Smart Fallback Strategy**: Use `or` fallbacks only when data absence is a valid scenario.

### Examples:

**NO Fallback Needed (Guaranteed Singletons):**
```lua
-- Core game objects - always present
local player = getPlayer();
local scriptMgr = ScriptManager.instance;
local searchMgr = forageSystem.searchManager;
local perkLevel = player:getPerkLevel(Perks.Foraging);
```

**Fallback Appropriate (Optional/Unknown Data):**
```lua
-- Item properties that might not exist
local itemWeight = item:getActualWeight() or item:getUnequippedWeight() or 1.0;
-- Mod option values that might be missing
local showFeature = modOptions:getValue("showFeature") or false;
-- Dynamic data that could be nil
local zoneData = zone and zone:getModData() or {};
```

## Debug Mode Toggle:
The mod includes a `DEBUG_MODE` toggle variable at the top of `FTE_Client.lua` for easy switching between debug and production modes:

```lua
-- DEBUG MODE TOGGLE: Set to false for production safety mode
local DEBUG_MODE = true
```

**When DEBUG_MODE = true (Development):**
- Uses fail-fast approach with direct tooltip generation
- Errors surface immediately for easier debugging
- No fallback to original tooltip on failure

**When DEBUG_MODE = false (Production):**
- Uses pcall() safety wrapper around extended tooltip
- Falls back to original vanilla tooltip on any error
- Logs errors to console but maintains game stability

# String Concatenation Guidelines

## When to Use Each Approach

### Use `..` for simple concatenations:
- Small strings (2-4 parts)
- Helper functions
- When readability matters most

```lua
-- Good: Simple, readable
return " " .. Colors.white .. _text .. ": " .. value .. " <LINE> ";
local cacheKey = "size_" .. tostring(itemSize);
```

### Use `table.concat()` for complex building:
- Many parts (5+) or loops
- Main tooltip functions
- Performance-critical paths

```lua
-- Good: Complex tooltips
local parts = {"Header: ", value, " more parts..."}
return table.concat(parts)
```

## Loop Performance

### Use numeric `for` loops for arrays:
```lua
-- Slower: iterator-based
for i, v in ipairs(t) do
    print(v)
end

-- MUCH faster: numeric indexing
for i = 1, #t do
    local v = t[i]
    print(v)
end
```

## Code Section Organization

Use visual section separators for large files:
```lua
-- ===================================================================================================== --
-- SECTION NAME (ALL CAPS, DESCRIPTIVE)
-- ===================================================================================================== --
```

**Typical sections**: Constants/Imports → Helper Functions → Main Logic → Exports/Overrides

**Alternative styles**: `-` or `/` separators, but `=` is most visible and widely adopted.

## Testing Guidelines:
- **No Automated Tests**: Avoid creating unit tests or automated test suites for this mod.
- **In-Game Testing Preferred**: All functionality should be tested directly in Project Zomboid.
- **Testing Instructions**: When implementing features, provide clear step-by-step instructions for manual testing in-game.
- **Test Scenarios**: Include specific scenarios to test (items to use, actions to perform, expected results).
- **Edge Cases**: Document edge cases that should be manually verified during gameplay.

### Testing Instruction Format:
When implementing a feature, include testing steps like:
```
## Testing Steps:
1. Spawn items: [list specific items needed]
2. Action: [describe what to do]
3. Expected: [what should happen]
4. Edge cases: [specific scenarios to verify]
```