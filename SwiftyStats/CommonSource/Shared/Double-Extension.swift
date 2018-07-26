//
//  Created by VT on 25.07.18.
//  Copyright © 2018 Volker Thieme. All rights reserved.
//
/*
 Copyright (c) 2017 Volker Thieme
 
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

import Foundation


extension Double {
    /// Adds the function sgn().
    /// - Returns: -1.0 if the receiver is < 0.0, +1.0 otherwise
    public var sgn: Double {
        get {
            if self.sign == .minus {
                return -1.0
            }
            else {
                return 1.0
            }
        }
    }
    
    public var gammaValue: Double {
        get {
            let res = tgamma(self)
            return res
        }
    }
    
    public var lGammaValue: Double {
        get {
            return lgamma(self)
        }
    }
    
    public var inverse: Double {
        get {
            if self.isZero {
                return Double.infinity
            }
            else {
                return 1.0 / self
            }
        }
    }
    
}
