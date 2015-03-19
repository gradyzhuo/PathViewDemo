//
//  ViewController.swift
//  Test
//
//  Created by Grady Zhuo on 3/18/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tipLabel:UILabel!
    @IBOutlet weak var pathView:GZPathView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tipLabel.text = "" //reset
        
        
        //預計會畫的單位路徑的點陣列
        let points = [CGPoint(x:0, y:0), CGPoint(x: 0.0, y: 0.2), CGPoint(x: 0.3, y: 0.2), CGPoint(x: 0.3, y: 0.7), CGPoint(x: 1.0, y: 1.0)]
        
        //設定Path的點座標
        self.pathView.pathPoints = points
        
        //設定Path的顏色
//        self.pathView.pathColor = UIColor.redColor()
        
        
    }

    @IBAction func pathTracking(sender:AnyObject){
    
        var pathView = sender as GZPathView
        
        var tip = ""
        
        if pathView.isInside {
            
            tip = "在線裡面"
            
            if pathView.trackingState == GZPathViewTrackingStatus.Move {
                tip = "還" + tip
            }
            
        }else{
            
            tip = "超出線，結束。"
        }
        
        self.tipLabel.text = "\(tip)"
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

