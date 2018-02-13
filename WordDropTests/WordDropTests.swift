//
//  WordDropTests.swift
//  WordDropTests
//
//  Created by Cihan Emre Kisakurek (Company) on 13.02.18.
//  Copyright © 2018 cekisakurek. All rights reserved.
//

import XCTest
@testable import WordDrop

class WordDropTests: XCTestCase, GameEngineDelegate {

    private var engine : GameEngineController?
    private var gameEndExpectation : XCTestExpectation = XCTestExpectation(description: "Game End Expectation")

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.engine = GameEngineController()
        self.engine?.delegate = self

    }

    func newRound(withDropWord: Word, targetWord: Word, engine: GameEngineController) {
        print("New round started with Drop word:\(withDropWord) target word:\(targetWord)")
        let decision = Int(arc4random_uniform(UInt32(2)))
        if decision < 0 {
            self.engine?.userDecided(decision: .Equal)
        }
        else {
            self.engine?.userDecided(decision: .NotEqual)
        }
        // simulate missed
    }

    func selected(decision: UserDecision, targetWord: Word, dropWord: Word, correct: Bool, engine: GameEngineController) {
        print("Selected :\(decision) target word:\(targetWord) drop word:\(dropWord) correct:\(correct)")

    }


    func gameEnded(engine: GameEngineController) {
        print("Game ended with score :\(engine.score)")
        self.gameEndExpectation.fulfill()
    }


    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGame() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        if let url = Bundle.main.url(forResource: "words", withExtension: "json") {
            self.engine?.gameMaxTime = 5
            self.engine?.startGame(withWordURL: url)

            wait(for: [self.gameEndExpectation], timeout: TimeInterval(self.engine!.gameMaxTime))

        }
        else {
            XCTAssert(false,"Words file couldn't loaded")
        }
    }

}
