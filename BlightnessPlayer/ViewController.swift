//
//  ViewController.swift
//
//  Created by TakeshiKaneko on 2016/09/09.
//  Copyright © 2016年 TakeshiKaneko. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVAudioPlayerDelegate {
    
     let userDefaults = NSUserDefaults.standardUserDefaults()
     var titleArray: [String] = []
     
     @IBOutlet var blightnessLabel: UILabel!
     var blightness: Float = 0.0
    
     @IBOutlet var thresholdLabel: UILabel!
     var threshold: Float = 0.0
     
     private var currentIndex: Int = 0
     private var musicLength: Int = 0

     var audio: AVAudioPlayer?
    
     // カメラ関係
     var cameraSession: AVCaptureSession?
     var cameraDevice: AVCaptureDevice?
     var videoInput: AVCaptureDeviceInput?
     var videoOutput: AVCaptureVideoDataOutput?
     @IBOutlet weak var cameraImageView: UIImageView!
    
     override func viewDidLoad() {
          super.viewDidLoad()
          
          // 表示用のテキスト
          blightnessLabel.text = "0"
          thresholdLabel.text = "0"
          
          // カメラセットアップとプレビュー表示
          if setupCamera() {
               self.cameraSession?.startRunning()
          }
          
          if let tempThreshold: Float = userDefaults.floatForKey("threshold") {
               thresholdLabel.text = String(format: "%.1f", tempThreshold)
               threshold = tempThreshold
          }
     }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        blightness = Float(UIScreen.mainScreen().brightness)
        blightnessLabel.text = String(format: "%.1f", blightness)
        
//        NSNotificationCenter.defaultCenter().addObserver(self,
//                                                         selector: #selector(brightnessDidChange(_:)),
//                                                         name: UIScreenBrightnessDidChangeNotification,
//                                                         object: nil)

     guard let tempTitleArray = (userDefaults.objectForKey("music") as? [String]) else {
          return
     }
     
     titleArray = tempTitleArray
     musicLength = titleArray.count
     let url = userDefaults.URLForKey(titleArray[currentIndex])
     if url != nil {
          do {
               audio = try AVAudioPlayer(contentsOfURL: url!, fileTypeHint: nil)
               audio?.numberOfLoops = 0
               audio?.delegate = self
          } catch {
               print(error)
          }
     }

        checkThreshold()
    }

    internal func brightnessDidChange(notification: NSNotification) {
        blightness = Float(UIScreen.mainScreen().brightness)
        blightnessLabel.text = String(format: "%.1f", blightness)
        checkThreshold()
    }

    internal func checkThreshold() {
        if (blightness <= threshold) {
            playTheMusic()
        } else {
            stopTheMusic()
        }
    }
     /// アイテム末尾に到達したときに呼ばれる
     func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
          let index = randomIndex()
          var url: NSURL
          if index != currentIndex {
               currentIndex = index
          } else {
               currentIndex = nextIndex()
          }
          url = userDefaults.URLForKey(titleArray[currentIndex])!
          do {
               audio = try AVAudioPlayer(contentsOfURL: url, fileTypeHint: nil)
               audio?.numberOfLoops = 0
               audio?.delegate = self
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
          if(audio != nil && audio!.playing) {
               audio!.stop()
          }
     }
     
     internal func playTheMusic() {
          if(audio != nil && !audio!.playing) {
               audio!.play()
          }
     }
    
    func setupCamera() -> Bool {
        self.cameraSession = AVCaptureSession()
        if self.cameraSession == nil {
            return false
        }

        self.cameraSession!.sessionPreset = AVCaptureSessionPreset352x288
        
        let devices = AVCaptureDevice.devices()
        
        for device in devices {
            if device.position == .Front {
                cameraDevice = device as? AVCaptureDevice
            }
        }
        if cameraDevice == nil {
            return false
        }
     
        do {
            // カメラの露出がオートで変更されない設定にする
            try cameraDevice?.lockForConfiguration()
            cameraDevice?.exposureMode = .Locked
            cameraDevice?.unlockForConfiguration()
        } catch {
            print("camera exposure cant lock")
        }
     
        do {
            self.videoInput = try AVCaptureDeviceInput(device: cameraDevice) as AVCaptureDeviceInput
        } catch {
            print("camera input can not find")
            return false
        }
        
        if self.cameraSession!.canAddInput(self.videoInput) {
            self.cameraSession!.addInput(self.videoInput)
        }else {
            return false
        }
        
        self.videoOutput = AVCaptureVideoDataOutput()
        self.videoOutput?.videoSettings = [kCVPixelBufferPixelFormatTypeKey : Int(kCVPixelFormatType_32BGRA)]
     
        do {
            try self.cameraDevice?.lockForConfiguration()
            self.cameraDevice?.activeVideoMinFrameDuration = CMTimeMake(1, 30)
            self.cameraDevice?.unlockForConfiguration()
        }catch {
            print("lock Error")
        }
        
        // デリゲートの設定
        let grobalQueue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
        self.videoOutput?.setSampleBufferDelegate(self, queue: grobalQueue)
        
        // 遅れてきたフレームは無視する
        self.videoOutput!.alwaysDiscardsLateVideoFrames = true
        
        if ((self.cameraSession?.canAddOutput(self.videoOutput)) != nil) {
            self.cameraSession?.addOutput(self.videoOutput)
        }else{
            return false
        }
     
        return true
    }
    
     // 新しいキャプチャの追加で呼ばれる
     func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
          
          // キャプチャしたsampleBufferからUIImageを作成
          let image:UIImage = self.captureImage(sampleBuffer)
          
          // 画像サイズをアスペクト比を保ったまま縮小する(輝度サンプル数をある程度確保し、かつ重くない程度)
          let newWidth: CGFloat = 50
          let newHeight = image.size.height / image.size.width * newWidth
          let resizedSize = CGSize(width: newWidth, height: newHeight)
          UIGraphicsBeginImageContext(resizedSize)
          image.drawInRect(CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
          let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
          var luminance: CGFloat = 0.0
          for x in 0..<Int(newWidth) {
               for y in 0..<Int(newHeight) {
                    let color = resizedImage!.getPixelColor(CGPointMake(CGFloat(x), CGFloat(y)))
                    luminance += (0.298912 * color.0 + 0.586611 * color.1 + 0.114478 * color.2)
               }
          }
          luminance = luminance / CGFloat(Int(newWidth) * Int(newHeight))
          self.blightness = Float(luminance)
          checkThreshold()
          
          // カメラの画像を画面に表示、輝度表示更新
          dispatch_async(dispatch_get_main_queue()) {
               self.cameraImageView.image = image
//               self.luminanceText.text = luminance.description
               self.blightnessLabel.text = luminance.description
          }
     }
     
     // sampleBufferからUIImageを作成
     func captureImage(sampleBuffer:CMSampleBufferRef) -> UIImage{
          
          // Sampling Bufferから画像を取得
          let imageBuffer:CVImageBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)!
          
          // pixel buffer のベースアドレスをロック
          CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
          
          let baseAddress:UnsafeMutablePointer<Void> = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)
          
          let bytesPerRow:Int = CVPixelBufferGetBytesPerRow(imageBuffer)
          let width:Int = CVPixelBufferGetWidth(imageBuffer)
          let height:Int = CVPixelBufferGetHeight(imageBuffer)
          
          // 色空間
          let colorSpace:CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()
          
          let newContext:CGContextRef = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace,  CGImageAlphaInfo.PremultipliedFirst.rawValue|CGBitmapInfo.ByteOrder32Little.rawValue)!
          
          let imageRef:CGImageRef = CGBitmapContextCreateImage(newContext)!
          let resultImage = UIImage(CGImage: imageRef, scale: 1.0, orientation: UIImageOrientation.Right)
          
          return resultImage
     }

}

