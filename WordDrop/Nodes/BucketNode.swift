//
//  BucketNode.swift
//  WordDrop
//
//  Created by Cihan Emre Kisakurek (Company) on 14.02.18.
//  Copyright © 2018 cekisakurek. All rights reserved.
//

import Foundation
import SpriteKit

class BucketNode : SKShapeNode {

    private var wordLabel: SKLabelNode?
    public var text: String?
    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(center: CGPoint, side: CGFloat, text: String) {

        let path = BucketNode.bucketPathWithCenter(width: side)
        self.init(path: path, centered: true)

        self.text = text
        self.position = center;
        self.lineCap = .round
        self.lineJoin = .round
        self.lineWidth = 2.0

        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: side, height: side))
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.isDynamic = false
        self.fillColor = UIColor.white

        let wordLabel = SKLabelNode(text: "")
        wordLabel.position = CGPoint(x:0,y:0)
        wordLabel.fontName = "Helvetica-Bold"
        wordLabel.fontSize = 58
        wordLabel.fontColor = UIColor.black
        wordLabel.horizontalAlignmentMode = .center
        wordLabel.verticalAlignmentMode = .center
        wordLabel.text = self.text
        self.addChild(wordLabel)
        self.wordLabel = wordLabel
    }

    public func animateDecision(correct:Bool) {

        wordLabel?.setScale(0.5)
        let scaleUpAction = SKAction.scale(to: 1.0, duration: 0.25)
        if correct {
            wordLabel?.text = "✅"
        }
        else {
            wordLabel?.text = "❌"
        }

        let clearAction = SKAction.customAction(withDuration: 0.0, actionBlock: { [unowned self]
            node, elapsedTime in
            let label = node as! SKLabelNode
            label.text = self.text
        })

        wordLabel?.run(SKAction.sequence([scaleUpAction,clearAction]))
    }

    class private func bucketPathWithCenter(width: CGFloat) -> CGPath {

        let circlePath = UIBezierPath()
        let fifthWidth = width/5.0

        circlePath.move(to: CGPoint(x: 0, y: width))
        circlePath.addLine(to: CGPoint(x: fifthWidth, y: 0))
        circlePath.addLine(to: CGPoint(x: width - fifthWidth, y: 0))
        circlePath.addLine(to: CGPoint(x: width, y: width))

        circlePath.close()
        return circlePath.cgPath
    }
}
