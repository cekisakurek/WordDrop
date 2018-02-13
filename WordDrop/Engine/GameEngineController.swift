//
//  GameEngineController.swift
//  WordDrop
//
//  Created by Cihan Emre Kisakurek (Company) on 13.02.18.
//  Copyright © 2018 cekisakurek. All rights reserved.
//

import Foundation

enum UserDecision {
    case Equal
    case NotEqual
    case Missed
}

protocol GameEngineDelegate: class {
    func newRound(withDropWord: Word, targetWord: Word, engine:GameEngineController)

    func selected(decision :UserDecision, targetWord: Word, dropWord: Word, correct: Bool, engine:GameEngineController)

    func gameEnded(engine:GameEngineController)

}

class GameEngineController : NSObject {

    private var words : [Word]?
    public private(set) var answers : [Dictionary<String,Word>]?
    public var gameStarted : Bool = false
    public private(set) var currentDropWord : Word?
    public private(set) var currentTargetWord : Word?
    public private(set) var score : Int = 0
    public var gameMaxTime : Int = 30
    public private(set) var gameTimeLeft : Int?
    private var roundTimer : Timer?
    weak var delegate: GameEngineDelegate?

    override init() {

        super.init()

    }

    func randomIndex(maxBound: Int) -> Int {
        return Int(arc4random_uniform(UInt32(maxBound)))

    }

    @objc func tick() {

        if self.gameTimeLeft! < 1 {
            endGame()
        }
        self.gameTimeLeft = self.gameTimeLeft! - 1
    }

    func startGame(withWordURL wordsURL: URL) {
        do {
            let data = try Data(contentsOf: wordsURL)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode([Word].self, from: data)

            self.words = jsonData
            self.gameStarted = true
            self.score = 0
            self.words = loadJson(filename: "words")
            self.gameTimeLeft = self.gameMaxTime
            self.roundTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
            dropWord()

        } catch {
            print("Words file couldn't parsed with error:\(error)")
        }
    }

    func dropWord() {
        if self.words!.count == 0 {
            print("Out of words")
            endGame()
        }
        else {
            let randomTargetIndex = randomIndex(maxBound: self.words!.count)
            let selectedWord = self.words![randomTargetIndex]
            self.currentTargetWord = selectedWord

            // %50 diversion
            let distractionWord = self.words![randomIndex(maxBound: self.words!.count)]
            if Int(arc4random_uniform(UInt32(2))) < 1 {
                self.currentDropWord = distractionWord
            }
            else {
                self.currentDropWord = self.currentTargetWord
            }
            self.words!.remove(at: randomTargetIndex)
            self.delegate?.newRound(withDropWord: self.currentDropWord!, targetWord: self.currentTargetWord!, engine:self)
        }
    }

    func userDecided(decision: UserDecision) {

        if self.gameStarted == false {
            assert(false,"Game is not started")
            return
        }
        switch decision {
            case .Equal:
                if self.currentDropWord?.text_eng == self.currentTargetWord?.text_eng {
                    correctAnswer(decision: decision)
                }
                else {
                    wrongAnswer(decision: decision)
                }
            break
            case .NotEqual:
                if self.currentDropWord?.text_eng != self.currentTargetWord?.text_eng {
                    correctAnswer(decision: decision)
                }
                else {
                    wrongAnswer(decision: decision)
                }
            break
            case .Missed:
                wrongAnswer(decision: decision)
            break
        }
    }

    private func updateAnswers() {
        self.answers = [["target":self.currentTargetWord!], ["selected":self.currentTargetWord!]]
    }

    private func correctAnswer(decision: UserDecision) {
        self.score = self.score+1
        updateAnswers()
        self.delegate?.selected(decision: decision, targetWord: self.currentTargetWord! ,dropWord: self.currentDropWord!, correct: true, engine: self)
        dropWord()
    }
    private func wrongAnswer(decision: UserDecision) {
        updateAnswers()
        self.delegate?.selected(decision: decision, targetWord: self.currentTargetWord! ,dropWord: self.currentDropWord!, correct: false, engine: self)
        dropWord()
    }

    func endGame() {
        self.roundTimer?.invalidate()
        self.gameStarted = false
        self.delegate?.gameEnded(engine: self)
    }


}
