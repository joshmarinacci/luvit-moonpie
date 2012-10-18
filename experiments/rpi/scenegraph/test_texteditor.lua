jit.off()

package.path = package.path .. ";../?.lua"
local pi = require("moonpie")
local scene = require("Scene")
local EB = require("eventbus").getShared()
local FM = require("FocusManager").getShared()

scene.window = pi.createFullscreenWindow()
scene:init()
require ("RectNode")
require ("TextNode")
require("ButtonNode")
require("RichTextNode")


-- background of the text editor
local bg = RectNode:new{ x=0,y=0,width=1024,height=600, color={0,0.5,0}}
scene.add(bg)

-- butons
local save_button = ButtonNode:new{x=5, y=5, text="save"}
scene.add(save_button)
local bold_button = ButtonNode:new{x=215, y=5, text="bold"}
scene.add(bold_button)
local italic_button = ButtonNode:new{x=425, y=5, text="italic"}
scene.add(italic_button)

-- text editor
local text_editor = RichTextNode:new{x=5,y=50, width=120, height=400}
scene.add(text_editor)

text_editor.str = "1234\n56789 123456789 123456789 123456789"
table.insert(text_editor.styles, {start=6,length=3,name="bold"})

FM:setFocusedNode(text_editor)

--text_editor.styles[1] = { start=6,  length=3, name="bold", view=view2}
--rt.styles[2] = { start=11,  length=4, name="bold", view=view2}
--rt.styles[3] = { start=40,  length=4, name="bold", view=view2}
--rt.styles[4] = { start=63,  length=5, name="bold", view=view2}


--[[
-- dialog background
local dialog = GroupNode:new{x=100, y=100}
local dialog_bg = RectNode:new { x=0, y=0, width=600, height=400, color={1.0,0.5,0.5}}
dialog:add(dialog_bg)
local dialog_text = TextNode:new {x=200,y=100, text="styled text editor", color={0,0,0}}
dialog:add(dialog_text)
local dialog_button = ButtonNode:new {x=200,y=300, text="close"}
dialog:add(dialog_button)
scene.add(dialog)


EB:on("action",function()
    print("action happened. close button?")
    dialog.visible = false
end)
--]]

scene.loop()
