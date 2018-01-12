//
//  FileOperator.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2018/01/02.
//  Copyright © 2018年 annolab. All rights reserved.
//

import Foundation
import AppKit

extension Operator {
	enum FileState {
		case none
		case exist
		func execute(_ url:URL) -> Bool {
			switch self {
			case .none: return true
			case .exist:
				return FileManager().fileExists(atPath: url.path)
			}
		}
	}
	enum FileProc {
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
}


// MARK: - Json
import SwiftyJSON

extension Operator.FileState : JsonConvertibleOperator {
	init(withJSON json:JSON) {
		switch json["type"] {
		case "exist": self = .exist
		default: self = .none
		}
	}
	var type : String {
		switch self {
		case .none: return "none"
		case .exist: return "exist"
		}
	}
	var args : Any {
		return []
	}
}

extension Operator.FileProc : JsonConvertibleOperator {
	init(withJSON json:JSON) {
		switch json["type"] {
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
