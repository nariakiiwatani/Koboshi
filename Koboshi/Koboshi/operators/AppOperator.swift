/*
AppOperator.swift
Koboshi

MIT LICENSE  

Copyright 2018 nariakiiwatani

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import Foundation
import AppKit

enum AppState {
	init() { self = .any }
	case any
	case running
	case notRunning
	case active
	func execute(_ url:URL) -> Bool {
		let apps = NSWorkspace.shared().runningApplications.filter{
			$0.bundleURL?.path == url.path
		}
		switch self {
		case .any: return true
		case .running:
			return apps.isEmpty ? false :
				apps.contains(where: { (app:NSRunningApplication) -> Bool in
					return app.isFinishedLaunching
				})
		case .notRunning:
			return apps.isEmpty
		case .active:
			return apps.isEmpty ? false :
				apps.contains(where: { (app:NSRunningApplication) -> Bool in
					return app.isActive
				})
		}
	}
}

enum AppProc {
	init() { self = .none }
	case none
	case launch
	case launchWithOptions(NSWorkspaceLaunchOptions, [String])
	case activate
	case terminate
	func execute(_ url:URL) -> Bool {
		let apps = NSWorkspace.shared().runningApplications.filter{
			$0.bundleURL?.path == url.path
		}
		switch self {
		case .none: return true
		case .launch:
			return (try? NSWorkspace().launchApplication(at: url, options: [], configuration: [:])) != nil
		case let .launchWithOptions(options, args):
			return (try? NSWorkspace().launchApplication(at: url, options: options, configuration: [NSWorkspaceLaunchConfigurationArguments:args])) != nil
		case .terminate:
			apps.forEach({ (app:NSRunningApplication) in
				app.terminate()
			})
			return true
		case .activate:
			apps.forEach({ (app:NSRunningApplication) in
				app.activate()
			})
			return true
		}
	}
}

//MARK: - Json
import SwiftyJSON

extension AppState : JsonConvertibleType {
	var typename: String { return "appStateType" }
	var flatten : Bool { return true }
	static var allTypes : [String] {
		return ["any","running","notRunning","active"]
	}
	
	init(withJSON json:JSON) {
		self.init()
		switch json[typename] {
		case "running": self = .running
		case "notRunning": self = .notRunning
		case "active": self = .active
		default: self = .any
		}
	}
	var type : String {
		switch self {
		case .running: return "running"
		case .notRunning: return "notRunning"
		case .active: return "active"
		default: return "any"
		}
	}
	var args : Any {
		return {}
	}
}
extension AppProc : JsonConvertibleType {
	var typename: String { return "appProcType" }
	var flatten : Bool { return true }
	static var allTypes : [String] {
		return ["none","launch","launchWithOptions","activate","terminate"]
	}

	init(withJSON json:JSON) {
		self.init()
		let args = flatten ? json : json["args"]
		switch json[typename] {
		case "launch": self = .launch
		case "launchWithOptions": self = .launchWithOptions(NSWorkspaceLaunchOptions(rawValue:args["flags"].uIntValue), args["arguments"].arrayValue.map{$0.stringValue})
		case "activate": self = .activate
		case "terminate": self = .terminate
		default: self = .none
		}
	}
	var type : String {
		switch self {
		case .none: return "none"
		case .launch: return "launch"
		case .launchWithOptions: return "launchWithOptions"
		case .activate: return "activate"
		case .terminate: return "terminate"
		}
	}
	var args : Any {
		switch self {
		case let .launchWithOptions(options, args): return [
			"flags" : options.rawValue,
			"arguments" : args
			]
		default: return {}
		}
	}
}
