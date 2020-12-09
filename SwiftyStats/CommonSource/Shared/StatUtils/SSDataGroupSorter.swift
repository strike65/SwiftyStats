//
//  SSDataGroupSorter.swift
//  SwiftyStats
//
//  Created by strike65 on 03.07.17.
//
/*
 Copyright (2017-2019) strike65
 
 GNU GPL 3+
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, version 3 of the License.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 */

#if os(macOS) || os(iOS)
import os.log
#endif



/// Sorts a given array in ascending order. Used for ranking.
/// Suppose we have a group named 'A' and a group 'B'.
/// Let the measurements for A and B be
///
/// `a = [1,4,6]`
///
/// `b = [0,3,2]`
///
/// respectively. We construct the input array `data` by appending b to a:
///
/// `c = a + b = [1,4,6,0,3,1]`
///
/// The array `groups` is constructed in the same way:
///
/// `groups =  [A,A,A,B,B,B]`
///
/// Result:
///
/// `sortedArrays().sortedGroups` would be: `[B,A,B,B,A,A]`
///
/// `sortedArrays().sortedData` would then be: `[0,1,2,3,4,6]`
internal class SSDataGroupSorter<T> where T: Hashable, T: Comparable, T: Codable {
    private var g: Array<Int>
    private var o: Array<T>
    
    init(data: Array<T>!, groups: Array<Int>!) {
        if data.count < 2 {
            #if os(macOS) || os(iOS)
            if #available(macOS 10.12, iOS 13, *) {
                os_log("number of observations is expected to be >= 2", log: .log_stat, type: .error)
            }
            #endif
            
        }
        if groups.count < 2 {
            #if os(macOS) || os(iOS)
            if #available(macOS 10.12, iOS 13, *) {
                os_log("number of observations is expected to be >= 2", log: .log_stat, type: .error)
            }
            #endif
            
        }
        if groups.count != data.count {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("number of observations and number of groups is expected to be equal", log: .log_stat, type: .error)
            }
            
            #endif
            
        }
        self.o = data
        self.g = groups
    }
    
    private func quickSort(_ lo: Int, _ hi: Int, ref: SSDataGroupSorter ) {
        var i: Int = lo
        var j: Int = hi
        let x:T = ref.o[(lo + hi) / 2]
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
    func sortedArrays() -> (sortedGroups: Array<Int>, sortedData: Array<T>) {
        quickSort(0, self.o.count - 1, ref: self)
        return (self.g, self.o)
    }
}
