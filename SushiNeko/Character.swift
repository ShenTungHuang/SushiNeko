//
//  Character.swift
//  SushiNeko
//
//  Created by STH on 2017/5/27.
//  Copyright © 2017年 STH. All rights reserved.
//

import Foundation
import SpriteKit

class Character: SKSpriteNode
{
    
    /* Character side */
    var side: Side = .left
    {
        didSet
        {
            if side == .left
            {
                xScale = 1
                position.x = -93
            }
            else
            {
                /* An easy way to flip an asset horizontally is to invert the X-axis scale */
                xScale = -1
                position.x = 93
            }
            
            /* Load/Run the punch action */
            let punch = SKAction(named: "Punch")!
            run(punch)
        }
    }
    
    /* You are required to implement this for your subclass to work */
    override init(texture: SKTexture?, color: UIColor, size: CGSize)
    {
        super.init(texture: texture, color: color, size: size)
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}
