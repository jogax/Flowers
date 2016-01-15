
//  CardGameScene.swift
//  Flowers
//
//  Created by Jozsef Romhanyi on 2015. 11. 26..
//  Copyright © 2015. Jozsef Romhanyi. All rights reserved.
//

import SpriteKit
import AVFoundation

class CardGameScene: MyGameScene {

    struct GenerateCard {
        var cardValue: Int
        var packageNr: Int
        var used: Bool
        init() {
            cardValue = 0
            packageNr = 0
            used      = false
        }
    }
    
    let emptySpriteTxt = "emptySprite"
    
    var cardStack:Stack<MySKNode> = Stack()
    var showCardStack:Stack<MySKNode> = Stack()
    
    var cardPackageButton: MySKButton?
    var cardPlaceButton: MySKButton?
    var cardPlaceButtonAddedToParent = false
    
    var showCard: MySKNode?

    var lastCollisionsTime = NSDate()
    var cardArray: [[GenerateCard]] = []
//    var valueTab = [Int]()
    let spriteCountPosKorr = CGPointMake(GV.onIpad ? 0.05 : 0.05, GV.onIpad ? 0.95 : 0.95)
    var levelsForPlay = LevelsForPlayWithCards()
    var countPackages = 0
    let nextLevel = true
    let previousLevel = false
    var lastUpdateSec = 0

    override func getTexture(index: Int)->SKTexture {
        if index == NoColor {
            return atlas.textureNamed("emptycard")
        } else {
            return atlas.textureNamed ("card\(index)")
        }
    }
    override func makeSpezialThings(first: Bool) {
        let multiplier = GV.deviceConstants.sizeMultiplier
        let width:CGFloat = 64.0
        let height: CGFloat = 89.0
        sizeMultiplier = CGSizeMake(multiplier, multiplier * height / width)
        levelsForPlay.setAktLevel(levelIndex)
    }
        
    override func specialPrepareFuncFirst() {
        let cardSize = CGSizeMake(buttonSize * sizeMultiplier.width * 0.6, buttonSize * sizeMultiplier.height * 0.6)
        let cardPackageButtonTexture = SKTexture(image: images.getCardPackage())
        cardPackageButton = MySKButton(texture: cardPackageButtonTexture, frame: CGRectMake(buttonXPosNormalized * 4.0, buttonYPos, cardSize.width, cardSize.height), makePicture: false)
        cardPackageButton!.name = "cardPackege"
        addChild(cardPackageButton!)
        
        let cardPlaceTexture = SKTexture(imageNamed: "emptycard")
        cardPlaceButton = MySKButton(texture: cardPlaceTexture, frame: CGRectMake(buttonXPosNormalized * 5.0, buttonYPos, cardSize.width, cardSize.height), makePicture: false)
        cardPlaceButton!.name = "cardPlace"
        addChild(cardPlaceButton!)
        cardPlaceButtonAddedToParent = true
        
        countContainers = levelsForPlay.aktLevel.countContainers
        countPackages = levelsForPlay.aktLevel.countPackages
        countSpritesProContainer = MaxCardValue //levelsForPlay.aktLevel.countSpritesProContainer
        countColumns = levelsForPlay.aktLevel.countColumns
        countRows = levelsForPlay.aktLevel.countRows
        minUsedCells = levelsForPlay.aktLevel.minProzent * countColumns * countRows / 100
        maxUsedCells = levelsForPlay.aktLevel.maxProzent * countColumns * countRows / 100
        containerSize = CGSizeMake(CGFloat(containerSizeOrig) * sizeMultiplier.width, CGFloat(containerSizeOrig) * sizeMultiplier.height)
        spriteSize = CGSizeMake(CGFloat(levelsForPlay.aktLevel.spriteSize) * sizeMultiplier.width, CGFloat(levelsForPlay.aktLevel.spriteSize) * sizeMultiplier.height )
         for _ in 0..<countContainers {
            var hilfsArray: [GenerateCard] = []
            for cardIndex in 0..<countSpritesProContainer! * countPackages {
                var card = GenerateCard()
                card.cardValue = cardIndex % countSpritesProContainer!
                card.packageNr = cardIndex / countSpritesProContainer!
                
                hilfsArray.append(card)
            }
            cardArray.append(hilfsArray)
        }
    }
    
    override func updateSpriteCount(adder: Int) {
        spriteCount += adder
        let spriteCountText: String = GV.language.getText(.TCCardCount)
        spriteCountLabel.text = "\(spriteCountText) \(spriteCount)"
    }

    override func changeLanguage()->Bool {
        playerLabel.text = GV.language.getText(TextConstants.TCGamer) + ": \(GV.globalParam.aktName)"
        levelLabel.text = GV.language.getText(TextConstants.TCLevel) + ": \(levelIndex + 1)"
        spriteCountLabel.text = "\(GV.language.getText(.TCCardCount)) + \(spriteCount)"
        showTimeLeft()
        return true
    }

    override func setBGImageNode()->SKSpriteNode {
        return SKSpriteNode(imageNamed: "cardBackground.png")
    }

//    override func generateValue(colorIndex: Int)->Int {
//        if valueTab.count < colorIndex + 1 {
//            valueTab.append(1)
//        }
//        return valueTab[colorIndex]++
//            
//    }
    
    override func spezialPrepareFunc() {
//        valueTab.removeAll()
        spriteCount = Int(CGFloat(countContainers * countSpritesProContainer!))
        let spriteCountText: String = GV.language.getText(.TCCardCount) + " \(spriteCount)"
        createLabels(spriteCountLabel, text: spriteCountText, position: CGPointMake(self.position.x + self.size.width * spriteCountPosKorr.x, self.position.y + self.size.height * spriteCountPosKorr.y), horAlignment: .Left)
    }

    override func getValueForContainer()->Int {
        return countSpritesProContainer!// + 1
    }
 
    func createSpriteStack() {
        cardStack.removeAll(.MySKNodeType)
        showCardStack.removeAll(.MySKNodeType)
        while colorTab.count > 0 && checkGameArray() < maxUsedCells {
            let colorTabIndex = random!.getRandomInt(0, max: colorTab.count - 1)//colorTab.count - 1 //
            let colorIndex = colorTab[colorTabIndex].colorIndex
            let spriteName = colorTab[colorTabIndex].spriteName
            let value = colorTab[colorTabIndex].spriteValue
            colorTab.removeAtIndex(colorTabIndex)
            let sprite = MySKNode(texture: getTexture(colorIndex), type: .SpriteType, value:value)
            sprite.name = spriteName
            sprite.colorIndex = colorIndex
//            sprite.row = NoValue
//            sprite.column = NoValue
            cardStack.push(sprite)
        }
    }

    override func generateSprites(first: Bool) {
        var positionsTab = [(Int, Int)]() // all available Positions
        for column in 0..<countColumns {
            for row in 0..<countRows {
                if !gameArray[column][row] {
                    let appendValue = (column, row)
                    positionsTab.append(appendValue)
                }
            }
        }
        
        while cardStack.count(.MySKNodeType) > 0 && checkGameArray() < maxUsedCells {
//            let colorTabIndex = random!.getRandomInt(0, max: colorTab.count - 1)//colorTab.count - 1 //
//            let colorIndex = colorTab[colorTabIndex].colorIndex
//            let spriteName = colorTab[colorTabIndex].spriteName
//            let value = colorTab[colorTabIndex].spriteValue
//            colorTab.removeAtIndex(colorTabIndex)
//            
//            let sprite = MySKNode(texture: getTexture(colorIndex), type: .SpriteType, value:value)
            let sprite: MySKNode = cardStack.pull()!
            tableCellSize = spriteTabRect.width / CGFloat(countColumns)
            
            let index = random!.getRandomInt(0, max: positionsTab.count - 1)
            let (aktColumn, aktRow) = positionsTab[index]
            
            let xPosition = spriteTabRect.origin.x - spriteTabRect.size.width / 2 + CGFloat(aktColumn) * tableCellSize + tableCellSize / 2
            let yPosition = spriteTabRect.origin.y - spriteTabRect.size.height / 2 + tableCellSize * 1.05 / 2 + CGFloat(aktRow) * tableCellSize * 1.05
            
            sprite.position = CGPoint(x: xPosition, y: yPosition)
            sprite.startPosition = sprite.position
            gameArray[aktColumn][aktRow] = true
            positionsTab.removeAtIndex(index)
            
            sprite.column = aktColumn
            sprite.row = aktRow
            
            deleteEmptySprite(aktColumn, row: aktRow)
//            sprite.colorIndex = colorIndex
//            sprite.name = spriteName
            
            sprite.size = CGSizeMake(spriteSize.width, spriteSize.height)
            
            addPhysicsBody(sprite)
            push(sprite, status: .AddedFromCardStack)
            addChild(sprite)
        }
        
        for column in 0..<countColumns {
            for row in 0..<countRows {
                if !gameArray[column][row] {
                    makeEmptyCard(column, row: row)
                }
            }
        }
        
        if first {
            countUp = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("doCountUp"), userInfo: nil, repeats: true)
        }
        
        stopped = false
    }
    
    func deleteEmptySprite(column: Int, row: Int) {
        let searchName = "\(emptySpriteTxt)-\(column)-\(row)"
        if self.childNodeWithName(searchName) != nil {
            self.childNodeWithName(searchName)!.removeFromParent()
        }

    
    }
    
    override func makeEmptyCard(column:Int, row: Int) {
        let searchName = "\(emptySpriteTxt)-\(column)-\(row)"
        if self.childNodeWithName(searchName) == nil {
            let xPosition = spriteTabRect.origin.x - spriteTabRect.size.width / 2 + CGFloat(column) * tableCellSize + tableCellSize / 2
            let yPosition = spriteTabRect.origin.y - spriteTabRect.size.height / 2 + tableCellSize * 1.05 / 2 + CGFloat(row) * tableCellSize * 1.05
            let emptySprite = MySKNode(texture: getTexture(NoColor), type: .EmptyCardType, value: NoColor)
            emptySprite.position = CGPoint(x: xPosition, y: yPosition)
            emptySprite.size = CGSizeMake(spriteSize.width, spriteSize.height)
            emptySprite.name = "\(emptySpriteTxt)-\(column)-\(row)"
            emptySprite.column = column
            emptySprite.row = row
            addChild(emptySprite)
        }
    }
    
    override func specialButtonPressed(buttonName: String) {
        if buttonName == "cardPackege" {
            if cardStack.count(.MySKNodeType) > 0 {
                if showCard != nil {
                    showCardStack.push(showCard!)
                    showCard?.removeFromParent()
                }
                showCard = cardStack.pull()!
                showCard!.position = (cardPlaceButton?.position)!
                showCard!.size = (cardPlaceButton?.size)!
                showCard!.type = .ShowCardType
                cardPlaceButton?.removeFromParent()
                cardPlaceButtonAddedToParent = false
                addChild(showCard!)
            }
        }
    }

    override func update(currentTime: NSTimeInterval) {
        let sec10: Int = Int(currentTime * 10) % 2
        if sec10 != lastUpdateSec && sec10 == 0 {
            let adder:CGFloat = 5
//            backgroudScrollUpdate()
            for index in 0..<tremblingSprites.count {
                let aktSprite = tremblingSprites[index]
                switch aktSprite.trembling {
                    case 0: aktSprite.trembling = adder
                    case adder: aktSprite.trembling = -adder
                    case -adder: aktSprite.trembling = adder
                    default: aktSprite.trembling = adder
                }
                switch aktSprite.tremblingType {
                    case .NoTrembling: break
                    case .ChangeSize:  aktSprite.size = CGSizeMake(aktSprite.origSize.width +  aktSprite.trembling, aktSprite.origSize.height +  aktSprite.trembling)
                    case .ChangePos: break
                case .ChangeDirection: aktSprite.zRotation = CGFloat(CGFloat(M_PI)/CGFloat(aktSprite.trembling == 0 ? 16 : aktSprite.trembling * CGFloat(8)))
                }
            }
        }
        lastUpdateSec = sec10
    }

    override func spriteDidCollideWithContainer(node1:MySKNode, node2:MySKNode) {
        let movingSprite = node1
        let container = node2
        
        var containerColorIndex = container.colorIndex
        let movingSpriteColorIndex = movingSprite.colorIndex
        
        
        if container.minValue == container.maxValue && container.maxValue == NoColor && movingSprite.maxValue == LastCardValue {
            var containerNotFound = true
            for index in 0..<countContainers {
                if containers[index].mySKNode.colorIndex == movingSpriteColorIndex {
                    containerNotFound = false
                }
            }
            if containerNotFound {
                push(container, status: .FirstCardAdded)
                containerColorIndex = movingSpriteColorIndex
                container.colorIndex = containerColorIndex
                container.texture = getTexture(containerColorIndex)
            }
        }
        
        let OK = movingSpriteColorIndex == containerColorIndex &&
        (
            container.minValue == NoColor ||
            movingSprite.maxValue + 1 == container.minValue ||
            movingSprite.minValue - 1 == container.maxValue ||
            (container.maxValue == LastCardValue && container.minValue == FirstCardValue && movingSprite.maxValue == LastCardValue)         )

        
        
        //print("spriteName: \(containerColorIndex), containerName: \(spriteColorIndex)")
        if OK  {
            push(container, status: .HitcounterChanged)
            push(movingSprite, status: .Removed)
            if container.maxValue < movingSprite.minValue {
                container.maxValue = movingSprite.maxValue
            } else {
                container.minValue = movingSprite.minValue
                if container.maxValue == NoColor {
                    container.maxValue = movingSprite.maxValue
                }
            }
            container.reload()
            //gameArray[movingSprite.column][movingSprite.row] = false
            movingSprite.removeFromParent()
            playSound("Container", volume: GV.soundVolume)
            countMovingSprites = 0
            
            updateSpriteCount(-1)
            
            collisionActive = false
            //movingSprite.removeFromParent()
            gameArray[movingSprite.column][movingSprite.row] = false
            checkGameFinished()
        } else {
            updateSpriteCount(-1)
            movingSprite.removeFromParent()
            countMovingSprites = 0
            push(movingSprite, status: .Removed)
            pull()
        }
        
     }

    override func spriteDidCollideWithMovingSprite(node1:MySKNode, node2:MySKNode) {
        let collisionsTime = NSDate()
        let timeInterval: Double = collisionsTime.timeIntervalSinceDate(lastCollisionsTime); // <<<<< Difference in seconds (double)

        if timeInterval < 1 {
            return
        }
        lastCollisionsTime = collisionsTime
        let movingSprite = node1
        let sprite = node2
        let movingSpriteColorIndex = movingSprite.colorIndex
        let spriteColorIndex = sprite.colorIndex
        
        //let aktColor = GV.colorSets[GV.colorSetIndex][sprite.colorIndex + 1].CGColor
        collisionActive = false
        
        let OK = movingSpriteColorIndex == spriteColorIndex &&
        (
            movingSprite.maxValue + 1 == sprite.minValue ||
            movingSprite.minValue - 1 == sprite.maxValue //||
        )
        if OK {
            push(sprite, status: .Unification)
            push(movingSprite, status: .Removed)
            
            if sprite.maxValue < movingSprite.minValue {
                sprite.maxValue = movingSprite.maxValue
            } else {
                sprite.minValue = movingSprite.minValue
            }
            sprite.reload()
            
            playSound("Sprite1", volume: GV.soundVolume)
            
            gameArray[movingSprite.column][movingSprite.row] = false
            movingSprite.removeFromParent()
            countMovingSprites = 0
            updateSpriteCount(-1)
//            spriteCount--
       } else {

            updateSpriteCount(-1)
            movingSprite.removeFromParent()
            countMovingSprites = 0
            push(movingSprite, status: .Removed)
            pull()
            
        }
        checkGameFinished()
    }

    override func checkGameFinished() {
        
        
        let usedCellCount = checkGameArray()
        let containersOK = checkContainers()
        
        if usedCellCount == 0 && containersOK { // Level completed, start a new game
            
            stopTimer()
            playMusic("Winner", volume: GV.musicVolume, loops: 0)
            
            let alert = getNextPlayArt(true)
            parentViewController!.presentViewController(alert, animated: true, completion: nil)
        }
        if usedCellCount <= minUsedCells {
            generateSprites(false)  // Nachgenerierung
        }
    }
    
    override func restartButtonPressed() {
        let alert = getNextPlayArt(false)
        parentViewController!.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func getNextPlayArt(congratulations: Bool)->UIAlertController {
        let playerName = GV.globalParam.aktName == GV.dummyName ? "!" : " " + GV.globalParam.aktName + "!"
//        var title = GV.language.getText(.TCChooseGame)
//        var message = GV.language.getText(TextConstants.TCCongratulations) + playerName
//        if congratulations {
//            title = GV.language.getText(.TCLevelComplete)
//        }
        let alert = UIAlertController(title: congratulations ? GV.language.getText(.TCLevelComplete) : GV.language.getText(.TCChooseGame),
            message: congratulations ? GV.language.getText(TextConstants.TCCongratulations) + playerName : "",
            preferredStyle: .Alert)
        let againAction = UIAlertAction(title: GV.language.getText(.TCGameAgain), style: .Default,
            handler: {(paramAction:UIAlertAction!) in
                self.newGame(false)
        })
        alert.addAction(againAction)
        let newGameAction = UIAlertAction(title: GV.language.getText(TextConstants.TCNewGame), style: .Default,
            handler: {(paramAction:UIAlertAction!) in
                self.newGame(true)
        })
        alert.addAction(newGameAction)
        if levelIndex > 0 {
            let easierAction = UIAlertAction(title: GV.language.getText(.TCPreviousLevel), style: .Default,
                handler: {(paramAction:UIAlertAction!) in
                    self.setLevel(self.previousLevel)
                    self.newGame(true)
            })
            alert.addAction(easierAction)
        }
        let complexerAction = UIAlertAction(title: GV.language.getText(TextConstants.TCNextLevel), style: .Default,
            handler: {(paramAction:UIAlertAction!) in
                self.setLevel(self.nextLevel)
                self.newGame(true)
        })
        alert.addAction(complexerAction)
        if !congratulations {
            let cancelAction = UIAlertAction(title: GV.language.getText(TextConstants.TCCancel), style: .Default,
                handler: {(paramAction:UIAlertAction!) in
//                    self.setLevel(self.nextLevel)
//                    self.newGame(true)
            })
            alert.addAction(cancelAction)
        }
        return alert
    }
    
    func setLevel(next: Bool) {
        if next {
            levelIndex = levelsForPlay.getNextLevel()
        } else {
            levelIndex = levelsForPlay.getPrevLevel()
        }
    }

    func checkContainers()->Bool {
        for index in 0..<containers.count {
            if containers[index].mySKNode.minValue != FirstCardValue || containers[index].mySKNode.maxValue % MaxCardValue != LastCardValue {
                return false
            }
            
        }
        return true

    }
    
    override func prepareContainers() {
        
        colorTab.removeAll(keepCapacity: false)
        var spriteName = 10000
        
        for cardIndex in 0..<countSpritesProContainer! * countPackages {
            for containerIndex in 0..<countContainers {
                let colorTabLine = ColorTabLine(colorIndex: containerIndex, spriteName: "\(spriteName++)",
                    spriteValue: cardArray[containerIndex][cardIndex % MaxCardValue].cardValue) //generateValue(containerIndex) - 1)
                colorTab.append(colorTabLine)
            }
        }
        
        createSpriteStack()

        
        let xDelta = size.width / CGFloat(countContainers)
        for index in 0..<countContainers {
            let centerX = (size.width / CGFloat(countContainers)) * CGFloat(index) + xDelta / 2
            let centerY = size.height * containersPosCorr.y
            let cont: Container
//            cont = Container(mySKNode: MySKNode(texture: getTexture(index), type: .ContainerType, value: getValueForContainer()), label: SKLabelNode(), countHits: 0)
            cont = Container(mySKNode: MySKNode(texture: getTexture(NoColor), type: .ContainerType, value: NoColor)) // getValueForContainer()))
            containers.append(cont)
            containers[index].mySKNode.name = "\(index)"
            containers[index].mySKNode.position = CGPoint(x: centerX, y: centerY)
            containers[index].mySKNode.size = CGSizeMake(containerSize.width, containerSize.height)
//            containers[index].mySKNode.size.width = containerSize.width
//            containers[index].mySKNode.size.height = containerSize.height
            
            containers[index].mySKNode.colorIndex = NoValue
            containers[index].mySKNode.physicsBody = SKPhysicsBody(circleOfRadius: containers[index].mySKNode.size.width / 3) // 1
            containers[index].mySKNode.physicsBody?.dynamic = true // 2
            containers[index].mySKNode.physicsBody?.categoryBitMask = PhysicsCategory.Container
            containers[index].mySKNode.physicsBody?.contactTestBitMask = PhysicsCategory.MovingSprite
            containers[index].mySKNode.physicsBody?.collisionBitMask = PhysicsCategory.None
            countColorsProContainer.append(countSpritesProContainer!)
            addChild(containers[index].mySKNode)
            containers[index].mySKNode.reload()
        }
    }
    
    


    override func pull() {
        let duration = 0.2
        var actionMoveArray = [SKAction]()
        if let savedSprite:SavedSprite  = stack.pull() {
            var savedSpriteInCycle = savedSprite
            var run = true
            var stopSoon = false
            
            repeat {
                
                switch savedSpriteInCycle.status {
                case .Added: break
                case .AddedFromCardStack:
                    if stack.countChangesInStack() > 0 {
                        let spriteName = savedSpriteInCycle.name
//                        let colorIndex = savedSpriteInCycle.colorIndex
                        let searchName = "\(spriteName)"
                        let cardToPush = self.childNodeWithName(searchName)! as! MySKNode
                        cardStack.push(cardToPush)
                        self.childNodeWithName(searchName)!.removeFromParent()
//                        let colorTabLine = ColorTabLine(colorIndex: colorIndex, spriteName: spriteName, spriteValue: savedSpriteInCycle.minValue)
//                        colorTab.append(colorTabLine)
                        gameArray[savedSpriteInCycle.column][savedSpriteInCycle.row] = false
                    }
                case .AddedFromShowCard:
                    if cardPlaceButtonAddedToParent {
                        cardPlaceButton?.removeFromParent()
                        cardPlaceButtonAddedToParent = false
                    }
                    if showCard != nil {
                        showCardStack.push(showCard!)
                        showCard!.removeFromParent()
                        showCard = nil
                    }
                    let spriteName = savedSpriteInCycle.name
                    let searchName = "\(spriteName)"
                    showCard = self.childNodeWithName(searchName)! as? MySKNode
                    showCard!.position = (cardPlaceButton?.position)!
                    showCard!.size = (cardPlaceButton?.size)!
                    showCard!.type = .ShowCardType
                    self.childNodeWithName(searchName)!.removeFromParent()
                    self.addChild(showCard!)
                    gameArray[savedSpriteInCycle.column][savedSpriteInCycle.row] = false
                    makeEmptyCard(savedSpriteInCycle.column, row: savedSpriteInCycle.row)
                case .Removed:
                    //let spriteTexture = SKTexture(imageNamed: "sprite\(savedSpriteInCycle.colorIndex)")
                    let spriteTexture = getTexture(savedSpriteInCycle.colorIndex)
                    let sprite = MySKNode(texture: spriteTexture, type: .SpriteType, value: savedSpriteInCycle.minValue) //NoValue)
                    
                    
                    sprite.colorIndex = savedSpriteInCycle.colorIndex
                    sprite.position = savedSpriteInCycle.endPosition
                    sprite.startPosition = savedSpriteInCycle.startPosition
                    sprite.size = savedSpriteInCycle.size
                    sprite.column = savedSpriteInCycle.column
                    sprite.row = savedSpriteInCycle.row
                    sprite.minValue = savedSpriteInCycle.minValue
                    sprite.maxValue = savedSpriteInCycle.maxValue
                    sprite.BGPictureAdded = savedSpriteInCycle.BGPictureAdded
                    sprite.name = savedSpriteInCycle.name
                    gameArray[savedSpriteInCycle.column][savedSpriteInCycle.row] = true
                    addPhysicsBody(sprite)
                    self.addChild(sprite)
                    updateSpriteCount(1)
                    sprite.reload()
                    
                case .Unification:
                    let sprite = self.childNodeWithName(savedSpriteInCycle.name)! as! MySKNode
                    sprite.size = savedSpriteInCycle.size
                    sprite.minValue = savedSpriteInCycle.minValue
                    sprite.maxValue = savedSpriteInCycle.maxValue
                    sprite.BGPictureAdded = savedSpriteInCycle.BGPictureAdded
                    //sprite.hitLabel.text = "\(sprite.hitCounter)"
                    sprite.reload()
                    
                case .HitcounterChanged:
                    
                    let container = containers[findIndex(savedSpriteInCycle.colorIndex)].mySKNode
                    container.minValue = savedSpriteInCycle.minValue
                    container.maxValue = savedSpriteInCycle.maxValue
                    container.BGPictureAdded = savedSpriteInCycle.BGPictureAdded
                    container.reload()
                    showScore()
                    
                case .FirstCardAdded:
                    let container = containers[findIndex(savedSpriteInCycle.colorIndex)].mySKNode
                    container.minValue = savedSpriteInCycle.minValue
                    container.maxValue = savedSpriteInCycle.maxValue
                    container.BGPictureAdded = savedSpriteInCycle.BGPictureAdded
                    container.colorIndex = NoColor
                    container.reload()
                    
                    
                case .MovingStarted:
                    let sprite = self.childNodeWithName(savedSpriteInCycle.name)! as! MySKNode
                    sprite.startPosition = savedSpriteInCycle.startPosition
                    sprite.minValue = savedSpriteInCycle.minValue
                    sprite.maxValue = savedSpriteInCycle.maxValue
                    sprite.BGPictureAdded = savedSpriteInCycle.BGPictureAdded
                    actionMoveArray.append(SKAction.moveTo(savedSpriteInCycle.endPosition, duration: duration))
                    sprite.runAction(SKAction.sequence(actionMoveArray))
                    let column = sprite.column
                    let row = sprite.row
                    if self.childNodeWithName("\(emptySpriteTxt)-\(column)-\(row)") != nil {
                        self.childNodeWithName("\(emptySpriteTxt)-\(column)-\(row)")!.removeFromParent()
                    }
                    sprite.reload()
                    
                case .FallingMovingSprite:
//                    let sprite = self.childNodeWithName(savedSpriteInCycle.name)! as! MySKNode
                    actionMoveArray.append(SKAction.moveTo(savedSpriteInCycle.endPosition, duration: duration))
                    
                case .FallingSprite:
                    let sprite = self.childNodeWithName(savedSpriteInCycle.name)! as! MySKNode
                    sprite.startPosition = savedSpriteInCycle.startPosition
                    let moveFallingSprite = SKAction.moveTo(savedSpriteInCycle.startPosition, duration: duration)
                    sprite.runAction(SKAction.sequence([moveFallingSprite]))
                    
                case .Mirrored:
                    //var sprite = self.childNodeWithName(savedSpriteInCycle.name)! as! MySKNode
                    actionMoveArray.append(SKAction.moveTo(savedSpriteInCycle.endPosition, duration: duration))
                case .Exchanged:
                    let sprite = self.childNodeWithName(savedSpriteInCycle.name)! as! MySKNode
                    let savedSprite:SavedSprite = stack.pull()!
                    let sprite1 = self.childNodeWithName(savedSprite.name) as! MySKNode
                    
                    sprite.startPosition = savedSpriteInCycle.startPosition
                    sprite.minValue = savedSpriteInCycle.minValue
                    sprite.maxValue = savedSpriteInCycle.maxValue
                    sprite.BGPictureAdded = savedSpriteInCycle.BGPictureAdded
                    
                    sprite1.startPosition = savedSprite.startPosition
                    sprite1.minValue = savedSprite.minValue
                    sprite1.maxValue = savedSprite.maxValue
                    sprite1.BGPictureAdded = savedSprite.BGPictureAdded

                    let action = SKAction.moveTo(sprite.startPosition, duration: 1.0)
                    let action1 = SKAction.moveTo(sprite1.startPosition, duration: 1.0)

                    sprite.runAction(SKAction.sequence([action]))
                    sprite1.runAction(SKAction.sequence([action1]))
                    
                    sprite.reload()
                    sprite1.reload()
                    savedSpriteInCycle = savedSprite
                    stopSoon = true
                case .Nothing: break
                }
                if let savedSprite:SavedSprite = stack.pull() {
                    savedSpriteInCycle = savedSprite
                    if ((savedSpriteInCycle.status == .AddedFromCardStack || savedSpriteInCycle.status == .AddedFromShowCard) && stack.countChangesInStack() == 0) || stopSoon {
                        stack.push(savedSpriteInCycle)
                        run = false
                    }
                    if savedSpriteInCycle.status == .MovingStarted {
                        stopSoon = true
                    }
                } else {
                    run = false
                }
            } while run
            showScore()
        }
        
        
        
    }
    
    func findIndex(colorIndex: Int)->Int {
        for index in 0..<countContainers {
            if containers[index].mySKNode.colorIndex == colorIndex {
                return index
            }
        }
        return NoColor
    }
    
    override func readNextLevel() -> Int {
        return levelsForPlay.getNextLevel()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //        if inFirstGenerateSprites {
        //            return
        //        }
        if movedFromNode != nil {
            while self.childNodeWithName("myLine") != nil {
                self.childNodeWithName("myLine")!.removeFromParent()
            }
            while self.childNodeWithName("nodeOnTheWall") != nil {
                self.childNodeWithName("nodeOnTheWall")!.removeFromParent()
            }
            //let countTouches = touches.count
            let firstTouch = touches.first
            let touchLocation = firstTouch!.locationInNode(self)
            let testNode = self.nodeAtPoint(touchLocation)
            let aktNodeType = analyzeNode(testNode)
            var aktNode: SKNode? = movedFromNode
            switch aktNodeType {
                case MyNodeTypes.LabelNode: aktNode = self.nodeAtPoint(touchLocation).parent as! MySKNode
                case MyNodeTypes.SpriteNode: aktNode = self.nodeAtPoint(touchLocation) as! MySKNode
                case MyNodeTypes.ButtonNode: aktNode = self.nodeAtPoint(touchLocation) as! MySKNode
                default: aktNode = nil
            }
            if movedFromNode != aktNode && !exchangeModus {
                if movedFromNode.type == .ButtonType {
                    //movedFromNode.texture = atlas.textureNamed("\(movedFromNode.name!)")
                } else if movedFromNode.type == .ShowCardType {
                    movedFromNode.position = touchLocation
                } else if movedFromNode.type == .EmptyCardType {
                    
                } else {
                    let line = JGXLine(fromPoint: movedFromNode.position, toPoint: touchLocation, inFrame: self.frame, lineSize: movedFromNode.size.width)
                    let pointOnTheWall = line.line.toPoint
                    makeHelpLine(movedFromNode.position, toPoint: pointOnTheWall, lineWidth: movedFromNode.size.width, numberOfLine: 1)
                    
                    
                    if GV.showHelpLines > 1 {
                        let mirroredLine1 = line.createMirroredLine()
                        makeHelpLine(mirroredLine1.line.fromPoint, toPoint: mirroredLine1.line.toPoint, lineWidth: movedFromNode.size.width, numberOfLine: 2)
                        
                        if GV.showHelpLines > 2 {
                            let mirroredLine2 = mirroredLine1.createMirroredLine()
                            makeHelpLine(mirroredLine2.line.fromPoint, toPoint: mirroredLine2.line.toPoint, lineWidth: movedFromNode.size.width, numberOfLine: 3)
                            
                            if GV.showHelpLines > 3 {
                                let mirroredLine3 = mirroredLine2.createMirroredLine()
                                makeHelpLine(mirroredLine3.line.fromPoint, toPoint: mirroredLine3.line.toPoint, lineWidth: movedFromNode.size.width, numberOfLine: 4)
                            }
                        }
                    }
                }
            }
            
            if showFingerNode {
                
                if let fingerNode = self.childNodeWithName("finger")! as? SKSpriteNode {
                    fingerNode.position = touchLocation
                }
                
            }
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        while self.childNodeWithName("myLine") != nil {
            self.childNodeWithName("myLine")!.removeFromParent()
        }
        while self.childNodeWithName("nodeOnTheWall") != nil {
            self.childNodeWithName("nodeOnTheWall")!.removeFromParent()
        }
        let firstTouch = touches.first
        let touchLocation = firstTouch!.locationInNode(self)
        let testNode = self.nodeAtPoint(touchLocation)
        
        let aktNodeType = analyzeNode(testNode)
        //        if self.inFirstGenerateSprites {
        //            switch aktNodeType {
        //            case MyNodeTypes.LabelNode, MyNodeTypes.SpriteNode: showNextSprite(touchLocation)
        //            default: return
        //            }
        //            return
        //        }
        if movedFromNode != nil && !stopped {
            //let countTouches = touches.count
            var aktNode: MySKNode?
            
            let startNode = movedFromNode
            
            switch aktNodeType {
            case MyNodeTypes.LabelNode: aktNode = self.nodeAtPoint(touchLocation).parent as? MySKNode
            case MyNodeTypes.SpriteNode: aktNode = self.nodeAtPoint(touchLocation) as? MySKNode
            case MyNodeTypes.ButtonNode:
                //(testNode as! MySKNode).texture = SKTexture(imageNamed: "\(testNode.name!)")
                //(testNode as! MySKNode).texture = atlas.textureNamed("\(testNode.name!)")
                aktNode = self.nodeAtPoint(touchLocation) as? MySKNode
            default: aktNode = nil
            }
            
            if showFingerNode {
                
                if let fingerNode = self.childNodeWithName("finger")! as? SKSpriteNode {
                    fingerNode.removeFromParent()
                }
                
            }
            if aktNode != nil && aktNode!.type == .ButtonType && startNode.type == .ButtonType  {
                //            if aktNode != nil && mySKNode.type == .ButtonType && startNode.type == .ButtonType  {
                var mySKNode = aktNode!
                
                //                var name = (aktNode as! MySKNode).parent!.name
                if mySKNode.name == buttonName {
                    mySKNode = (mySKNode.parent) as! MySKNode
                }
                //switch (aktNode as! MySKNode).name! {
                switch mySKNode.name! {
                case "settings": settingsButtonPressed()
                case "undo": undoButtonPressed()
                case "exchange": exchangeButtonPressed()
                case "restart": restartButtonPressed()
                default: specialButtonPressed(mySKNode.name!)
                }
                return
            }
            
            if exchangeModus {
                let myAktNode = aktNode!
                if startNode != nil && startNode != myAktNode && myAktNode.type == .SpriteType {
                    let column = startNode.column
                    let row = startNode.row
                    let startPosition = startNode.startPosition
                    
                    push(startNode, sprite2: aktNode!)
                    startNode.zPosition = 5
                    myAktNode.zPosition = 4
                    let actionMove1 = SKAction.moveTo(startNode.position, duration: 1.0)
                    myAktNode.runAction(SKAction.sequence([actionMove1]))
                    let actionMove2 = SKAction.moveTo(myAktNode.position, duration: 1.0)
                    startNode.runAction(SKAction.sequence([actionMove2]))
                    
                    startNode.column = aktNode!.column
                    startNode.row = aktNode!.row
                    startNode.startPosition = aktNode!.startPosition
                    
                    aktNode!.column = column
                    aktNode!.row = row
                    aktNode!.startPosition = startPosition
                    
                }
                for index in 0..<tremblingSprites.count {
                    tremblingSprites[index].size = tremblingSprites[index].origSize
                    tremblingSprites[index].tremblingType = .NoTrembling
                    tremblingSprites[index].zRotation = 0
                    tremblingSprites[index].zPosition = 0
                }
                tremblingSprites.removeAll()
                exchangeModus = false
                return
            }
            
            
            if startNode.type == .SpriteType && (aktNode == nil || aktNode! != movedFromNode) {
                let sprite = movedFromNode// as! SKSpriteNode
                
                
                sprite!.physicsBody = SKPhysicsBody(circleOfRadius: sprite!.size.width/2)
                sprite.physicsBody?.dynamic = true
                sprite.physicsBody?.categoryBitMask = PhysicsCategory.MovingSprite
                sprite.physicsBody?.contactTestBitMask = PhysicsCategory.Sprite | PhysicsCategory.Container //| PhysicsCategory.WallAround
                sprite.physicsBody?.collisionBitMask = PhysicsCategory.None
                //sprite.physicsBody?.velocity=CGVectorMake(200, 200)
                
                sprite.physicsBody?.usesPreciseCollisionDetection = true
                /*
                let offset = touchLocation - movedFromNode.position
                
                let direction = offset.normalized()
                
                // 7 - Make it shoot far enough to be guaranteed off screen
                let shootAmount = direction * 1000
                
                // 8 - Add the shoot amount to the current position
                let realDest = shootAmount + movedFromNode.position
                */
                push(sprite, status: .MovingStarted)
                
                // 9 - Create the actions
                let line = JGXLine(fromPoint: movedFromNode.position, toPoint: touchLocation, inFrame: self.frame, lineSize: movedFromNode.size.width)
                let pointOnTheWall = line.line.toPoint
                
                let mirroredLine1 = line.createMirroredLine()
                let pointOnTheWall1 = mirroredLine1.line.toPoint
                
                let mirroredLine2 = mirroredLine1.createMirroredLine()
                let pointOnTheWall2 = mirroredLine2.line.toPoint
                
                let mirroredLine3 = mirroredLine2.createMirroredLine()
                let pointOnTheWall3 = mirroredLine3.line.toPoint
                
                let countAndPushAction = SKAction.runBlock({
                    self.push(sprite, status: .Mirrored)
                    sprite.hitCounter *= 2
                    sprite.hitLabel.text = "\(sprite.hitCounter)"
                })
                
                
                
                let actionMove = SKAction.moveTo(pointOnTheWall, duration: line.duration)
                
                let actionEmpty = SKAction.runBlock({
                    self.makeEmptyCard(sprite.column, row: sprite.row)
                })
                
                let actionMove1 = SKAction.moveTo(pointOnTheWall1, duration: mirroredLine1.duration)
                
                let actionMove2 = SKAction.moveTo(pointOnTheWall2, duration: mirroredLine2.duration)
                
                let actionMove3 = SKAction.moveTo(pointOnTheWall3, duration: mirroredLine3.duration)
                
                
                //                let waitSparkAction = SKAction.runBlock({
                //                    sprite.hidden = true
                //                    sleep(0)
                //                    sprite.removeFromParent()
                //                })
                //
                let actionMoveStopped =  SKAction.runBlock({
                    self.push(sprite, status: .Removed)
                    sprite.hidden = true
                    self.gameArray[sprite.column][sprite.row] = false
                    //sprite.size = CGSizeMake(sprite.size.width / 3, sprite.size.height / 3)
                    sprite.colorBlendFactor = 4
                    self.playSound("Drop", volume: GV.soundVolume)
                    sprite.removeFromParent()
                    //                    let sparkEmitter = SKEmitterNode(fileNamed: "MyParticle.sks")
                    //                    sparkEmitter?.position = sprite.position
                    //                    sparkEmitter?.zPosition = 1
                    //                    sparkEmitter?.particleLifetime = 1
                    //                    let emitterDuration = CGFloat(sparkEmitter!.numParticlesToEmit) * sparkEmitter!.particleLifetime
                    //
                    //                    let wait = SKAction.waitForDuration(NSTimeInterval(emitterDuration))
                    //
                    //                    let remove = SKAction.runBlock({sparkEmitter!.removeFromParent()/*; print("Emitter removed")*/})
                    //                    sparkEmitter!.runAction(SKAction.sequence([wait, remove]))
                    //                    self.addChild(sparkEmitter!)
                    self.pull()
                    self.userInteractionEnabled = true
                    
                    
                })
                
                
                
                
                //let actionMoveDone = SKAction.removeFromParent()
                collisionActive = true
                lastMirrored = ""
                
                self.userInteractionEnabled = false  // userInteraction forbidden!
                countMovingSprites = 1
                self.waitForSKActionEnded = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("checkCountMovingSprites"), userInfo: nil, repeats: false) // start timer for check
                
                movedFromNode.runAction(SKAction.sequence([actionEmpty, actionMove, countAndPushAction, actionMove1, countAndPushAction, actionMove2, countAndPushAction, actionMove3, actionMoveStopped//,
                    /*waitSparkAction*/]))
                //actionMoveDone]))
            } else if startNode.type == .ShowCardType {
                var foundedCard: MySKNode?
                let nodes = self.nodesAtPoint(touchLocation)
                for index in 0..<nodes.count {
                    if nodes[index] is MySKNode && (nodes[index] as! MySKNode).type == .EmptyCardType {
                        foundedCard = nodes[index] as? MySKNode
                        startNode.size = foundedCard!.size
                        startNode.position = foundedCard!.position
                        startNode.type = .SpriteType
                        startNode.column = foundedCard!.column
                        startNode.row = foundedCard!.row
                        gameArray[startNode.column][startNode.row] = true
                        addPhysicsBody(startNode)
//                        push(startNode, status: .MovingStarted)
                        push(startNode, status: .AddedFromShowCard)
                        foundedCard!.removeFromParent()
                        showCard = nil
                        if showCardStack.count(.MySKNodeType) > 0 {
                            showCard = showCardStack.pull()
                            self.addChild(showCard!)
                        } else {
                            addChild(cardPlaceButton!)
                            cardPlaceButtonAddedToParent = true
                        }
                        break
                    }
                }
                
            }
            
        }
    }


}
