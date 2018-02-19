//
//  AppWatcher.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2018/02/05.
//  Copyright © 2018年 annolab. All rights reserved.
//

import Foundation
import AppKit

class AppWatcherEditor : NSObject
{
	class OptionFlags : NSObject {
		dynamic var andPrint = false
		dynamic var withErrorPresentation = false
		dynamic var inhibitingBackgroundOnly = false
		dynamic var withoutAddingToRecents = false
		dynamic var withoutActivation = false
		dynamic var async = false
		dynamic var newInstance = false
		dynamic var andHide = false
		dynamic var andHideOthers = false
		var options : NSWorkspaceLaunchOptions {
			set(options) {
				andPrint = options.contains(.andPrint)
				withErrorPresentation = options.contains(.withErrorPresentation)
				inhibitingBackgroundOnly = options.contains(.inhibitingBackgroundOnly)
				withoutAddingToRecents = options.contains(.withoutAddingToRecents)
				withoutActivation = options.contains(.withoutActivation)
				async = options.contains(.async)
				newInstance = options.contains(.newInstance)
				andHide = options.contains(.andHide)
				andHideOthers = options.contains(.andHideOthers)
			}
			get {
				var options = NSWorkspaceLaunchOptions(rawValue:0)
				if andPrint { options.insert(.andPrint) }
				if withErrorPresentation { options.insert(.withErrorPresentation) }
				if inhibitingBackgroundOnly { options.insert(.inhibitingBackgroundOnly) }
				if withoutAddingToRecents { options.insert(.withoutAddingToRecents) }
				if withoutActivation { options.insert(.withoutActivation) }
				if async { options.insert(.async) }
				if newInstance { options.insert(.newInstance) }
				if andHide { options.insert(.andHide) }
				if andHideOthers { options.insert(.andHideOthers) }
				return options
			}
		}
	}
	dynamic var flags = OptionFlags()
	dynamic var url = ""
	dynamic var keepActive = true
	dynamic var arguments = ""
	var trigger = TriggerType.interval(1)

	weak var reference : AppWatcher?
	func setReference(_ watcher : inout AppWatcher) {
		reference = watcher
		url = watcher.url
		keepActive = watcher.keepActive
		flags.options = watcher.options
		trigger = watcher.trigger
	}
	func clearReference() {
		reference = nil
	}
	@IBAction func apply(_ sender : Any?) {
		guard let ref = reference else {
			return
		}
		ref.url = url
		ref.keepActive = keepActive
		ref.options = flags.options

		let appurl = URL(fileURLWithPath: url)
		let running = ref.isRunning
		let args = arguments.split(withDelimiters: [" "])
		ref.statement = Statement()
		ref.statement.trigger = trigger.toTrigger()
		ref.statement.op = 
			Operator.and(
				Operator.ifthen(Operator.applicationState(url: appurl, AppState.notRunning),
				                Operator.applicationProc(url: appurl, AppProc.launchWithOptions(flags.options, args))),
				Operator.ifthen(Operator(keepActive),
				                Operator.applicationProc(url: appurl, AppProc.activate))
		)
		ref.isRunning = running
	}
	@IBAction func browseFile(_ sender : Any?) {
		let dialog = NSOpenPanel()
		dialog.canChooseDirectories=false
		dialog.canChooseFiles = true
		dialog.canCreateDirectories = false
		dialog.allowsMultipleSelection = false
		dialog.begin { (result) -> Void in
			if result == NSFileHandlingPanelOKButton {
				guard let url = dialog.url else { return }
				self.url = url.path
			}
		}
	}
}

class AppWatcher : NSObject
{
	init(_ s : Statement) {
		statement = s
	}
	dynamic var name : String = "New Item"
	var statement : Statement!
	var isRunning : Bool {
		set { statement.isRunning = newValue }
		get { return statement.isRunning }
	}
	var url = ""
	var keepActive = true
	var options = NSWorkspaceLaunchOptions.default
	var trigger = TriggerType.interval(1)
}


import SwiftyJSON

extension AppWatcher {
	convenience init(withJSON json:JSON) {
		self.init(Statement(withJSON:json["statement"]))
		name = json["name"].stringValue
		isRunning = json["enabled"].boolValue
		url = json["url"].stringValue
		keepActive = json["keepActive"].boolValue
		options = NSWorkspaceLaunchOptions(rawValue:json["options"].uIntValue)
	}
	var json : JSON {
		return [
			"name" : name,
			"statement" : statement.json,
			"enabled" : isRunning,
			"url" : url,
			"keepActive" : keepActive,
			"options" : options.rawValue
		]
	}
}
