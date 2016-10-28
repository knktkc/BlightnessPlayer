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
     
     @IBOutlet var blightnessLabel: UILabel!
     var blightness: Float = 0.0
    
     @IBOutlet var thresholdLabel: UILabel!
     var threshold: Float = 0.0
     
     var appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
     var audioController: AudioController?
     
     var isAnimating: Bool = false
    
     // カメラ関係
     var cameraSession: AVCaptureSession?
     var cameraDevice: AVCaptureDevice?
     var videoInput: AVCaptureDeviceInput?
     var videoOutput: AVCaptureVideoDataOutput?
     @IBOutlet weak var cameraImageView: UIImageView!
     var luminanceArray: [Float] = []
     let maxKeepLuminance: Float = 300
    
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
          
          self.audioController = appDelegate.audioController
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

    }

    internal func brightnessDidChange(notification: NSNotification) {
        blightness = Float(UIScreen.mainScreen().brightness)
        blightnessLabel.text = String(format: "%.1f", blightness)
        checkThreshold()
    }

    internal func checkThreshold() {
        if (blightness <= threshold) {
            self.audioController!.playTheMusic()
            self.startAnimation()
        } else {
            self.audioController!.stopTheMusic()
            self.stopAnimation()
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
          
          // 輝度に敏感に反応するのを防ぐため30フレームの平均値を取る処理
          if self.luminanceArray.count > Int(maxKeepLuminance) {
               self.luminanceArray.removeFirst()
               self.luminanceArray.append(self.blightness)
               var totalLuminance: Float = 0
               for lumi in self.luminanceArray {
                    totalLuminance += lumi
               }
               self.blightness = totalLuminance / maxKeepLuminance
          } else {
               self.luminanceArray.append(self.blightness)
               var totalLuminance: Float = 0
               for lumi in self.luminanceArray {
                    totalLuminance += lumi
               }
               self.blightness = totalLuminance / Float(self.luminanceArray.count)
          }
          
          // カメラの画像を画面に表示、輝度表示更新
          dispatch_async(dispatch_get_main_queue()) {
               self.checkThreshold()    // ImageViewControllerの変更を通知するのでメインスレッドで起動すること
               self.cameraImageView.image = image
               self.blightnessLabel.text = String(format: "%.1f", luminance)
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
     
     // PlayViewControllerのアニメーションを開始する
     func startAnimation() {
          // 最前面のViewControllerを取得
          var topViewcon = UIApplication.sharedApplication().keyWindow?.rootViewController
          while ((topViewcon?.presentedViewController) != nil) {
               topViewcon = topViewcon?.presentedViewController
          }
          
          if topViewcon is PlayViewController && isAnimating == false {
               let playViewcon = topViewcon as! PlayViewController
               playViewcon.animationImageView.startAnimating()
               isAnimating = true
          }
     }
     
     // PlayViewControllerのアニメーションを止める
     func stopAnimation() {
          // 最前面のViewControllerを取得
          var topViewcon = UIApplication.sharedApplication().keyWindow?.rootViewController
          while ((topViewcon?.presentedViewController) != nil) {
               topViewcon = topViewcon?.presentedViewController
          }
          
          if topViewcon is PlayViewController {
               let playViewcon = topViewcon as! PlayViewController
               playViewcon.animationImageView.stopAnimating()
               isAnimating = false
          }
     }

}

