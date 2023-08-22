//
//  UITest2ViewController.swift
//  Currency-API-RxSwift
//
//  Created by Mohamed Salah on 22/08/2023.
//

import UIKit
import iOSDropDown
import SwiftyMenu

class UITest2ViewController: UIViewController {

    @IBOutlet weak var dropDown: DropDown!

    override func viewDidLoad() {
        super.viewDidLoad()
        dropDown.optionArray = ["1", "2", "3"]
        
    }
}
