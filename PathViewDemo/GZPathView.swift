//
//  GZPathView.swift
//  Test
//
//  Created by Grady Zhuo on 3/19/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import UIKit
import QuartzCore

//擴充UIColor，取得同為ColorSpace為RGB的CGColor
//參考來源: http://stackoverflow.com/questions/970475/how-to-compare-uicolors
extension UIColor{
    
    func convertToRGBColorSpace()->CGColorRef{
        
        var oldComponents = [CGFloat]()
        var oldComponentsPtr = CGColorGetComponents(self.CGColor)
        var bufferPtr = UnsafeBufferPointer(start: oldComponentsPtr, count: 2)
        
        
        if CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor)).value == kCGColorSpaceModelMonochrome.value {
            
            let red = bufferPtr[0]
            let green = bufferPtr[0]
            let blue = bufferPtr[0]
            let alpha = bufferPtr[1]
            
            return CGColorCreate(CGColorSpaceCreateDeviceRGB(), [red, green, blue, alpha])
        }
        
        return self.CGColor
        
    }
}

//擴充CALayer，取得特定點所代表的顏色
//參考來源 : http://stackoverflow.com/questions/1160229/how-to-get-the-color-of-a-pixel-in-an-uiview

extension CALayer {
    
    
    
    func colorOfPoint(point:CGPoint)->CGColor
    {
        var pixel:[CUnsignedChar] = [0,0,0,0]
        var colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let bitmapInfo = CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue)
        
        let context = CGBitmapContextCreate(&pixel, 1, 1, 8, 4, colorSpace,bitmapInfo)
        
        CGContextTranslateCTM(context, -point.x, -point.y)
        
        self.renderInContext(context)
        
        let red:CGFloat = CGFloat(pixel[0])/255.0
        let green:CGFloat = CGFloat(pixel[1])/255.0
        let blue:CGFloat = CGFloat(pixel[2])/255.0
        let alpha:CGFloat = CGFloat(pixel[3])/255.0
        
        return CGColorCreate(colorSpace, [red, green, blue, alpha])
    }
    
}

//描述使用者touch時的狀態enum
enum GZPathViewTrackingStatus{
    case Begin
    case Move
    case End
    case Cancel
}

//畫路徑用的View
class GZPathView:UIControl{
    
    var trackingState:GZPathViewTrackingStatus = .Begin
    private var unitBezierPath:UIBezierPath = UIBezierPath()
    
    var pathColor:UIColor = UIColor.blackColor(){
        didSet{
            self.setupLayer()
        }
    }
    
    var pathPoints:[CGPoint] = []{
        didSet{
            self.unitBezierPath = self.createBezierPath(pathPoints)
            self.setupLayer()
        }
    }
    
    var isInside:Bool = false{
        didSet{
            
            self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
            
        }
    }
    
    
    
    var lineWidth:CGFloat = 10{
        //variable的observer，效果同Objective-C的KVO(Key-Value-Observer)
        didSet{
            
            self.setupLayer()
        }
    }
    
    override class func layerClass() -> AnyClass{
        return CAShapeLayer.self
    }

    
    func setupLayer(){

        var shapeLayer = self.layer as CAShapeLayer
        
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        shapeLayer.strokeColor = self.pathColor.CGColor
        shapeLayer.lineWidth = self.lineWidth
        shapeLayer.bounds = self.bounds
        
    }
    
    //layer進行layout時會呼叫的method
    override func layoutSublayersOfLayer(layer: CALayer!) {
        
        self.setupLayer()
        
        //把單位路徑放大到目前的size. 並扣掉邊框寬度的一半
        var transform = CGAffineTransformMakeTranslation(self.lineWidth/2, self.lineWidth/2)
        transform = CGAffineTransformScale(transform, self.bounds.width - self.lineWidth, self.bounds.height - self.lineWidth)
        
        var path = CGPathCreateCopyByTransformingPath(self.unitBezierPath.CGPath, &transform)
        
        var shapeLayer = layer as CAShapeLayer
        shapeLayer.path = path
        
        super.layoutSublayersOfLayer(layer)
    }
    
    func createBezierPath(points:[CGPoint])->UIBezierPath{
        
        //make a new path
        var path = UIBezierPath()
        
        //取points的第一個點代表起點，如果沒有第一個，就用(0,0)代替
        let startPoint = points.first ?? CGPoint.zeroPoint
        
        //移到第一個點的地方
        path.moveToPoint(startPoint)
        
        //把路徑資訊以直線的方式加上去
        for i in 1..<points.count {
            var point = points[i]
            path.addLineToPoint(point)
        }
        
        return path
    }
    
    //透過按到的顏色，檢查Touch的點是不是在Inside
    func checkTouchInside(touch:UITouch)->Bool{
        
        var shapeLayer = self.layer as CAShapeLayer
        var detectedColor = self.layer.colorOfPoint(touch.locationInView(self))
        
        self.isInside = CGColorEqualToColor(pathColor.convertToRGBColorSpace(), detectedColor)
        
        return self.isInside
        
    }
    
    //UIControl的tracking event實作
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        self.trackingState = .Begin
        return self.checkTouchInside(touch)
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        self.trackingState = .Move
        return self.checkTouchInside(touch)
    }
    
    override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
        self.trackingState = .End
        self.checkTouchInside(touch)
    }
    
    override func cancelTrackingWithEvent(event: UIEvent?) {
        self.trackingState = .Cancel
        self.isInside = false
    }
    
}
