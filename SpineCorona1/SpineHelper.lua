------------------------------------
---- SpineHelper Module ------------
---- version 1.0 -------------------
---- by Hector Sanchez -------------
----- http://www.spinehelper.net----
------------------------------------



local SpineHelper = {}
SpineHelper.__index = SpineHelper


--- EXTERNAL LIBRARIES ----
local matrix = require 'matrix'
local spine = require ("spine-corona.spine") --Require Spine Runtime
--require ("ssk.RGExtensions")
--local  inspect = require("inspect")


---------------------------------------------------------------------------------------------------------
--------------------------- PRIVATE FUNCTION: inverseMatrix(bone, calculatedX, calculatedY)--------------
---------------------------------------------------------------------------------------------------------

local function inverseMatrix(bone, calculatedX, calculatedY)
        
        local bone = bone.parent
        local calculatedX = calculatedX or 0
        local calculatedY = calculatedY or 0
        
        local m00 = bone.m00
        local m01 = bone.m01
        local m02 = bone.worldX --bone.worldX
        local m10 = bone.m10
        local m11 = bone.m11
        local m12 = bone.worldY --bone.worldY
        local m20 = 0
        local m21 = 0
        local m22 = 1
        
        local mat = {
            {m00, m01, m02},
            {m10, m11, m12},
            {m20, m21, m22},
          }
      
        local mi = matrix.invert(mat)
      

--      			self.worldX = self.x * parent.m00 + self.y * parent.m01 + parent.worldX
--			      self.worldY = self.x * parent.m10 + self.y * parent.m11 + parent.worldY
        
        local xLocal =  ((calculatedX * mi[1][1]) + (calculatedY * mi[1][2]) + mi[01][03])
        local yLocal =  ((calculatedX * mi[2][1]) + (calculatedY * mi[2][2]) + mi[02][03])


        return xLocal, yLocal
end



---------------------------------------------------------------------------------------------------------
------------------------------------------- START OF METHODS --------------------------------------------
---------------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------------
------------------------------------------- SpineHelper:new(config)--------------------------------------
---------------------------------------------------------------------------------------------------------


function SpineHelper:new(...)
    --decorate instance with class attributes, then initialize
    local instance = setmetatable( {}, self )
    instance:initialize(...)
    return instance
end


function SpineHelper:initialize(config) --Runs whenever we create a new object
        
    --CLASS PROPERTIES (You can change these properties)
      self.x = 0 --initial position of root bone
      self.y = 0 --initial position of root bone
      self.rotation = 0 --initial rotation
      self.scaleX = 1 --intial scaleX
      self.scaleY = 1 -- initial scaleY
      self.flipX = false -- initial flip on X
      self.flipY = false -- Initial flip on Y
      self.alpha = 1
      self.isVisible = true
      self.dragEnabled = false
      self.playAnimationAfterDrag = true
      
      --CLASS PROPERTIES (Don't change these properties)
      self.imgBoxes = display.newGroup()  --Assign the display group that holds the bounding boxes to the instance
      self.isPolygonPresent = false
      self.animationIsPlaying = false
      self.physicsIsPlaying = false
      self.physicsEnabled = false
      self.animationCompleted = true

      -------------------------------------------------
      --1.- Initial Configuration of Spine Animation
      -------------------------------------------------
      local config = config or {}
      
      local spineJson = config.spineJson -- JSON file produced by Spine (*** REQUIRED **)
      local imageSheetName = config.imageSheetName --PNG image file produced by Texture Packer (*** REQUIRED **)
      local texturePackerLuaFile = config.texturePackerLuaFile --Lua file produced by Texture Packer (*** REQUIRED **)
      local debug = config.debug  -- Debug Mode
      local debugAabb = config.debugAabb  -- Debug Mode
      local skin = config.skin --In Absense of Parameter, it applies the first one
      local animationName = config.animationName--In Absense of Parameter, it applies the first one
      local scale = config.scale or 1 -- Initial Scale of animation 


    ---------------------------------------------
    --2.- Load Texture Packer Image Sheet
    ---------------------------------------------        
    local info = require (texturePackerLuaFile)
    local sheet = graphics.newImageSheet ( imageSheetName, info:getSheet() )
    local sequence = {start=1, count= #info:getSheet().frames }   

    -------------------------------------------
    --3.- Spine Implementation
    -------------------------------------------
    local json = spine.SkeletonJson.new() 
    json.scale = scale or 1
    local skeletonData = json:readSkeletonDataFile(spineJson)
    local skeleton = spine.Skeleton.new(skeletonData, nil)
    local root = skeleton:getRootBone ()
    local bounds = spine.SkeletonBounds.new()
    
    -------------------------------------------
    --3.1 Draw Skeleton with its images
    -------------------------------------------

      function skeleton:createImage(attachment)
            local image = display.newSprite(sheet, sequence)
            image.name = attachment.name
            image:setFrame (info:getFrameIndex (attachment.name))
            image.width, image.height = attachment.width, attachment.height

            return image
      end
    
    
      function skeleton:modifyImage( image, attachment )
            image:setFrame( info:getFrameIndex( attachment.name ) )
            image.width, image.height = attachment.width, attachment.height
      end
    
    
      skeleton.group.x = 0  --Position Skeleton at origin (0,0)
      skeleton.group.y = 0   --Position Skeleton at origin (0,0)
      skeleton.group.alpha = self.alpha
      skeleton.flipX = self.flipX 
      skeleton.flipY = self.flipY
      skeleton.debug = debug --debug or true -- Omit or set to false to not draw debug lines on top of the images.
      skeleton.debugAabb = debugAabb --debugAabb or true
      
 
      --Insert Animation in a Display Group or Composer sceneGroup
      if (config.displayGroup) then
          self.displayGroup = config.displayGroup or sceneGroup
          self.displayGroup:insert(skeleton.group)
      end
      
      skeleton:setToSetupPose() --Sets the bones and slots to the setup pose.
      skeleton:updateWorldTransform() --Computes the world SRT from the local SRT for each bone
      
      

      --- Initial Position of Root Bone
      root.x = 0
      root.y = 0
      root.rotation = 0
      root.scaleX = 1
      root.scaleY = 1
    
    -------------------------------------------
    --3.2 Set Skins
    -------------------------------------------
    
    if #skeletonData.skins > 0 then
        local skinExists --Forward Reference, internal to if-then (true or false)
            if (skin) then
                    for i=1, #skeletonData.skins do
                            if (skin == skeletonData.skins[i].name) then
                                skinExists = true
                                break
                            else
                                skinExists = false
                            end
                    end

                    if (skinExists == true) then
                         skeleton:setSkin(skin)
                         skeleton:setSlotsToSetupPose () -- always use this after changing a skin
                         print ("skin exists: ", skin)
                    else
                              skeleton:setSkin(skeletonData.skins[1].name) -- Sets up the first skin if skinName gets an error
                              skeleton:setSlotsToSetupPose () -- always use this after changing a skin
                              print ("skin doesn't exist, using the first one available")
                    end
                    
            else --No config.skin provided even when there skins exist
                    skeleton:setSkin(skeletonData.skins[1].name) -- Sets up the first skin if skinName gets an error
                    skeleton:setSlotsToSetupPose () -- always use this after changing a skin
                    print ("No config.skin provided even when skins exist, using the first one available")
            end
    end
 
    -------------------------------------------
    --3.3 stateData and Animation Mixes
    -------------------------------------------
 
         local stateData = spine.AnimationStateData.new(skeletonData)
        --stateData:setMix("stopped", "guyWalking", 0.2)
        --stateData:setMix("guyWalking", "running", 0.4)   

     -------------------------------------------
    --3.4 Queue of Animations ready to be played
    -------------------------------------------    
        
        if animationName == nil then
            local animationExists --Forward Reference, internal to if-then (true or false)          
          
            animationName = skeletonData.animations[1].name
            print ("No params.animation provided, applying the first one: " .. skeletonData.animations[1].name)
        else
                for i=1, #skeletonData.animations do
                       if animationName == skeletonData.animations[i].name then
                                animationExists = true
                                break
                       else
                                animationExists = false
                        end
                end
            
                if (animationExists == true) then
                         
                         print ("Initial Animation exists" )
                else
                    animationName = skeletonData.animations[1].name
                    print ("Animation name doesn't exist, applying the first one: " .. skeletonData.animations[1].name)
                end
            
        end
        
        --Check if Initial animation gets looped or not
        if config.animLoop == nil then
          config.animLoop = true
        else
          config.animLoop = config.animLoop
        end
        
        
        -- AnimationState has a queue of animations and can apply them with crossfading.
        local state = spine.AnimationState.new(stateData)
        state:setAnimationByName(0, animationName, config.animLoop, 0, 0) --trackIndex, name, loop, delay
        --state:addAnimationByName(0, "guyWalking", false, 0)
        --state:addAnimationByName(0, "running", true, 0)
 
 
        ----------------------------------------------------------------
        --3.5 Assign key values to instance for easy access later on
        ----------------------------------------------------------------  
  
        self.skeletonData = skeletonData
        self.skeleton = skeleton
        self.root = root
        self.stateData = stateData
        self.state = state

 
         -------------------------------------------
        --3.6 Play Animation as soon as the instance is ready
        -------------------------------------------  
 
        --Play Animation based on initial configuration
        self:playAnimation()

end


---------------------------------------------------------------------------------------------------------
---------------------------SpineHelper:playAnimation()---------------------------------------------------
---------------------------------------------------------------------------------------------------------

function SpineHelper:playAnimation()

          --Local References of Key Variables
          local state = self.state
          local skeleton = self.skeleton
          local root = self.root
          local imgBoxes = self.imgBoxes


            --Update Status
            self.animationIsPlaying = true
            self.physicsIsPlaying = false
            self.dragEnabled = false

            local lastTime = 0
            local animationTime = 0

    --Stops Physics control on bone's direction if it is enabled
    if (self.physicsEF) then 
      Runtime:removeEventListener('enterFrame', self.physicsEF) 
      self.physicsEF = nil 
    end


            local function onEachFrame(event)
                        -- Compute time in seconds since last frame.
                        local currentTime = event.time / 1000
                        local delta = currentTime - lastTime
                        lastTime = currentTime
                        
                        --Detect if Animation completed
                        if (state:getCurrent(0)) then
                            self.animationCompleted = false
                        else
                            self.animationCompleted = true
                        end
                        
                        -- Update the state with the delta time, apply it, and update the world transforms.
                        state:update(delta)
                        state:apply(skeleton)
                        
                        
                        --Position Character per x/y coordinates
                         skeleton.group.x = self.x
                         skeleton.group.y = self.y
                         skeleton.group.alpha = self.alpha
                         skeleton.flipX = self.flipX
                         skeleton.flipY = self.flipY
                         root.rotation = -self.rotation
                         root.scaleX = self.scaleX
                         root.scaleY = self.scaleY
                

                    if (self.isPolygonPresent == true) then
                      
                            for i=1, imgBoxes.numChildren do
                                     
                                      local polygon = imgBoxes[i]
                                      local bone = imgBoxes[i].bbBone
                       
                       
                                            --Update bounding box's position
                                         if (skeleton.flipX == true and skeleton.flipY == false) then

                                            polygon.x = skeleton.group.x + bone.worldX
                                            polygon.y = skeleton.group.y - bone.worldY
                                            polygon.rotation = bone.worldRotation
             
                                         elseif (skeleton.flipX == false and skeleton.flipY == false) then

                                            polygon.x = skeleton.group.x + bone.worldX
                                            polygon.y = skeleton.group.y - bone.worldY
                                            polygon.rotation = -bone.worldRotation
                                           

                                          elseif (skeleton.flipX == false and skeleton.flipY == true) then

                                            polygon.x = skeleton.group.x + bone.worldX
                                            polygon.y = skeleton.group.y - bone.worldY
                                            polygon.rotation = bone.worldRotation

                                           elseif (skeleton.flipX == true and skeleton.flipY == true) then

                                            polygon.x = skeleton.group.x + bone.worldX
                                            polygon.y = skeleton.group.y - bone.worldY
                                            polygon.rotation = -bone.worldRotation
              
                                       end
                              end   
                    end

                        skeleton:updateWorldTransform()
                          
            end
            self.moveEF = onEachFrame --allow instance to keep reference to this for pause/ resume purposes
            Runtime:addEventListener("enterFrame", onEachFrame)

end


---------------------------------------------------------------------------------------------------------
---------------------------SpineHelper:stopAnimation()---------------------------------------------------
---------------------------------------------------------------------------------------------------------

function SpineHelper:stopAnimation()
  
        --Local References of Key Variables
        local skeletonData = self.skeletonData
        local skeleton = self.skeleton
        local stateData = self.stateData
        local state = self.state
  
  
  
    if (self.moveEF) then 
          Runtime:removeEventListener('enterFrame', self.moveEF) 
          self.moveEF = nil 

          if (self.physicsEnabled == true) then
                --Once Animation stops, let physics take over if physics is enabled
                self:playPhysics()
          end
         
    end

    self.animationIsPlaying = false
end


---------------------------------------------------------------------------------------------------------
---------------------------SpineHelper:changeSkin(skinName)----------------------------------------------
---------------------------------------------------------------------------------------------------------

function SpineHelper:changeSkin(skinName)
  
        --Local References of Key Variables
        local skeletonData = self.skeletonData
        local skeleton = self.skeleton
  
 if #skeletonData.skins > 0 then
        local skinExists --Forward Reference, internal to if-then (true or false)
            if (skinName) then
                    for i=1, #skeletonData.skins do
                            if (skinName == skeletonData.skins[i].name) then
                                skinExists = true
                                break
                            else
                                skinExists = false
                            end
                    end

                    if (skinExists == true) then
                         skeleton:setSkin(skinName)
                         skeleton:setSlotsToSetupPose () -- always use this after changing a skin
                         print ("skin exists: ", skinName)
                    else
                              skeleton:setSkin(skeletonData.skins[1].name) -- Sets up the first skin if skinName gets an error
                              skeleton:setSlotsToSetupPose () -- always use this after changing a skin
                              print ("skin doesn't exist, using the first one available")
                    end
                    
            else --No config.skin provided even when there skins exist
                    skeleton:setSkin(skeletonData.skins[1].name) -- Sets up the first skin if skinName gets an error
                    skeleton:setSlotsToSetupPose () -- always use this after changing a skin
                    print ("No config.skin provided even when skins exist, using the first one available")
            end
    end
 
end 


---------------------------------------------------------------------------------------------------------
---------------------------SpineHelper:changeAnimation(params)-------------------------------------
---------------------------------------------------------------------------------------------------------


function SpineHelper:changeAnimation(params)
    
             ----  PARAMETERS  --------
        local params = params or {}

        local newAnimation = params.newAnimation --***REQUIRED ******
        local transitionTime = params.transitionTime or 0.5
        local delay = params.delay or 0      
        local track = params.track or 0
        local loop = true
        
        if (params.loop == nil) then
            loop = true
        else
             loop = params.loop
        end
        print ("Loop: ", loop)
    
        --Local References of Key Variables
        local skeletonData = self.skeletonData
        local skeleton = self.skeleton
        local stateData = self.stateData
        local state = self.state
    
    
      local animationExists--Forward Reference
      local currentAnimation -- Forward Reference 

    
  
      --Check if Animation Name is valid
      if (newAnimation == nil) then
              local alert = native.showAlert( "SpineHelper",  "Pleaes provide a valid animation name", { "OK" })
      else
                for i=1, #skeletonData.animations do
                       if (newAnimation == (skeletonData.animations[i].name)) then
                               animationExists = true
                                print ("Animation exists")
                                break
                       else
                                 animationExists = false
                                 print ("animation doesn't exist")
                        end
                end
                 
                 if (animationExists == true) then
                      if (self.animationCompleted) then
                            print ("Initial Animation Completed")
                            state:setAnimationByName(track, newAnimation, loop, delay) --trackIndex, name, loop, delay
                      else
                            print ("Initial Animation is still running")
                            currentAnimation = state:getCurrent(0).animation.name
                            stateData:setMix(currentAnimation, newAnimation, transitionTime)
                            state:setAnimationByName(track, newAnimation, loop, delay) --trackIndex, name, loop, delay
                      end
                 else
                      local alert = native.showAlert( "SpineHelper",  "Animation named: " .. newAnimation .. " is not valid. Pleaese provide a valid animation name", { "OK" })
                 end
      end
end


---------------------------------------------------------------------------------------------------------
---------------------------SpineHelper:changeItem(params)------------------------------------------------
---------------------------------------------------------------------------------------------------------


function SpineHelper:changeItem(params)
  
       --Local References of Key Variables
        local skeletonData = self.skeletonData
        local skeleton = self.skeleton
  
       ----- PARAMETERS ----------
      local params = params or {}
      
      local slot = params.slot  --***REQUIRED ******
      local item = params.item or nil
      local slotExists --Forward Reference
      
      if slot == nil  then
            local alert = native.showAlert( "SpineHelper",  "Plese provide a slot name", { "OK" })  
      else
                for i=1, #skeletonData.slots do
                       if (slot == (skeletonData.slots[i].name)) then
                               slotExists = true
                                print ("Slot exists")
                                break
                       else
                                 slotExists = false
                                 print ("Slot doesn't exist")
                        end
                end
        
                if (slotExists == true) then
                          if (item == nil) then
                            skeleton:setAttachment(slot, nil)
                          else 
                                    local attachmentName = skeleton:getAttachment(slot, item)
                                    if (attachmentName == nil ) then
                                        local alert = native.showAlert( "SpineHelper",  "Attachment named: ".. item.. " doesn't exist. Please verify", { "OK" })
                                        print ("item is not a valid attachment name")
                                    else
                                           if  (item == skeleton:getAttachment(slot, item).name) then
                                              skeleton:setAttachment(slot, item)
                                              print ("item is a valid attachment name")
                                           end
                                     end
                          end
                else
                      local alert = native.showAlert( "SpineHelper",  "Slot named: " .. slot.. " doesn't exist. Please verity", { "OK" }) 
                end
        end
end


---------------------------------------------------------------------------------------------------------
---------------------------SpineHelper:drawBoundingBox(params)-------------------------------------------
---------------------------------------------------------------------------------------------------------

function SpineHelper:drawBoundingBox(params)
      
         --Local References of Key Variables
        local skeletonData = self.skeletonData
        local skeleton = self.skeleton
        local imgBoxes = self.imgBoxes

      self.isPolygonPresent = true
      
        local params = params or {}
        local bone = params.bone                   --***REQUIRED
        local slot = params.slot                   --***REQUIRED
        local boundingBox = params.boundingBox     --***REQUIRED
        local anchorX = params.anchorX or 0.5
        local anchorY = params.anchorY or 0.5
        local hasBody = params.hasBody or false
                
        local bbBone = skeleton:findBone(bone)
        local bbBox = skeleton:getAttachment(slot, boundingBox)
        local bbSlot = skeleton:findSlot(slot)
        local vertices = bbBox.vertices
        local polygon --forward reference

 
        --Make sure bone, slot and boundingBox are not nill
         
          if (bbBone == nil or bbBox == nil or bbSlot == nil) then
             local alert = native.showAlert( "Spine Helper",  "Please provide a valid bone, slot or bounding box name", { "OK" })
          else
        --        

          --Check if we have to flip bounding Box Vertices and draw the Polygon BEFORE adding Physics Body
           if (self.flipX == true and self.flipY == true) then

                    --Flip bounding box horizontally
                    for i=1, #vertices, 2 do
                       vertices[i] = vertices[i]* -1
                    end
                  
                    --Position the Polygon
                    polygon = display.newPolygon( 0, 0, vertices)
                    polygon.anchorX = anchorX                  
                    polygon.anchorY = anchorY

                    polygon.x = skeleton.group.x + bbBone.worldX-- Root Bone position minus Bounding Box's bone positio
                    polygon.y = skeleton.group.y - bbBone.worldY-- Root Bone position minus Bounding Box's bone position

           elseif (self.flipX == false and self.flipY == false) then
               
                     --Flip bounding box vertically
                    for i=2, #vertices, 2 do
                        vertices[i] = vertices[i]* -1
                    end   

                    --Position the Polygon
                    polygon = display.newPolygon( 0, 0, vertices)
                    polygon.anchorX = anchorX                   
                    polygon.anchorY = anchorY
                    
                    polygon.x = skeleton.group.x + bbBone.worldX-- Root Bone position minus Bounding Box's bone positio
                    polygon.y = skeleton.group.y - bbBone.worldY-- Root Bone position minus Bounding Box's bone position
                    
            elseif (self.flipX == true and self.flipY == false) then
                    
                    --Flip bounding box horizontally
                    for i=1, #vertices, 2 do
                       vertices[i] = vertices[i]* -1
                    end
                  
                     --Flip bounding box vertically
                    for i=2, #vertices, 2 do
                        vertices[i] = vertices[i]* -1
                    end                   
                  
                    --Position the Polygon
                    polygon = display.newPolygon( 0, 0, vertices)
                    polygon.anchorX = anchorX                  
                    polygon.anchorY = anchorY

                    polygon.x = skeleton.group.x + bbBone.worldX-- Root Bone position minus Bounding Box's bone positio
                    polygon.y = skeleton.group.y - bbBone.worldY-- Root Bone position minus Bounding Box's bone position
                    
           elseif (self.flipX == false and self.flipY == true) then

                    --Position the Polygon
                    polygon = display.newPolygon( 0, 0, vertices)
                    polygon.anchorX = anchorX   
                    polygon.anchorY = anchorY                 

                    polygon.x = skeleton.group.x + bbBone.worldX-- Root Bone position minus Bounding Box's bone positio
                    polygon.y = skeleton.group.y - bbBone.worldY-- Root Bone position minus Bounding Box's bone position
           end
           
                    --Attach boundingBox, boneName and Bone to Polygon
                    polygon.boundingBox = boundingBox
                    polygon.boneName = bone
                    polygon.bbBone = bbBone --Assign Bone as a Polygon Property
                    polygon.name = bone
                    polygon.slotName = slot

                    --Color the polygon  
                    polygon:setFillColor(0, 1, 1, 1)
                    polygon.strokeWidth = 1
                    polygon:setStrokeColor(1, 0, 0, 1)
                    polygon.alpha = 0.01

                     
                --Enable Physics  
                if (params.hasBody) then

                    self.physicsEnabled = true
                     --Allow physics parameters to be passed by parameters:
                     polygon.density = params.density or 0.3
                     polygon.friction = params.friction or 0.3
                     polygon.bounce = params.bounce or 0.2
                     polygon.isSensor = params.isSensor or false
                     polygon.bodyType = params.bodyType or "dynamic"


                    physics.addBody(polygon, polygon.bodyType, {density = polygon.density, friction = polygon.friction, bounce = polygon.bounce, isSensor = polygon.isSensor})

                end
                
                ---Drag Functionality
                if (self.dragEnabled == true) then
                        print ("Drag is enabled")
                        if (self.physicsEnabled == true and polygon.bodyType=="dynamic") then
                          print ("Physics drag enabled")
                          
                               local function dragFunction (event)
                                    local body = event.target
                                    local phase = event.phase
                                    local stage = display.getCurrentStage()
                                    
                                    local RealWorldX = body.x --worldX coordinate where I want the bone to be located at
                                    local RealWorldY = body.y --worldX coordinate where I want the bone to be located at
                                    local RealWorldRotation = body.rotation

                                    local calculatedWorldX = (RealWorldX-skeleton.group.x)
                                    local calculatedWorldY = (RealWorldY-skeleton.group.y)*-1
                                    local calculatedRotation = (RealWorldRotation - skeleton.group.rotation)    

                                    local localX, localY = inverseMatrix(body.bbBone, calculatedWorldX, calculatedWorldY)

                                    if (phase == "began") then
                                         body.oldX = body.x
                                         body.oldY = body.y
                                        
                                         stage:setFocus(body)
                                         body.hasFocus = true
                                         
                                         --Stop Animation
                                        self:stopAnimation()

                                        -- Create a temporary touch joint and store it in the object for later reference
                                        body.tempJoint = physics.newJoint( "touch", body, event.x, event.y )
                                        print ("joint created at", event.x, event.y)
                                         
                                    elseif (body.hasFocus) then
                                      
                                        if (phase == "moved") then

                                          -- Update the joint to track the touch
                                          body.tempJoint:setTarget( event.x, event.y )
                                          body.tempJoint.maxForce = 10000
                                          body.tempJoint.frequency = 50
                                          body.tempJoint.dampingRatio = 0.0
                                          body.bbBone.x = localX
                                          body.bbBone.y = localY
                                          body.bbBone.rotation = -calculatedRotation
                                          skeleton:updateWorldTransform()


                                        elseif (phase == "ended" or phase == "cancelled") then
                                            stage:setFocus(nil)
                                            body.hasFocus = false
                                            
                                            -- Remove the joint when the touch ends                 
                                            display.remove(body.tempJoint)
                                            --print ("drag ended")
  
                                          --play Animation if it was already playing before drag
                                            if (self.playAnimationAfterDrag == true) then
                                                self:playAnimation()

                                            elseif (self.playAnimationAfterDrag == false) then
                                               self:stopAnimation()

                                            end
                                            
                                        end
                                    end
                               end
                               polygon:addEventListener("touch", dragFunction)                        
                          
                        elseif (self.physicsEnabled == false or polygon.bodyType=="static") then
                          print ("Non-Physics drag enabled")
                          
                             local function dragFunction (event)
                                    local body = event.target
                                    local phase = event.phase
                                    local stage = display.getCurrentStage()

                                    local RealWorldX = body.x --worldX coordinate where I want the bone to be located at
                                    local RealWorldY = body.y --worldX coordinate where I want the bone to be located at
                                    local RealWorldRotation = body.rotation

                                    local calculatedWorldX = (RealWorldX-skeleton.group.x)
                                    local calculatedWorldY = (RealWorldY-skeleton.group.y)*-1
                                    local calculatedRotation = (RealWorldRotation - skeleton.group.rotation)    

                                    local localX, localY = inverseMatrix(body.bbBone, calculatedWorldX, calculatedWorldY)

                                    if (phase == "began") then
                                         body.oldX = body.x
                                         body.oldY = body.y
                                        
                                         stage:setFocus(body)
                                         body.hasFocus = true

                                         --Stop Animation
                                        if (self.moveEF) then 
                                            Runtime:removeEventListener('enterFrame', self.moveEF) 
                                        end
                                          --self:stopAnimation()

                                    elseif (body.hasFocus) then
                                      
                                        if (phase == "moved") then
                                            body.x = (event.x - event.xStart) + body.oldX
                                            body.y = (event.y - event.yStart) + body.oldY

                                          body.bbBone.x = localX
                                          body.bbBone.y = localY
                                          body.bbBone.rotation = -calculatedRotation
                                          skeleton:updateWorldTransform()

                                        elseif (phase == "ended" or phase == "cancelled") then
                                            stage:setFocus(nil)
                                            body.hasFocus = false

                                            --play Animation if it was already playing before drag
                                            if (self.playAnimationAfterDrag == true) then
                                                self:playAnimation()

                                            elseif (self.playAnimationAfterDrag == false) then
                                               self:stopAnimation()

                                            end
                                        end
                                    end
                               end
                               polygon:addEventListener("touch", dragFunction)
                          
                        end
                end
                
                
                    --Insert polygon into images group
                    imgBoxes:insert(polygon)
                    imgBoxes:toFront()
          end
    return polygon
  end


---------------------------------------------------------------------------------------------------------
---------------------------SpineHelper:playPhysics()-----------------------------------------------------
---------------------------------------------------------------------------------------------------------


function SpineHelper:playPhysics()
  
    print ("Because Physics is Enabled, now playPhysics() is running")
  
        --Local References of Key Variables
        local imgBoxes = self.imgBoxes
        local skeleton = self.skeleton

        --Update Status
        self.physicsIsPlaying = true
        self.animationIsPlaying = false


        local function onEachFrame(event)
              for i=1, imgBoxes.numChildren do 
                            
                            local polygon = imgBoxes[i]
                            local bone = imgBoxes[i].bbBone
                            
                            local RealWorldX = polygon.x --worldX coordinate where I want the bone to be located at
                            local RealWorldY = polygon.y --worldX coordinate where I want the bone to be located at
                            local RealWorldRotation = polygon.rotation

                            local calculatedWorldX = (RealWorldX-skeleton.group.x)
                            local calculatedWorldY = (RealWorldY-skeleton.group.y)*-1
                            local calculatedRotation = (RealWorldRotation - skeleton.group.rotation)                            

                            local localX, localY = inverseMatrix(bone, calculatedWorldX, calculatedWorldY)
                            bone.x = localX
                            bone.y = localY
                            
                            --Change Rotation depending on orientation of animation
                            if (self.flipX == true and self.flipY == false) then
                                bone.rotation = calculatedRotation
                            elseif (self.flipX == false and self.flipY == false) then
                                bone.rotation = -calculatedRotation
                            elseif (self.flipX == false and self.flipY == true) then
                                 bone.rotation = calculatedRotation
                            elseif (self.flipX == true and self.flipY == true) then
                                 bone.rotation = -calculatedRotation
                            end
                            skeleton:updateWorldTransform()  
              end          
        end
        self.physicsEF = onEachFrame --allow instance to keep reference to this for pause/ resume purposes
        Runtime:addEventListener("enterFrame", onEachFrame)
end


---------------------------------------------------------------------------------------------------------
---------------------------SpineHelper:createJoint(parentBoneName, childBoneName, rotationLimit)------------------------
---------------------------------------------------------------------------------------------------------

function SpineHelper:createJoint(parentBoneName, childBoneName, rotationLimitA, rotationLimitB)
        
         local imgBoxes = self.imgBoxes
         local parentBoneName = parentBoneName --**REQUIRED
         local childBoneName = childBoneName   --**REQUIRED
         local rotationLimitA = rotationLimitA or -270
         local rotationLimitB = rotationLimitB or 270
         local parentBoneExists --forward reference
         local childBoneExists --forward reference
         local parentBone --to hold parentBone display object
         local childBone -- to hold childBone display object
         

    
         if (parentBoneName == nil or childBoneName == nil ) then
           
           local alert = native.showAlert( "SpineHelper",  "Child or Parent Bone Name: is not valid. Please provide a valid bone name", { "OK" })
          
         else
                     --Validate Name of Parent and Child Bones
                    for i=1, imgBoxes.numChildren do 
                            if (parentBoneName == imgBoxes[i].name) then
                                
                                parentBoneExists = true
                                print ("Parent boneName exists")
                                parentBone = imgBoxes[i]
                                break
                            else
                                parentBoneExists = false
                            end
                    end
                
                    for i=1, imgBoxes.numChildren do 
                            if (childBoneName == imgBoxes[i].name) then
                                childBoneExists = true
                                print ("Child boneName exists")
                                childBone = imgBoxes[i]
                                break
                            else
                                childBoneExists = false
                            end
                    end
              
                if (parentBoneExists == false or childBoneExists == false) then
                  local alert = native.showAlert( "SpineHelper",  "Child or Parent Bone Name: is not valid. Please provide a valid bone name", { "OK" })
                end

                -----Create Joint
                local myJoint = physics.newJoint( "pivot", parentBone, childBone, childBone.x, childBone.y )
                myJoint.isLimitEnabled = true
                myJoint:setRotationLimits( rotationLimitA, rotationLimitB )
               

          end
end

---------------------------------------------------------------------------------------------------------
---------------------------SpineHelper:hideBone(slotName, boundingBoxSlot)-------------------------------
---------------------------------------------------------------------------------------------------------

function SpineHelper:hideBone(slotName, boundingBoxSlot)
    
        local imgBoxes = self.imgBoxes
        local skeleton = self.skeleton 
        local boundingBoxSlotExists -- forward reference
        local slotName = slotName --***REQUIRED
        local bbSlot --forward reference
        local boundingBox

        if (slotName == nil ) then
              local alert = native.showAlert( "SpineHelper",  "Slot Name: is not valid. Please provide a valid slot name", { "OK" })
        else
                    ---Remove Image from Slot
                    bbSlot = skeleton:findSlot(slotName)
                    skeleton:setAttachment(slotName)
                   
                   if (boundingBoxSlot) then
                     
                           --Validate BoundingBoxSlot
                          for i=1, imgBoxes.numChildren do 
                                  if (boundingBoxSlot == imgBoxes[i].boundingBox) then
                                      
                                      boundingBoxSlotExists = true
                                      print ("boundingBox Slot exists")
                                      boundingBox = imgBoxes[i]
                                      break
                                  else
                                      boundingBoxSlotExists = false
                                  end
                          end

                         if (boundingBoxSlotExists == false) then
                            local alert = native.showAlert( "SpineHelper",  "BoundingBox Name: is not valid. Please provide a BoundingBox name", { "OK" })

                         else
                              --Remove Bounding Box if any
                              if (self.physicsEnabled == true) then
                                    physics.removeBody( boundingBox )
                              end
                         end
                  end
        end
end

---------------------------------------------------------------------------------------------------------
---------------------------SpineHelper:identifyBoundingBoxes()-------------------------------------------
---------------------------------------------------------------------------------------------------------

function SpineHelper:identifyBoundingBoxes()
      local imgBoxes = self.imgBoxes

      table.print_r(imgBoxes)

      for i=1, imgBoxes.numChildren do
            print ( "BoundingBox Name: "..imgBoxes[i].name, "=> YourInstance.imgBoxes["..i.."]")

      end

end



return SpineHelper