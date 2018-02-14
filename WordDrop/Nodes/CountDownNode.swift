//
//  CountDownNode.swift
//  WordDrop
//
//  Created by Cihan Emre Kisakurek (Company) on 14.02.18.
//  Copyright © 2018 cekisakurek. All rights reserved.
//

import Foundation
import SpriteKit

protocol GameStartDelegate: class {
    
    func startGame()
}

class CountDownNode : SKLabelNode {

    weak var delegate: GameStartDelegate?

    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(position: CGPoint) {

        self.init()
        self.position = position

        self.numberOfLines = 2
        self.horizontalAlignmentMode = .left
        self.colorBlendFactor = 0.0;
        self.text = NSLocalizedString("Tap to Start!", comment: "Tap to start")
        self.fontName = "Helvetica-Bold"
        self.fontSize = 38
        self.fontColor = UIColor.white
    }

    private func changeColorAction(withColor: UIColor, duration: TimeInterval) -> SKAction {

        let changeColorAction = SKAction.customAction(withDuration: duration, actionBlock: {
            node, elapsedTime in
            let label = node as! SKLabelNode
            label.fontColor = withColor
        })
        return changeColorAction
    }

    private func changeTextAndResetScaleAction(text: String) -> SKAction {

        let changeTextToTwoAction = SKAction.customAction(withDuration: 0.0, actionBlock: {
            node, elapsedTime in
            let label = node as! SKLabelNode
            label.setScale(1.0)
            label.text = text
        })
        return changeTextToTwoAction
    }

    func reset() {

        self.text = NSLocalizedString("Tap to Start", comment: "Tap to start")
        self.fontSize = 40
        self.fontColor = UIColor.white
        self.setScale(1.0)
    }

    func startCountDown() {

        let duration = 0.25

        self.text = "3"
        self.fontSize = 100
        self.fontColor = UIColor.red

        let scaleDownAction = SKAction.scale(to: 0.5, duration: duration)
        let secondStepAction = changeTextAndResetScaleAction(text: "2")
        let changeColorYellowAction = changeColorAction(withColor: UIColor.yellow, duration: duration)

        let thirdStepAction = changeTextAndResetScaleAction(text: "1")
        let changeColorGreenAction = changeColorAction(withColor: UIColor.green, duration: duration)

        let removeCountDownLabelAndNotifyDelegateAction = SKAction.run {
            self.delegate?.startGame()
            self.reset()
        }

        let actions = [scaleDownAction,secondStepAction,changeColorYellowAction,
                       scaleDownAction,thirdStepAction,changeColorGreenAction,
                       scaleDownAction,removeCountDownLabelAndNotifyDelegateAction]

        self.run(SKAction.sequence(actions))

    }
}
