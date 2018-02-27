//
//  FileOperator.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2018/01/02.
//  Copyright © 2018年 annolab. All rights reserved.
//

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
		return []
	}
}

extension FileProc : JsonConvertibleType {
	var typename: String { return "fileProcType" }
	static var allTypes : [String] {
		return ["none","open","move","copy","create","delete"]
	}

	init(withJSON json:JSON) {
		self.init()
		switch json[typename] {
		case "open": self = .open(withApp:URL(fileURLWithPath:json["args"]["withApp"].stringValue))
		case "move": self = .move(to:URL(fileURLWithPath:json["args"]["to"].stringValue))
		case "copy": self = .copy(to:URL(fileURLWithPath:json["args"]["to"].stringValue))
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
		     .delete: return []
		case let .open(url): return ["withApp":url.path]
		case let .move(url),
		     let .copy(url): return ["to":url.path] 
		}
	}
}
