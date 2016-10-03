//
//  ViewController.swift
//
//  Created by TakeshiKaneko on 2016/09/09.
//  Copyright © 2016年 TakeshiKaneko. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
     let userDefaults = NSUserDefaults.standardUserDefaults()
     var titleArray: [String] = []
     
     @IBOutlet var blightnessLabel: UILabel!
     var blightness: Float = 0.0
     @IBOutlet weak var luminanceText: UITextField!
    
     @IBOutlet var thresholdLabel: UILabel!
     var threshold: Float = 0.9
    
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

