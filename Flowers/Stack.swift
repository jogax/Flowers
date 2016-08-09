//
//  Stack.swift
//  JLines
//
//  Created by Jozsef Romhanyi on 27.08.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//


enum StackType: Int {
    case SaveSpriteType = 0, MySKNodeType
}
class Stack<T> {
    private var savedSpriteStack: Array<SavedSprite>
    private var cardStack: Array<MySKNode>
    var lastRandomIndex = -1
    
    init() {
        savedSpriteStack = Array<SavedSprite>()
        cardStack = Array<MySKNode>()
    }
    
    func push (value: SavedSprite) {
        savedSpriteStack.append(value)
    }
    
    func push (value: MySKNode) {
        cardStack.append(value)
    }

    func pushLast (value: MySKNode) {
        cardStack.insert(value, atIndex: 0)
    }

    func count(type: StackType)->Int {
        switch type {
            case .MySKNodeType: return cardStack.count
            case .SaveSpriteType: return savedSpriteStack.count
        }
    }
    
    func pull () -> SavedSprite? {

        if savedSpriteStack.count > 0 {
            let value = savedSpriteStack.last
            savedSpriteStack.removeLast()
            return value!
        } else {
            return nil
        }
    }
    
    func pull () -> MySKNode? {        
        if cardStack.count > 0 {
            let value = cardStack.last
            cardStack.removeLast()
            return value!
        } else {
            return nil
        }
    }
    
    func last() -> MySKNode? {
        if cardStack.count > 0 {
            let value = cardStack.last
            return value!
        } else {
            return nil
        }
    }
    
    func random(random: MyRandom?)->MySKNode? {
        lastRandomIndex = random!.getRandomInt(0, max: cardStack.count - 1)
        return cardStack[lastRandomIndex]
    }
    
    func removeAtLastRandomIndex() {
        if lastRandomIndex >= 0 {
            cardStack.removeAtIndex(lastRandomIndex)
            lastRandomIndex = -1
        }
    }
    
    func countChangesInStack() -> Int {
        var counter = 0
        for index in 0..<savedSpriteStack.count {
            if !(savedSpriteStack[index].status == .Added || savedSpriteStack[index].status == .AddedFromCardStack) {counter += 1}
        }
        return counter
    }
    
    func removeAll(type: StackType) {
        switch type {
            case .MySKNodeType: cardStack.removeAll(keepCapacity: false)
            case .SaveSpriteType: savedSpriteStack.removeAll(keepCapacity: false)
        }
    }
}
