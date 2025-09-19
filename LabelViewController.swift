//
//  LabelViewController.swift
//  Split MessagesExtension
//
//  Created by Shabicha Sureshkumar on 2025-08-21.
//

import UIKit
import Messages

class LabelViewController: UIViewController {
    private var textLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.text = "hello world"
        view.addSubview(textLabel)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

#Preview {
    LabelViewController()
}
