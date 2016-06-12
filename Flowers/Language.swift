//
//  Package.swift
//  JLinesV1
//
//  Created by Jozsef Romhanyi on 11.02.15.
//  Copyright (c) 2015 Jozsef Romhanyi. All rights reserved.
//

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
    TCGameComplete,
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
    TCChooseLanguage,
    TCPlayer,
    TCGameModus,
    TCSoundVolume,
    TCMusicVolume,
    TCStandardGame,
    TCCardGame,
    TCPreviousLevel,
    TCNextLevel,
    TCNewGame,
    TCRestart,
    TCChooseGame,
    TCTippCount,
    TCStatistics,
    TCActScore,
    TCBestScore,
    TCActTime,
    TCAllTimeForLevel,
    TCAllTime,
    TCBestTimeForLevel,
    TCBestTime,
    TCCountPlaysForLevel,
    TCCountPlays,
    TCGameCompleteWithBestScore,
    TCGameCompleteWithBestTime,
    TCGuest,
    TCAnonym,
    TCStatistic,
    TCPlayerStatisticHeader,
    TCStatisticOfGame,
    TCBestScoreOfGame,
    TCYourScore,
    TCYouAreTheBest,
    TCGameNumber,
    TCChooseGameNumber
}

    let LanguageEN = "en" // index 0
    let LanguageDE = "de" // index 1
    let LanguageHU = "hu" // index 2
    let LanguageRU = "ru" // index 3

enum LanguageCodes: Int {
    case ENCode = 0, DECode, HUCode, RUCode
}


class Language {
    
    let languageNames = [LanguageEN, LanguageDE, LanguageHU, LanguageRU]
    
    let languages = [
        "de": deDictionary,
        "en": enDictionary,
        "hu": huDictionary,
        "ru": ruDictionary
    ]
    
    
    struct Callback {
        var function: ()->Bool
        var name: String
        init(function:()->Bool, name: String) {
            self.function = function
            self.name = name
        }
    }
    var callbacks: [Callback] = []
    var aktLanguage = [TextConstants: String]()
    
    init() {
        aktLanguage = languages[getPreferredLanguage()]!
    }
    
    func setLanguage(languageKey: String) {        
        aktLanguage = languages[languageKey]!
        for index in 0..<callbacks.count {
            callbacks[index].function()
        }
    }
    
    func setLanguage(languageCode: LanguageCodes) {
        aktLanguage = languages[languageNames[languageCode.rawValue]]!
        for index in 0..<callbacks.count {
            callbacks[index].function()
        }
    }
    
    func getText (textIndex: TextConstants, values: String ...) -> String {
        return aktLanguage[textIndex]!.replace("%", values: values)
    }

    func getAktLanguageKey() -> String {
        return aktLanguage[.TCAktLanguage]!
    }
    
    func isAktLanguage(language:String)->Bool {
        return language == aktLanguage[.TCAktLanguage]
    }
    
    func addCallback(callback: ()->Bool, callbackName: String) {
        callbacks.append(Callback(function: callback, name: callbackName))
    }
    
    func removeCallback(callbackName: String) {
        for index in 0..<callbacks.count {
            if callbacks[index].name == callbackName {
                callbacks.removeAtIndex(index)
                return
            }
        }
    }
    
    func getPreferredLanguage()->String {
        let deviceLanguage = NSLocale.preferredLanguages()[0]
        let languageKey = deviceLanguage[deviceLanguage.startIndex..<deviceLanguage.startIndex.advancedBy(2)]
        return languageKey
    }
    
    func count()->Int {
        return languages.count
    }
    
    func getLanguageNames(index:LanguageCodes)->(String, Bool) {
        switch index {
            case .ENCode: return (aktLanguage[.TCEnglish]!, aktLanguage[.TCAktLanguage] == LanguageEN)
            case .DECode: return (aktLanguage[.TCGerman]!, aktLanguage[.TCAktLanguage] == LanguageDE)
            case .HUCode: return (aktLanguage[.TCHungarian]!, aktLanguage[.TCAktLanguage] == LanguageHU)
            case .RUCode: return (aktLanguage[.TCRussian]!, aktLanguage[.TCAktLanguage] == LanguageRU)
        }
    }
    
}


