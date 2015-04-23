//
//  ViewController.swift
//  pintu
//
//  Created by 颜魏 on 15/4/12.
//  Copyright (c) 2015年 颜魏. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITextFieldDelegate {

    var diffculty:Int = 4
    var labelArray:NSArray = []
    var screenW:CGFloat = UIScreen.mainScreen().bounds.width
    var screenH:CGFloat = UIScreen.mainScreen().bounds.height
    var whiteView:UIView = UIView()
    var originalDataArray:NSMutableArray = [] //成功时图片的顺序
    var dataArray:NSMutableArray = [] //实时图片顺序
    var successDirectionArray:NSMutableArray = [] //记录通关的步奏
    var imageWidth:CGFloat = 0.0
    var timeLabel:UILabel = UILabel()
    var timer:NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var button = UIButton(frame: CGRectMake(screenW-80, 40, 60, 30))
        button.addTarget(self, action: "actionStart:", forControlEvents: UIControlEvents.TouchUpInside)
        button.layer.masksToBounds = true;
        button.layer.cornerRadius = 5;
        button.backgroundColor = UIColor.grayColor()
        button.setTitle("开始", forState: UIControlState.Normal)
        button.titleLabel!.textColor = UIColor.redColor()
        button.titleLabel?.font = UIFont(name: "Heiti SC", size: 15)
        self.view.addSubview(button)
        
        var tf = UITextField(frame: CGRectMake(20, 40, 150, 30))
        tf.delegate = self
        tf.placeholder = "请输入游戏的星级2-10"
        tf.borderStyle = UITextBorderStyle.RoundedRect
        tf.font = UIFont(name: "Heiti SC", size: 13)
        tf.layer.masksToBounds = true;
        tf.layer.cornerRadius = 5;
        self.view.addSubview(tf)
        
        timeLabel.frame = CGRectMake((screenW-100)/2, 80, 100, 20)
        timeLabel.textAlignment = NSTextAlignment.Center
        timeLabel.text = ""
        self.view.addSubview(timeLabel)
        
    
        //初始化游戏界面
        initGameView()
        
    }
    
    var timeCount = 0
    //计时器
    func time() {
        timeCount += 1
        timeLabel.text = "时间: " + "\(timeCount)"
    }
    
    //开始游戏事件
    func actionStart(button:UIButton) {
        //随机生成一副拼图
        bringIntoBeingGame()
        timeLabel.text = ""
        
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "time", userInfo: nil, repeats: true)
    }
    
    //初始化游戏界面
    func initGameView() {

        var view = UIView(frame: CGRectMake(screenW/2-CGFloat(20*diffculty)/2, screenH-CGFloat(20*diffculty+20), CGFloat(20*diffculty), CGFloat(20*diffculty)))
        self.view.addSubview(view)
        view.backgroundColor = UIColor.whiteColor()
        
        var colors:Array = [UIColor]()
        for i in 0..<diffculty*diffculty {
            var arc = arc4random()%3
            var color:[UIColor] = [UIColor.blackColor(), UIColor.redColor(), UIColor.greenColor()]
            colors.append(color[i%3])
        }

        var space:CGFloat = 40
        var width:CGFloat = (screenW-2*space)/CGFloat(diffculty)
        imageWidth = width
        for i in 0..<diffculty {
            for j in 0..<diffculty {
                //留出最后一个空白视图
                let x:CGFloat = width*CGFloat(j)+space
                let y:CGFloat = 70+width*CGFloat(i)+space
                if i*diffculty+j >= diffculty*diffculty-1 {
                    whiteView = UIView(frame: CGRectMake(x, y, width-1, width-1))
                    dataArray.addObject(whiteView)
                    originalDataArray.addObject(whiteView)
                    whiteView.backgroundColor = UIColor.lightGrayColor()
                    self.view.addSubview(whiteView)
                    
                    return
                }
                
                var backgroundView = UIView(frame: CGRectMake(x, y, width-1, width-1))
                self.view.addSubview(backgroundView)
                dataArray.addObject(backgroundView)
                originalDataArray.addObject(backgroundView)
                var gesture = UITapGestureRecognizer()
                gesture.addTarget(self, action: "tap:")
                backgroundView.addGestureRecognizer(gesture)
                
                var label = UILabel(frame: CGRectMake(0, 0, width-1, width-1))
                backgroundView.addSubview(label)
                label.userInteractionEnabled = true
                label.text = "\(i*diffculty+j)"
                if diffculty >= 7 {
                    label.font = UIFont(name: "Heiti SC", size: 20)
                }else {
                    label.font = UIFont(name: "Heiti SC", size: 30)
                }
                label.textColor = UIColor.whiteColor()
                label.textAlignment = NSTextAlignment.Center
                label.backgroundColor = colors[i*diffculty+j]
                
                //效果图
                var image = UIImageView(frame: CGRectMake(CGFloat(20*j), CGFloat(20*i), 20, 20))
                view.addSubview(image)
                image.backgroundColor = colors[i*diffculty+j]
                var label1 = UILabel(frame: CGRectMake(0, 0, 20, 20))
                label1.text = "\(i*diffculty+j)"
                label1.textColor = UIColor.whiteColor()
                label1.textAlignment = NSTextAlignment.Center
                label1.font = UIFont(name: "Heiti SC", size: 13)
                image.addSubview(label1)

            }
        
        }
        
    }
    
    //手势响应方法
    func tap(gesture:UITapGestureRecognizer) {
        var value = isCanMove(gesture.view!, withDirection: "")
        if value.value == true {
            dataArray.exchangeObjectAtIndex(dataArray.indexOfObject(whiteView), withObjectAtIndex: dataArray.indexOfObject(gesture.view!))
            switch value.direction {
                case  "Up":
                    UIView.animateWithDuration(0.1, animations: { () -> Void in
                        self.whiteView.frame.origin.y -= self.imageWidth
                        gesture.view!.frame.origin.y += self.imageWidth
                    })
                case  "Down":
                    UIView.animateWithDuration(0.1, animations: { () -> Void in
                        self.whiteView.frame.origin.y += self.imageWidth
                        gesture.view!.frame.origin.y -= self.imageWidth
                    })
                case  "Left":
                    UIView.animateWithDuration(0.1, animations: { () -> Void in
                        self.whiteView.frame.origin.x += self.imageWidth
                        gesture.view!.frame.origin.x -= self.imageWidth
                    })
                case  "Right":
                    UIView.animateWithDuration(0.1, animations: { () -> Void in
                        self.whiteView.frame.origin.x -= self.imageWidth
                        gesture.view!.frame.origin.x += self.imageWidth
                    })
                default:
                    println("参数错误")
            }
        }
        //检测是否成功
        isSuccess()
    }

    var befroeDirection:String = ""
    //随机生成一个拼图
    func bringIntoBeingGame() {
        var cnt:Int = 100
        for i in 0..<cnt {
            var directionArray:Array = ["Up", "Down", "Left", "Right"]
            var direction = directionArray[Int(arc4random()%4)]
            switch direction {
                case "Up":
                    if befroeDirection == "Down" {
                        continue
                    }
                case "Down":
                    if befroeDirection == "Up" {
                        continue
                }
                case "Left":
                    if befroeDirection == "Right" {
                        continue
                }
                case "Right":
                    if befroeDirection == "Left" {
                        continue
                }
                default:
                    println("参数错误")
            }
            befroeDirection = direction

            var value = isCanMove(whiteView, withDirection: direction)
            if value.value == true {
                successDirectionArray.addObject(value.direction)
                switch value.direction {
                    case  "Up":
                        var index = dataArray.indexOfObject(whiteView)-diffculty
                        var view:UIView = dataArray[index] as! UIView
                        dataArray.exchangeObjectAtIndex(dataArray.indexOfObject(whiteView), withObjectAtIndex: index)
                        UIView.animateWithDuration(0.1, animations: { () -> Void in
                            self.whiteView.frame.origin.y -= self.imageWidth
                            view.frame.origin.y += self.imageWidth
                        })
                    case  "Down":
                        var index = dataArray.indexOfObject(whiteView)+diffculty
                        var view:UIView = dataArray[index] as! UIView
                        dataArray.exchangeObjectAtIndex(dataArray.indexOfObject(whiteView), withObjectAtIndex: index)
                        UIView.animateWithDuration(0.1, animations: { () -> Void in
                            self.whiteView.frame.origin.y += self.imageWidth
                            view.frame.origin.y -= self.imageWidth
                        })
                    case  "Left":
                        var index = dataArray.indexOfObject(whiteView)-1
                        var view:UIView = dataArray[index] as! UIView
                        dataArray.exchangeObjectAtIndex(dataArray.indexOfObject(whiteView), withObjectAtIndex: index)
                        UIView.animateWithDuration(0.1, animations: { () -> Void in
                            self.whiteView.frame.origin.x -= self.imageWidth
                            view.frame.origin.x += self.imageWidth
                        })
                    case  "Right":
                        var index = dataArray.indexOfObject(whiteView)+1
                        var view:UIView = dataArray[index] as! UIView
                        dataArray.exchangeObjectAtIndex(dataArray.indexOfObject(whiteView), withObjectAtIndex: index)
                        UIView.animateWithDuration(0.1, animations: { () -> Void in
                            self.whiteView.frame.origin.x += self.imageWidth
                            view.frame.origin.x -= self.imageWidth
                        })
                    default :
                        println("参数错误")
                }
            }
        }
        moveWhiteViewToLastLocation()
    }
    
    //将随机生成的拼图的空白图片放到最后一个
    func moveWhiteViewToLastLocation() {
        var index = dataArray.indexOfObject(whiteView)
        for i in index % diffculty ..< diffculty-1 {
            var view = dataArray[index+1] as! UIView
            dataArray.exchangeObjectAtIndex(index, withObjectAtIndex: index+1)
            index = dataArray.indexOfObject(whiteView)
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.whiteView.frame.origin.x += self.imageWidth
                view.frame.origin.x -= self.imageWidth
            })
        }
        for j in index / diffculty ..< diffculty-1 {
            var view = dataArray[index+diffculty] as! UIView
            dataArray.exchangeObjectAtIndex(index, withObjectAtIndex: index+diffculty)
            index = dataArray.indexOfObject(whiteView)
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.whiteView.frame.origin.y += self.imageWidth
                view.frame.origin.y -= self.imageWidth
            })
        }
    }
    
    //判断某一个图片是否能响应某一个方向的移动事件
    func isCanMove(view:UIView, withDirection direction:String) -> (value:Bool, direction:String) {
        if view == whiteView {
            let index = dataArray.indexOfObject(whiteView)
            switch direction {
                case "Up":
                    if index < diffculty {
                        return  (false, "Up")
                    }else {
                        return (true, "Up")
                    }
                case "Down":
                    if index >= Int (diffculty * Int(diffculty-1)) {
                        return (false, "Down")
                    }else {
                        return (true, "Down")
                    }
                case "Left":
                    let cnt = index % diffculty
                    if cnt != 0 {
                        return (true, "Left")
                    }else {
                        return (false, "Left")
                    }
                case "Right":
                    let cnt = index % diffculty
                    if cnt != diffculty-1 {
                        return (true, "Right")
                    }else {
                        return (false, "Right")
                    }
                default:
                    return (false, "other")

                }
        }else {
            let index1 = dataArray.indexOfObject(whiteView)
            let index2 = dataArray.indexOfObject(view)
            //判断传入的这个图片是否和空图相邻
            switch index1-index2 {
                case  diffculty:
                    return (true, "Up")
                case  -diffculty:
                    return (true, "Down")
                case  -1:
                    return (true, "Left")
                case  1:
                    return (true, "Right")
                default:
                    return (false, "other")
            }
        }
    }
    
    //检测游戏是否成功
    func isSuccess() {
        var value:Bool = true
        for i in 0..<diffculty*diffculty {
            if dataArray[i] as! UIView != originalDataArray[i] as! UIView {
                value = false
            }
        }
        
        if value == true {
            timer?.invalidate()
            timeCount = 0
            var alterView = UIAlertView(title: "过关", message: "你太厉害了", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "确定")
            alterView.show()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        println(textField.text)
        if textField.text.toInt()! > 10 || textField.text.toInt()! < 2 {
            var alterView = UIAlertView(title: "", message: "你选择的关卡不存在", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "确定")
            alterView.show()
        }else {
            dataArray.removeAllObjects()
            originalDataArray.removeAllObjects()
            removeAllSubViews()
            diffculty = textField.text.toInt()!;
            initGameView()
            bringIntoBeingGame()
        }
        textField.text = ""
        textField.resignFirstResponder()
        
        return true
    }
    
    func removeAllSubViews() {
        for view in self.view.subviews {
            if view.isKindOfClass(UIView) || view.isKindOfClass(UILabel) {
                if view.isKindOfClass(UITextField) {
                    println("textFile")
                }else if view.isKindOfClass(UIButton) {
                    println("button")
                }else {
                    view .removeFromSuperview()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

