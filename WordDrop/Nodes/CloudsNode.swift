//
//  CloudsNode.swift
//  WordDrop
//
//  Created by Cihan Emre Kisakurek (Company) on 14.02.18.
//  Copyright © 2018 cekisakurek. All rights reserved.
//

import Foundation
import SpriteKit

class CloudsNode : SKShapeNode {

    private var clouds : [SKSpriteNode]!
    private var maxCloudsCount = 15

    override init() {
        super.init()
        self.lineWidth = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addClouds() {
        // create clouds
        self.clouds = []

        let cloudImage = UIImage(named: "cloud") //82 × 56
        let cloudTexture = SKTexture(image:cloudImage!)

        for i in 1...self.maxCloudsCount
        {
            let cloud = SKSpriteNode(texture: cloudTexture)

            let yWiggle:Int = Int(arc4random_uniform(14))

            let xPos = CGFloat((i*42))
            let yPos = yWiggle + 28
            cloud.position = CGPoint(x: xPos, y: CGFloat(yPos))

            let moveX = CGFloat(arc4random_uniform(20) + 20)
            let horizontalMoveAction = SKAction.repeatForever(SKAction.moveBy(x: moveX, y: 0, duration: 1.0))

            cloud.run(horizontalMoveAction, withKey: "horizontalMove")
            self.clouds?.append(cloud)
            self.addChild(cloud)
        }
    }

    func updateClouds() {

        for cloud in self.clouds! {
            //reset nodes if they are out of bounds
            if cloud.position.x - cloud.size.width > self.frame.size.width {

                cloud.isHidden = true
                cloud.removeAction(forKey: "horizontalMove")

                cloud.position = CGPoint(x: -cloud.size.width, y: cloud.position.y)

                let moveX = CGFloat(arc4random_uniform(20) + 20)
                let horizontalMoveAction = SKAction.repeatForever(SKAction.moveBy(x: moveX, y: 0, duration: 1.0))
                cloud.run(horizontalMoveAction, withKey: "horizontalMove")

                cloud.isHidden = false
            }
        }
    }
}
