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
        // アニメーション用の画像
        let image12_1 = UIImage(named:"images/12-1.png")!
        let image12_2 = UIImage(named:"images/12-2.png")!
        
        // UIImage の配列を作る
        var imageListArray :Array<UIImage> = []
        // UIImage 各要素を追加
        imageListArray.append(image12_1)
        imageListArray.append(image12_2)
        
        let rect = CGRect(x:0, y:0, width:image12_1.size.width, height:image12_1.size.height)
        animationImageView.frame = rect
        
        animationImageView.image = image12_1
        // 画像の配列をアニメーションにセット
        animationImageView.animationImages = imageListArray
        // 1秒間隔
        animationImageView.animationDuration = 1.0
        // 5回繰り返し
        animationImageView.animationRepeatCount = 10
        // アニメーションを開始
        animationImageView.startAnimating()
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
        // アニメーションを終了
        animationImageView.stopAnimating()
    }
}
