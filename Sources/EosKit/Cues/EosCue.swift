//
//  EosCue.swift
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

public struct EosCue: EosTarget, Hashable, Identifiable {
    
    public var id: UUID { uuid }
    static internal let stepCount: Int = 4
    static internal let target: EosRecordTarget = .cue
    public let listNumber: Double          // This is only a Double to conform to EosTarget, in reality it's a UInt32.
    public let number: Double
    public let uuid: UUID
    public let label: String
    public let upTimeDuration: Int32       // milliseconds
    public let upTimeDelay: Int32          // milliseconds
    public let downTimeDuration: Int32     // milliseconds
    public let downTimeDelay: Int32        // milliseconds
    public let focusTimeDuration: Int32    // milliseconds
    public let focusTimeDelay: Int32       // milliseconds
    public let colorTimeDuration: Int32    // milliseconds
    public let colorTimeDelay: Int32       // milliseconds
    public let beamTimeDuration: Int32     // milliseconds
    public let beamTimeDelay: Int32        // milliseconds
    public let preheat: Bool               // TODO: Preheat levels?
    public let curve: Double?              // OSC Number
    public let rate: UInt32
    public let mark: String                // "m", "M" or ""
    public let block: String               // "b", "B" or ""
    public let assert: String              // "a", "A" or ""
    public let link: String                // OSC Number or String - String if links to a separate cue list.
    public let followTime: Int32           // milliseconds
    public let hangTime: Int32             // milliseconds
    public let allFade: Bool
    public let loop: Int32
    public let solo: Bool
    public let timecode: String
    public let partCount: UInt32           // This will always show the true part count.
    public let cueNotes: String
    public let sceneText: String
    public let sceneEnd: Bool
    public let effects: [Double]
    public let links: [Double]
    public let actions: String
    public let parts: [EosCuePart]         // Depending on the sync options this will either contain the parts or will be empty if only cues have been synced.
    
    init?(messages: [OSCMessage]) {
        self.init(messages: messages, parts: [])
    }
    
    init?(messages: [OSCMessage], parts: [EosCuePart]) {
        guard messages.count == Self.stepCount,
              let indexMessage = messages.first(where: { $0.addressPattern.fullPath.contains("fx") == false &&
                                                    $0.addressPattern.fullPath.contains("links") == false &&
                                                    $0.addressPattern.fullPath.contains("actions") == false }),
              let fxMessage = messages.first(where: { $0.addressPattern.fullPath.contains("fx") == true }),
              let linksMessage = messages.first(where: { $0.addressPattern.fullPath.contains("links") == true }),
              let actionsMessage = messages.first(where: { $0.addressPattern.fullPath.contains("actions") == true }),
              let listNumber = indexMessage.number(), let dListNumber = Double(listNumber),
              let number = indexMessage.subNumber(), let double = Double(number),
              let uuid = indexMessage.uuid(),
              let label = indexMessage.arguments[2] as? String,
              let upTimeDuration = indexMessage.arguments[3] as? Int32,
              let upTimeDelay = indexMessage.arguments[4] as? Int32,
              let downTimeDuration = indexMessage.arguments[5] as? Int32,
              let downTimeDelay = indexMessage.arguments[6] as? Int32,
              let focusTimeDuration = indexMessage.arguments[7] as? Int32,
              let focusTimeDelay = indexMessage.arguments[8] as? Int32,
              let colorTimeDuration = indexMessage.arguments[9] as? Int32,
              let colorTimeDelay = indexMessage.arguments[10] as? Int32,
              let beamTimeDuration = indexMessage.arguments[11] as? Int32,
              let beamTimeDelay = indexMessage.arguments[12] as? Int32,
              let preheat = indexMessage.arguments[13] as? Bool,
              let curve = EosOSCNumber.doubles(from:  indexMessage.arguments[14]).first,
              let rate = indexMessage.arguments[15] as? Int32, let uRate = UInt32(exactly: rate),
              let mark = indexMessage.arguments[16] as? String,
              let block = indexMessage.arguments[17] as? String,
              let assert = indexMessage.arguments[18] as? String,
              let link = EosCue.link(from: indexMessage.arguments[19]),
              let followTime = indexMessage.arguments[20] as? Int32,
              let hangTime = indexMessage.arguments[21] as? Int32,
              let allFade = indexMessage.arguments[22] as? Bool,
              let loop = indexMessage.arguments[23] as? Int32,
              let solo = indexMessage.arguments[24] as? Bool,
              let timecode = indexMessage.arguments[25] as? String,
              let partCount = indexMessage.arguments[26] as? Int32, let uPartCount = UInt32(exactly: partCount),
              let cueNotes = indexMessage.arguments[27] as? String,
              let sceneText = indexMessage.arguments[28] as? String,
              let sceneEnd = indexMessage.arguments[29] as? Bool
        else { return nil }
        self.listNumber = dListNumber
        self.number = double
        self.uuid = uuid
        self.label = label
        self.upTimeDuration = upTimeDuration
        self.upTimeDelay = upTimeDelay
        self.downTimeDuration = downTimeDuration
        self.downTimeDelay = downTimeDelay
        self.focusTimeDuration = focusTimeDuration
        self.focusTimeDelay = focusTimeDelay
        self.colorTimeDuration = colorTimeDuration
        self.colorTimeDelay = colorTimeDelay
        self.beamTimeDuration = beamTimeDuration
        self.beamTimeDelay = beamTimeDelay
        self.preheat = preheat
        self.curve = curve
        self.rate = uRate
        self.mark = mark
        self.block = block
        self.assert = assert
        self.link = link
        self.followTime = followTime
        self.hangTime = hangTime
        self.allFade = allFade
        self.loop = loop
        self.solo = solo
        self.timecode = timecode
        self.partCount = uPartCount
        self.cueNotes = cueNotes
        self.sceneText = sceneText
        self.sceneEnd = sceneEnd
        
        var effectsList: [Double] = []
        for argument in fxMessage.arguments[2...] {
            let effects = EosOSCNumber.doubles(from: argument)
            effectsList += effects
        }
        self.effects = effectsList
        
        var linkedCueLists: [Double] = []
        for argument in linksMessage.arguments[2...] {
            let lists = EosOSCNumber.doubles(from: argument)
            linkedCueLists += lists
        }
        self.links = linkedCueLists

        if actionsMessage.arguments.count == 3, let actions = actionsMessage.arguments[2] as? String {
            self.actions = actions
        } else {
            self.actions = ""
        }
        
        self.parts = parts
    }
    
    internal static func link(from any: Any) -> String? {
        if let int = any as? Int32 {
            return int == 0 ? "" : String(int)
        }
        if let string = any as? String {
            return string
        }
        return nil
    }
    
}

extension EosCue: CustomStringConvertible {
    
    public var description: String {
        "Cue \(number)\(label.isEmpty == true ? "" : " - \(label)")"
    }
    
}
