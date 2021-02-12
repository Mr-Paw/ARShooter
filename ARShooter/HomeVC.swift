//
//  HomeVC.swift
//  ARShooter
//
//  Created by paw on 13.02.2021.
//

import UIKit

class HomeVC: UIViewController {

    @IBOutlet weak var scoreLabel: UILabel!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scoreLabel.text = "Highest score: \(AppDelegate.score)"
    }
}
