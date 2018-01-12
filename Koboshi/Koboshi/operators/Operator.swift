//
//  Operator.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2017/12/27.
//  Copyright © 2017年 annolab. All rights reserved.
//

import Foundation
import SwiftyJSON

indirect enum Operator {
	
	init() {
		self = .none
	}
	case none
	case always
	case never
	case and(Operator, Operator)
	case nand(Operator, Operator)
	case or(Operator, Operator)
	case xor(Operator, Operator)
	case ifthen(Operator, Operator)
	case ifnot(Operator, Operator)
	case ifelse(Operator, Operator, Operator)
	case anyway(Operator)
	case ignore(Operator)

	case applicationState(url:URL, AppState)
	case applicationProc(url:URL, AppProc)

	func execute() -> Bool {
		switch self {
		case .none: assert(false); return true
		case .always: return true
		case .never: return false
		case let .and(l,r): return l.execute() && r.execute()
		case let .nand(l,r): return !(l.execute() && r.execute())
		case let .or(l,r): return l.execute() || r.execute()
		case let .xor(l,r): return l.execute() != r.execute()
		case let .ifthen(c,s): return c.execute() ? s.execute() : true
		case let .ifnot(c,s): return c.execute() ? true : s.execute()
		case let .ifelse(c,t,f): return c.execute() ? t.execute() : f.execute()
		case let .anyway(o): return o.execute() || true
		case .ignore(_): return true
			
		case let .applicationState(url, state): return state.execute(url)
		case let .applicationProc(url, proc): return proc.execute(url)
			
		}
	}

	// MARK: - JSONConvertible
	var type : String {
		switch self {
		case .none: return "none"
		case .always: return "always"
		case .never: return "never"
		case .and: return "and"
		case .nand: return "nand"
		case .or: return "or"
		case .xor: return "xor"
		case .ifthen: return "ifthen"
		case .ifnot: return "ifnot"
		case .ifelse: return "ifelse"
		case .anyway: return "anyway"
		case .ignore: return "ignore"

		default: return ""
//		case let .applicationState(_,state): return state.type
//		case let .applicationProc(_,proc): return proc.type
		}
	}
	var arg : Any {
		switch self {
		case let .and(l,r),
		     let .nand(l,r),
		     let .or(l,r),
		     let .xor(l,r): return [l.json, r.json]
		case let .ifthen(c,s),
		     let .ifnot(c,s): return [c.json, s.json]
		case let .ifelse(c,t,f): return [c.json, t.json, f.json]
		case let .anyway(o),
		     let .ignore(o): return o.json
			
//		case let .applicationState(url, state): return state.execute(url)
//		case let .applicationProc(url, proc): return proc.execute(url)
			
		default: return [:]
		}
	}
	init(withJSON json:JSON) {
		let args = json["args"]
		switch json["type"] {
		case "none":	self = .none
		case "always":	self = .always
		case "never":	self = .never
		case "and":		self = .and(Operator(withJSON: args[0]), Operator(withJSON: args[1]))
		case "nand":	self = .nand(Operator(withJSON: args[0]), Operator(withJSON: args[1]))
		case "or":		self = .or(Operator(withJSON: args[0]), Operator(withJSON: args[1]))
		case "xor":		self = .xor(Operator(withJSON: args[0]), Operator(withJSON: args[1]))
		case "ifthen":	self = .ifthen(Operator(withJSON: args[0]), Operator(withJSON: args[1]))
		case "ifnot":	self = .ifnot(Operator(withJSON: args[0]), Operator(withJSON: args[1]))
		case "ifelse":	self = .ifelse(Operator(withJSON: args[0]), Operator(withJSON: args[1]), Operator(withJSON: args[2]))
		case "anyway":	self = .anyway(Operator(withJSON: args))
		case "ignore":	self = .ignore(Operator(withJSON: args))
		default: self = .none
		}
	}
	var json : JSON {
		return [
			"type" : JSON(type),
			"args" : JSON(arg)
			]
	}
}

