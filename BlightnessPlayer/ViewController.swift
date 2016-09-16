//
//  ViewController.swift
//
//  Created by TakeshiKaneko on 2016/09/09.
//  Copyright © 2016年 TakeshiKaneko. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController {
    
    @IBOutlet var blightnessLabel: UILabel!
    var blightness: Float = 0.0
    
    @IBOutlet var thresholdSlider: UISlider!
    @IBOutlet var thresholdLabel: UILabel!
    var threshold: Float = 0.0
    
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
    
    override func viewDidAppear(animated: Bool) {
        blightness = Float(UIScreen.mainScreen().brightness)
        blightnessLabel.text = String(format: "%.1f", blightness)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(brightnessDidChange(_:)),
                                                         name: UIScreenBrightnessDidChangeNotification,
                                                         object: nil)
        
        threshold = thresholdSlider.value
        thresholdLabel.text = String(format: "%.1f", threshold)
        
        thresholdSlider.addTarget(self, action: #selector(thresholdSliderValueDidChange(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        checkThreshold()
    }
    
    internal func brightnessDidChange(notification: NSNotification) {
        blightness = Float(UIScreen.mainScreen().brightness)
        blightnessLabel.text = String(format: "%.1f", blightness)
        checkThreshold()
    }
    
    internal func thresholdSliderValueDidChange(sender :UISlider) {
        threshold = thresholdSlider.value
        thresholdLabel.text = String(format: "%.1f", threshold)
        checkThreshold()
    }
    
    internal func checkThreshold() {
        if (blightness <= threshold) {
            getWildAndTough()
        } else {
            stopTheMusic()
        }
    }
    
    internal func stopTheMusic() {
        if(audio!.playing) {
            audio!.stop()
        }
    }
    
    internal func getWildAndTough() {
        if(!audio!.playing) {
            audio!.play()
        }
    }
    
    internal func getMediaItemBySongFreeword(songFreeword : NSString) -> MPMediaItem {
        let property: MPMediaPropertyPredicate = MPMediaPropertyPredicate(value: songFreeword, forProperty: MPMediaItemPropertyTitle)
        let query: MPMediaQuery = MPMediaQuery()
        query.addFilterPredicate(property)
        let items: [MPMediaItem] = query.items! as [MPMediaItem]
        return items[items.count - 1]
    }
    
}

