/*
FileOperator.swift
Koboshi

MIT LICENSE  

Copyright 2018 nariakiiwatani

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import Foundation
import AppKit

enum FileState {
	init() { self = .any }
	case any
	case exist
	func execute(_ url:URL) -> Bool {
		switch self {
		case .exist:
			return FileManager().fileExists(atPath: url.path)
		default: return true
		}
	}
}
enum FileProc {
	init() { self = .none }
	case none
	case open(withApp:URL)
	case move(to:URL)
	case copy(to:URL)
	case create
	case delete
	func execute(_ url:URL) -> Bool {
		switch self {
		case .none: return true
		case let .open(app):
			return NSWorkspace().openFile(url.path, withApplication:app.path)
		case let .move(to):
			return (try? FileManager().moveItem(at: url, to: to)) != nil
		case let .copy(to):
			return (try? FileManager().copyItem(at: url, to: to)) != nil
		case .create:
			return FileManager().createFile(atPath: url.path, contents: nil)
		case .delete:
			return (try? FileManager().removeItem(at: url)) != nil
		}
	}
}


// MARK: - Json
import SwiftyJSON

extension FileState : JsonConvertibleType {
	var typename: String { return "fileStateType" }
	static var allTypes : [String] {
		return ["any","exist"]
	}

	init(withJSON json:JSON) {
		self.init()
		switch json[typename] {
		case "exist": self = .exist
		default: self = .any
		}
	}
	var type : String {
		switch self {
		case .exist: return "exist"
		default: return "any"
		}
	}
	var args : Any {
		return {}
	}
}

extension FileProc : JsonConvertibleType {
	var typename: String { return "fileProcType" }
	var flatten : Bool { return true }
	static var allTypes : [String] {
		return ["none","open","move","copy","create","delete"]
	}

	init(withJSON json:JSON) {
		self.init()
		let args = flatten ? json : json["args"]
		switch json[typename] {
		case "open": self = .open(withApp:URL(fileURLWithPath:args["withApp"].stringValue))
		case "move": self = .move(to:URL(fileURLWithPath:args["to"].stringValue))
		case "copy": self = .copy(to:URL(fileURLWithPath:args["to"].stringValue))
		case "create": self = .create
		case "delete": self = .delete
		default: self = .none
		}
	}
	var type : String {
		switch self {
		case .none: return "none"
		case .open: return "open"
		case .move: return "move"
		case .copy: return "copy"
		case .create: return "create"
		case .delete: return "delete"
		}
	}
	var args : Any {
		switch self {
		case .none,
		     .create,
		     .delete: return {}
		case let .open(url): return ["withApp":url.path]
		case let .move(url),
		     let .copy(url): return ["to":url.path] 
		}
	}
}
