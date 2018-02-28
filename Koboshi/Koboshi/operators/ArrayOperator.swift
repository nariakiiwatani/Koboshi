/*
ArrayOperator.swift
Koboshi

MIT LICENSE  

Copyright 2018 nariakiiwatani

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import Foundation

enum ArrayCompare {
	init() { self = .any }
	case any
	case count(Int)
	case element(Int,Any)
	func execute(_ data:[Any?]) -> Bool {
		switch self {
		case let .count(c): return data.count == c
		case let .element(i,d):
			guard data.count > i else {
				return false
			}
			switch data[i] {
			case is String: return strcmp((data[i] as! String), (d as! String)) == 0
			default: return JSON(data[i] as Any) == JSON(d)
			}
		default: return true
		}
	}
}

// MARK: - Json
import SwiftyJSON

extension ArrayCompare : JsonConvertibleType {
	var typename: String { return "arrayCompareType" }
	var flatten : Bool { return true }
	static var allTypes : [String] {
		return ["any","count","element"]
	}

	init(withJSON json:JSON) {
		self.init()
		let args = flatten ? json : json["args"]
		switch json[typename] {
		case "count": self = .count(args["value"].intValue)
		case "element": self = .element(args["index"].intValue, args["value"].object)
		default: self = .any
		}
	}
	var type : String {
		switch self {
		case .count: return "count"
		case .element: return "element"
		default: return "any"
		}
	}
	var args : Any {
		switch self {
		case let .count(c): return ["value":c]
		case let .element(i,d): return ["index":i, "value":d]
		default: return {}
		}
	}
}

