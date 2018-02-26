//
//  StringOperator.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2018/01/24.
//  Copyright © 2018年 annolab. All rights reserved.
//

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
	static var typename: String { return "stringCompareType" }

	init(withJSON json:JSON) {
		self.init()
		let args = json["args"]
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
		default: return []
		}
	}
}

