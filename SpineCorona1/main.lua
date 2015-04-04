local SpineHelper = require ("SpineHelper")


local bg = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
bg.fill = {0, 0.5, 1}

local sceneGroup = display.newGroup()

local config = {
  spineJson = "skeleton.json",
  imageSheetName = "spineTutorial1.png",
  texturePackerLuaFile = "spineTutorial1",
  debug = false,
 debugAabb = false,
 --skin = "greenGuy",
 animationName = "startButton",
 animLoop = false,
 scale = 0.5,
  displayGroup = sceneGroup
}


local button = SpineHelper:new(config)
button.x = display.contentCenterX
button.y = display.contentHeight


timer.performWithDelay( 1500, function() 
			button:changeAnimation({newAnimation="animation2", loop=true})

	end ,1 )		


button:drawBoundingBox({bone="buttonBone", slot="bbButton", boundingBox="bbButton"})

function button:tap(event)
		print ("Thank you for taking this training")
end

button.imgBoxes[1]:addEventListener( "tap", button )


