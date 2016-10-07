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
    var appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var audioController: AudioController?

    let userDefaults = NSUserDefaults.standardUserDefaults()

    @IBOutlet weak var animationImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // アニメーション用の画像
        let image12_1 = UIImage(named:"images/12-1_1.png")!
//        let image12_2 = UIImage(named:"images/12-2.png")!
        let image13_1 = UIImage(named:"images/13-1.png")!
//        let image13_2 = UIImage(named:"images/13-2.png")!
        
        // UIImage の配列を作る
        var imageListArray :Array<UIImage> = []
        // UIImage 各要素を追加
        imageListArray.append(image12_1)
        imageListArray.append(image13_1)
        
        let rect = CGRect(x:0, y:0, width:image12_1.size.width, height:image12_1.size.height)
        animationImageView.frame = rect
        
        animationImageView.image = image12_1
        // 画像の配列をアニメーションにセット
        animationImageView.animationImages = imageListArray
        // 1秒間隔
        animationImageView.animationDuration = 1.0
        // 10回繰り返し
        animationImageView.animationRepeatCount = 10
        
    }
    
    // 画面が表示されたあとのイベントハンドラ
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // アニメーションを開始
        animationImageView.startAnimating()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // アニメーションを終了
        animationImageView.stopAnimating()
    }
}
