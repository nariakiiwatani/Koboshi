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
		case running
		case notRunning
		case active
		func execute(_ url:URL) -> Bool {
			let apps = NSWorkspace.shared().runningApplications.filter{
				$0.bundleURL == url
			}
			switch self {
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
		case launch
		case activate
		case terminate
		func execute(_ url:URL) -> Bool {
			let apps = NSWorkspace.shared().runningApplications.filter{
				$0.bundleURL == url
			}
			switch self {
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
	}
}

