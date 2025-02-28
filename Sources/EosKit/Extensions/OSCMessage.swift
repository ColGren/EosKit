//
//  OSCMessage.swift
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

extension OSCMessage {
    
    internal var isFromEos: Bool { get { self.addressPattern.fullPath.hasPrefix(eosOutPrefix) }}
    
    internal func addressWithoutEosOut() -> String {
        let startIndex = self.addressPattern.fullPath.index(self.addressPattern.fullPath.startIndex, offsetBy: eosOutPrefix.count)
        return String(self.addressPattern.fullPath[startIndex...])
    }
    
    internal func isHeartbeat(with uuid: UUID) -> Bool {
        guard self.addressPattern.fullPath == eosPingRequest,
              self.arguments.count == 2,
              let argument1 = self.arguments[0] as? String,
              let argument2 = self.arguments[1] as? String else { return false }
        return argument1 == eosHeartbeatString && uuid.uuidString == argument2
    }
    
    internal func uuid() -> UUID? {
        guard  self.arguments.count >= 2 else { return nil }
        guard let uid = self.arguments[1] as? String, let uuid = UUID(uuidString: uid) else { return nil }
        return uuid
    }
    
    internal func number() -> String? {
        guard self.addressPattern.parts.count >= 3 else { return nil }
        return self.addressPattern.parts[2]
    }
    
    internal func subNumber() -> String? {
        guard self.addressPattern.parts.count >= 4 else { return nil }
        return self.addressPattern.parts[3]
    }
    
    static internal func getCount(of target: EosRecordTarget) -> OSCMessage {
        return try! OSCMessage(with: "/eos/get/\(target.part)/count")
    }
    
    static internal func get(target: EosRecordTarget, withIndex index: Int32) -> OSCMessage {
        return try! OSCMessage(with: "/eos/get/\(target.part)/index/\(index)")
    }
    
    static internal func get(target: EosRecordTarget, withUUID uuid: UUID) -> OSCMessage {
        return try! OSCMessage(with: "/eos/get/\(target.part)/uid/\(uuid)")
    }
    
    static internal func get(target: EosRecordTarget, withNumber number: String) -> OSCMessage {
        return try! OSCMessage(with: "/eos/get/\(target.part)/\(number)")
    }

}
