//
//  AppOperator.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2018/01/02.
//  Copyright © 2018年 annolab. All rights reserved.
//

import Foundation
import AppKit
import SwiftyJSON

extension Operator {
	enum AppState : JsonConvertibleOperator {
		case none
		case running
		case notRunning
		case active
		init(withJSON json:JSON) {
			switch json["type"] {
			case "running": self = .running
			case "notRunning": self = .notRunning
			case "active": self = .active
			default: self = .none
			}
		}
		func execute(_ url:URL) -> Bool {
			let apps = NSWorkspace.shared().runningApplications.filter{
				$0.bundleURL == url
			}
			switch self {
			case .none: return true
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
		var type : String {
			switch self {
			case .none: return "none"
			case .running: return "running"
			case .notRunning: return "notRunning"
			case .active: return "active"
			}
		}
		var args : Any {
			return []
		}
	}
	
	enum AppProc : JsonConvertibleOperator {
		case none
		case launch
		case activate
		case terminate
		init(withJSON json:JSON) {
			switch json["type"] {
			case "launch": self = .launch
			case "activate": self = .activate
			case "terminate": self = .terminate
			default: self = .none
			}
		}
		func execute(_ url:URL) -> Bool {
			let apps = NSWorkspace.shared().runningApplications.filter{
				$0.bundleURL == url
			}
			switch self {
			case .none: return true
			case .launch:
				return (try? NSWorkspace().launchApplication(at: url, options: [], configuration: [:])) != nil
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
		var type : String {
			switch self {
			case .none: return "none"
			case .launch: return "launch"
			case .activate: return "activate"
			case .terminate: return "terminate"
			}
		}
		var args : Any {
			return []
		}
	}
}

