//
//  Extenstions.swift
//  Currency-API-RxSwift
//
//  Created by Mohamed Salah on 21/08/2023.
//

import Foundation
import UIKit

extension UIViewController {
    func selectItem(title: String, source: [String], completion: @escaping (String) -> ()) {
        let alertController = UIAlertController.init(title: title, message: nil, preferredStyle: .actionSheet)
        source.forEach({ string in
            let action = UIAlertAction.init(title: string, style: .default) { _ in
                completion(string)
            }
            alertController.addAction(action)
        })
        let action = UIAlertAction.init(title: "Cancel", style: .cancel) { _ in
            
        }
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
        
    }
}
