//
//  ShellScriptOperator.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2018/01/02.
//  Copyright © 2018年 annolab. All rights reserved.
//

import Foundation

enum ShellScriptExec {
	case none
	case file(URL, [String])
	case command(String, [String])
	private func shell(launchPath: String, arguments: [String]) -> (Int, String) {
		let task = Process()
		task.launchPath = launchPath
		task.arguments = arguments
		
		let pipe = Pipe()
		task.standardOutput = pipe
		task.launch()
		
		let data = pipe.fileHandleForReading.readDataToEndOfFile()
		let output = String(data: data, encoding: String.Encoding.utf8)!
		if output.characters.count > 0 {
			//remove newline character.
			let lastIndex = output.index(before: output.endIndex)
			return (Int(task.terminationStatus), output[output.startIndex ..< lastIndex])
		}
		return (Int(task.terminationStatus), output)
	}
	
	func execute(_ program:URL) -> Bool {
		switch self {
		case let .file(url, args):
			var arguments = args
			arguments.insert(url.path, at:0)
			return shell(launchPath: program.path, arguments: arguments).0 == 0
		case let .command(command, args):
			let path = shell(launchPath: program.path, arguments: [ "-l", "-c", "which \(command)" ])
			return path.0 == 0 ? shell(launchPath: path.1, arguments: args).0 == 0 : false
		default: return true
		}
	}
}

//MARK: - Json
import SwiftyJSON

extension ShellScriptExec : JsonConvertibleType {
	init(withJSON json:JSON) {
		let args = json["args"]
		switch json["type"] {
		case "file": self = .file(URL(fileURLWithPath:args["url"].stringValue), args["args"].arrayValue.map { $0.stringValue})
		case "command": self = .command(args["command"].stringValue, args["args"].arrayValue.map { $0.stringValue})
		default: self = .none
		}
	}
	var type : String {
		switch self {
		case .file: return "file"
		case .command: return "command"
		default: return "none"
		}
	}
	var args : Any {
		switch self {
		case let .file(url, args): return ["url":url, "args":args]
		case let .command(command, args): return ["command":command, "args":args]
		default: return []
		}
	}
}
