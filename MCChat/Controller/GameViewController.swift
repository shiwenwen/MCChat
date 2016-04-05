//
//  GameViewController.swift
//  Flappy Bird
//
//  Created by sww on 16/3/27.
//  Copyright (c) 2016年 sww. All rights reserved.
//

import UIKit
import SpriteKit

@objc class GameViewController: UIViewController {
  
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let skView = self.view as?SKView{
            
            if skView.scene == nil{//如果没有场景
                //创建场景
                
                let scale = skView.bounds.size.height / skView.bounds.size.width//长宽比
                
                let scene = GameScene(size:CGSize(width: 320, height: 320*scale))//创建场景
                
//                skView.showsFPS = true
                skView.showsNodeCount = true //节点数量
//                skView.showsPhysics = true //物理模型
                skView.ignoresSiblingOrder = true //忽略元素添加顺序
                
                scene.scaleMode = .AspectFill //缩放
                
                skView.presentScene(scene)
                
                
            }
            
        }
        
        
    }
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    
}