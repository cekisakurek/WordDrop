//
//  GameScene.swift
//  WordDrop
//
//  Created by Cihan Emre Kisakurek (Company) on 13.02.18.
//  Copyright © 2018 cekisakurek. All rights reserved.
//

import SpriteKit
import GameplayKit

extension SKSpriteNode {

    func aspectFillToSize(fillSize: CGSize) {

        if texture != nil {
            self.size = texture!.size()

            let verticalRatio = fillSize.height / self.texture!.size().height
            let horizontalRatio = fillSize.width /  self.texture!.size().width

            let scaleRatio = horizontalRatio > verticalRatio ? horizontalRatio : verticalRatio

            self.setScale(scaleRatio)
        }
    }

}

enum BodyCategory: UInt32 {
    case WordDropBody = 1
    case EqualBucketBody = 2
    case NotEqualBucketBody = 4
    case MissBody = 8
}

protocol GameSettingsDelegate: class {

    func showHelp()
}

class GameScene: SKScene, SKPhysicsContactDelegate, GameEngineDelegate, GameStartDelegate {

    weak var helpDelegate: GameSettingsDelegate?
    private var engine : GameEngineController!

    private var scoreLabelNode : SKLabelNode!
    private var gameTimeLabelNode : SKLabelNode!

    private var cloudsNode : CloudsNode!
    private var groundNode : SKSpriteNode!
    private var countDownNode : CountDownNode!
    private var helpButtonNode : SKLabelNode!

    private var targetWordNode : SKLabelNode!
    private var dropWordNode : WordDropNode!

    private var equalBucketNode : BucketNode!
    private var notEqualBucketNode : BucketNode!

    private var touchDownPosition : CGPoint?
    private var touchMovedPosition : CGPoint?

    // for testing
    var accessibleElements: [UIAccessibilityElement] = []

    override func didMove(to view: SKView) {

        self.isAccessibilityElement = false

        // create background
        let size = CGSize(width: (self.view?.bounds.width)!,height: (self.view?.bounds.height)!)
        UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
        let context = UIGraphicsGetCurrentContext()

        let gradient = backgroundGradient()
        gradient.frame = CGRect(origin: CGPoint.zero, size: size)
        gradient.render(in: context!)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let texture = SKTexture(image:image!)
        let node = SKSpriteNode(texture:texture)
        node.anchorPoint = CGPoint.zero
        node.zPosition = -10.0
        self.addChild(node)

        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx:0.0,dy: -0.9)
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)

        self.scoreLabelNode = SKLabelNode()
        self.scoreLabelNode.position = CGPoint(x: 10, y: self.size.height - 15)
        self.scoreLabelNode.horizontalAlignmentMode = .left
        self.scoreLabelNode.verticalAlignmentMode = .center
        self.scoreLabelNode.fontName = "Helvetica-Bold"
        self.scoreLabelNode.fontSize = 12
        self.scoreLabelNode.text = "\(NSLocalizedString("Score", comment: "Score")): 0"
        self.scoreLabelNode.fontColor = UIColor.white
        self.addChild(self.scoreLabelNode)

        self.gameTimeLabelNode = SKLabelNode()
        self.gameTimeLabelNode.position = CGPoint(x: self.size.width - 80, y: self.size.height - 15)
        self.gameTimeLabelNode.horizontalAlignmentMode = .left
        self.gameTimeLabelNode.verticalAlignmentMode = .center
        self.gameTimeLabelNode.fontName = "Helvetica-Bold"
        self.gameTimeLabelNode.fontSize = 12
        self.gameTimeLabelNode.text = "\(NSLocalizedString("Time", comment: "Time")): 00:00"
        self.gameTimeLabelNode.fontColor = UIColor.white
        self.addChild(self.gameTimeLabelNode)

        // add clouds
        self.cloudsNode = CloudsNode(rect: CGRect(x: 0, y: 0, width: self.size.width, height: 70))
        self.cloudsNode.position = CGPoint(x: 0, y: self.size.height - 100)
        self.cloudsNode.addClouds()
        self.addChild(self.cloudsNode);

        self.groundNode = SKSpriteNode()
        self.groundNode.texture = SKTexture(imageNamed: "ground")
        self.groundNode.aspectFillToSize(fillSize: CGSize(width: self.size.width - 2, height: 40))
        self.groundNode.position = CGPoint(x: self.size.width / 2.0, y: 20)

        self.groundNode.physicsBody = SKPhysicsBody(rectangleOf: self.groundNode.size)
        self.groundNode.physicsBody?.isDynamic = false
        self.groundNode.physicsBody?.categoryBitMask = BodyCategory.MissBody.rawValue
        self.addChild(self.groundNode)

        self.targetWordNode = SKLabelNode()
        self.targetWordNode.position = CGPoint(x: self.size.width / 2.0, y: self.size.height - 80)
        self.targetWordNode.fontName = "Helvetica-Bold"
        self.targetWordNode.fontSize = 20
        self.targetWordNode.fontColor = UIColor.black
        self.addChild(self.targetWordNode)

        self.notEqualBucketNode = BucketNode(center: CGPoint(x:50, y:50 + self.groundNode.size.height), side: 100, text: "≠")
        self.notEqualBucketNode.physicsBody?.categoryBitMask = BodyCategory.NotEqualBucketBody.rawValue
        self.addChild(self.notEqualBucketNode)

        self.equalBucketNode = BucketNode(center: CGPoint(x:self.size.width - 50, y: 50  + self.groundNode.size.height), side: 100, text: "=")
        self.equalBucketNode.physicsBody?.categoryBitMask = BodyCategory.EqualBucketBody.rawValue
        self.addChild(self.equalBucketNode)

        let centerY = self.size.height / 2.0

        self.countDownNode = CountDownNode(position: CGPoint(x: self.size.width / 2.0, y: centerY + 40))
        self.countDownNode.delegate = self
        self.countDownNode.horizontalAlignmentMode = .center
        self.countDownNode.verticalAlignmentMode = .center
        self.addChild(self.countDownNode)

        // For UI Testing
        let countDownNodeAccessibilityElement = UIAccessibilityElement(accessibilityContainer: self.view!)
        countDownNodeAccessibilityElement.accessibilityFrame = nodeToDevicePointsFrame(node: self.countDownNode)
        countDownNodeAccessibilityElement.accessibilityTraits = UIAccessibilityTraitButton
        countDownNodeAccessibilityElement.accessibilityIdentifier = "StartNode"
        accessibleElements.append(countDownNodeAccessibilityElement)

        self.helpButtonNode = SKLabelNode()
        self.helpButtonNode.position = CGPoint(x: self.size.width / 2.0, y: centerY - 40)
        self.helpButtonNode.fontName = "Helvetica-Bold"
        self.helpButtonNode.fontSize = 40
        self.helpButtonNode.text = NSLocalizedString("Help", comment: "Help")
        self.helpButtonNode.fontColor = UIColor.white
        self.addChild(self.helpButtonNode)

        self.engine = GameEngineController()
        self.engine.delegate = self
    }

    func willStart() {

        self.helpButtonNode.isHidden = true
    }

    func startGame() {

        self.countDownNode.isHidden = true

        if let url = Bundle.main.url(forResource: "words", withExtension: "json") {
            self.engine.startGame(withWordURL: url)
        }
        else {
            print("Words file couldn't loaded")
        }
    }

    func newRound(withDropWord: Word, targetWord: Word, engine: GameEngineController) {

        print("New round started with Drop word:\(withDropWord) target word:\(targetWord)")
        self.targetWordNode.text = targetWord.text_eng

        if let previousNode = self.dropWordNode {
            previousNode.removeFromParent()
            accessibleElements.removeAll()
        }

        let startPoint = CGPoint(x: self.size.width/2.0, y: self.size.height - 130)

        self.dropWordNode = WordDropNode(word: withDropWord.text_spa, position: startPoint)
        self.dropWordNode.physicsBody?.categoryBitMask = BodyCategory.WordDropBody.rawValue
        self.dropWordNode.physicsBody?.collisionBitMask = BodyCategory.EqualBucketBody.rawValue | BodyCategory.NotEqualBucketBody.rawValue | BodyCategory.MissBody.rawValue
        self.dropWordNode.name = "raindrop"
        self.addChild(self.dropWordNode)

        // For UI Testing
        let dropNodeAccessibilityElement = UIAccessibilityElement(accessibilityContainer: self.view!)
        dropNodeAccessibilityElement.accessibilityFrame = nodeToDevicePointsFrame(node: self.dropWordNode)
        dropNodeAccessibilityElement.accessibilityTraits = UIAccessibilityTraitButton
        dropNodeAccessibilityElement.accessibilityIdentifier = "Drop"
        accessibleElements.append(dropNodeAccessibilityElement)
    }

    func selected(decision: UserDecision, targetWord: Word, dropWord: Word, correct: Bool, engine: GameEngineController) {

        print("Selected :\(decision) target word:\(targetWord) drop word:\(dropWord) correct:\(correct)")
        self.scoreLabelNode.text = "\(NSLocalizedString("Score", comment: "Score")): \(engine.score)"

        if decision == .Equal {
            self.equalBucketNode.animateDecision(correct: correct)
        }
        else if decision == .NotEqual {
            self.notEqualBucketNode.animateDecision(correct: correct)
        }
    }

    func gameEnded(engine: GameEngineController) {

        print("Game ended with score :\(engine.score)")
        
        self.countDownNode.isHidden = false
        self.helpButtonNode.isHidden = false
        self.targetWordNode.text = ""

        if let currentDropNode = self.dropWordNode {
            currentDropNode.removeFromParent()
            accessibleElements.removeAll()
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {

        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        if firstBody.categoryBitMask == BodyCategory.WordDropBody.rawValue{

            if secondBody.categoryBitMask == BodyCategory.EqualBucketBody.rawValue {
                print("equal")
                self.engine.userDecided(decision: .Equal)
            }
            else if secondBody.categoryBitMask == BodyCategory.NotEqualBucketBody.rawValue {
                print("Not - equal")
                self.engine.userDecided(decision: .NotEqual)
            }
            else if secondBody.categoryBitMask == BodyCategory.MissBody.rawValue {
                print("Miss")
                self.engine.userDecided(decision: .Missed)
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        let touchLocation = touch?.location(in: self)

        let touchedNodes = self.nodes(at: touchLocation!)
        if touchedNodes.first == self.countDownNode {
            self.countDownNode.startCountDown()
        }
        else if touchedNodes.first == self.helpButtonNode {
            self.helpDelegate?.showHelp()
        }

        self.touchDownPosition = touchLocation
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endTouches(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endTouches(touches, with: event)
    }

    func endTouches(_ touches: Set<UITouch>, with event: UIEvent?) {

        if let drop = self.dropWordNode {

            let touch = touches.first
            let touchLocation = touch?.location(in: self)

            self.touchMovedPosition = touchLocation

            let t1 = self.touchDownPosition!
            let t2 = self.touchMovedPosition!

            let dX = Int((t2.x - t1.x)/1.0)

            var dY = Int((t2.y - t1.y)/2.0)
            if dY > 0 {
                dY = 0 // Don't let drop to go up
            }
            let vector = CGVector(dx: dX , dy: dY)
            drop.physicsBody?.applyImpulse(vector)
        }
    }

    override func update(_ currentTime: TimeInterval) {

        // Called before each frame is rendered
        self.cloudsNode.updateClouds()

        if let engine = self.engine {
            if engine.gameStarted != false {
                let remaining = self.engine.gameTimeLeft!
                
                let remainingMinutes = remaining / 60
                let remainingSecods = remaining % 60
                var remainingMinutesPrefix = ""
                var remainingSecodsPrefix = ""
                if remainingMinutes < 10 {
                    remainingMinutesPrefix = "0"
                }
                if remainingSecods < 10 {
                    remainingSecodsPrefix = "0"
                }

                let minutes = remainingMinutesPrefix + String(remaining / 60)
                let seconds = remainingSecodsPrefix + String(remaining % 60)
                
                self.gameTimeLabelNode.text = "\(NSLocalizedString("Time", comment: "Time")): \(minutes + ":" + seconds)"
            }
        }
    }

    // MARK: Helpers
    func backgroundGradient() -> CAGradientLayer {

        let gradientColors:[CGColor] = [UIColor.lightGray.cgColor, UIColor.blue.cgColor]
        let gradientLocations = [1, 0]

        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations as [NSNumber]

        return gradientLayer
    }

    override func accessibilityElementCount() -> Int {
        return self.accessibleElements.count
    }

    override func accessibilityElement(at index: Int) -> Any? {

        if (index < self.accessibleElements.count) {
            return self.accessibleElements[index]
        } else {
            return nil
        }
    }

    override func index(ofAccessibilityElement element: Any) -> Int {

        return self.accessibleElements.index(of: element as! UIAccessibilityElement)!
    }

    private func nodeToDevicePointsFrame(node: SKNode) -> CGRect {

        // first convert from frame in SKNode to frame in SKScene's coordinates
        var sceneFrame = node.frame
        sceneFrame.origin = node.scene!.convert(node.frame.origin, from: node.parent!)

        // convert frame from SKScene coordinates to device points
        // sprite kit scene origin is in lower left, accessibility device screen origin is at upper left
        // assumes scene is initialized using SKSceneScaleMode.Fill using dimensions same as device points

        var deviceFrame = sceneFrame
        deviceFrame.origin.y = CGFloat(self.size.height) - (sceneFrame.origin.y + sceneFrame.size.height)
        return deviceFrame
    }
}
