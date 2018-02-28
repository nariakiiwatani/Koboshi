/*
Operator.swift
Koboshi

MIT LICENSE  

Copyright 2018 nariakiiwatani

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

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

extension Operator : JsonConvertibleType {
	var typename: String { return "operatorType" }
	var flatten : Bool { return true }
	static var allTypes : [String] {
		return ["none","always","never","and","nand","or","xor",
		"ifthen","ifnot","ifelse","anyway","ignore",
		"stringCompare","arrayCompare","appState","appProc","fileState","fileProc","shellScriptExec"]
	}

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
			
		case .stringCompare: return "stringCompare"

		case .arrayCompare: return "arrayCompare"

		case .applicationState: return "appState"
		case .applicationProc: return "appProc"

		case .fileState: return "fileState"
		case .fileProc: return "fileProc"

		case .shellScriptExec: return "shellScriptExec"
		}
	}
	var args : Any {
		switch self {
		case .none,
		     .always,
		     .never: return {}
		case let .and(l,r),
		     let .nand(l,r),
		     let .or(l,r),
		     let .xor(l,r): return ["cond1":l.json, "cond2":r.json]
		case let .ifthen(c,s),
		     let .ifnot(c,s): return ["condition":c.json, "statement":s.json]
		case let .ifelse(c,t,f): return ["condition":c.json, "iftrue":t.json, "iffalse":f.json]
		case let .anyway(o),
		     let .ignore(o): return ["statement":o.json]

		case let .stringCompare(str, comparator): return ["string":str, "comparator":comparator.json]

		case let .arrayCompare(arr, comparator): return ["array":arr, "comparator":comparator.json]

		case let .applicationState(url, state): return ["url":url.path, "state":state.json]
		case let .applicationProc(url, proc): return ["url":url.path, "proc":proc.json]
			
		case let .fileState(url, state): return ["url":url.path, "state":state.json]
		case let .fileProc(url, proc): return ["url":url.path, "proc":proc.json]
		
		case let .shellScriptExec(program,exec): return ["program":program.path, "exec":exec.json]
		}
	}
	init(withJSON json:JSON) {
		self.init()
		let args = flatten ? json : json["args"]
		switch json[typename] {
		case "none":	self = .none
		case "always":	self = .always
		case "never":	self = .never
		case "and":		self = .and(Operator(withJSON: args["cond1"]), Operator(withJSON: args["cond2"]))
		case "nand":	self = .nand(Operator(withJSON: args["cond1"]), Operator(withJSON: args["cond2"]))
		case "or":		self = .or(Operator(withJSON: args["cond1"]), Operator(withJSON: args["cond2"]))
		case "xor":		self = .xor(Operator(withJSON: args["cond1"]), Operator(withJSON: args["cond2"]))
		case "ifthen":	self = .ifthen(Operator(withJSON: args["condition"]), Operator(withJSON: args["statement"]))
		case "ifnot":	self = .ifnot(Operator(withJSON: args["condition"]), Operator(withJSON: args["statement"]))
		case "ifelse":	self = .ifelse(Operator(withJSON: args["condition"]), Operator(withJSON: args["iftrue"]), Operator(withJSON: args["ifelse"]))
		case "anyway":	self = .anyway(Operator(withJSON: args["statement"]))
		case "ignore":	self = .ignore(Operator(withJSON: args["statement"]))
		case "stringCompare":	self = .stringCompare(args["string"].stringValue, StringCompare(withJSON: args["comparator"]))
		case "arrayCompare":	self = .arrayCompare(args["array"].arrayValue, ArrayCompare(withJSON: args["comparator"]))
		case "appState":		self = .applicationState(url:URL(fileURLWithPath: args["url"].stringValue), AppState(withJSON: args["state"]))
		case "appProc":			self = .applicationProc(url:URL(fileURLWithPath: args["url"].stringValue), AppProc(withJSON: args["proc"]))
		case "fileState":		self = .fileState(url:URL(fileURLWithPath: args["url"].stringValue), FileState(withJSON: args["state"]))
		case "fileProc":		self = .fileProc(url:URL(fileURLWithPath: args["url"].stringValue), FileProc(withJSON: args["proc"]))
		case "shellScriptExec":	self = .shellScriptExec(program:URL(fileURLWithPath: args["program"].stringValue), ShellScriptExec(withJSON: args["exec"]))
		default: self = .none
		}
	}
}

