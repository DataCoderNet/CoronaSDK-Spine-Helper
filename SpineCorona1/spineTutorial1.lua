--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:a661e8f1c607396b5b8e921561a01cb0:90e48dd5b4cadc90b0dcdb8dd3931612:493240bd0479b310e307b299693979d2$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- button_button
            x=4,
            y=4,
            width=224,
            height=96,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 225,
            sourceHeight = 97
        },
        {
            -- greenGuy_center
            x=180,
            y=416,
            width=52,
            height=52,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 51,
            sourceHeight = 51
        },
        {
            -- greenGuy_head
            x=236,
            y=376,
            width=32,
            height=132,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 31,
            sourceHeight = 129
        },
        {
            -- greenGuy_larm
            x=284,
            y=236,
            width=108,
            height=124,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 106,
            sourceHeight = 121
        },
        {
            -- greenGuy_lleg
            x=4,
            y=448,
            width=84,
            height=132,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 81,
            sourceHeight = 132
        },
        {
            -- greenGuy_rarm
            x=124,
            y=240,
            width=116,
            height=116,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 113,
            sourceHeight = 115
        },
        {
            -- greenGuy_rleg
            x=92,
            y=360,
            width=84,
            height=132,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 84,
            sourceHeight = 130
        },
        {
            -- orangeGuy_center
            x=180,
            y=360,
            width=52,
            height=52,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 51,
            sourceHeight = 51
        },
        {
            -- orangeGuy_head
            x=244,
            y=240,
            width=32,
            height=132,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 31,
            sourceHeight = 129
        },
        {
            -- orangeGuy_larm
            x=396,
            y=144,
            width=108,
            height=124,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 106,
            sourceHeight = 121
        },
        {
            -- orangeGuy_lleg
            x=372,
            y=524,
            width=84,
            height=132,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 81,
            sourceHeight = 132
        },
        {
            -- orangeGuy_rarm
            x=4,
            y=192,
            width=116,
            height=116,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 113,
            sourceHeight = 115
        },
        {
            -- orangeGuy_rleg
            x=4,
            y=312,
            width=84,
            height=132,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 84,
            sourceHeight = 130
        },
        {
            -- star_center
            x=156,
            y=104,
            width=124,
            height=132,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 121,
            sourceHeight = 129
        },
        {
            -- star_head
            x=280,
            y=364,
            width=88,
            height=172,

            sourceX = 8,
            sourceY = 0,
            sourceWidth = 94,
            sourceHeight = 171
        },
        {
            -- star_larm
            x=4,
            y=104,
            width=148,
            height=84,

            sourceX = 0,
            sourceY = 24,
            sourceWidth = 149,
            sourceHeight = 108
        },
        {
            -- star_lleg
            x=396,
            y=4,
            width=108,
            height=136,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 137,
            sourceHeight = 133
        },
        {
            -- star_rarm
            x=232,
            y=4,
            width=160,
            height=96,

            sourceX = 0,
            sourceY = 24,
            sourceWidth = 160,
            sourceHeight = 118
        },
        {
            -- star_rleg
            x=284,
            y=104,
            width=108,
            height=128,

            sourceX = 32,
            sourceY = 0,
            sourceWidth = 137,
            sourceHeight = 127
        },
        {
            -- tools_arrow
            x=396,
            y=272,
            width=96,
            height=248,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 96,
            sourceHeight = 246
        },
        {
            -- tools_lightning
            x=460,
            y=524,
            width=44,
            height=272,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 43,
            sourceHeight = 274
        },
    },
    
    sheetContentWidth = 512,
    sheetContentHeight = 1024
}

SheetInfo.frameIndex =
{

    ["button_button"] = 1,
    ["greenGuy_center"] = 2,
    ["greenGuy_head"] = 3,
    ["greenGuy_larm"] = 4,
    ["greenGuy_lleg"] = 5,
    ["greenGuy_rarm"] = 6,
    ["greenGuy_rleg"] = 7,
    ["orangeGuy_center"] = 8,
    ["orangeGuy_head"] = 9,
    ["orangeGuy_larm"] = 10,
    ["orangeGuy_lleg"] = 11,
    ["orangeGuy_rarm"] = 12,
    ["orangeGuy_rleg"] = 13,
    ["star_center"] = 14,
    ["star_head"] = 15,
    ["star_larm"] = 16,
    ["star_lleg"] = 17,
    ["star_rarm"] = 18,
    ["star_rleg"] = 19,
    ["tools_arrow"] = 20,
    ["tools_lightning"] = 21,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
