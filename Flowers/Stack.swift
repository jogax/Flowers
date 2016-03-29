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
    private var spriteStack: Array<MySKNode>
    
    init() {
        savedSpriteStack = Array<SavedSprite>()
        spriteStack = Array<MySKNode>()
    }
    
    func push (value: SavedSprite) {
        savedSpriteStack.append(value)
    }
    
    func push (value: MySKNode) {
        spriteStack.append(value)
    }

    func pushLast (value: MySKNode) {
        spriteStack.insert(value, atIndex: 0)
    }

    func count(type: StackType)->Int {
        switch type {
            case .MySKNodeType: return spriteStack.count
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
        if spriteStack.count > 0 {
            let value = spriteStack.last
            spriteStack.removeLast()
            return value!
        } else {
            return nil
        }
    }
    
    func last() -> MySKNode? {
        if spriteStack.count > 0 {
            let value = spriteStack.last
            return value!
        } else {
            return nil
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
            case .MySKNodeType: spriteStack.removeAll(keepCapacity: false)
            case .SaveSpriteType: savedSpriteStack.removeAll(keepCapacity: false)
        }
    }
}
