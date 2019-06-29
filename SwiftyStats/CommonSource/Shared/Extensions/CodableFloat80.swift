//
//  Created by VT on 08.08.18.
//  Copyright © 2018 strike65. All rights reserved.
//
/*
 Copyright (2017-2019) strike65
 
 GNU GPL 3+
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, version 3 of the License.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 */

import Foundation

#if arch(i386) || arch(x86_64)
/// Add Codable protocol conformance to Float80
extension Float80: Codable {
    private enum CodingKeys: String, CodingKey {
        case string = "stringValue"
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let stringRep: String = "\(self)"
        try container.encode(stringRep, forKey: .string)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let string = try container.decode(String.self, forKey: .string)
        if let f = Float80.init(string) {
            self = f
        }
        else {
            self = Float80.nan
        }
    }
}

#endif
