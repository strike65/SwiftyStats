//
//  SSDataFrame.swift
//  SwiftyStats
//
//  Created by volker on 19.08.17.
//  Copyright © 2017 VTSoftware. All rights reserved.
//

import Foundation

// Defines a structure holding multiple SSExamine objects:
// Each column or row contains an SSExamine object. Basically this makes no difference. But we can imagine what's going on much better that way.
public class SSDataFrame<SSElement> where SSElement: Comparable, SSElement: Hashable{
    
    private var data:Array<SSExamine<SSElement>>
    private var tags: Array<Any>
    
    init(count: Int) {
        data = Array<SSExamine<SSElement>>.init()
        tags = Array<Any>.init()
    }
    
    
}
