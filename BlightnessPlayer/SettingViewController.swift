//
//  SettingViewController.swift
//  BlightnessPlayer
//
//  Created by TakeshiKaneko on 2016/09/16.
//  Copyright © 2016年 knktkc. All rights reserved.
import UIKit
import MediaPlayer

class SettingViewController: UIViewController {

    var blightness: Float = 0.0
    
    @IBOutlet var thresholdSlider: UISlider!
    var threshold: Float = 0.1
    
    var audio: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // スライダーの設定（最小値：0.1、最大値：0.9、初期値：0.1）
        thresholdSlider.minimumValue = 0.1;
        thresholdSlider.maximumValue = 0.9;
        thresholdSlider.value = 0.1;
        
        let item: MPMediaItem = getMediaItemBySongFreeword("Cross The Line")
        let url: NSURL = item.valueForProperty(MPMediaItemPropertyAssetURL) as! NSURL
        
        do {
            audio = try AVAudioPlayer(contentsOfURL: url, fileTypeHint: nil)
        } catch {
            print(error)
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

