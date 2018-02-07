//
//  Operator.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2017/12/27.
//  Copyright © 2017年 annolab. All rights reserved.
//

import Foundation

indirect enum Operator {
	
	init() {
		self = .none
	}
	init(_ bool:Bool) {
		self = bool ? .always : .never
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
	
	case stringCompare(_:String, StringCompare)

	case arrayCompare(_:[Any?], ArrayCompare)

	case applicationState(url:URL, AppState)
	case applicationProc(url:URL, AppProc)

	case fileState(url:URL, FileState)
	case fileProc(url:URL, FileProc)
	
	case shellScriptExec(program:URL, ShellScriptExec)

	func execute() -> Bool {
		switch self {
		case .none: return true
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

		case let .stringCompare(str, comparator): return comparator.execute(str)

		case let .arrayCompare(arr, comparator): return comparator.execute(arr)

		case let .applicationState(url, state): return state.execute(url)
		case let .applicationProc(url, proc): return proc.execute(url)

		case let .fileState(url, state): return state.execute(url)
		case let .fileProc(url, proc): return proc.execute(url)
			
		case let .shellScriptExec(program, exec): return exec.execute(program)


		}
	}
}


//MARK: - Json
import SwiftyJSON

protocol JsonConvertibleOperator {
	init(withJSON json:JSON)
	var type : String{get}
	var args : Any{get}
	var json : JSON{get}
}

extension JsonConvertibleOperator {
	var json : JSON {
		return [
			"type" : JSON(type),
			"args" : JSON(args)
		]
	}
}
extension Operator : JsonConvertibleOperator {
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
			
		case let .stringCompare(_,comparator): return "stringCompare."+comparator.type

		case let .arrayCompare(_,comparator): return "arrayCompare."+comparator.type

		case let .applicationState(_,state): return "appState."+state.type
		case let .applicationProc(_,proc): return "appProc."+proc.type

		case let .fileState(_,state): return "fileState."+state.type
		case let .fileProc(_,proc): return "fileProc."+proc.type

		case let .shellScriptExec(_,exec): return "shellScriptExec."+exec.type
		}
	}
	var args : Any {
		switch self {
		case .none,
		     .always,
		     .never: return []
		case let .and(l,r),
		     let .nand(l,r),
		     let .or(l,r),
		     let .xor(l,r): return [l.json, r.json]
		case let .ifthen(c,s),
		     let .ifnot(c,s): return [c.json, s.json]
		case let .ifelse(c,t,f): return [c.json, t.json, f.json]
		case let .anyway(o),
		     let .ignore(o): return o.json

		case let .stringCompare(str, comparator): return ["string":str, "args":comparator.args]

		case let .arrayCompare(arr, comparator): return ["array":arr, "args":comparator.args]

		case let .applicationState(url, state): return ["url":url.path, "args":state.args]
		case let .applicationProc(url, proc): return ["url":url.path, "args":proc.args]
			
		case let .fileState(url, state): return ["url":url.path, "args":state.args]
		case let .fileProc(url, proc): return ["url":url.path, "args":proc.args]
		
		case let .shellScriptExec(program,exec): return ["program":program.path, "args":exec.args]
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
		case let type where type.stringValue.hasPrefix("stringCompare."):
			let childJson: JSON = [
				"type" : type.stringValue.components(separatedBy: ".")[1],
				"args" : args["args"]
			]
			self = .stringCompare(args["string"].stringValue, Operator.StringCompare(withJSON: childJson))
		case let type where type.stringValue.hasPrefix("arrayCompare."):
			let childJson: JSON = [
				"type" : type.stringValue.components(separatedBy: ".")[1],
				"args" : args["args"]
			]
			self = .arrayCompare(args["array"].arrayValue, Operator.ArrayCompare(withJSON: childJson))
		case let type where type.stringValue.hasPrefix("appState."):
			let childJson: JSON = [
				"type" : type.stringValue.components(separatedBy: ".")[1],
				"args" : args["args"]
			]
			self = .applicationState(url:URL(fileURLWithPath: args["url"].stringValue), Operator.AppState(withJSON: childJson))
		case let type where type.stringValue.hasPrefix("appProc."):
			let childJson: JSON = [
				"type" : type.stringValue.components(separatedBy: ".")[1],
				"args" : args["args"]
			]
			self = .applicationProc(url:URL(fileURLWithPath: args["url"].stringValue), Operator.AppProc(withJSON: childJson))
		case let type where type.stringValue.hasPrefix("fileState."):
			let childJson: JSON = [
				"type" : type.stringValue.components(separatedBy: ".")[1],
				"args" : args["args"]
			]
			self = .fileState(url:URL(fileURLWithPath: args["url"].stringValue), Operator.FileState(withJSON: childJson))
		case let type where type.stringValue.hasPrefix("fileProc."):
			let childJson: JSON = [
				"type" : type.stringValue.components(separatedBy: ".")[1],
				"args" : args["args"]
			]
			self = .fileProc(url:URL(fileURLWithPath: args["url"].stringValue), Operator.FileProc(withJSON: childJson))
		case let type where type.stringValue.hasPrefix("shellScriptExec."):
			let childJson: JSON = [
				"type" : type.stringValue.components(separatedBy: ".")[1],
				"args" : args["args"]
			]
			self = .shellScriptExec(program:URL(fileURLWithPath: args["program"].stringValue), Operator.ShellScriptExec(withJSON: childJson))
		default: self = .none
		}
	}
}

