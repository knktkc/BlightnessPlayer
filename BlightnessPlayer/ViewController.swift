//
//  ViewController.swift
//
//  Created by TakeshiKaneko on 2016/09/09.
//  Copyright © 2016年 TakeshiKaneko. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet var blightnessLabel: UILabel!
    var blightness: Float = 0.0
     @IBOutlet weak var luminanceText: UITextField!
    
    @IBOutlet var thresholdLabel: UILabel!
    var threshold: Float = 0.1
    
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
        let item: MPMediaItem = getMediaItemBySongFreeword("いけないボーダーライン")
        let url: NSURL = item.valueForProperty(MPMediaItemPropertyAssetURL) as! NSURL
        
        do {
            audio = try AVAudioPlayer(contentsOfURL: url, fileTypeHint: nil)
        } catch {
            print(error)
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
     
     override func viewWillAppear(animated: Bool) {
          super.viewWillAppear(animated)
          
          // カメラセットアップとプレビュー表示
          if setupCamera() {
               self.cameraSession?.startRunning()
          }
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
          
          let color = image.getPixelColor(CGPointMake(0, 0))
          let luminance = ( 0.298912 * color.0 + 0.586611 * color.1 + 0.114478 * color.2 );    // rgb->輝度
          
          // カメラの画像を画面に表示、輝度表示更新
          dispatch_async(dispatch_get_main_queue()) {
               self.cameraImageView.image = image
               self.luminanceText.text = luminance.description
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

