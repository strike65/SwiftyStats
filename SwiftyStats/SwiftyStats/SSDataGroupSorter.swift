//
//  SSDataGroupSorter.swift
//  SwiftyStats
//
//  Created by volker on 10.08.17.
//  Copyright © 2017 VTSoftware. All rights reserved.
//

import Foundation
import os.log

public class SSDataGroupSorter<T> where T: Hashable, T: Comparable {
    
    
    private var g: Array<Int>
    private var o: Array<T>
    
    
    init(data: Array<T>!, groups: Array<Int>!) {
        if data.count < 2 {
            os_log("number of observations is expected to be >= 2", log: log_stat, type: .error)
        }
        if groups.count < 2 {
            os_log("number of observations is expected to be >= 2", log: log_stat, type: .error)
        }
        if groups.count != data.count {
            os_log("number of observations and number of groups.length is expected to be equal", log: log_stat, type: .error)
        }
        self.o = data
        self.g = groups
    }

    
    fileprivate func quickSort(_ lo: Int, _ hi: Int, ref: SSDataGroupSorter ) {
        var i: Int = lo
        var j: Int = hi
        let x:T = ref.o[(lo + hi) / 2]
        //        var x:T = ref.sortedData[(i + j) / 2]
        var temp: T
        var tg: Int
        while i <= j {
            while ref.o[i] < x {
                i += 1
            }
            while ref.o[j] > x {
                j -= 1
            }
            if i <= j {
                temp = ref.o[i]
                ref.o[i] = ref.o[j]
                ref.o[j] = temp
                tg = ref.g[i]
                ref.g[i] = ref.g[j]
                ref.g[j] = tg
                i += 1
                j -= 1
            }
        }
        if lo < j {
            quickSort(lo, j, ref: self)
        }
        if i < hi {
            quickSort(i, hi, ref: self)
        }
    }
    /// Returns the sorted groups and data as a tuple
    public func sortedArrays() -> (sortedGroups: Array<Int>, sortedData: Array<T>) {
        quickSort(0, self.o.count - 1, ref: self)
        return (self.g, self.o)
    }
    
}
