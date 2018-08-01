//
//  ScreenSize_IOS.swift
//  Cherry Inspect
//
//  Created by Jefferson S. Batista on 8/8/16.
//  Copyright © 2016 Slate Development. All rights reserved.
//

import UIKit

struct ScreenSize
{
    static let SCREEN_WIDTH = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

