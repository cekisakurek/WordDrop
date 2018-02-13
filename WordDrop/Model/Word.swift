//
//  Word.swift
//  WordDrop
//
//  Created by Cihan Emre Kisakurek on 13.02.18.
//  Copyright © 2018 cekisakurek. All rights reserved.
//

import Foundation

struct Words: Decodable {
    var person: [Word]
}
struct Word : Decodable, Hashable, Equatable {
    var text_eng: String
    var text_spa: String

    static func == (lhs: Word, rhs: Word) -> Bool {
        return lhs.text_eng == rhs.text_eng &&
            lhs.text_spa == rhs.text_spa
    }
    var hashValue: Int {
        return text_eng.hashValue ^ text_spa.hashValue
    }
}
// TODO : Async loading. Remote URL loading
func loadJson(filename fileName: String) -> [Word]? {
    if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode([Word].self, from: data)
            return jsonData
        } catch {
            print("error:\(error)")
        }
    }
    return nil
}

