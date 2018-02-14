//
//  HelpViewController.swift
//  WordDrop
//
//  Created by Cihan Emre Kisakurek (Company) on 14.02.18.
//  Copyright © 2018 cekisakurek. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

    private var rulesLabel: UILabel!

    override func loadView() {
        
        super.loadView()

        self.view.backgroundColor = UIColor.white

        self.rulesLabel = UILabel()
        self.rulesLabel.translatesAutoresizingMaskIntoConstraints = false
        self.rulesLabel.numberOfLines = 0
        self.view.addSubview(self.rulesLabel)

        let titleParagraph = NSMutableParagraphStyle()
        titleParagraph.alignment = .center
        titleParagraph.paragraphSpacing = 20

        let helpStringTitle = NSLocalizedString("It is raining words!", comment: "Help string title")

        let helpTitleAttributedString = NSAttributedString(string: helpStringTitle, attributes: [.paragraphStyle : titleParagraph, .font : UIFont.boldSystemFont(ofSize: 38)])

        let rulesParagraph = NSMutableParagraphStyle()
        rulesParagraph.alignment = .left
        rulesParagraph.paragraphSpacing = 10

        let gameRulesString = NSLocalizedString("• If you think dropping word is matching translation then swipe right and aim for the equals bucket(=).\n• If you think we are fooling you swipe left! And aim for the not equals bucket(≠).\n• You should think fast you don't want to spill the drop to the ground", comment: "Help text")

        let gameRulesAttributedString = NSAttributedString(string: gameRulesString, attributes: [.paragraphStyle : rulesParagraph, .font : UIFont.systemFont(ofSize: 18)])

        let completeString = NSMutableAttributedString(attributedString: helpTitleAttributedString)
        completeString.append(NSAttributedString(string: "\n"))
        completeString.append(gameRulesAttributedString)

        self.rulesLabel.attributedText =  completeString

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            self.rulesLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 20),
            self.rulesLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            self.rulesLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            self.rulesLabel.bottomAnchor.constraintLessThanOrEqualToSystemSpacingBelow(guide.bottomAnchor, multiplier: 1.0)
        ])
    }

    override func viewDidLoad() {

        super.viewDidLoad()
        self.title = NSLocalizedString("Help", comment: "Help")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(dismiss(sender:)))
    }

    @objc func dismiss(sender: UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
