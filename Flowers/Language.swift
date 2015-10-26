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
    TCAktLanguage = 0,
    TCLevel,
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
    TCGameOver,
    TCCongratulations,
    TCName,
    TCMusicVolume,
    TCSoundVolume,
    TCCountHelpLines,
    TCLanguage,
    TCEnglish,
    TCGerman,
    TCHungarian,
    TCRussian

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
        let languageKey = myString[myString.startIndex..<myString.startIndex.advancedBy(2)]
        aktLanguage = languages[languageKey]!

        
    }
    
    func setLanguage(languageKey: String) {
        
        aktLanguage = languages[languageKey]!

        for index in 0..<callBacks.count {
            callBacks[index]()
        }
    }
    
    func getText (textIndex: TextConstants) -> String {
        return aktLanguage[textIndex]!
    }

    func getAktLanguageKey() -> String {
        return aktLanguage[.TCAktLanguage]!
    }
    
    func isAktLanguage(language:TextConstants)->Bool {
        let languageName = GV.language.getText(language)
        let ind = languageName.lowercaseString.rangeOfString(" (")
        let startIndex = ind?.startIndex.advancedBy(2)
        let endIndex = ind?.endIndex.advancedBy(2)
        let substring = languageName.lowercaseString.substringWithRange(Range<String.Index>(start: startIndex!, end: endIndex!))
        print(ind)
        return substring == GV.language.getText(.TCAktLanguage)
        
        
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


