-- main.lua
local gameState = "menu"  -- "menu", "playing", "gameover", "settings", "credits", "quit", "deletedata", "store"
local menuSelection = 1
local selectedSetting = 1
local selectedItem = nil
--local deleteDaveConfirm = false
local versionNumber = " 1.0.0"
local versionDev = false

local selectedCategory = "[Monster Cloth]"
local monsterMoney = 0
local equippedItem = nil
local equippedMonsterSkin = nil
local equippedLandscapeSkin = nil
local displayEquipText = {}
local equipText = "" 
local equipTextDisplay = {}

local canDoubleJump = false
local doubleMoney = false


local items = {
    ["[Monster Cloth]"] = {
        {name = "Skin 1", price = 50, image = love.graphics.newImage("img/skin1.png")},
        {name = "Skin 2", price = 50, image = love.graphics.newImage("img/skin2.png")},
        {name = "Skin 3", price = 50, image = love.graphics.newImage("img/skin3.png")},
        {name = "Skin 4", price = 50, image = love.graphics.newImage("img/skin4.png")},
    },
    ["[Landscape]"] = {
        {name = "Landscape Skin 1", price = 50, image = love.graphics.newImage("img/obstacle1.png")},
        {name = "Landscape Skin 2", price = 50, image = love.graphics.newImage("img/obstacle2.png")},
        {name = "Landscape Skin 3", price = 50, image = love.graphics.newImage("img/obstacle3.png")},
        {name = "Landscape Skin 4", price = 50, image = love.graphics.newImage("img/obstacle4.png")},
    },
    ["[Monster Mastery]"] = {
        {name = "Double Jump", price = 100, image = love.graphics.newImage("img/doublejump.png")},
        {name = "2x Teeth", price = 150, image = love.graphics.newImage("img/doublemoney.png")},
    }
}

local equippedItems = {
    ["[Monster Cloth]"] = nil,
    ["[Landscape]"] = nil,
    ["[Monster Mastery]"] = nil,
}

local prevMasterVolume = masterVolume

local music = love.audio.newSource("music/StrengthoftheTitans.mp3", "stream")
local jumpSound = love.audio.newSource("sfx/jumpSfx.mp3", "static")
local gameOverSound = love.audio.newSource("sfx/gameoverSfx.mp3", "static")
local gameOverSoundPlayed = false

local masterVolume = 0.2
local musicVolume = 0.05
local sfxVolume = 0.5

local muteMusic = false
local muteSFX = false

local monster
local obstacles = {}
local score = 0
local gameOver = false
local restartText = ""

function love.load()
    love.window.setTitle("Monster Dash")
    love.window.setMode(800, 400)

    music:play()
    music:setVolume(musicVolume)
    music:setLooping(true)

    monster = {
        x = 100,
        y = 300,
        width = 50,
        height = 50,
        jumpHeight = -300,
        velocityY = 0,
        isJumping = false,
        jumpCount = 1,
    }
    
    obstacles = {}
    
    monster.image = love.graphics.newImage("img/monster.png")
    obstacleImage = love.graphics.newImage("img/obstacle.png")
end

function love.update(dt)
    if gameState == "playing" then
        monster.velocityY = monster.velocityY + 500 * dt
        monster.y = monster.y + monster.velocityY * dt
        
        if monster.y > 300 then
            monster.y = 300
            monster.velocityY = 0
            monster.isJumping = false
            monster.jumpCount = 1
        end
        
        for i, obstacle in ipairs(obstacles) do
            obstacle.x = obstacle.x - 200 * dt
            
            if checkCollision(monster, obstacle) then
                gameOver = true
                restartText = "Press 'Space' to play again"
                gameState = "gameover"
            end
            
            if obstacle.x < -obstacle.width then
                table.remove(obstacles, i)
            end
        end
        
        if love.math.random() < 0.02 then
            local obstacle = {
                x = 800,
                y = 300,
                width = 10,
                height = 50,
            }
            table.insert(obstacles, obstacle)
        end
        
        score = score + dt
    elseif gameState == "gameover" then
        if love.keyboard.isDown("space") then
            restartGame()
            gameState = "playing"
        end
    elseif gameState == "menu" then
        if love.keyboard.isDown("return") then
            if menuSelection == 1 then
                gameState = "playing"
            elseif menuSelection == 2 then
                gameState = "store"
            elseif menuSelection == 3 then
                gameState = "settings"
            elseif menuSelection == 4 then
                gameState = "quit"
            end
        end
    elseif gameState == "quit" then
        if love.keyboard.isDown("y") then
            love.event.quit()
        elseif love.keyboard.isDown("n") then
            gameState = "menu"
        end
    elseif gameState == "store" then
        if love.keyboard.isDown("escape") then
            gameState = "menu"
        end

    end

    if masterVolume ~= prevMasterVolume then
        love.audio.setVolume(masterVolume)
        prevMasterVolume = masterVolume
    end

    if muteMusic then
        music:setVolume(0)
    else
        music:setVolume(musicVolume)
    end
end

function love.draw()
    if gameState ~= "menu" and gameState ~= "playing" and gameState ~= "gameover" and gameState ~= "settings" and gameState ~= "credits" and gameState ~= "quit" and gameState ~= "deletedata" and gameState ~= "store" then
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("404 not found", 310, 150, 0, 2, 2)
        love.graphics.print("Press 'Escape' to return to menu", 300, 200)
    else 
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", 0, 350, love.graphics.getWidth(), 50)
    
        local scale = 0.05
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(monster.image, monster.x, monster.y, 0, scale, scale)
    
        local scaleobstacle = 0.7
        for _, obstacle in ipairs(obstacles) do
            love.graphics.draw(obstacleImage, obstacle.x, obstacle.y, 0, scaleobstacle, scaleobstacle)
        end
    
        love.graphics.setColor(0, 0, 0)
        love.graphics.print("Score: " .. math.floor(score), 10, 10)
    
        if gameState == "gameover" then
            love.graphics.print("Game Over", 350, 150, 0, 2, 2)
            love.graphics.print(restartText, 340, 200)
        elseif gameState == "menu" or gameState == "quit" then
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        
            local menuOptions = {"[Play]", "[Store]", "[Settings]", "[Quit]", "[Github]"}
            local startX = 50
            local startY = 100
            local spacing = 30
            for i, option in ipairs(menuOptions) do
                local y = startY + (i - 1) * spacing
                local x = startX
                
                if i == 5 then
                    y = startY + 175
                end
                
                if i == menuSelection and gameState ~= "quit" then
                    love.graphics.setColor(1, 0, 0)
                else
                    love.graphics.setColor(1, 1, 1)
                end
                love.graphics.print(option, x, y)
            end
        
            love.graphics.setColor(1, 1, 1)
            local title = "Monster Dash"
            local titleWidth = love.graphics.getFont():getWidth(title)
            local centerX = startX
            local titleY = startY - 80
            love.graphics.print(title, centerX, titleY, 0, 2, 2)
        
            local smallText = "By Enur & Martin"
            local smallTextWidth = love.graphics.getFont():getWidth(smallText)
            local smallTextY = titleY + 30
            local centerX = startX + (titleWidth - smallTextWidth) / 2
            love.graphics.print(smallText, centerX + titleWidth + 10, smallTextY)
        
            love.graphics.print("Press Enter to select", startX, love.graphics.getHeight() - 50)

            if versionDev then
                versionText = "Version: devbuild " .. versionNumber
            else
                versionText = "Version: " .. versionNumber
            end
            local versionTextWidth = love.graphics.getFont():getWidth(versionText)
            local versionTextY = love.graphics.getHeight() - 50
            local versionTextX = love.graphics.getWidth() - versionTextWidth - 50
            love.graphics.print(versionText, versionTextX, versionTextY)
        end

        if gameState == "quit" then
            local screenWidth = love.graphics.getWidth()
            local screenHeight = love.graphics.getHeight()
            local rectWidth = 400
            local rectHeight = 150
            local rectX = (screenWidth - rectWidth) / 2
            local rectY = (screenHeight - rectHeight) / 2

            love.graphics.setColor(0, 0, 1)
            love.graphics.rectangle("fill", rectX, rectY, rectWidth, rectHeight)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("Do you want to quit?", rectX + 135, rectY + 50)
            local yesColor = menuSelection == 1 and {1, 0, 0} or {1, 1, 1}
            local noColor = menuSelection == 2 and {1, 0, 0} or {1, 1, 1}
            love.graphics.setColor(yesColor)
            love.graphics.print("[yes]", rectX + 135, rectY + 85)
            love.graphics.setColor(noColor)
            love.graphics.print("[no]", rectX + 235, rectY + 85)
        end

        if gameState == "credits" then
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

            local creditsText = {
                "Game Design         Enur Ibryam & Martin Stoyadinov",
                "Animation              Martin Stoyadinov",
                "Music & SFX           Martin Stoyadinov",
                "Main Menu             Enur Ibryam",
                "Graphic Design       Enur Ibryam",
                "",
                "Press 'Escape' to return to settings"
            }

            local startY = 100
            local spacing = 30

            for i, creditLine in ipairs(creditsText) do
                local y = startY + (i - 1) * spacing
                local x = love.graphics.getWidth() / 4

                love.graphics.setColor(1, 1, 1)
                love.graphics.print(creditLine, x, y)
            end

        end

        if gameState == "settings" or gameState == "deletedata" then
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

            love.graphics.setColor(1, 1, 1)
            love.graphics.print("Settings", love.graphics.getWidth() / 2 - 50, 50)

            local startY = 100
            local spacing = 30
            local x = love.graphics.getWidth() / 4

            local startX = love.graphics.getWidth() / 4
            local startY = 100
            local spacing = 30
            local x = startX
            for i, option in ipairs({"Master Volume", "Music Volume", "SFX Volume", "Mute Music", "Mute SFX", "[Credits]", "[Delete Data]"}) do
                local y = startY + (i - 1) * spacing

                if i == 6 then
                    y = startY + 160
                end

                if i == selectedSetting then
                    love.graphics.setColor(1, 0, 0)
                else
                    love.graphics.setColor(1, 1, 1)
                end

                love.graphics.print(option, x, y)

                if i == 4 or i == 5 then
                    local checkboxSize = 15
                    local checkboxX = x + 150
                    local checkboxY = y

                    if i == selectedSetting then
                        love.graphics.setColor(1, 0, 0)
                    else
                        love.graphics.setColor(1, 1, 1)
                    end

                    if (i == 4 and muteMusic) or (i == 5 and muteSFX) then
                        love.graphics.rectangle("fill", checkboxX, checkboxY, checkboxSize, checkboxSize)
                    else
                        love.graphics.rectangle("line", checkboxX, checkboxY, checkboxSize, checkboxSize)
                    end
                else
                    if i ~= 6 and i ~= 7 then
                        love.graphics.setColor(1, 1, 1)

                        if i == selectedSetting then
                            love.graphics.setColor(1, 0, 0)
                        end

                        love.graphics.rectangle("line", x + 150, y + 0, 200, 10)
                        love.graphics.setColor(1, 1, 1)

                        if i == selectedSetting then
                            love.graphics.setColor(1, 0, 0)
                        end

                        love.graphics.rectangle("fill", x + 150, y + 0, 200 * (i == 1 and masterVolume or i == 2 and musicVolume or sfxVolume), 10)
                    end
                end
            end
        end

        if gameState == "deletedata" then
            local screenWidth = love.graphics.getWidth()
            local screenHeight = love.graphics.getHeight()
            local rectWidth = 400
            local rectHeight = 150
            local rectX = (screenWidth - rectWidth) / 2
            local rectY = (screenHeight - rectHeight) / 2

            love.graphics.setColor(0, 0, 1)
            love.graphics.rectangle("fill", rectX, rectY, rectWidth, rectHeight)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("Do you want to delete data?", rectX + 115, rectY + 50)
            local yesColor = menuSelection == 1 and {1, 0, 0} or {1, 1, 1}
            local noColor = menuSelection == 2 and {1, 0, 0} or {1, 1, 1}
            love.graphics.setColor(yesColor)
            love.graphics.print("[yes]", rectX + 135, rectY + 85)
            love.graphics.setColor(noColor)
            love.graphics.print("[no]", rectX + 235, rectY + 85)
        end

        if gameState == "gameover" then
            gameOverSound:setVolume(sfxVolume)
            if not muteSFX and not gameOverSoundPlayed then
                gameOverSound:play()
                gameOverSound:setLooping(false)
                gameOverSoundPlayed = true
            end
        end

        if gameState == "store" then
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

            love.graphics.setColor(1, 1, 1)
            love.graphics.print("Store", love.graphics.getWidth() / 2 - love.graphics.getFont():getWidth("Store") / 2, 50)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("Teeth:", love.graphics.getWidth() / 4, 50)
            love.graphics.setColor(1, 1, 0)
            love.graphics.print(monsterMoney, love.graphics.getWidth() / 4 + love.graphics.getFont():getWidth("Teeth: "), 50)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("Press 'Space' to buy/equip", 300, 325)

            love.graphics.setColor(1, 1, 1)
            local categoryOrder = {"[Monster Cloth]", "[Landscape]", "[Monster Mastery]"}

            local startX = love.graphics.getWidth() / 4
            local startY = 100
            local spacing = 165

            for _, category in ipairs(categoryOrder) do
                if category == selectedCategory then
                    love.graphics.setColor(1, 0, 0)
                else
                    love.graphics.setColor(1, 1, 1)
                end
                love.graphics.print(category, startX, 85)
                startX = startX + spacing
            end

            startX = love.graphics.getWidth() / 4
            startY = 150
            spacing = 30

            

            for _, item in ipairs(items[selectedCategory]) do
                
                local itemText = item.name .. " (" .. item.price .. ")"

                if item == selectedItem then
                    love.graphics.setColor(1, 0, 0)
                elseif item.bought then
                    love.graphics.setColor(1, 1, 0)
                elseif monsterMoney >= item.price then
                    love.graphics.setColor(1, 1, 1)
                else
                    love.graphics.setColor(0.5, 0.5, 0.5)
                end

                love.graphics.print(itemText, startX, startY)

                if selectedCategory == "[Monster Cloth]" then
                    if equippedItems["[Monster Cloth]"] == item then
                        love.graphics.setColor(1, 1, 0)
                        love.graphics.print("Equipped", startX + 200, startY)
                    elseif item.bought then
                        love.graphics.setColor(1, 1, 1)
                        love.graphics.print("Owned", startX + 200, startY)
                    end
                elseif selectedCategory == "[Landscape]" then
                    if equippedItems["[Landscape]"] == item then
                        love.graphics.setColor(1, 1, 0)
                        love.graphics.print("Equipped", startX + 200, startY)
                    elseif item.bought then
                        love.graphics.setColor(1, 1, 1)
                        love.graphics.print("Owned", startX + 200, startY)
                    end
                elseif selectedCategory == "[Monster Mastery]" then
                    if equippedItems["[Monster Mastery]"] == item then
                        love.graphics.setColor(1, 1, 0)
                        love.graphics.print("Equipped", startX + 200, startY)
                    elseif item.bought then
                        love.graphics.setColor(1, 1, 1)
                        love.graphics.print("Owned", startX + 200, startY)
                    end
                end

                if item == selectedItem then
                    selectedSkinImage = item.image
                end
            
                startY = startY + spacing
            end
              

            if selectedSkinImage then

                local imageWidth, imageHeight = selectedSkinImage:getDimensions()
                local boxWidth, boxHeight = 150, 150
                local boxX = love.graphics.getWidth() - boxWidth - 160
                local boxY = 150

                love.graphics.setColor(1, 1, 1)
                love.graphics.rectangle("line", boxX, boxY, boxWidth, boxHeight)
                love.graphics.setColor(0.5, 0.5, 0.5, 0.05)
                love.graphics.rectangle("fill", boxX, boxY, boxWidth, boxHeight)
                
                local scale = math.min(boxWidth / imageWidth, boxHeight / imageHeight)

                local scaledWidth = imageWidth * scale * 0.8
                local scaledHeight = imageHeight * scale * 0.8

                local offsetX = (boxWidth - scaledWidth) / 2
                local offsetY = (boxHeight - scaledHeight) / 2

                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(selectedSkinImage, boxX + offsetX, boxY + offsetY, 0, scaledWidth / imageWidth, scaledHeight / imageHeight)

            else

                local boxWidth, boxHeight = 150, 150
                local boxX = love.graphics.getWidth() - boxWidth - 160
                local boxY = 150

                love.graphics.setColor(1, 1, 1)
                love.graphics.rectangle("line", boxX, boxY, boxWidth, boxHeight)

                love.graphics.setColor(0.5, 0.5, 0.5, 0.05)
                love.graphics.rectangle("fill", boxX, boxY, boxWidth, boxHeight)
            end
        end
    end
end

function love.keypressed(key)
    if gameState == "gameover" then
        if key == "escape" then
            gameState = "menu"
            restartGame()
        end
    end

    if gameState == "playing" then
        if key == "space" and not monster.isJumping then
            monster.velocityY = monster.jumpHeight
            monster.isJumping = true

            jumpSound:setVolume(sfxVolume)
            if not muteSFX then
                jumpSound:play()
            end

        elseif key == "space" and canDoubleJump and monster.isJumping and monster.jumpCount < 2 then
            monster.velocityY = monster.jumpHeight
            monster.isJumping = true
            monster.jumpCount = monster.jumpCount + 1

            jumpSound:setVolume(sfxVolume)
            if not muteSFX then
                jumpSound:play()
            end
        end
        if key == "escape" then
            gameState = "menu"
            restartGame()
        end

    elseif gameState == "menu" then
            if key == "up" then
                menuSelection = (menuSelection - 2) % 5 + 1
            elseif key == "down" then
                menuSelection = menuSelection % 5 + 1
            elseif key == "return" then
                if menuSelection == 1 then
                    gameState = "playing"
                elseif menuSelection == 2 then
                    gameState = "store"
                elseif menuSelection == 3 then
                    gameState = "settings"
                elseif menuSelection == 4 then
                    gameState = "quit"
                elseif menuSelection == 5 then
                    love.system.openURL("https://github.com/EnurDev/Monster_Dash_Project")
                end
            end

    elseif gameState == "quit" then
        if key == "left" or key == "right" then
            menuSelection = (menuSelection % 2) + 1
        elseif key == "return" then
            if menuSelection == 1 then
                love.event.quit()
            elseif menuSelection == 2 then
                gameState = "menu"
                menuSelection = 0
            end

        elseif key == "y" or key == "n" then
            gameState = key == "y" and "quit" or "menu"
        end

    elseif gameState == "settings" then
        if key == "up" then
            selectedSetting = math.max(1, selectedSetting - 1)
        elseif key == "down" then
            selectedSetting = math.min(7, selectedSetting + 1)
        elseif key == "left" or key == "right" then
            local volumeIncrement = 0.1
            if key == "left" then
                adjustVolume(selectedSetting, -volumeIncrement)
            elseif key == "right" then
                adjustVolume(selectedSetting, volumeIncrement)
            end
        
        elseif key == "return" then
            if selectedSetting == 4 or selectedSetting == 5 then
                if selectedSetting == 4 then
                    muteMusic = not muteMusic
                elseif selectedSetting == 5 then
                    muteSFX = not muteSFX
                end
            elseif selectedSetting == 6 then
                gameState = "credits"
            end
            if selectedSetting == 7 then
                gameState = "deletedata"
            end

        elseif key == "escape" then
            gameState = "menu"
        end
        
    elseif gameState == "deletedata" then
        if key == "left" or key == "right" then
            menuSelection = (menuSelection % 2) + 1
        elseif key == "return" then
            if menuSelection == 1 then
                --deleteDaveConfirm = true
                gameState = "settings"
            elseif menuSelection == 2 then
                --deleteDaveConfirm = false
                gameState = "settings"
            end
        end

    elseif gameState == "credits" then
        if key == "escape" then
            gameState = "settings"
        end
    end

    if gameState ~= "menu" and gameState ~= "playing" and gameState ~= "gameover" and gameState ~= "settings" and gameState ~= "credits" and gameState ~= "quit" and gameState ~= "deletedata" then
        if key == "escape" then
            gameState = "menu"
        end
    end

    if gameState == "store" then
        if key == "left" then
            local categoryOrder = {"[Monster Cloth]", "[Landscape]", "[Monster Mastery]"}
            local categoryIndex = 1
            for i, category in ipairs(categoryOrder) do
                if category == selectedCategory then
                    categoryIndex = i
                    break
                end
            end
            categoryIndex = categoryIndex - 1
            if categoryIndex == 0 then
                categoryIndex = #categoryOrder
            end
            selectedCategory = categoryOrder[categoryIndex]
        elseif key == "right" then
            local categoryOrder = {"[Monster Cloth]", "[Landscape]", "[Monster Mastery]"}
            local categoryIndex = 1
            for i, category in ipairs(categoryOrder) do
                if category == selectedCategory then
                    categoryIndex = i
                    break
                end
            end
            categoryIndex = categoryIndex + 1
            if categoryIndex > #categoryOrder then
                categoryIndex = 1
            end
            selectedCategory = categoryOrder[categoryIndex]
        elseif key == "up" then
            local itemIndex = 1
            for i, item in ipairs(items[selectedCategory]) do
                if item == selectedItem then
                    itemIndex = i
                    break
                end
            end
            itemIndex = itemIndex - 1
            if itemIndex == 0 then
                itemIndex = #items[selectedCategory]
            end
            selectedItem = items[selectedCategory][itemIndex]
        elseif key == "down" then
            local itemIndex = 0
            for i, item in ipairs(items[selectedCategory]) do
                if item == selectedItem then
                    itemIndex = i
                    break
                end
            end
            itemIndex = itemIndex + 1
            if itemIndex > #items[selectedCategory] then
                itemIndex = 1
            end
            selectedItem = items[selectedCategory][itemIndex]
        elseif key == "space" then
            if not selectedItem.bought then
                if monsterMoney >= selectedItem.price then
                    monsterMoney = monsterMoney - selectedItem.price
                    selectedItem.bought = true
        
                    equippedItems[selectedCategory] = selectedItem

                    if selectedCategory == "[Monster Cloth]" then
                        monsterSkin = selectedItem
                        monster.image = selectedItem.image
                    elseif selectedCategory == "[Landscape]" then
                        landscapeSkin = selectedItem
                        obstacleImage = selectedItem.image
                    elseif selectedCategory == "[Monster Mastery]" then
                        monsterMasterySkin = selectedItem
                        if selectedItem.name == "Double Jump" then
                            canDoubleJump = true
                            doubleMoney = false
                        elseif selectedItem.name == "2x Teeth" then
                            doubleMoney = true
                            canDoubleJump = false
                        end
                    end
                else
                    print("Not enough money to buy this item!")
                end
            else

                if equippedItems[selectedCategory] == selectedItem then
                    equippedItems[selectedCategory] = nil
        
                    if selectedCategory == "[Monster Cloth]" then
                        monsterSkin = nil
                        monster.image = love.graphics.newImage("img/monster.png")
                    elseif selectedCategory == "[Landscape]" then
                        landscapeSkin = nil
                        obstacleImage = love.graphics.newImage("img/obstacle.png")
                    elseif selectedCategory == "[Monster Mastery]" then
                        monsterMasterySkin = nil
                        if selectedItem.name == "Double Jump" then
                            canDoubleJump = false
                            doubleMoney = false
                        elseif selectedItem.name == "2x Teeth" then
                            doubleMoney = false
                            canDoubleJump = false

                        end
                    end
                else
                    equippedItems[selectedCategory] = selectedItem
        
                    if selectedCategory == "[Monster Cloth]" then
                        monsterSkin = selectedItem
                        monster.image = selectedItem.image
                    elseif selectedCategory == "[Landscape]" then
                        landscapeSkin = selectedItem
                        obstacleImage = selectedItem.image
                    elseif selectedCategory == "[Monster Mastery]" then
                        monsterMasterySkin = selectedItem
                        if selectedItem.name == "Double Jump" then
                            canDoubleJump = true
                            doubleMoney = false
                        elseif selectedItem.name == "2x Teeth" then
                            doubleMoney = true
                            canDoubleJump = false
                        end
                    end
                end
            end
            
        elseif key == "escape" then
            gameState = "menu"
        end
    end
end


function adjustVolume(setting, increment)
    local volumeStep = 0.5

    if setting == 1 then
        masterVolume = math.min(1, math.max(0, (masterVolume or 0) + increment * volumeStep))
    elseif setting == 2 then
        musicVolume = math.min(1, math.max(0, (musicVolume or 0) + increment * volumeStep))
        if not muteMusic then
            music:setVolume(musicVolume)
        end
    elseif setting == 3 then
        sfxVolume = math.min(1, math.max(0, (sfxVolume or 0) + increment * volumeStep))

        jumpSound:setVolume(sfxVolume)
        gameOverSound:setVolume(sfxVolume)

        if not muteSFX then
            jumpSound:play()
        end
            
    end
end



function checkCollision(a, b)
    return a.x + a.width * 0.5 > b.x and a.x < b.x + b.width and a.y + a.height * 0.5 > b.y and a.y < b.y + b.height
end

function restartGame()
    monster.y = 300
    monster.velocityY = 0
    monster.isJumping = false
    gameOver = false
    restartText = ""
    obstacles = {}
    gameOverSoundPlayed = false
    if doubleMoney then
        score = score * 2
        monsterMoney = math.floor(score) + monsterMoney
    elseif not doubleMoney then
        monsterMoney = math.floor(score) + monsterMoney
    end
    score = 0
end
