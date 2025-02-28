//
//  EosDefine.swift
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

internal typealias EosKitCompletionHandler = (OSCMessage) -> Void

// MARK:- Heartbeat
internal let EosConsoleHeartbeatMaxAttempts: Int = 3
internal let EosConsoleHeartbeatInterval: TimeInterval = 5
internal let EosConsoleHeartbeatFailureInterval: TimeInterval = 1
internal let eosHeartbeatString = "EosKit Heartbeat"

// MARK:- OSC Address Patterns
internal let eosDiscoveryRequest = "/etc/discovery/request"
internal let eosDiscoveryReply = "/etc/discovery/reply"
internal let eosFiltersRemove = "/eos/filter/remove"
internal let eosFiltersAdd = "/eos/filter/add"
internal let eosSubscribe = "/eos/subscribe"
internal let eosRequestPrefix = "/eos"
internal let eosOutPrefix = "/eos/out"
internal let eosPingRequest = "/ping"

internal let eosSystemFilters: Set =            ["/get/version",
                                                 "/ping",
                                                 "/filter/add",
                                                 "/filter/remove"]

internal let eosPatchFilters: Set =             ["/get/patch/count",
                                                 "/get/patch/#/#/list/#/#",
                                                 "/get/patch/#/#/notes",
                                                 "/notify/patch/list/#/#"]

internal let eosCueListFilters: Set =           ["/get/cuelist/count",
                                                 "/get/cuelist/#/list/#/#",
                                                 "/get/cuelist/#/links/list/#/#",
                                                 "/notify/cuelist/list/#/#"]

internal let eosCueFilters: Set =               ["/get/cuelist/count",
                                                 "/get/cuelist/#/list/#/#",
                                                 "/get/cue/#/count", // Get the number of cues (including parts) for a given cue list.
                                                 "/get/cue/#/#/#/list/#/#",
                                                 "/get/cue/#/#/#/fx/list/#/#",
                                                 "/get/cue/#/#/#/links/list/#/#",
                                                 "/get/cue/#/#/#/actions/list/#/#",
                                                 "/notify/cue/#/list/#/#"]

internal let eosCueNoPartsFilters: Set =        ["/get/cuelist/count",
                                                 "/get/cuelist/#/list/#/#",
                                                 "/get/cue/#/noparts/count", // Get the number of cues (excluding parts) for a given cue list.
                                                 "/get/cue/#/#/noparts/list/#/#",
                                                 "/get/cue/#/#/noparts/fx/list/#/#",
                                                 "/get/cue/#/#/noparts/links/list/#/#",
                                                 "/get/cue/#/#/noparts/actions/list/#/#",
                                                 "/get/cue/#/#/count", // Get the number of parts for a given cue.
                                                 "/get/cue/#/#/#/list/#/#",
                                                 "/get/cue/#/#/#/fx/list/#/#",
                                                 "/get/cue/#/#/#/links/list/#/#",
                                                 "/get/cue/#/#/#/actions/list/#/#",
                                                 "/notify/cue/#/list/#/#",
                                                 "/get/cue/#/#"] // You'll receive /get/cue/0/0 if you request a cue by the uuid that no longet exists.

internal let eosGroupFilters: Set =             ["/get/group/count",
                                                 "/get/group/#/list/#/#",
                                                 "/get/group/#/channels/list/#/#",
                                                 "/notify/group/list/#/#",
                                                 "/get/group/0"]

internal let eosMacroFilters: Set =             ["/get/macro/count",
                                                 "/get/macro/#/list/#/#",
                                                 "/get/macro/#/text/list/#/#",
                                                 "/get/macro/0"]

internal let eosSubFilters: Set =               ["/get/sub/count",
                                                 "/get/sub/#/list/#/#",
                                                 "/get/sub/#/fx/list/#/#",
                                                 "/get/sub/0"]

internal let eosPresetFilters: Set =            ["/get/preset/count",
                                                 "/get/preset/#/list/#/#",
                                                 "/get/preset/#/channels/list/#/#",
                                                 "/get/preset/#/byType/list/#/#",
                                                 "/get/preset/#/fx/list/#/#",
                                                 "/get/preset/0"]

internal let eosIntensityPaletteFilters: Set =  ["/get/ip/count",
                                                 "/get/ip/#/list/#/#",
                                                 "/get/ip/#/channels/list/#/#",
                                                 "/get/ip/#/byType/list/#/#",
                                                 "/get/ip/0"]

internal let eosFocusPaletteFilters: Set =      ["/get/fp/count",
                                                 "/get/fp/#/list/#/#",
                                                 "/get/fp/#/channels/list/#/#",
                                                 "/get/fp/#/byType/list/#/#",
                                                 "/get/fp/0"]

internal let eosColorPaletteFilters: Set =      ["/get/cp/count",
                                                 "/get/cp/#/list/#/#",
                                                 "/get/cp/#/channels/list/#/#",
                                                 "/get/cp/#/byType/list/#/#",
                                                 "/get/cp/0"]

internal let eosBeamPaletteFilters: Set =       ["/get/bp/count",
                                                 "/get/bp/#/list/#/#",
                                                 "/get/bp/#/channels/list/#/#",
                                                 "/get/bp/#/byType/list/#/#",
                                                 "/get/bp/0"]

internal let eosCurveFilters: Set =             ["/get/curve/count",
                                                 "/get/curve/#/list/#/#",
                                                 "/get/curve/0"]

internal let eosEffectFilters: Set =            ["/get/fx/count",
                                                 "/get/fx/#/list/#/#",
                                                 "/get/fx/0"]

internal let eosSnapshotFilters: Set =          ["/get/snap/count",
                                                 "/get/snap/#/list/#/#",
                                                 "/get/snap/0"]

internal let eosPixelMapFilters: Set =          ["/get/pixmap/count",
                                                 "/get/pixmap/#/list/#/#",
                                                 "/get/pixmap/#/channels/list/#/#",
                                                 "/get/pixmap/0"]

internal let eosMagicSheetFilters: Set =        ["/get/ms/count",
                                                 "/get/ms/#/list/#/#",
                                                 "/get/ms/0"]

internal let eosSetupFilters: Set =             ["/get/setup/list/#/#"]

internal let eosPlaybackFilters: Set =          ["/event/cue/#/#/fire"]
