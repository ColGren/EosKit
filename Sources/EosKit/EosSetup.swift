//
//  EosSetup.swift
//  EosKit
//
//  Created by Sam Smallman on 12/05/2020.
//  Copyright © 2020 Sam Smallman. https://github.com/SammySmallman
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import OSCKit

public struct EosSetup: Hashable {

    var upTimeDuration: Int32       // milliseconds
    var downTimeDuration: Int32     // milliseconds
    var focusTimeDuration: Int32    // milliseconds
    var colorTimeDuration: Int32    // milliseconds
    var beamTimeDuration: Int32     // milliseconds
    
    init?(message: OSCMessage) {
        guard let upTimeDuration = message.arguments[0] as? Int32,
              let downTimeDuration = message.arguments[1] as? Int32,
              let focusTimeDuration = message.arguments[2] as? Int32,
              let colorTimeDuration = message.arguments[3] as? Int32,
              let beamTimeDuration = message.arguments[4] as? Int32
        else { return nil }
        self.upTimeDuration = upTimeDuration
        self.downTimeDuration = downTimeDuration
        self.focusTimeDuration = focusTimeDuration
        self.colorTimeDuration = colorTimeDuration
        self.beamTimeDuration = beamTimeDuration
    }

}
