//
//  EosCueList.swift
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
//

import Foundation
import OSCKit

public struct EosCueList: EosTarget, Hashable {

    static internal let stepCount: Int = 2
    static internal let target: EosRecordTarget = .cueList
    public let number: Double // This is only a Double to conform to EosTarget, in reality it's a UInt32.
    public let uuid: UUID
    public let label: String
    public let playbackMode: String
    public let faderMode: String
    public let independent: Bool
    public let htp: Bool
    public let assert: Bool
    public let block: Bool
    public let background: Bool
    public let soloMode: Bool
    public let timecodeList: UInt32?
    public let oosSync: Bool
    public let links: [Double]
    public let cues: [EosCue]?
    
    internal init?(messages: [OSCMessage]) {
        self.init(messages: messages, cues: nil)
    }
    
    internal init?(messages: [OSCMessage], cues: [EosCue]? = nil) {
        guard messages.count == Self.stepCount,
              let indexMessage = messages.first(where: { $0.addressPattern.fullPath.contains("links") == false }),
              let linksMessage = messages.first(where: { $0.addressPattern.fullPath.contains("links") == true }),
              let number = indexMessage.number(), let double = Double(number),
              let uuid = indexMessage.uuid(),
              let label = indexMessage.arguments[2] as? String,
              let playbackMode = indexMessage.arguments[3] as? String,
              let faderMode = indexMessage.arguments[4] as? String,
              let independent = indexMessage.arguments[5] as? Bool,
              let htp = indexMessage.arguments[6] as? Bool,
              let assert = indexMessage.arguments[7] as? Bool,
              let block = indexMessage.arguments[8] as? Bool,
              let background = indexMessage.arguments[9] as? Bool,
              let soloMode = indexMessage.arguments[10] as? Bool,
              let timecodeList = indexMessage.arguments[11] as? NSNumber,
              let oosSync = indexMessage.arguments[12] as? Bool
        else { return nil }
        self.number = double
        self.uuid = uuid
        self.label = label
        self.playbackMode = playbackMode
        self.faderMode = faderMode
        self.independent = independent
        self.htp = htp
        self.assert = assert
        self.block = block
        self.background = background
        self.soloMode = soloMode
        self.timecodeList = UInt32(exactly: timecodeList)
        self.oosSync = oosSync
        
        var linkedCueLists: [Double] = []
        for argument in linksMessage.arguments[2...] {
            let lists = EosOSCNumber.doubles(from: argument)
            linkedCueLists += lists
        }
        self.links = linkedCueLists.sorted()
        self.cues = cues
    }

}
