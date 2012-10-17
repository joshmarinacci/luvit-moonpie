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
require("TextField")



--[[
left sidebar with nodes
right sidebar with properties
center area with neutral background
center panel that we are dragging on to. it's white.

--]]
local gray = {0.8,0.8,0.8}
local white = {1,1,1}
local black = {0,0,0}

local bg = RectNode:new{x=0,y=0,width=scene.window.width,height=scene.window.height, color=black}
scene.add(bg)

local nodePanel = RectNode:new{ x=0,y=0,width=200,height=600, color=gray}
scene.add(nodePanel)

local propsPanel = RectNode:new {x=scene.window.width-200,y=0,width=200,height=600,color=gray}
scene.add(propsPanel)

local targetPanel = RectNode:new {x=250,y=50,width=500,height=400, color=white}
scene.add(targetPanel)

local protoButton = ButtonNode:new {x=10,y=10,width=100,height=30, text="Button"}
scene.add(protoButton)

local protoLabel = TextNode:new {x=10,y=80,width=100,height=30, textstring="Label", color=black}
scene.add(protoLabel)


-- the properties panel

local propGroup = GroupNode:new{x=scene.window.width-200+10,y=20}
scene.add(propGroup)
local propLabelVarname = TextNode:new {x=0,y=20,  textstring="Variable", color=black}
propGroup:add(propLabelVarname)
local propTextfieldVarname = TextField:new {x=80,y=20,text="varname"}
propGroup:add(propTextfieldVarname)

local anchorPanel = {
    lleft = TextNode:new {x=0,y=50, textstring="left", color=black},
    left = ButtonNode:new {x=80,y=50, text="anchored", color=black},
    lright = TextNode:new {x=0,y=100, textstring="right", color=black},
    right = ButtonNode:new {x=80,y=100, text="anchored", color=black},
    ltop = TextNode:new {x=0,y=150, textstring="top", color=black},
    top = ButtonNode:new {x=80,y=150, text="anchored", color=black},
    lbottom = TextNode:new {x=0,y=200, textstring="bottom", color=black},
    bottom = ButtonNode:new {x=80,y=200, text="anchored", color=black},
}

propGroup:add(anchorPanel.lleft)
propGroup:add(anchorPanel.left)
propGroup:add(anchorPanel.lright)
propGroup:add(anchorPanel.right)
propGroup:add(anchorPanel.ltop)
propGroup:add(anchorPanel.top)
propGroup:add(anchorPanel.lbottom)
propGroup:add(anchorPanel.bottom)

local selection = RectNode:new {x=0,y=0,width=10,height=10, color={1,1,0}}
scene.add(selection)


local saveButton = ButtonNode:new {x=20,y=scene.window.height-30, width=100,height=30, text="save"}
scene.add(saveButton)


function contains(n, e) 
    if(e.x >= n.x and e.x < n.x + n.width) then
        if(e.y >=n.y and e.y < n.y + n.height) then
            return true
        end
    end
    return false
end


function selectNode(n)
    selection.x = n.x
    selection.y = n.y
    selection.width = n.width
    selection.height = n.height
    selection.visible = true
    selection.node = n
    selection:update()
    propTextfieldVarname.textstring = n.varname
    anchorPanel.left.selected = (n.anchorLeft == true)
    propTextfieldVarname:update()
end

function clearSelection()
    selection.visible = false
    selection.node = nil
end

local targetScene = {}
local md = nil

local nodecount = 0

EB:on("mousepress",function(e) 
    print("mouse pressed. starting a drag")
    
    
    --check for dragging stuff out of the node panel
    if contains(protoLabel,e) then
        md = {}
        print("dragging a label")
        md.node = TextNode:new {x=protoLabel.x,y=protoLabel.y, width=100,height=30, textstring="Label", color={1,0,0}}
        md.node.varname = "TextNode"..nodecount
        nodecount = nodecount + 1
        md.node:init()
        scene.add(md.node)
        table.insert(targetScene,md.node)
        return
    end
    
    if contains(targetPanel,e) then
        --check for dragging one of the create nodes
        for i,n in ipairs(targetScene) do
            if contains(n,e) then
                print("pressed on a target node")
                md = {}
                md.node = n
                selectNode(n)
                return
            end
        end
        clearSelection()
    end
    
    
end)
EB:on("mousemove",function(e)
    if md == nil then 
        return 
    end
    md.node.x = e.x
    md.node.y = e.y
end)
EB:on("mouserelease",function(e)
    if md == nil then return end
    print("released")
    md = nil
end)

EB:on("action",function(e)
    if(e.target == anchorPanel.left) then
        if(selection.node ~= nil) then
            selection.node.anchorLeft = anchorPanel.left.selected
            print("updating the anchor to  ", selection.node.anchorLeft )
        end
    end
end)

EB:on("action",function(e)
    if(e.target ~= saveButton) then return end
    
    print("pretending to save")
    for i,n in ipairs(targetScene) do
        print("   node = ", n.varname, "x=",n.x, "y=",n.y,"w=",n.width,"h=",n.height)
        print("    anchors = ", n.anchorLeft, " ",n.anchorRight)
    end
end)

EB:on("action",function(e)
    if(e.source ~= propTextfieldVarname) then return end
    
    print("updating the varname")
    if(selection.node ~= nil) then
        selection.node.varname = propTextfieldVarname.textstring
    end
end)


scene.loop()

