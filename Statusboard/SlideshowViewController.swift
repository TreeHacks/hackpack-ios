//
//  SlideshowViewController.swift
//  Statusboard
//
//  Created by Joshua Singer on 1/11/17.
//
//

import UIKit

class SlideshowViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    
    @IBAction func buttonTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.curveEaseIn, animations: {
            [weak self] in
            self?.button.alpha = 0.0
        })
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        button.alpha = 0.0
        UIView.animate(withDuration: 0.5, delay: 1.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.curveEaseIn, animations: {
            [weak self] in
            self?.button.alpha = 1.0
        })
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
