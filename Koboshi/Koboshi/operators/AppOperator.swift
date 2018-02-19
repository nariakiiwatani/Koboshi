//
//  AppOperator.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2018/01/02.
//  Copyright © 2018年 annolab. All rights reserved.
//

import Foundation
import AppKit

extension Operator {
	enum AppState {
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
}

//MARK: - Json
import SwiftyJSON

extension Operator.AppState : JsonConvertibleType {
	init(withJSON json:JSON) {
		switch json["type"] {
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
		return []
	}
}
extension Operator.AppProc : JsonConvertibleType {
	init(withJSON json:JSON) {
		let args = json["args"]
		switch json["type"] {
		case "launch": self = .launch
		case "launchWithOptions": self = .launchWithOptions(NSWorkspaceLaunchOptions(rawValue:args["flags"].uIntValue), args["args"].arrayValue.map{$0.stringValue})
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
			"args" : args
			]
		default: return []
		}
	}
}
