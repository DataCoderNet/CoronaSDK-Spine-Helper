--calculate the aspect ratio of the device:
local aspectRatio = display.pixelHeight / display.pixelWidth

application = {
        content = {
                width = aspectRatio > 1.5 and 320 or math.ceil( 480 / aspectRatio ),
                height = aspectRatio < 1.5 and 480 or math.ceil( 320 * aspectRatio ),
                scale = "letterBox",
                fps = 60,
                audioPlayFrequency = 22050,
                --graphicsCompatibility = 1,  -- Enable V1 Compatibility mode

                imageSuffix = {
                    ["@2x"] = 1.5,
                    ["@4x"] = 3.0,
                },
        },

        LevelHelperSettings = 
        {
            imagesSubfolder = "LH1Assets", --Instruct LevelHelper API where images are kept
            levelsSubfolder = "Levels" --Instruct LevelHelper API where levels are kept
        },


        notification =
        {
            google =
            {
                -- This Project Number (also known as a Sender ID) tells Corona to register this application
                -- for push notifications with the Google Cloud Messaging service on startup.
                -- This number can be obtained from the Google API Console at:  https://code.google.com/apis/console
                projectNumber = "411286242000",
            },

            iphone = 
            {
                types = {"badge", "sound", "alert"}
            }
        },


}