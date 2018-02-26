//
//  OSCMessageOperator.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2018/01/24.
//  Copyright © 2018年 annolab. All rights reserved.
//

import Foundation
import SwiftOSC

enum OSCMessageCompare {
	init() { self = .any }
	case any
	case compare(address:StringCompare?, args:ArrayCompare?)
	func execute(_ message:OSCMessage) -> Bool {
		switch self {
		case let .compare(address, args):
			return (address?.execute(message.address.string) ?? true) && (args?.execute(message.arguments) ?? true)
		default: return true
		}
	}
}


// MARK: - Json
import SwiftyJSON

extension OSCMessageCompare : JsonConvertibleType {
	static var typename: String { return "oscMessageCompareType" }

	init(withJSON json:JSON) {
		self.init()
		let args = json["args"]
		switch json[typename] {
		case "compare": self = .compare(address:StringCompare(withJSON:args["address"]), args:ArrayCompare(withJSON:args["args"]))
		default: self = .any
		}
	}
	var type : String {
		switch self {
		case .compare: return "compare"
		default: return "any"
		}
	}
	var args : Any {
		switch self {
		case let .compare(address,args): return ["address":address?.json ?? [], "args":args?.json ?? []]
		default: return []
		}
	}
}

