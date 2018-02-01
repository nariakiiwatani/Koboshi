//
//  StringOperator.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2018/01/24.
//  Copyright © 2018年 annolab. All rights reserved.
//

import Foundation

extension Operator {
	enum StringCompare {
		case none
		case equals(_:String)
		case contains(_:String)
		case regex(_:String)
		func execute(_ str:String) -> Bool {
			switch self {
			case .none: return true
			case let .equals(pattern): return str==pattern
			case let .contains(pattern): return !(str.range(of: pattern)?.isEmpty ?? true)
			case let .regex(pattern): return !(str.range(of: pattern, options: .regularExpression)?.isEmpty ?? true)
			}
		}
	}
}


// MARK: - Json
import SwiftyJSON

extension Operator.StringCompare : JsonConvertibleOperator {
	init(withJSON json:JSON) {
		let args = json["args"]
		switch json["type"] {
		case "equals": self = .equals(args["pattern"].stringValue)
		case "contains": self = .contains(args["pattern"].stringValue)
		case "regex": self = .regex(args["pattern"].stringValue)
		default: self = .none
		}
	}
	var type : String {
		switch self {
		case .equals: return "equals"
		case .contains: return "contains"
		case .regex: return "regex"
		default: return "none"
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

