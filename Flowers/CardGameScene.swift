
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
    
    struct Founded {
        let maxDistance: CGFloat = 100000.0
        var point: CGPoint
        var column: Int
        var row: Int
        var foundContainer: Bool
        var distanceToP1: CGFloat
        var distanceToP0: CGFloat
        init(column: Int, row: Int, foundContainer: Bool, point: CGPoint, distanceToP1: CGFloat, distanceToP0: CGFloat) {
            self.distanceToP1 = distanceToP1
            self.distanceToP0 = distanceToP0
            self.column = column
            self.row = row
            self.foundContainer = foundContainer
            self.point = point
        }
        init() {
            self.distanceToP1 = maxDistance
            self.distanceToP0 = maxDistance
            self.point = CGPointMake(0, 0)
            self.column = 0
            self.row = 0
            self.foundContainer = false
        }
    }
    

    
    let emptySpriteTxt = "emptySprite"
    
    var cardStack:Stack<MySKNode> = Stack()
    var showCardStack:Stack<MySKNode> = Stack()
    
    var cardPackege: MySKButton?
    var cardPlaceButton: MySKButton?
    var cardPlaceButtonAddedToParent = false
    var cardToChange: MySKNode?
    
    var showCard: MySKNode?
    var showCardFromStack: MySKNode?
    var showCardFromStackAddedToParent = false

    var lastCollisionsTime = NSDate()
    var cardArray: [[GenerateCard]] = []
//    var valueTab = [Int]()
    let spriteCountPosKorr = CGPointMake(GV.onIpad ? 0.05 : 0.05, GV.onIpad ? 0.95 : 0.95)
    var levelsForPlay = LevelsForPlayWithCards()
    var countPackages = 0
    let nextLevel = true
    let previousLevel = false
    var lastUpdateSec = 0
    var lastClosestPoint: Founded?
    //var gameArrayPositions = [[GameArrayPositions]]()
    
    
    var tapLocation: CGPoint?

    override func getTexture(index: Int)->SKTexture {
        if index == NoColor {
            return atlas.textureNamed("emptycard")
        } else {
            return atlas.textureNamed ("card\(index)")
        }
    }
    override func makeSpezialThings(first: Bool) {
//        let multiplier = GV.deviceConstants.sizeMultiplier
        let width:CGFloat = 64.0
        let height: CGFloat = 89.0
        sizeMultiplier = CGSizeMake(GV.deviceConstants.sizeMultiplier, GV.deviceConstants.sizeMultiplier * height / width)
        buttonSizeMultiplier = CGSizeMake(GV.deviceConstants.buttonSizeMultiplier, GV.deviceConstants.buttonSizeMultiplier * height / width)
        levelsForPlay.setAktLevel(levelIndex)
    }
        
    override func specialPrepareFuncFirst() {
        let cardSize = CGSizeMake(buttonSize * sizeMultiplier.width * 0.8, buttonSize * sizeMultiplier.height * 0.8)
        let cardPackageButtonTexture = SKTexture(image: images.getCardPackage())
        cardPackege = MySKButton(texture: cardPackageButtonTexture, frame: CGRectMake(buttonXPosNormalized * 5.0, buttonYPos, cardSize.width, cardSize.height), makePicture: false)
        cardPackege!.name = "cardPackege"
        addChild(cardPackege!)
        
        showCardFromStack = nil
        
        let cardPlaceTexture = SKTexture(imageNamed: "emptycard")
        cardPlaceButton = MySKButton(texture: cardPlaceTexture, frame: CGRectMake(buttonXPosNormalized * 7.0, buttonYPos, cardSize.width, cardSize.height), makePicture: false)
        cardPlaceButton!.name = "cardPlace"
        addChild(cardPlaceButton!)
        cardPlaceButton!.alpha = 0.3
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
        //gameArrayPositions.removeAll(keepCapacity: false)
        tableCellSize = spriteTabRect.width / CGFloat(countColumns)
        
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
    
    func fillEmptySprites() {
        for column in 0..<countColumns {
            for row in 0..<countRows {
                makeEmptyCard(column, row: row)
            }
        }
    }

    override func generateSprites(first: Bool) {
        var positionsTab = [(Int, Int)]() // all available Positions
        for column in 0..<countColumns {
            for row in 0..<countRows {
                if !gameArray[column][row].used {
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
            
            let index = random!.getRandomInt(0, max: positionsTab.count - 1)
            let (aktColumn, aktRow) = positionsTab[index]
            
//            let xPosition = spriteTabRect.origin.x - spriteTabRect.size.width / 2 + CGFloat(aktColumn) * tableCellSize + tableCellSize / 2
//            let yPosition = spriteTabRect.origin.y - spriteTabRect.size.height / 2 + tableCellSize * 1.10 / 2 + CGFloat(aktRow) * tableCellSize * 1.10
            let zielPosition = gameArray[aktColumn][aktRow].position
            sprite.position = cardPackege!.position
            sprite.startPosition = zielPosition
            gameArray[aktColumn][aktRow].used = true
            positionsTab.removeAtIndex(index)
            
            sprite.column = aktColumn
            sprite.row = aktRow
            
//            sprite.colorIndex = colorIndex
//            sprite.name = spriteName
            
            sprite.size = CGSizeMake(spriteSize.width, spriteSize.height)
            
            addPhysicsBody(sprite)
            push(sprite, status: .AddedFromCardStack)
            addChild(sprite)
            let actionMove = SKAction.moveTo(zielPosition, duration: 1.5)
            let actionHideEmptyCard = SKAction.runBlock({
                self.deleteEmptySprite(aktColumn, row: aktRow)
            })
            sprite.runAction(SKAction.sequence([actionMove, actionHideEmptyCard]))
            if cardStack.count(.MySKNodeType) == 0 {
                cardPackege!.changeButtonPicture(SKTexture(imageNamed: "emptycard"))
                cardPackege!.alpha = 0.3
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
//            let xPosition = spriteTabRect.origin.x - spriteTabRect.size.width / 2 + CGFloat(column) * tableCellSize + tableCellSize / 2
//            let yPosition = spriteTabRect.origin.y - spriteTabRect.size.height / 2 + tableCellSize * 1.10 / 2 + CGFloat(row) * tableCellSize * 1.10
            let emptySprite = MySKNode(texture: getTexture(NoColor), type: .EmptyCardType, value: NoColor)
            emptySprite.position = gameArray[column][row].position
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
                if cardStack.count(.MySKNodeType) == 0 {
                    cardPackege!.changeButtonPicture(SKTexture(imageNamed: "emptycard"))
                    cardPackege!.alpha = 0.3
                }
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
                    case .ChangeSizeOnce:
                        if aktSprite.size == aktSprite.origSize {
                            aktSprite.size.width += adder
                            aktSprite.size.height += adder
                        }
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
                containerColorIndex = movingSpriteColorIndex
                container.colorIndex = containerColorIndex
                container.texture = getTexture(containerColorIndex)
                push(container, status: .FirstCardAdded)
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
            gameArray[movingSprite.column][movingSprite.row].used = false
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
            
            gameArray[movingSprite.column][movingSprite.row].used = false
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
        if levelIndex < levelsForPlay.levelParam.count - 1 {
            let complexerAction = UIAlertAction(title: GV.language.getText(TextConstants.TCNextLevel), style: .Default,
                handler: {(paramAction:UIAlertAction!) in
                    self.setLevel(self.nextLevel)
                    self.newGame(true)
            })
            alert.addAction(complexerAction)
        }
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
        fillEmptySprites()

        
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
                        gameArray[savedSpriteInCycle.column][savedSpriteInCycle.row].used = false
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
                    showCard!.position = savedSpriteInCycle.endPosition //(cardPlaceButton?.position)!
                    showCard!.size = (cardPlaceButton?.size)!
                    showCard!.type = .ShowCardType
                    self.childNodeWithName(searchName)!.removeFromParent()
                    self.addChild(showCard!)
                    gameArray[savedSpriteInCycle.column][savedSpriteInCycle.row].used = false
                    makeEmptyCard(savedSpriteInCycle.column, row: savedSpriteInCycle.row)
                    let actionMove = SKAction.moveTo(cardPlaceButton!.position, duration: 0.5)
                    showCard!.runAction(actionMove)
                case .Removed:
                    //let spriteTexture = SKTexture(imageNamed: "sprite\(savedSpriteInCycle.colorIndex)")
                    let spriteTexture = getTexture(savedSpriteInCycle.colorIndex)
                    let type = savedSpriteInCycle.type
                    let sprite = MySKNode(texture: spriteTexture, type: type, value: savedSpriteInCycle.minValue) //NoValue)
                    
                    
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
                    gameArray[savedSpriteInCycle.column][savedSpriteInCycle.row].used = true
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
                    actionMoveArray.append(SKAction.runBlock({
                        if self.childNodeWithName("\(self.emptySpriteTxt)-\(sprite.column)-\(sprite.row)") != nil {
                            self.childNodeWithName("\(self.emptySpriteTxt)-\(sprite.column)-\(sprite.row)")!.removeFromParent()
                        }
                    }))
                    sprite.zPosition = 50
                    sprite.runAction(SKAction.sequence(actionMoveArray))
//                    let column = sprite.column
//                    let row = sprite.row
//                    if self.childNodeWithName("\(emptySpriteTxt)-\(column)-\(row)") != nil {
//                        self.childNodeWithName("\(emptySpriteTxt)-\(column)-\(row)")!.removeFromParent()
//                    }
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
                case .StopCycle: break
                case .Nothing: break
                }
                if let savedSprite:SavedSprite = stack.pull() {
                    savedSpriteInCycle = savedSprite
                    if ((savedSpriteInCycle.status == .AddedFromCardStack || savedSpriteInCycle.status == .AddedFromShowCard) && stack.countChangesInStack() == 0) || stopSoon  || savedSpriteInCycle.status == .StopCycle {
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
            if movedFromNode.type == .ShowCardType {
                movedFromNode.position = touchLocation
                if showCardStack.count(.MySKNodeType) > 0 {
                    if !showCardFromStackAddedToParent {
                        showCardFromStackAddedToParent = true
                        showCardFromStack = showCardStack.last()
                        showCardFromStack!.position = cardPlaceButton!.position
                        showCardFromStack!.size = cardPlaceButton!.size
                        addChild(showCardFromStack!)
                    }
                } else if !cardPlaceButtonAddedToParent {
                    cardPlaceButtonAddedToParent = true
                    addChild(cardPlaceButton!)
                }
            }  else if movedFromNode == aktNode && tremblingSprites.count > 0 { // stop trembling
                for index in 0..<tremblingSprites.count {
                    tremblingSprites[index].tremblingType = .NoTrembling
                }
                tremblingSprites.removeAll()
                lastClosestPoint = nil
            } else if movedFromNode != aktNode && !exchangeModus {
                if movedFromNode.type == .ButtonType {
                    //movedFromNode.texture = atlas.textureNamed("\(movedFromNode.name!)")
                } else if movedFromNode.type == .EmptyCardType {
                    
                } else {
                    var founded = false
                    let line = JGXLine(fromPoint: movedFromNode.position, toPoint: touchLocation, inFrame: self.frame, lineSize: movedFromNode.size.width)
                    let pointOnTheWall = line.line.toPoint
                    founded = makeHelpLine(movedFromNode.position, toPoint: pointOnTheWall, lineWidth: movedFromNode.size.width, numberOfLine: 1)
                    
                    
                    if !founded && GV.showHelpLines > 1 {
                        let mirroredLine1 = line.createMirroredLine()
                        founded = makeHelpLine(mirroredLine1.line.fromPoint, toPoint: mirroredLine1.line.toPoint, lineWidth: movedFromNode.size.width, numberOfLine: 2)
                        
                        if !founded && GV.showHelpLines > 2 {
                            let mirroredLine2 = mirroredLine1.createMirroredLine()
                            founded = makeHelpLine(mirroredLine2.line.fromPoint, toPoint: mirroredLine2.line.toPoint, lineWidth: movedFromNode.size.width, numberOfLine: 3)
                            
                            if !founded && GV.showHelpLines > 3 {
                                let mirroredLine3 = mirroredLine2.createMirroredLine()
                                founded = makeHelpLine(mirroredLine3.line.fromPoint, toPoint: mirroredLine3.line.toPoint, lineWidth: movedFromNode.size.width, numberOfLine: 4)
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
    
    override func makeHelpLine(fromPoint: CGPoint, toPoint: CGPoint, lineWidth: CGFloat, numberOfLine: Int)->Bool {

        var toPoint = toPoint
        var pointFounded = false
        if let closestPoint = findClosestPoint(fromPoint, P2: toPoint, lineWidth: lineWidth, movedFrom: movedFromNode) {
            toPoint = closestPoint.point //gameArray[closestPoint.column][closestPoint.row].position
            var tremblingCardPosition = CGPointZero
            if lastClosestPoint != nil && ((lastClosestPoint!.column != closestPoint.column) ||  (lastClosestPoint!.row != closestPoint.row)) {
                if lastClosestPoint!.foundContainer {
                   tremblingCardPosition = containers[lastClosestPoint!.column].mySKNode.position
                } else {
                   tremblingCardPosition = gameArray[lastClosestPoint!.column][lastClosestPoint!.row].position
                }
                let nodes = nodesAtPoint(tremblingCardPosition)
                for index in 0..<nodes.count {
                    if nodes[index] is MySKNode {
                        (nodes[index] as! MySKNode).tremblingType = .NoTrembling
                        tremblingSprites.removeAll()
                    }
                }
                lastClosestPoint = nil
            }
            if lastClosestPoint == nil {
                if closestPoint.foundContainer {
                    tremblingCardPosition = containers[closestPoint.column].mySKNode.position
                } else {
                    tremblingCardPosition = gameArray[closestPoint.column][closestPoint.row].position
                }
                let nodes = nodesAtPoint(tremblingCardPosition)
                for index in 0..<nodes.count {
                    if nodes[index] is MySKNode {
                        tremblingSprites.append(nodes[index] as! MySKNode)
                        (nodes[index] as! MySKNode).tremblingType = .ChangeSize
                    }
                }
                lastClosestPoint = closestPoint
            }
            pointFounded = true
        }
        
        
        let pathToDraw:CGMutablePathRef = CGPathCreateMutable()
        let myLine:SKShapeNode = SKShapeNode(path:pathToDraw)
        myLine.lineWidth = lineWidth / 5
        
        myLine.name = "myLine"
        CGPathMoveToPoint(pathToDraw, nil, fromPoint.x, fromPoint.y)
//        CGPathAddLineToPoint(pathToDraw, nil, realDest.x, realDest.y)
        CGPathAddLineToPoint(pathToDraw, nil, toPoint.x, toPoint.y)
        
        myLine.path = pathToDraw
    
        myLine.strokeColor = SKColor(red: 1.0, green: 0, blue: 0, alpha: 0.5) // GV.colorSets[GV.colorSetIndex][colorIndex + 1]
        myLine.zPosition = 50
        
        
        self.addChild(myLine)
        return pointFounded
        
    }
    
    func findClosestPoint(P1: CGPoint, P2: CGPoint, lineWidth: CGFloat, movedFrom: MySKNode?) -> Founded? {
        
/*
        Ax+By=C  - Equation of a line
        Line is given with 2 Points (x1, y1) and (x2, y2)
        A = y2-y1
        B = x1-x2
        C = A*x1+B*y1
*/
        //let offset = P1 - P2
        var founded = Founded()
        
        for column in 0..<countColumns {
            for row in 0..<countRows {
                if gameArray[column][row].used {
                    let P0 = gameArray[column][row].position
//                    if (P0 - P1).length() > lineWidth { // check all others but not me!!!
                    if !(movedFrom!.column == column && movedFrom!.row == row) {
                        let intersectionPoint = findIntersectionPoint(P1, b:P2, c:P0)
                        
                        let distanceToP0 = (intersectionPoint - P0).length()
                        let distanceToP1 = (intersectionPoint - P1).length()
                        let distanceToP2 = (intersectionPoint - P2).length()
                        let lengthOfLineSegment = (P1 - P2).length()
                        
                        if distanceToP0 < lineWidth && distanceToP2 < lengthOfLineSegment {
                            if founded.distanceToP1 > distanceToP1 {
                                founded.point = intersectionPoint
                                founded.distanceToP1 = distanceToP1
                                founded.distanceToP0 = distanceToP0
                                founded.column = column
                                founded.row = row
                                founded.foundContainer = false
                            }
                        }
                    }
                }
            }
        }
        
        for index in 0..<countContainers {
            let P0 = containers[index].mySKNode.position
            if (P0 - P1).length() > lineWidth { // check all others but not me!!!
                let intersectionPoint = findIntersectionPoint(P1, b:P2, c:P0)
                
                let distanceToP0 = (intersectionPoint - P0).length()
                let distanceToP1 = (intersectionPoint - P1).length()
                let distanceToP2 = (intersectionPoint - P2).length()
                let lengthOfLineSegment = (P1 - P2).length()
                
                if distanceToP0 < lineWidth && distanceToP2 < lengthOfLineSegment {
                    if founded.distanceToP1 > distanceToP1 {
                        founded.point = intersectionPoint
                        founded.distanceToP1 = distanceToP1
                        founded.distanceToP0 = distanceToP0
                        founded.column = index
                        founded.foundContainer = true
                    }
                }
            }

        }
        if founded.distanceToP1 != founded.maxDistance {
            return founded
        } else {
            return nil
        }
    }
    
    func findIntersectionPoint(a:CGPoint, b:CGPoint, c:CGPoint) ->CGPoint {
        let x1=a.x
        let y1=a.y
        let x2=b.x
        let y2=b.y
        let x3=c.x
        let y3=c.y
        let px = x2-x1
        let py = y2-y1
        let dAB = px*px + py*py
        let u = ((x3 - x1) * px + (y3 - y1) * py) / dAB
        let x = x1 + u * px
        let y = y1 + u * py
        return CGPointMake(x, y)
    }


    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if lastClosestPoint != nil {
            let nodes = nodesAtPoint(gameArray[lastClosestPoint!.column][lastClosestPoint!.row].position)
            for index in 0..<nodes.count {
                if nodes[index] is MySKNode {
                    (nodes[index] as! MySKNode).tremblingType = .NoTrembling
                    tremblingSprites.removeAll()
                }
            }
        }
        let firstTouch = touches.first
        let touchLocation = firstTouch!.locationInNode(self)
        
        while self.childNodeWithName("myLine") != nil {
            self.childNodeWithName("myLine")!.removeFromParent()
        }
        while self.childNodeWithName("nodeOnTheWall") != nil {
            self.childNodeWithName("nodeOnTheWall")!.removeFromParent()
        }
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
            
            movedFromNode.zPosition = 0
            let startNode = movedFromNode
            
            switch aktNodeType {
            case MyNodeTypes.LabelNode: aktNode = self.nodeAtPoint(touchLocation).parent as? MySKNode
            case MyNodeTypes.SpriteNode: aktNode = self.nodeAtPoint(touchLocation) as? MySKNode
            case MyNodeTypes.ButtonNode:
                //(testNode as! MySKNode).texture = SKTexture(imageNamed: "\(testNode.name!)")
                //(testNode as! MySKNode).texture = atlas.textureNamed("\(testNode.name!)")
                aktNode = (self.nodeAtPoint(touchLocation) as! MySKNode).parent as? MySKNode
            default: aktNode = nil
            }
            
            if showFingerNode {
                
                if let fingerNode = self.childNodeWithName("finger")! as? SKSpriteNode {
                    fingerNode.removeFromParent()
                }
                
            }
            if aktNode != nil && aktNode!.type == .ButtonType && startNode.type == .ButtonType && aktNode!.name == movedFromNode.name {
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
                    case "restart": restartButtonPressed()
                    default: specialButtonPressed(mySKNode.name!)
                }
                return
            }
            
            let touchesEndedAt = NSDate()
            
            let downTime = touchesEndedAt.timeIntervalSinceDate(touchesBeganAt!)
            if downTime < 0.3 && aktNode == movedFromNode {
                tapLocation = touchLocation
                doubleTapped()
                return
            }

            if exchangeModus {
                exchangeModus = false
                for index in 0..<tremblingSprites.count {
                    tremblingSprites[index].tremblingType = .NoTrembling
                }
                tremblingSprites.removeAll()
            }
            
            if startNode.type == .SpriteType && (aktNode == nil || aktNode! != movedFromNode) {
                let sprite = movedFromNode// as! SKSpriteNode
                
                sprite.zPosition = 50
                sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite!.size.width/2)
                sprite.physicsBody?.dynamic = true
                sprite.physicsBody?.categoryBitMask = PhysicsCategory.MovingSprite
                sprite.physicsBody?.contactTestBitMask = PhysicsCategory.Sprite | PhysicsCategory.Container //| PhysicsCategory.WallAround
                sprite.physicsBody?.collisionBitMask = PhysicsCategory.None
                //sprite.physicsBody?.velocity=CGVectorMake(200, 200)
                
                sprite.physicsBody?.usesPreciseCollisionDetection = true
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
                
                
                let actionMoveStopped =  SKAction.runBlock({
                    self.push(sprite, status: .Removed)
                    sprite.hidden = true
                    self.gameArray[sprite.column][sprite.row].used = false
                    //sprite.size = CGSizeMake(sprite.size.width / 3, sprite.size.height / 3)
                    sprite.colorBlendFactor = 4
                    self.playSound("Drop", volume: GV.soundVolume)
                    sprite.removeFromParent()
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
                var founded = false
                for index in 0..<nodes.count {
                    foundedCard = nodes[index] as? MySKNode
                   if nodes[index] is MySKNode && foundedCard!.type == .EmptyCardType {
                        startNode.column = foundedCard!.column
                        startNode.row = foundedCard!.row
                        push(startNode, status: .StopCycle)
                        push(startNode, status: .AddedFromShowCard)
                        startNode.size = foundedCard!.size
                        startNode.position = foundedCard!.position
                        startNode.type = .SpriteType
                        gameArray[startNode.column][startNode.row].used = true
                        addPhysicsBody(startNode)
                        foundedCard!.removeFromParent()
                        founded = true
                        pullShowCard()
                        break
                    } else if nodes[index] is MySKNode && foundedCard!.type == .SpriteType && startNode.colorIndex == foundedCard!.colorIndex &&
                        (foundedCard!.maxValue + 1 == startNode.minValue ||
                         foundedCard!.minValue - 1 == startNode.maxValue) {
                            push(startNode, status: .StopCycle)
                            push(foundedCard!, status: .Unification)
                            push(startNode, status: .AddedFromShowCard)
                            
                            if foundedCard!.maxValue < startNode.minValue {
                                foundedCard!.maxValue = startNode.maxValue
                            } else {
                                foundedCard!.minValue = startNode.minValue
                            }
                            foundedCard!.reload()
                            push(startNode, status: .Removed)
                            startNode.removeFromParent()
                            pullShowCard()
                            founded = true
                            break
                   }
                }
                if !founded {
                    let actionMove = SKAction.moveTo(cardPlaceButton!.position, duration: 0.5)
                    let actionDropShowCardFromStack = SKAction.runBlock({
                        self.removeShowCardFromStack()
                        startNode.zPosition = 0
                    })
                    startNode.zPosition = 50
                    startNode.runAction(SKAction.sequence([actionMove, actionDropShowCardFromStack]))
                }
            }
            
        }
        
    }
    func pullShowCard() {
        showCard = nil
        if showCardStack.count(.MySKNodeType) > 0 {
            removeShowCardFromStack()
            showCard = showCardStack.pull()
            self.addChild(showCard!)
        } else if !cardPlaceButtonAddedToParent {
            addChild(cardPlaceButton!)
            cardPlaceButtonAddedToParent = true
        }
    }
    
    func removeShowCardFromStack() {
        if showCardFromStackAddedToParent {
            showCardFromStack!.removeFromParent()
            showCardFromStack = nil
            showCardFromStackAddedToParent = false
        }
        if cardPlaceButtonAddedToParent {
            cardPlaceButton!.removeFromParent()
            cardPlaceButtonAddedToParent = false
        }
    }

    override func doubleTapped() {
        //let location = tapLocation
        let realLocation = tapLocation //CGPointMake(location!.x, self.view!.frame.size.height - location!.y)
        let nodes = nodesAtPoint(realLocation!)
        for index in 0..<nodes.count {
            if nodes[index] is MySKNode {
                let aktSprite = nodes[index] as! MySKNode
                if aktSprite.type == .SpriteType {
                    if exchangeModus {
                        push(aktSprite, status: .Exchanged)
                        push(cardToChange!, status: .Exchanged)
                        exchangeModus = false
                        createAndRunAction(cardToChange!, card2: aktSprite)
                        createAndRunAction(aktSprite, card2: cardToChange!)
                        
//                        let actionMove = SKAction.moveTo(aktSprite.position, duration: 0.5)
//                        cardToChange!.runAction(actionMove)
//                        let actionMove1 = SKAction.moveTo(cardToChange!.position, duration: 0.5)
//                        aktSprite.runAction(actionMove1)
                        let column = aktSprite.column
                        let row = aktSprite.row
                        let startPosition = aktSprite.startPosition
                        
                        aktSprite.column = cardToChange!.column
                        aktSprite.row = cardToChange!.row
                        aktSprite.startPosition = cardToChange!.startPosition
                        
                        cardToChange!.column = column
                        cardToChange!.row = row
                        cardToChange!.startPosition = startPosition
                        //
                        for index in 0..<tremblingSprites.count {
                            //tremblingSprites[index].size = tremblingSprites[index].origSize
                            tremblingSprites[index].tremblingType = .NoTrembling
                            tremblingSprites[index].zRotation = 0
                            tremblingSprites[index].zPosition = 0
                        }
                        tremblingSprites.removeAll()
                        cardToChange = nil
                    } else {
                        exchangeModus = true
                        //aktSprite.origSize = aktSprite.size
                        tremblingSprites.append(aktSprite)
                        aktSprite.tremblingType = .ChangeSize
                        cardToChange = aktSprite
                    }
                }
            }
        }
    }

    func createAndRunAction(card1: MySKNode, card2: MySKNode) {
        let actionShowEmptyCard = SKAction.runBlock({
            self.makeEmptyCard(card1.column, row: card1.row)
        })
        let actionMove = SKAction.moveTo(card2.position, duration: 0.5)
        
        let actionDeleteEmptyCard = SKAction.runBlock({
//            if self.childNodeWithName("\(self.emptySpriteTxt)-\(card1.column)-\(card1.row)") != nil {
//                self.childNodeWithName("\(self.emptySpriteTxt)-\(card1.column)-\(card1.row)")!.removeFromParent()
//            }
            self.deleteEmptySprite(card1.column, row: card1.row)
        })
        card1.runAction(SKAction.sequence([actionShowEmptyCard, actionMove, actionDeleteEmptyCard]))
        
    }

}
