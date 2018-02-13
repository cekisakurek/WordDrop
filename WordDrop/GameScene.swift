//
//  GameScene.swift
//  WordDrop
//
//  Created by Cihan Emre Kisakurek (Company) on 13.02.18.
//  Copyright © 2018 cekisakurek. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

    private var engine : GameEngineController!

    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    override func didMove(to view: SKView) {

        self.engine = GameEngineController()

//        if let url = Bundle.main.url(forResource: "words", withExtension: "json") {
//            self.engine.startGame(withWordURL: url)
//        }
//        else {
//            print("Words file couldn't loaded")
//        }
    }

    func newRound(withDropWord: Word, targetWord: Word, engine: GameEngineController) {
        print("New round started with Drop word:\(withDropWord) target word:\(targetWord)")

    }

    func selected(decision: UserDecision, targetWord: Word, dropWord: Word, correct: Bool, engine: GameEngineController) {
        print("Selected :\(decision) target word:\(targetWord) drop word:\(dropWord) correct:\(correct)")

    }


    func gameEnded(engine: GameEngineController) {
        print("Game ended with score :\(engine.score)")

    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
