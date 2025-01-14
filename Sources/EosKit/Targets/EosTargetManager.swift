//
//  EosTargetManager.swift
//  EosKit
//
//  Created by Sam Smallman on 06/04/2021.
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

internal class EosTargetManager<T: EosTarget>: EosTargetManagerProtocol {
    
    private let targets: CurrentValueSubject<[T], Never>
    private let console: EosConsole
    internal var addressFilter = OSCAddressFilter()
    
    private var managerProgress: Progress?
    private var progress: Progress?
    private var messages: [UUID:[OSCMessage]] = [:]
    
    init(console: EosConsole, targets: CurrentValueSubject<[T], Never>, progress: Progress? = nil) {
        self.console = console
        self.targets = targets
        self.managerProgress = progress
        addressFilter.priority = .string
    }
    
    private func count(message: OSCMessage) {
        guard let count = message.arguments[0] as? Int32, count > 0 else {
            managerProgress?.completedUnitCount = 1
            return
        }
        progress = Progress(totalUnitCount: Int64(count))
        managerProgress?.addChild(progress!, withPendingUnitCount: 1)
        for index in 0..<count {
            console.send(OSCMessage.get(target: T.target, withIndex: index))
        }
    }
    
    private func index(message: OSCMessage) {
        guard let number = message.number() else { return }
        if number == "0" {
            // The EosConsole has been notified of a change to a target and details have
            // been requested using the uuid for a target that does not exist anymore.
            if let uuid = message.uuid(), let firstIndex = targets.value.firstIndex(where: { $0.uuid == uuid }) {
                messages[uuid] = nil
                targets.value.remove(at: firstIndex)
            }
        } else if message.arguments.isEmpty {
            // The EosConsole has been notified of a change to a target and details have been requested using the number
            // for a target that does not exist anymore. The likelihood of receiving this message is very low as all
            // requests for detailed information use either the index number provided by the count method, or the
            // uuid directly associated with the target in the targets. The only time you would see this called
            // would be when a target has been deleted and detailed information has been requested using the
            // old target number... which we don't do.
            if let dNumber = Double(number), let firstIndex = targets.value.firstIndex(where: { $0.number == dNumber }) {
                messages[targets.value[firstIndex].uuid] = nil
                targets.value.remove(at: firstIndex)
            }
        } else {
            guard let uuid = message.uuid() else { return }
            if let targetMessage = messages[uuid], targetMessage.first?.number() == number {
                messages[uuid]?.append(message)
            } else {
                messages[uuid] = [message]
            }
            if let targetMessages = messages[uuid], targetMessages.count == T.stepCount {
                if let target = T(messages: targetMessages) {
                    if let firstIndex = targets.value.firstIndex(where: { $0.uuid == target.uuid }) {
                        targets.value[firstIndex] = target
                    } else {
                        let index = targets.value.insertionIndex { $0.number < target.number }
                        targets.value.insert(target, at: index)
                    }
                    // TODO: This function also gets triggered by a notify message which isnt part of the synchronise proceedure...
                    // Do we need to query whether we are currently synchronising?
                    progress?.completedUnitCount += 1
                }
                messages[uuid] = nil
            }
        }
    }
    
    private func notify(message: OSCMessage) {
        var targetList: Set<Double> = []
        for argument in message.arguments[1...] where message.arguments.count >= 2 {
            targetList = targetList.union(EosOSCNumber.doubles(from: argument))
        }
        for targetNumber in targetList {
            if let target = targets.value.first(where: { $0.number == targetNumber }) {
                console.send(OSCMessage.get(target: T.target, withUUID: target.uuid))
            } else {
                console.send(OSCMessage.get(target: T.target, withNumber: "\(targetNumber)"))
            }
        }
    }
    
    func synchronize() {
        if addressFilter.methods.isEmpty {
            var methods: Set<OSCFilterMethod> = []
            T.target.filters.forEach {
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
        console.send(OSCMessage.getCount(of: T.target))
    }
    
}
