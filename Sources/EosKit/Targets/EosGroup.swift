//
//  EosGroup.swift
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


/// An Eos Group
///
/// Groups do not receive notification changes when an Eos console has changed the patch.
/// Whilst groups are considered a collection of channels, the two are *very* loosely coupled.
/// You should consider a group as a shortcut to place a collection of channels in a specific
/// order onto the command line.
public struct EosGroup: EosTarget, Hashable {

    static internal let stepCount: Int = 2
    static internal let target: EosRecordTarget = .group
    public let number: Double
    public let uuid: UUID
    public let label: String
    public let channels: [Double]
    
    internal init?(messages: [OSCMessage]) {
        guard messages.count == Self.stepCount,
              let indexMessage = messages.first(where: { $0.addressPattern.fullPath.contains("channels") == false }),
              let channelsMessage = messages.first(where: { $0.addressPattern.fullPath.contains("channels") == true }),
              let number = indexMessage.number(), let double = Double(number),
              let uuid = indexMessage.uuid(),
              let label = indexMessage.arguments[2] as? String
        else { return nil }
        self.number = double
        self.uuid = uuid
        self.label = label
        var channelsList: [Double] = []
        for argument in channelsMessage.arguments[2...] where channelsMessage.arguments.count >= 3 {
            let channelsAsDoubles = EosOSCNumber.doubles(from: argument)
            channelsList += channelsAsDoubles
        }
        self.channels = channelsList
    }
    
}

