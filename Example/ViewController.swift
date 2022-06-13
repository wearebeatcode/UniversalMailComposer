//
//  ViewController.swift
//  Example
//
//  Created by Giada Ciotola on 13 Jun 2022.
//  Copyright © 2022 Beatcode. All rights reserved.
//

import UIKit
import UniversalMailComposer

// MARK: - ViewController

/// The ViewController
class ViewController: UIViewController {

    // MARK: Properties
    
    /// The Label
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = "🚀Open Mail"
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()
    
    // MARK: View-Lifecycle
    
    /// View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
    }
    
    @objc
    func tapFunction(sender: UITapGestureRecognizer) {
        UniversalMailComposer.shared.sendMail(recipient: "feedback@beatcode.it", subject: "sono un soggetto", body: "sono un body", hostVC: self)
    }
    
    /// LoadView
    override func loadView() {
        self.view = self.label
    }

}
