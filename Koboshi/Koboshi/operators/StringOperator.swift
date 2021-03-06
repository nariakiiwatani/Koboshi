/*
StringOperator.swift
Koboshi

MIT LICENSE  

Copyright 2018 nariakiiwatani

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import Foundation

enum StringCompare {
	init() { self = .any }
	case any
	case equals(_:String)
	case contains(_:String)
	case regex(_:String)
	func execute(_ str:String) -> Bool {
		switch self {
		case let .equals(pattern): return str==pattern
		case let .contains(pattern): return !(str.range(of: pattern)?.isEmpty ?? true)
		case let .regex(pattern): return !(str.range(of: pattern, options: .regularExpression)?.isEmpty ?? true)
		default: return true
		}
	}
}


// MARK: - Json
import SwiftyJSON

extension StringCompare : JsonConvertibleType {
	var typename: String { return "stringCompareType" }
	var flatten : Bool { return true }
	static var allTypes : [String] {
		return ["any","equals","contains","regex"]
	}

	init(withJSON json:JSON) {
		self.init()
		let args = flatten ? json : json["args"]
		switch json[typename] {
		case "equals": self = .equals(args["pattern"].stringValue)
		case "contains": self = .contains(args["pattern"].stringValue)
		case "regex": self = .regex(args["pattern"].stringValue)
		default: self = .any
		}
	}
	var type : String {
		switch self {
		case .equals: return "equals"
		case .contains: return "contains"
		case .regex: return "regex"
		default: return "any"
		}
	}
	var args : Any {
		switch self {
		case let .equals(str),
		     let .contains(str),
		     let .regex(str): return ["pattern":str]
		default: return {}
		}
	}
}

