
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
    
    var cardPackege: MySKButton?
    var cardPlaceButton: MySKButton?
    var tippsButton: MySKButton?
    
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
    var lastNextPoint: Founded?
    var generatingTipps = false
    var tippIndex = 0
    let oneGrad:CGFloat = CGFloat(M_PI) / 180
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
        cardPackege = MySKButton(texture: cardPackageButtonTexture, frame: CGRectMake(buttonXPosNormalized * 4.0, buttonYPos, cardSize.width, cardSize.height), makePicture: false)
        cardPackege!.name = "cardPackege"
        addChild(cardPackege!)
        
        showCardFromStack = nil
        
        let cardPlaceTexture = SKTexture(imageNamed: "emptycard")
        cardPlaceButton = MySKButton(texture: cardPlaceTexture, frame: CGRectMake(buttonXPosNormalized * 6.0, buttonYPos, cardSize.width, cardSize.height), makePicture: false)
        cardPlaceButton!.name = "cardPlace"
        addChild(cardPlaceButton!)
        cardPlaceButton!.alpha = 0.3
        cardPlaceButtonAddedToParent = true
        
        let tippsTexture = SKTexture(image: images.getTipp())
        tippsButton = MySKButton(texture: tippsTexture, frame: CGRectMake(buttonXPosNormalized * 7.5, buttonYPos, buttonSize, buttonSize))
        tippsButton!.name = "tipps"
        addChild(tippsButton!)
        

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
            let sprite: MySKNode = cardStack.pull()!
            
            let index = random!.getRandomInt(0, max: positionsTab.count - 1)
            let (aktColumn, aktRow) = positionsTab[index]
            
            let zielPosition = gameArray[aktColumn][aktRow].position
            sprite.position = cardPackege!.position
            sprite.startPosition = zielPosition
            

            positionsTab.removeAtIndex(index)
            
            sprite.column = aktColumn
            sprite.row = aktRow
            
            sprite.size = CGSizeMake(spriteSize.width, spriteSize.height)

            updateGameArrayCell(sprite)

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
        gameArrayChanged = true
        if first {
            countUp = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("doCountUp"), userInfo: nil, repeats: true)
        }
        
        stopped = false
    }
    
    
//    func startCreateTippsInBackground() {
//        if !generatingTipps {
//            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) { //(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
//                self.generatingTipps = true
//                self.createTipps()
//                dispatch_async(dispatch_get_main_queue(), {
//                    self.generatingTipps = false
//                })
//            }
//        }
//
//    }
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
        if buttonName == "tipps" {
            getTipps()
        }
    }
    
    func getTipps() {
        if gameArrayChanged {
            let startTime = NSDate()
            createTipps()
            print(NSDate().timeIntervalSinceDate(startTime))
            gameArrayChanged = false
            tippIndex = 0
        }
        if tippArray.count > 0 {
            for index in 0..<tippArray[tippIndex].points.count {
                tremblingSprites.removeAll()
//                self.addChild(tippArray[tippIndex].points[index])
                drawHelpLines(tippArray[tippIndex].points, lineWidth: spriteSize.width, drawFirstArrow: false)
                var position = CGPointZero
                if tippArray[tippIndex].from.row == NoValue {
                    position = containers[tippArray[tippIndex].from.column].mySKNode.position
                } else {
                    position = gameArray[tippArray[tippIndex].from.column][tippArray[tippIndex].from.row].position
                }
                addSpriteToTremblingSprites(position)
                if tippArray[tippIndex].to.row == NoValue {
                    position = containers[tippArray[tippIndex].to.column].mySKNode.position
                } else {
                    position = gameArray[tippArray[tippIndex].to.column][tippArray[tippIndex].to.row].position
                }
                addSpriteToTremblingSprites(position)
            }
            tippIndex = ++tippIndex % tippArray.count
        }
        
    }
    
    func createTipps() {
        tippArray.removeAll()
        var pairsToCheck = [(card1:(column:Int,row:Int), card2:(column:Int,row:Int))]()
        for column1 in 0..<countColumns {
            for row1 in 0..<countRows {
                if gameArray[column1][row1].used {
                    for column2 in 0..<countColumns {
                        for row2 in 0..<countRows {
                            if (column1 != column2 || row1 != row2) && gameArray[column2][row2].colorIndex == gameArray[column1][row1].colorIndex &&
                                (gameArray[column2][row2].minValue == gameArray[column1][row1].maxValue + 1 ||
                                    gameArray[column2][row2].maxValue == gameArray[column1][row1].minValue - 1) {
                                        if !findPair(pairsToCheck, column1: column1,row1: row1,column2: column2, row2: row2) {
                                            pairsToCheck.append(((column1,row1),(column2, row2)))
                                            pairsToCheck.append(((column2,row2),(column1, row1)))
                                        }
                            }
                        }
                    }
                    for index in 0..<containers.count {
                        if containers[index].mySKNode.minValue == NoColor && gameArray[column1][row1].maxValue == LastCardValue {
                            pairsToCheck.append(((column1,row1),(index, NoValue)))
                        }
                        if containers[index].mySKNode.colorIndex == gameArray[column1][row1].colorIndex &&
                         containers[index].mySKNode.minValue == gameArray[column1][row1].maxValue + 1 {
                                    pairsToCheck.append(((column1,row1),(index, NoValue)))
                        }
                    }
                }
            }
        }
 //       sleep(5)
        for ind in 0..<pairsToCheck.count {
            print(pairsToCheck[ind])
            checkPathToFoundedCards(pairsToCheck[ind])
        }
        print(tippArray.count)
     }
    
    func findPair(pairsToCheck:[(card1:(column:Int,row:Int), card2:(column:Int,row:Int))], column1:Int, row1:Int, column2:Int, row2:Int)->Bool {
        for index in 0..<pairsToCheck.count {
            let aktPairToCheck = pairsToCheck[index]
            if aktPairToCheck.card1.column == column1 && aktPairToCheck.card1.row == row1 && aktPairToCheck.card2.column == column2 && aktPairToCheck.card2.row == row2 {
                return true
            }
        }
        return false
    }

    
    func checkPathToFoundedCards(ind:(card1:(column:Int, row:Int), card2:(column:Int, row: Int))) {
        var targetPoint = CGPointZero
        var myTipp: (tipp:(from:(column: Int, row:Int), to:(column:Int, row:Int), points:[CGPoint]), distanceToLine:CGFloat)?
       let startPoint = gameArray[ind.card1.column][ind.card1.row].position
//        let name = gameArray[index.card1.column][index.card1.row].name
        if ind.card2.row == NoValue {
            targetPoint = containers[ind.card2.column].mySKNode.position
        } else {
            targetPoint = gameArray[ind.card2.column][ind.card2.row].position
        }
        let startAngle = calculateAngle(startPoint, point2: targetPoint).angleRadian - oneGrad * 20
        let stopAngle = startAngle + CGFloat(M_PI) * 2 // + 360°
//        let startNode = self.childNodeWithName(name)! as! MySKNode
        var founded = false
        var angle = startAngle
        while angle <= stopAngle && !founded {
            let toPoint = pointOfCircle(1.0, center: startPoint, angle: angle)
            let (foundedPoint, myLines) = createHelpLines(ind.card1, toPoint: toPoint, inFrame: self.frame, lineSize: spriteSize.width, showLines: false)
            if foundedPoint != nil {
                if foundedPoint!.foundContainer && ind.card2.row == NoValue && foundedPoint!.column == ind.card2.column ||
                    (foundedPoint!.column == ind.card2.column && foundedPoint!.row == ind.card2.row) {
                    if myTipp == nil ||
                    myTipp!.tipp.points.count > myLines.count ||
                    (myTipp!.tipp.points.count == myLines.count && myTipp!.distanceToLine > foundedPoint!.distanceToP0) {
                        myTipp = (tipp:(from:(column:ind.card1.column, row:ind.card1.row), to:(column:ind.card2.column, row:ind.card2.row),points:myLines), distanceToLine: foundedPoint!.distanceToP0)
                    }
                    if myTipp != nil && myTipp!.tipp.points.count < myLines.count {
                        founded = true
                    }
                }
            } else {
                print("in else zweig von checkPathToFoundedCards !")
            }
            angle += oneGrad
        }
        if myTipp != nil {
            tippArray.append(myTipp!.tipp)
        }
     }
    
    func calculateAngle(point1: CGPoint, point2: CGPoint) -> (angleRadian:CGFloat, angleDegree: CGFloat) {
        //        let pointOfCircle = CGPoint (x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
        let offset = point2 - point1
        let length = offset.length()
        let sinAlpha = offset.y / length
        let angleRadian = asin(sinAlpha);
        let angleDegree = angleRadian * 180.0 / CGFloat(M_PI)
        return (angleRadian, angleDegree)
    }

    func pointOfCircle(radius: CGFloat, center: CGPoint, angle: CGFloat) -> CGPoint {
        let pointOfCircle = CGPoint (x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
        return pointOfCircle
    }


    override func update(currentTime: NSTimeInterval) {
        let sec10: Int = Int(currentTime * 10) % 3
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
            resetGameArrayCell(movingSprite)
            movingSprite.removeFromParent()
//            startCreateTippsInBackground()
            playSound("Container", volume: GV.soundVolume)
            countMovingSprites = 0
            
            updateSpriteCount(-1)
            
            collisionActive = false
            //movingSprite.removeFromParent()
            checkGameFinished()
        } else {
            updateSpriteCount(-1)
            movingSprite.removeFromParent()
            countMovingSprites = 0
            push(movingSprite, status: .Removed)
            pull()
        }
        
     }
    
    func resetGameArrayCell(sprite:MySKNode) {
        gameArray[sprite.column][sprite.row].used = false
        gameArray[sprite.column][sprite.row].colorIndex = NoColor
        gameArray[sprite.column][sprite.row].minValue = NoValue
        gameArray[sprite.column][sprite.row].maxValue = NoValue
    }
    
    func updateGameArrayCell(sprite:MySKNode) {
        gameArray[sprite.column][sprite.row].used = true
        gameArray[sprite.column][sprite.row].name = sprite.name!
        gameArray[sprite.column][sprite.row].colorIndex = sprite.colorIndex
        gameArray[sprite.column][sprite.row].minValue = sprite.minValue
        gameArray[sprite.column][sprite.row].maxValue = sprite.maxValue
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
        
            updateGameArrayCell(sprite)
            resetGameArrayCell(movingSprite)
            
            movingSprite.removeFromParent()
//            startCreateTippsInBackground()
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
        gameArrayChanged = true
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
                self.gameArrayChanged = true
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
 
                    gameArray[sprite.column][sprite.row].colorIndex = sprite.colorIndex
                    gameArray[sprite.column][sprite.row].minValue = sprite.minValue
                    gameArray[sprite.column][sprite.row].maxValue = sprite.maxValue
                    
                    gameArray[sprite.column][sprite.row].used = true
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

                    gameArray[sprite.column][sprite.row].colorIndex = sprite.colorIndex
                    gameArray[sprite.column][sprite.row].minValue = sprite.minValue
                    gameArray[sprite.column][sprite.row].maxValue = sprite.maxValue
                    
                    sprite.BGPictureAdded = savedSpriteInCycle.BGPictureAdded
                    actionMoveArray.append(SKAction.moveTo(savedSpriteInCycle.endPosition, duration: duration))
                    actionMoveArray.append(SKAction.runBlock({
                        if self.childNodeWithName("\(self.emptySpriteTxt)-\(sprite.column)-\(sprite.row)") != nil {
                            self.childNodeWithName("\(self.emptySpriteTxt)-\(sprite.column)-\(sprite.row)")!.removeFromParent()
                        }
                    }))
                    sprite.runAction(SKAction.sequence(actionMoveArray))
//                    let column = sprite.column
//                    let row = sprite.row
//                    if self.childNodeWithName("\(emptySpriteTxt)-\(column)-\(row)") != nil {
//                        self.childNodeWithName("\(emptySpriteTxt)-\(column)-\(row)")!.removeFromParent()
//                    }
//                    startCreateTippsInBackground()
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

                    gameArray[sprite.column][sprite.row].colorIndex = sprite.colorIndex
                    gameArray[sprite.column][sprite.row].minValue = sprite.minValue
                    gameArray[sprite.column][sprite.row].maxValue = sprite.maxValue
                    
                    gameArray[sprite1.column][sprite1.row].colorIndex = sprite1.colorIndex
                    gameArray[sprite1.column][sprite1.row].minValue = sprite1.minValue
                    gameArray[sprite1.column][sprite1.row].maxValue = sprite1.maxValue
                    
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
        
        gameArrayChanged = true
        
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

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        //        if inFirstGenerateSprites {
        //            return
        //        }
        //let countTouches = touches.count
        
        touchesBeganAt = NSDate()
        let firstTouch = touches.first
        let touchLocation = firstTouch!.locationInNode(self)
        
        let testNode = self.nodeAtPoint(touchLocation)
        
        let aktNodeType = analyzeNode(testNode)
        switch aktNodeType {
        case MyNodeTypes.LabelNode: movedFromNode = self.nodeAtPoint(touchLocation).parent as! MySKNode
        case MyNodeTypes.SpriteNode:
            movedFromNode = self.nodeAtPoint(touchLocation) as! MySKNode
            //            if exchangeModus {
            //                movedFromNode.origSize = movedFromNode.size
            //                movedFromNode.tremblingType = .ChangeDirection
            //                tremblingSprites.append(movedFromNode)
            //            }
            if showFingerNode {
                let fingerNode = SKSpriteNode(imageNamed: "finger.png")
                fingerNode.name = "finger"
                fingerNode.position = touchLocation
                fingerNode.size = CGSizeMake(25,25)
                fingerNode.zPosition = 50
                addChild(fingerNode)
            }
            
        case MyNodeTypes.ContainerNode:
            movedFromNode = nil
            
        case MyNodeTypes.ButtonNode:
            movedFromNode = (self.nodeAtPoint(touchLocation) as! MySKNode).parent as! MySKNode
            //let textureName = "\(testNode.name!)Pressed"
            //let textureSelected = SKTexture(imageNamed: textureName)
            //(testNode as! MySKNode).texture = textureSelected
            //(testNode as! MySKNode).texture = atlas.textureNamed("\(testNode.name!)Pressed")
        default: movedFromNode = nil
        }
        if movedFromNode != nil {
            movedFromNode.zPosition = 50
        }
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
            var myLine: SKShapeNode = SKShapeNode()
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
                lastNextPoint = nil
            } else if movedFromNode != aktNode && !exchangeModus {
                if movedFromNode.type == .ButtonType {
                    //movedFromNode.texture = atlas.textureNamed("\(movedFromNode.name!)")
                } else if movedFromNode.type == .EmptyCardType {
                    
                } else {
                    createHelpLines((movedFromNode.column, movedFromNode.row), toPoint: touchLocation, inFrame: self.frame, lineSize: movedFromNode.size.width, showLines: true)
                }
            }
            
            if showFingerNode {
                
                if let fingerNode = self.childNodeWithName("finger")! as? SKSpriteNode {
                    fingerNode.position = touchLocation
                }
                
            }
        }
    }
    
    func createHelpLines(movedFrom: (column: Int, row: Int), toPoint: CGPoint, inFrame: CGRect, lineSize: CGFloat, showLines: Bool)->(foundedPoint: Founded?, [CGPoint]) {
//        print("createHelpLines start")
        var linesArray = [SKShapeNode]()
        var pointArray = [CGPoint]()
        var foundedPoint: Founded?
        var founded = false
        var myLine: SKShapeNode?
        let fromPosition = gameArray[movedFrom.column][movedFrom.row].position
        let line = JGXLine(fromPoint: fromPosition, toPoint: toPoint, inFrame: inFrame, lineSize: lineSize)
        let pointOnTheWall = line.line.toPoint
        pointArray.append(fromPosition)
        (founded, foundedPoint) = findEndPoint(movedFrom, fromPoint: fromPosition, toPoint: pointOnTheWall, lineWidth: lineSize, showLines: showLines)
//        linesArray.append(myLine)
//        if showLines {self.addChild(myLine)}
        if founded {
            pointArray.append(foundedPoint!.point)
        } else {
            pointArray.append(pointOnTheWall)
            let mirroredLine1 = line.createMirroredLine()
            (founded, foundedPoint) = findEndPoint((movedFrom.column, movedFrom.row), fromPoint: mirroredLine1.line.fromPoint, toPoint: mirroredLine1.line.toPoint, lineWidth: lineSize, showLines: showLines)
            
//            linesArray.append(myLine)
//            if showLines {self.addChild(myLine)}
            if founded {
                pointArray.append(foundedPoint!.point)
            } else {
                pointArray.append(mirroredLine1.line.toPoint)
                let mirroredLine2 = mirroredLine1.createMirroredLine()
                (founded, foundedPoint) = findEndPoint(movedFrom, fromPoint: mirroredLine2.line.fromPoint, toPoint: mirroredLine2.line.toPoint, lineWidth: lineSize, showLines: showLines)
//                linesArray.append(myLine)
//                if showLines {self.addChild(myLine)}
                if founded {
                    pointArray.append(foundedPoint!.point)
                } else {
                    pointArray.append(mirroredLine2.line.toPoint)
                    let mirroredLine3 = mirroredLine2.createMirroredLine()
                    (founded, foundedPoint) = findEndPoint(movedFrom, fromPoint: mirroredLine3.line.fromPoint, toPoint: mirroredLine3.line.toPoint, lineWidth: lineSize, showLines: showLines)
//                    linesArray.append(myLine)
//                    if showLines {self.addChild(myLine)}
                    if founded {
                        pointArray.append(foundedPoint!.point)
                    } else {
                        pointArray.append(mirroredLine3.line.toPoint)
                    }
                    
                }
            }
        }
        if showLines {
            drawHelpLines(pointArray, lineWidth: lineSize, drawFirstArrow: false)
        }
        return (foundedPoint, pointArray)
    }
    
    func findEndPoint(movedFrom: (column: Int, row: Int), fromPoint: CGPoint, toPoint: CGPoint, lineWidth: CGFloat, showLines: Bool)->(pointFounded:Bool, closestPoint: Founded?) {
        var foundedPoint = Founded()
        var toPoint = toPoint
        var pointFounded = false
        if let nextCard = findNextPoint(fromPoint, P2: toPoint, lineWidth: lineWidth, movedFrom: movedFrom) {
            toPoint = nextCard.point //gameArray[closestPoint.column][closestPoint.row].position
            if showLines {makeTrembling(nextCard)}
            foundedPoint = nextCard
            pointFounded = true
        }
 
        return (pointFounded, foundedPoint)
    }
    
    func drawHelpLines(points: [CGPoint], lineWidth: CGFloat, drawFirstArrow: Bool) {
        
        let pathToDraw:CGMutablePathRef = CGPathCreateMutable()
        let myLine:SKShapeNode = SKShapeNode(path:pathToDraw)
        myLine.lineWidth = lineWidth / 15
       
        myLine.name = "myLine"
        // check if valid data
        for index in 0..<points.count {
            if points[0].x.isNaN || points[0].y.isNaN {
                print("isNan")
                return
            }
        }
        
        CGPathMoveToPoint(pathToDraw, nil, points[0].x, points[0].y)
        for index in 1..<points.count {
            CGPathAddLineToPoint(pathToDraw, nil, points[index].x, points[index].y)
        }
        
        let lastButOneIndex = points.count - 2
        
        let offset = points.last! - points[lastButOneIndex]
        var angleR:CGFloat = 0.0
    
        if offset.x > 0 {
            angleR = asin(offset.y / offset.length())
        } else {
            if offset.y > 0 {
                angleR = acos(offset.x / offset.length())
            } else {
                angleR = -acos(offset.x / offset.length())
                
            }
        }
        let angleD = angleR / oneGrad
        let p1 = pointOfCircle(20.0, center: points.last!, angle: angleR - (150 * oneGrad))
        let p2 = pointOfCircle(20.0, center: points.last!, angle: angleR + (150 * oneGrad))
        
        

        CGPathAddLineToPoint(pathToDraw, nil, p1.x, p1.y)
        CGPathMoveToPoint(pathToDraw, nil, points.last!.x, points.last!.y)
        CGPathAddLineToPoint(pathToDraw, nil, p2.x, p2.y)

        myLine.path = pathToDraw
    
        myLine.strokeColor = SKColor(red: 1.0, green: 0, blue: 0, alpha: 1.0) // GV.colorSets[GV.colorSetIndex][colorIndex + 1]
        myLine.zPosition = 100
        myLine.lineCap = .Round
        
        self.addChild(myLine)
        
    }
    
    func makeTrembling(nextPoint: Founded) {
        var tremblingCardPosition = CGPointZero
        if lastNextPoint != nil && ((lastNextPoint!.column != nextPoint.column) ||  (lastNextPoint!.row != nextPoint.row)) {
            if lastNextPoint!.foundContainer {
                tremblingCardPosition = containers[lastNextPoint!.column].mySKNode.position
            } else {
                tremblingCardPosition = gameArray[lastNextPoint!.column][lastNextPoint!.row].position
            }
            let nodes = nodesAtPoint(tremblingCardPosition)
            for index in 0..<nodes.count {
                if nodes[index] is MySKNode {
                    (nodes[index] as! MySKNode).tremblingType = .NoTrembling
                    tremblingSprites.removeAll()
                }
            }
            lastNextPoint = nil
        }
        if lastNextPoint == nil {
            if nextPoint.foundContainer {
                tremblingCardPosition = containers[nextPoint.column].mySKNode.position
            } else {
                tremblingCardPosition = gameArray[nextPoint.column][nextPoint.row].position
            }
//            let nodes = nodesAtPoint(tremblingCardPosition)
//            for index in 0..<nodes.count {
//                if nodes[index] is MySKNode {
//                    tremblingSprites.append(nodes[index] as! MySKNode)
//                    (nodes[index] as! MySKNode).tremblingType = .ChangeSize
//                }
//            }
            addSpriteToTremblingSprites(tremblingCardPosition)
            lastNextPoint = nextPoint
        }

    }
 
    func addSpriteToTremblingSprites(position: CGPoint) {
        let nodes = nodesAtPoint(position)
        for index in 0..<nodes.count {
            if nodes[index] is MySKNode {
                tremblingSprites.append(nodes[index] as! MySKNode)
                (nodes[index] as! MySKNode).tremblingType = .ChangeSize
            }
        }

    }
    func findNextPoint(P1: CGPoint, P2: CGPoint, lineWidth: CGFloat, movedFrom: (column: Int, row: Int)) -> Founded? {
        
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
                    if !(movedFrom.column == column && movedFrom.row == row) {
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
                        founded.row = NoValue
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
        let x1 = a.x
        let y1 = a.y
        let x2 = b.x
        let y2 = b.y
        let x3 = c.x
        let y3 = c.y
        let px = x2-x1
        let py = y2-y1
        let dAB = px * px + py * py
        let u = ((x3 - x1) * px + (y3 - y1) * py) / dAB
        let x = x1 + u * px
        let y = y1 + u * py
        return CGPointMake(x, y)
    }


    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var position = CGPointZero
        tremblingSprites.removeAll()
        if lastNextPoint != nil {
            if lastNextPoint!.row == NoValue {
                position = containers[lastNextPoint!.column].mySKNode.position
            } else {
                position = gameArray[lastNextPoint!.column][lastNextPoint!.row].position
            }
            
            let nodes = nodesAtPoint(position)
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
//                        startCreateTippsInBackground()
                        foundedCard!.removeFromParent()
                        founded = true
                        gameArray[startNode.column][startNode.row].colorIndex = startNode.colorIndex
                        gameArray[startNode.column][startNode.row].minValue = startNode.minValue
                        gameArray[startNode.column][startNode.row].maxValue = startNode.maxValue
                        pullShowCard()
                        gameArrayChanged = true
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
                            gameArray[startNode.column][startNode.row].minValue = foundedCard!.minValue
                            gameArray[startNode.column][startNode.row].maxValue = foundedCard!.maxValue
                            startNode.removeFromParent()
                            pullShowCard()
                            founded = true
                            gameArrayChanged = true
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
                        gameArrayChanged = true
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
