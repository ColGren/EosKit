//
//  EosIntensityPalette.swift
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

public struct EosIntensityPalette: EosTarget, Hashable {
    
    static internal let stepCount: Int = 3
    static internal let target: EosRecordTarget = .intensityPalette
    public let number: Double
    public let uuid: UUID
    public let label: String
    public let absolute: Bool
    public let locked: Bool
    public let channels: [Double]
    public let byTypeChannels: [Double]
    
    internal init?(messages: [OSCMessage]) {
        guard messages.count == Self.stepCount,
              let indexMessage = messages.first(where: { $0.addressPattern.fullPath.contains("channels") == false &&
                                                    $0.addressPattern.fullPath.contains("byType") == false }),
              let channelsMessage = messages.first(where: { $0.addressPattern.fullPath.contains("channels") == true }),
              let byTypeMessage = messages.first(where: { $0.addressPattern.fullPath.contains("byType") == true }),
              let number = indexMessage.number(), let double = Double(number),
              let uuid = indexMessage.uuid(),
              let label = indexMessage.arguments[2] as? String,
              let absolute = indexMessage.arguments[3] as? Bool,
              let locked = indexMessage.arguments[4] as? Bool
        else { return nil }
        self.number = double
        self.uuid = uuid
        self.label = label
        self.absolute = absolute
        self.locked = locked
        
        var channelsList: [Double] = []
        for argument in channelsMessage.arguments[2...] where channelsMessage.arguments.count >= 3 {
            let channelsAsDoubles = EosOSCNumber.doubles(from: argument)
            channelsList += channelsAsDoubles
        }
        self.channels = channelsList.sorted()
        
        var byTypeChannelsList: [Double] = []
        for argument in byTypeMessage.arguments[2...] where byTypeMessage.arguments.count >= 3 {
            let byTypeChannelsAsDoubles = EosOSCNumber.doubles(from: argument)
            byTypeChannelsList += byTypeChannelsAsDoubles
        }
        self.byTypeChannels = byTypeChannelsList.sorted()
    }

}

