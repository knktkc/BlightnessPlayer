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

class PlayViewController: UIViewController, AVAudioPlayerDelegate {

    let userDefaults = NSUserDefaults.standardUserDefaults()
    var titleArray: [String] = []
    var audio: AVAudioPlayer?
//    
//    private var currentIndex: Int = 0
//    private var musicLength: Int = 0

    @IBOutlet weak var animationImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        guard let tempTitleArray = (userDefaults.objectForKey("music") as? [String]) else {
//            return
//        }
//        
//        titleArray = tempTitleArray
//        musicLength = titleArray.count
//        let url = userDefaults.URLForKey(titleArray[currentIndex])
//        if url != nil {
//            do {
//                audio = try AVAudioPlayer(contentsOfURL: url!, fileTypeHint: nil)
//                audio?.numberOfLoops = 0
//                audio?.delegate = self
//            } catch {
//                print(error)
//            }
//        }
        
        let image12_1:UIImage = UIImage(named:"images/12-1.png")!
        animationImageView.image = image12_1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
//    /// アイテム末尾に到達したときに呼ばれる
//    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
//        let index = randomIndex()
//        var url: NSURL
//        if index != currentIndex {
//            currentIndex = index
//        } else {
//            currentIndex = nextIndex()
//        }
//        url = userDefaults.URLForKey(titleArray[currentIndex])!
//        do {
//            audio = try AVAudioPlayer(contentsOfURL: url, fileTypeHint: nil)
//            audio?.numberOfLoops = 0
//            audio?.delegate = self
//            playTheMusic()
//        } catch {
//            print(error)
//        }
//    }
//    
//    func randomIndex()-> Int {
//        let retunIndex = Int(arc4random() % UInt32(musicLength))
//        return retunIndex
//    }
//
//    func nextIndex()-> Int {
//        // 範囲外になるなら最初の曲に戻る
//        if currentIndex >= titleArray.count - 1 {
//            return 0
//        } else {
//            return currentIndex + 1
//        }
//    }
//    
//    internal func stopTheMusic() {
//        if(audio != nil && audio!.playing) {
//            audio!.stop()
//        }
//    }
//    
//    internal func playTheMusic() {
//        if(audio != nil && !audio!.playing) {
//            audio!.play()
//        }
//    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        stopTheMusic()
    }
}
