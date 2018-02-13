//
//  GameEngineController.swift
//  WordDrop
//
//  Created by Cihan Emre Kisakurek (Company) on 13.02.18.
//  Copyright © 2018 cekisakurek. All rights reserved.
//

import Foundation

class GameEngineController : NSObject {



    private var words : [Word]?

    override init() {

        super.init()
        self.words = loadJson(filename: "words")


    }

    func randomWord() -> Word {
        let count:Int = (self.words?.count)!
        let randomIndex = Int(arc4random_uniform(UInt32(count)))
        return self.words![randomIndex]
    }


}
