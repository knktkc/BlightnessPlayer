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

    let userDefaults = NSUserDefaults.standardUserDefaults()
    var titleArray: [String] = []
    var audio: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleArray = (userDefaults.objectForKey("music") as? [String])!
        
        if !titleArray.isEmpty {
            let url = userDefaults.URLForKey(titleArray[0])
            if url != nil {
                do {
                    audio = try AVAudioPlayer(contentsOfURL: url!, fileTypeHint: nil)
                    playTheMusic()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    internal func stopTheMusic() {
        if(audio != nil && audio!.playing) {
            audio!.stop()
        }
    }
    
    internal func playTheMusic() {
        if(audio != nil && !audio!.playing) {
            audio!.play()
        }
    }
}
