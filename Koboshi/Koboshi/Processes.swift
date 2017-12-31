//
//  Processes.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2017/12/27.
//  Copyright © 2017年 annolab. All rights reserved.
//

import Foundation
import AppKit


class ProcessInterface
{
	static func getRunningApplications() -> [NSRunningApplication] {
		let apps = NSWorkspace.shared().runningApplications
		return apps
	}
	static func getRunningApplications(containsName:String!) -> [NSRunningApplication] {
		let apps = NSWorkspace.shared().runningApplications
		return apps.filter{($0.localizedName?.contains(containsName))!}
	}
	
	struct AppInfo {
		var executableURL:String?
		var bundleID:String?
	}
	var watchingApps:[AppInfo]?
	
	func startWatching(app:AppInfo!) {
		watchingApps?.append(app)
	}
	func launchIfNotRunning(_ executableURL:String!) {
		NSWorkspace().launchApplication(executableURL)
	}
}
