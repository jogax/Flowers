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
    TCCardCount,
    TCReturn,
    TCOK,
    TCLevelComplete,
    TCNoMessage,
    TCGameAgain,
    TCTimeout,
    TCGameOver,
    TCCongratulations,
    TCName,
    TCVolume,
    TCCountHelpLines,
    TCLanguage,
    TCEnglish,
    TCGerman,
    TCHungarian,
    TCRussian,
    TCCancel,
    TCDone,
    TCModify,
    TCDelete,
    TCNewName,
    TCChoose,
    TCGamer,
    TCGameModus,
    TCSoundVolume,
    TCMusicVolume,
    TCStandardGame,
    TCCardGame,
    TCPreviousLevel,
    TCNextLevel,
    TCNewGame,
    TCRestart

}

    let LanguageDE = "de"
    let LanguageEN = "en"
    let LanguageHU = "hu"
    let LanguageRU = "ru"




class Language {
    
    let languages = [
        "de": deDictionary,
        "en": enDictionary,
        "hu": huDictionary,
        "ru": ruDictionary
    ]
    
    var callBacks: [()->Bool] = []
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
    
    func isAktLanguage(language:String)->Bool {
        return language == aktLanguage[.TCAktLanguage]
    }
    
    func addCallback(callBack: ()->Bool) {
        callBacks.append(callBack)
    }
    
}


