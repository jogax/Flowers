//
//  Package.swift
//  JLinesV1
//
//  Created by Jozsef Romhanyi on 11.02.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

//import Foundation
import UIKit

enum TextConstants: Int {
    case
    TCLevel = 0,
    TCLevelScore,
    TCGameScore,
    TCTargetScore,
    TCTimeLeft,
    TCGameLost,
    TCGameLost3,
    TCTargetNotReached,
    TCSpriteCount,
    TCReturn,
    TCOK,
    TCLevelComplete,
    TCNoMessage,
    TCNextLevel,
    TCGameAgain,
    TCTimeout,
    TCGameOver
}



class Language {
    
    let languages = [
        "de": deDictionary,
        "en": enDictionary,
        "hu": huDictionary,
        "ru": ruDictionary
    ]
    
    var callBacks: [()->()] = []
    var aktLanguage = [TextConstants: String]()
    
    init() {
        
        let myString = NSLocale.preferredLanguages()[0]
        aktLanguage = languages[myString[myString.startIndex..<myString.startIndex.advancedBy(2)]]!

        
    }
    
    func setLanguage(language: String) {
        
        aktLanguage = languages[language]!

        for index in 0..<callBacks.count {
            callBacks[index]()
        }
    }
    
    func getText (textIndex: TextConstants) -> String {
            return aktLanguage[textIndex]!
    }
/*
    func getLanguageCount() -> Int {
        var index = 0
        while json!["languages"][index]["EN"] != nil {
            index++
        }
        return index
    }

    func getLanguages() -> [String] {
        var index = 0
        var languages: [String] = []
        while json!["languages"][index] != nil {
            languages.append(json!["languages"][index++].string!)
        }
        return languages
    }
    
    func callBackWhenNewLanguage(updateLanguage: ()->()) {
        callBacks.append(updateLanguage)
        for index in 0..<callBacks.count {
            callBacks[index]()
        }

    }

    func getAktLanguageIndex() -> Int {
       return Int(json!["languageIndex"].string!)!
    }
*/
}


