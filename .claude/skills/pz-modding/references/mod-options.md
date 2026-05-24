# Mod Options API Quick Reference

## Guidelines
- Do not create mod options automatically — only when explicitly requested
- Use positive names ("Show X" not "Hide X")
- Labels and tooltips go in `UI_EN.txt` with naming: `UI_options_{MOD_PREFIX}_<optionName>` and `_tooltip` suffix
- No separators unless explicitly requested

## API

```lua
local options = PZAPI.ModOptions:create("ModID", getText("UI_options_title"))

-- Formatting
options:addTitle("Section Title")
options:addDescription("Description text")
options:addSeparator()

-- Controls
local checkbox = options:addTickBox("id", getText("label"), defaultValue, getText("tooltip"))
local textField = options:addTextEntry("id", getText("label"), "defaultText", getText("tooltip"))
local keybind = options:addKeyBind("id", getText("label"), Keyboard.KEY_Z, getText("tooltip"))
local slider = options:addSlider("id", getText("label"), min, max, step, defaultValue, getText("tooltip"))
local colorPicker = options:addColorPicker("id", getText("label"), r, g, b, a, getText("tooltip"))
local button = options:addButton("id", getText("label"), getText("tooltip"), callbackFunction)

-- Dropdown
local dropdown = options:addComboBox("id", getText("label"), getText("tooltip"))
dropdown:addItem("Option 1", false)
dropdown:addItem("Option 2", true)   -- true = initially selected

-- Multiple checkboxes
local multiBox = options:addMultipleTickBox("id", getText("label"), getText("tooltip"))
multiBox:addTickBox("Sub Option 1", false)
multiBox:addTickBox("Sub Option 2", true)

-- Reading values
checkbox:getValue()      -- boolean
textField:getValue()     -- string
keybind:getValue()       -- keyboard key constant
slider:getValue()        -- number
colorPicker:getValue()   -- table {r, g, b, a}
dropdown:getValue()      -- number (1-based index)
multiBox:getValue(1)     -- boolean for sub-checkbox
```
