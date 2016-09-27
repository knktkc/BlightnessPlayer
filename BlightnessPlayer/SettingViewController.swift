//
//  SettingViewController.swift
//  BlightnessPlayer
//
//  Created by TakeshiKaneko on 2016/09/16.
//  Copyright © 2016年 knktkc. All rights reserved.
import UIKit
import MediaPlayer
import AVFoundation

class SettingViewController: UIViewController, MPMediaPickerControllerDelegate {

    var blightness: Float = 0.0
    
    @IBOutlet var thresholdSlider: UISlider!
    var threshold: Float = 0.1
    
    var audio: AVAudioPlayer?
    var player = MPMusicPlayerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // スライダーの設定（最小値：0.1、最大値：0.9、初期値：0.1,000）
        thresholdSlider.minimumValue = 0.1;
        thresholdSlider.maximumValue = 0.9;
        thresholdSlider.value = 0.1;
        
        player = MPMusicPlayerController.applicationMusicPlayer()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // SelectMusicボタン押下時のイベント。ミュージックライブラリへ飛ぶ
    @IBAction func pickMusic(sender: UIButton) {
        //MPMediaPickerControllerのインスタンス作成
        let picker = MPMediaPickerController()
        //pickerのデリゲートを設定
        picker.delegate = self
        //複数選択を可にする（true/falseで設定）
        picker.allowsPickingMultipleItems = true
        //AssetURLが読み込めない音源は表示しない
        picker.showsItemsWithProtectedAssets = false
        //CloudItemsもAssetURLが読み込めないので表示しない
        picker.showsCloudItems = false
        //ピッカーを表示する
        presentViewController(picker, animated:true, completion: nil)
    }
    
    /// メディアアイテムピッカーでアイテムを選択完了したときに呼び出される
    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        player.setQueueWithItemCollection(mediaItemCollection)
        player.play()
        dismissViewControllerAnimated(true, completion: nil)
    }

    /// 選択がキャンセルされた場合に呼ばれる
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}

