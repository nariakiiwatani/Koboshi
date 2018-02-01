//
//  OSCMessageOperator.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2018/01/24.
//  Copyright © 2018年 annolab. All rights reserved.
//

import Foundation
import SwiftOSC

extension Operator {
	enum OSCMessageCompare {
		case none
		case compare(address:StringCompare, args:ArrayCompare)
		func execute(_ message:OSCMessage) -> Bool {
			switch self {
			case let .compare(address, args):
				return address.execute(message.address.string) && args.execute(message.arguments)
			default: return true
			}
		}
	}
}


// MARK: - Json
import SwiftyJSON

extension Operator.OSCMessageCompare : JsonConvertibleOperator {
	init(withJSON json:JSON) {
		let args = json["args"]
		switch json["type"] {
		case "compare": self = .compare(address:Operator.StringCompare(withJSON:args["address"]), args:Operator.ArrayCompare(withJSON:args["args"]))
		default: self = .none
		}
	}
	var type : String {
		switch self {
		case .compare: return "compare"
		default: return "none"
		}
	}
	var args : Any {
		switch self {
		case let .compare(address,args): return ["address":address.json, "args":args.json]
		default: return []
		}
	}
}

