/*
OSCMessageOperator.swift
Koboshi

MIT LICENSE  

Copyright 2018 nariakiiwatani

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import Foundation
import SwiftOSC

enum OSCMessageCompare {
	init() { self = .any }
	case any
	case compare(address:StringCompare?, arguments:ArrayCompare?)
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
	var typename: String { return "oscMessageCompareType" }
	var flatten : Bool { return true }
	static var allTypes : [String] {
		return ["any","compare"]
	}

	init(withJSON json:JSON) {
		self.init()
		let args = flatten ? json : json["args"]
		switch json[typename] {
		case "compare": self = .compare(address:StringCompare(withJSON:args["address"]), arguments:ArrayCompare(withJSON:args["arguments"]))
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
		case let .compare(address,args): return ["address":address?.json ?? [], "arguments":args?.json ?? []]
		default: return {}
		}
	}
}

