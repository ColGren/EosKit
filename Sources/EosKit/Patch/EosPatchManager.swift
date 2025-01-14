//
//  EosPatchManager.swift
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
import Combine

internal final class EosPatchManager: EosTargetManagerProtocol {
    
    private let console: EosConsole
    private let targets: CurrentValueSubject<[EosChannel], Never>
    internal var addressFilter = OSCAddressFilter()

    private var managerProgress: Progress?
    private var progress: Progress?
    /// A dictionary of `OSCMessage`'s to build an EosChannel with its component `EosChannelPart`'s.
    ///
    /// - The key of the dictionary is the EosChannel number.
    /// - `count` is the number of parts the channel has.
    /// - `parts` holds the current cached arrays of part messages.
    private var messages: [String:(count: UInt32, parts: [[OSCMessage]])] = [:]
    
    init(console: EosConsole, targets: CurrentValueSubject<[EosChannel], Never>, progress: Progress? = nil) {
        self.console = console
        self.targets = targets
        self.managerProgress = progress
        addressFilter.priority = .string
    }
    
    internal func count(message: OSCMessage) -> () {
        guard let count = message.arguments[0] as? Int32 else { return }
        progress = Progress(totalUnitCount: Int64(count))
        managerProgress?.addChild(progress!, withPendingUnitCount: 1)
        for index in 0..<count {
            console.send(OSCMessage.get(target: .patch, withIndex: index))
        }
    }
    
    internal func index(message: OSCMessage) {
        guard let number = message.number(), let subNumber = message.subNumber() else { return }
        if let targetMessage = messages[number], targetMessage.parts.first?.first?.number() == number {
            if let partIndex = targetMessage.parts.firstIndex(where: { $0.contains { $0.subNumber() == subNumber } }) {
                // This will be a notes message
                messages[number]?.parts[partIndex].append(message)
            } else {
                messages[number]?.parts.append([message])
                // TODO: This function gets called via a notify message which isnt part of the synchronise proceedure...
                // Do we need to query whether we are currently synchronising?
                progress?.completedUnitCount += 1
            }
        } else {
            // This gets called once per channel when receiving the first part.
            guard message.addressPattern.fullPath.hasSuffix("notes") == false,
                  let partCount = message.arguments[19] as? NSNumber,
                  let uPartCount = UInt32(exactly: partCount) else { return }
            messages[number] = (count: uPartCount, parts: [[message]])
            // TODO: This function gets called triggered via a notify message which isnt part of the synchronise proceedure...
            // Do we need to query whether we are currently synchronising?
            progress?.completedUnitCount += 1
        }
        if let targetMessages = messages[number],
           targetMessages.count == targetMessages.parts.count,
           targetMessages.parts.allSatisfy({ $0.count == EosChannelPart.stepCount }),
           let uNumber = UInt32(number)
        {
            let channel = EosChannel(number: uNumber, parts: targetMessages.parts.compactMap { EosChannelPart(messages: $0) }.sorted(by: { $0.number < $1.number }))
            if let firstIndex = targets.value.firstIndex(where: { $0.number == channel.number }) {
                targets.value[firstIndex] = channel
            } else {
                let index = targets.value.insertionIndex(for: { $0.number < channel.number })
                targets.value.insert(channel, at: index)
            }
            messages[number] = nil
        }
    }
    
    private func notify(message: OSCMessage) {
        synchronize()
    }
    
    func synchronize() {
        if addressFilter.methods.isEmpty {
            var methods: Set<OSCFilterMethod> = []
            EosRecordTarget.patch.filters.forEach {
                let address = try! OSCFilterAddress($0)
                if $0.hasSuffix("count") {
                    methods.insert(OSCFilterMethod(with: address,
                                                   invokedAction: { message, _ in
                        self.count(message: message)
                    }))
                } else if $0.hasPrefix("/notify") {
                    methods.insert(OSCFilterMethod(with: address,
                                                   invokedAction: { message, _ in
                        self.notify(message: message)
                    }))
                } else {
                    methods.insert(OSCFilterMethod(with: address,
                                                   invokedAction: { message, _ in
                        self.index(message: message)
                    }))
                }
            }
            addressFilter.methods = methods
        }
        messages.removeAll()
        targets.value.removeAll()
        console.send(OSCMessage.getCount(of: .patch))
    }

}
