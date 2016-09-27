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
    
    @IBOutlet var thresholdLabel: UILabel!
    var threshold: Float = 0.1
    
    var audio: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 表示用のテキスト
        blightnessLabel.text = String(format: "%.1f", blightness)
        thresholdLabel.text = String(format: "%.1f", threshold)
        
//        let currentStatus = MPMediaLibrary.authorizationStatus()
//        thresholdLabel.text = currentStatus
//        MPMediaLibrary.requestAuthorization { (status: MPMediaLibraryAuthorizationStatus) in
            // 結果に応じた処理
//        }
        // ”Cross The Line”って曲が端末に存在しないとエラーで落ちます
        // 好きな曲名に変更してください
        // TODO:予定では設定画面で選択した曲が流れます
//         let item: MPMediaItem = getMediaItemBySongFreeword("Cross The Line")
//         let url: NSURL = item.valueForProperty(MPMediaItemPropertyAssetURL) as! NSURL
//        
//         do {
//             audio = try AVAudioPlayer(contentsOfURL: url, fileTypeHint: nil)
//         } catch {
//             print(error)
//         }
        
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
        
        // threshold = thresholdSlider.value
        // thresholdLabel.text = String(format: "%.1f", threshold)
        //
        // thresholdSlider.addTarget(self, action: #selector(thresholdSliderValueDidChange(_:)), forControlEvents: UIControlEvents.ValueChanged)
        //
        checkThreshold()
    }

    internal func brightnessDidChange(notification: NSNotification) {
        blightness = Float(UIScreen.mainScreen().brightness)
        blightnessLabel.text = String(format: "%.1f", blightness)
        checkThreshold()
    }
    
//     internal func thresholdSliderValueDidChange(sender :UISlider) {
//         threshold = thresholdSlider.value
//         thresholdLabel.text = String(format: "%.1f", threshold)
//         checkThreshold()
//     }

    internal func checkThreshold() {
        if (blightness <= threshold) {
            playTheMusic()
        } else {
            stopTheMusic()
        }
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

    internal func getMediaItemBySongFreeword(songFreeword : NSString) -> MPMediaItem {
        let property: MPMediaPropertyPredicate = MPMediaPropertyPredicate(value: songFreeword, forProperty: MPMediaItemPropertyTitle)
        let query: MPMediaQuery = MPMediaQuery()
        query.addFilterPredicate(property)
        let items: [MPMediaItem] = query.items! as [MPMediaItem]
        return items[items.count - 1]
    }

}

