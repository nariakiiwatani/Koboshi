/*
ShellScriptOperator.swift
Koboshi

MIT LICENSE  

Copyright 2018 nariakiiwatani

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import Foundation

enum ShellScriptExec {
	init() { self = .none }
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
	var typename: String { return "shellScriptExecType" }
	var flatten : Bool { return true }
	static var allTypes : [String] {
		return ["none","file","command"]
	}

	init(withJSON json:JSON) {
		self.init()
		let args = flatten ? json : json["args"]
		switch json[typename] {
		case "file": self = .file(URL(fileURLWithPath:args["url"].stringValue), args["arguments"].arrayValue.map { $0.stringValue})
		case "command": self = .command(args["command"].stringValue, args["arguments"].arrayValue.map { $0.stringValue})
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
		case let .file(url, args): return ["url":url, "arguments":args]
		case let .command(command, args): return ["command":command, "arguments":args]
		default: return {}
		}
	}
}
