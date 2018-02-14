//
//  WordDropNode.swift
//  WordDrop
//
//  Created by Cihan Emre Kisakurek (Company) on 14.02.18.
//  Copyright © 2018 cekisakurek. All rights reserved.
//

import Foundation
import SpriteKit


class WordDropNode : SKShapeNode {

    private var radius : CGFloat!

    override init() {

        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(word: String, position: CGPoint) {

        let r:CGFloat = 40 // calculate?
        let path = WordDropNode.dropPathWithCenter(center: CGPoint.zero, radius: r)
        self.init(path: path, centered: true)

        self.isAccessibilityElement = true
        self.radius = r
        self.position = position;
        self.lineCap = .round
        self.lineJoin = .round
        self.lineWidth = 12.0
        self.fillColor = UIColor.white

        self.physicsBody = SKPhysicsBody(circleOfRadius: r)
        self.physicsBody?.mass = 1
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.isDynamic = true;
        self.physicsBody?.restitution = 0.0
        self.physicsBody!.contactTestBitMask = self.physicsBody!.collisionBitMask

        let wordLabel = SKLabelNode(text: word)
        wordLabel.position = CGPoint(x:0,y:0)
        wordLabel.horizontalAlignmentMode = .center;
        wordLabel.verticalAlignmentMode = .center
        wordLabel.fontName = "Helvetica"

        let scalingFactor = (r*2) / wordLabel.frame.width
        // Change the fontSize to fit.
        wordLabel.fontSize *= min(scalingFactor,1.0)
        wordLabel.fontColor = UIColor.black
        self.addChild(wordLabel)
    }

    public func isMissed() -> Bool {
        
        return self.position.y == -(self.radius + self.lineWidth)
    }

    class private func dropPathWithCenter(center: CGPoint, radius: CGFloat) -> CGPath {

        let circlePath = UIBezierPath()
        let side:CGFloat = radius * 2

        circlePath.move(to: CGPoint(x: center.x - radius, y: 0))
        circlePath.addLine(to: CGPoint(x: center.x, y: side/2.0))
        circlePath.addLine(to: CGPoint(x: center.x + radius, y: 0))
        circlePath.addArc(withCenter: center, radius: radius, startAngle: CGFloat(Double.pi), endAngle: 0, clockwise: true)

        circlePath.close()
        return circlePath.cgPath
    }
}
