------------------------------------------------------------------------------
 -- Spine Runtime Software License - Version 1.0
 -- 
 -- Copyright (c) 2013, Esoteric Software
 -- All rights reserved.
 -- 
 -- Redistribution and use in source and binary forms in whole or in part, with
 -- or without modification, are permitted provided that the following conditions
 -- are met:
 -- 
 -- 1. A Spine Essential, Professional, Enterprise, or Education License must
 --    be purchased from Esoteric Software and the license must remain valid:
 --    http://esotericsoftware.com/
 -- 2. Redistributions of source code must retain this license, which is the
 --    above copyright notice, this declaration of conditions and the following
 --    disclaimer.
 -- 3. Redistributions in binary form must reproduce this license, which is the
 --    above copyright notice, this declaration of conditions and the following
 --    disclaimer, in the documentation and/or other materials provided with the
 --    distribution.
 -- 
 -- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 -- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 -- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 -- DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 -- ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 -- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 -- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 -- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 -- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 -- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 ------------------------------------------------------------------------------

local AnimationStateData = {}

function AnimationStateData.new (skeletonData)
	if not skeletonData then error("skeletonData cannot be nil", 2) end

	local self = {
		animationToMixTime = {},
		skeletonData = skeletonData,
		defaultMix = 0
	}

	function self:setMix (fromName, toName, duration)
		if not self.animationToMixTime[fromName] then
			self.animationToMixTime[fromName] = {}
		end
		self.animationToMixTime[fromName][toName] = duration
	end
	
	function self:getMix (fromName, toName)
		local first = self.animationToMixTime[fromName]
		if not first then return self.defaultMix end
		local duration = first[toName]
		if not duration then return self.defaultMix end
		return duration
	end

	return self
end
return AnimationStateData
