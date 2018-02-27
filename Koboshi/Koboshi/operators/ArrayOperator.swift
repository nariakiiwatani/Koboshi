//
//  ArrayOperator.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2018/01/24.
//  Copyright © 2018年 annolab. All rights reserved.
//

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
	static var allTypes : [String] {
		return ["any","count","element"]
	}

	init(withJSON json:JSON) {
		self.init()
		let args = json["args"]
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
		default: return []
		}
	}
}

