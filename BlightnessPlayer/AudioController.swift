//
//  AudioController.swift
//  BlightnessPlayer
//
//  Created by TakeshiKaneko on 2016/10/07.
//  Copyright © 2016年 knktkc. All rights reserved.
//

import Foundation
import MediaPlayer

class AudioController: NSObject, AVAudioPlayerDelegate {
    var audio: AVAudioPlayer?

    let userDefaults = NSUserDefaults.standardUserDefaults()
    var titleArray: [String] = []

    private var currentIndex: Int = 0
    private var musicLength: Int = 0

    override init() {
        super.init()

        addAudio()
    }
    
    internal func addAudio() {
        // タイトルが設定されてたら曲を取りに行く
        guard let tempTitleArray = (userDefaults.objectForKey("music") as? [String]) else {
            return
        }
        // 既にセットされてたらセットしない
        if self.audio != nil {
            return
        }
        
        titleArray = tempTitleArray
        musicLength = titleArray.count
        let url = userDefaults.URLForKey(titleArray[currentIndex])
        if url != nil {
            do {
                self.audio = try AVAudioPlayer(contentsOfURL: url!, fileTypeHint: nil)
                self.audio?.numberOfLoops = 0
                self.audio?.delegate = self
            } catch {
                print(error)
            }
        }
    }
    
    /// アイテム末尾に到達したときに呼ばれる
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        let index = randomIndex()
        if index != currentIndex {
            currentIndex = index
        } else {
            currentIndex = nextIndex()
        }
        let url = userDefaults.URLForKey(titleArray[currentIndex])!
        do {
            self.audio = try AVAudioPlayer(contentsOfURL: url, fileTypeHint: nil)
            self.audio?.numberOfLoops = 0
            self.audio?.delegate = self
            playTheMusic()
        } catch {
            print(error)
        }
    }
    
    func randomIndex()-> Int {
        let retunIndex = Int(arc4random() % UInt32(musicLength))
        return retunIndex
    }
    
    func nextIndex()-> Int {
        // 範囲外になるなら最初の曲に戻る
        if currentIndex >= titleArray.count - 1 {
            return 0
        } else {
            return currentIndex + 1
        }
    }
    
    internal func stopTheMusic() {
        if(self.audio != nil && self.audio!.playing) {
            self.audio!.stop()
        }
    }
    
    internal func playTheMusic() {
        if(self.audio != nil && !self.audio!.playing) {
            self.audio!.play()
        }
    }
}
