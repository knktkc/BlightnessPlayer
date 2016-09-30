//
//  PlayViewController.swift
//  BlightnessPlayer
//
//  Created by TakeshiKaneko on 2016/09/30.
//  Copyright © 2016年 knktkc. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
import AVFoundation

class PlayViewController: UIViewController, MPMediaPickerControllerDelegate {
    @IBOutlet weak var playView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        playView.userInteractionEnabled = true
        playView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PlayViewController.ViewTapped(_:))))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func ViewTapped(sender: UITapGestureRecognizer) {
        let targetViewController = self.storyboard!.instantiateViewControllerWithIdentifier( "target" )
        self.presentViewController( targetViewController, animated: true, completion: nil)
    }
}
