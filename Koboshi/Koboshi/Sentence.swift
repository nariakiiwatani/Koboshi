//
//  Sentence.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2017/12/27.
//  Copyright © 2017年 annolab. All rights reserved.
//

import Foundation
import AppKit

enum Condition
{
	enum appType {
		case isRunning
		case isNotRunning
	}
	enum shellType {
		case succceed
		case failed
	}
	case application(path:String, type:appType)
	case shellfile(file:String, type:shellType)
	case shellscript(script:String, type:shellType)

	func check() -> Bool {
		switch self {
		case .application(let path, let type):
			let apps = NSWorkspace.shared().runningApplications.filter{
				$0.bundleURL?.path == path
			}
			switch type {
			case .isRunning: return !apps.isEmpty && apps[0].isFinishedLaunching
			case .isNotRunning: return apps.isEmpty
			}
		default:
			return true
		}
	}
}

enum Sentence {
	case launch(path:String)
	case activate(path:String)
	case quit(path:String)
	case shell(path:String)
	case shellString(script:String)
	case open(file:String, app:String)
	case wait(seconds:Int)
	func execute() -> Bool {
		switch self {
		case .launch(let path):
			let result = try? NSWorkspace().launchApplication(at: URL(fileURLWithPath: path), options: [], configuration: [:])
			return result != nil
//			return NSWorkspace().launchApplication(withBundleIdentifier: bundleIdentifier, options: [], additionalEventParamDescriptor: nil, launchIdentifier: nil)
		case .quit(let path):
			let testapps = NSWorkspace.shared().runningApplications;
			testapps.forEach({ (app:NSRunningApplication) in
				print(app.localizedName ?? "no URL")
				print(app.bundleURL?.path ?? "no URL")
			})
			let apps = NSWorkspace.shared().runningApplications.filter{
				$0.bundleURL?.path == path
			}
			apps.forEach({ (app:NSRunningApplication) in
				app.terminate()
			})
			return true
		case .wait(let seconds):
			Thread.sleep(forTimeInterval: TimeInterval(seconds))
			return true
		default:
			return true
		}
	}
}

class Statement
{
	var timer : Timer!
	var condition : Condition
	var sentences : [Sentence]
	
	init() {
		condition = Condition.application(path: "/Applications/QuickTime Player.app", type: .isNotRunning)
		sentences = Array<Sentence>()
		sentences.append(Sentence.launch(path:"/Applications/QuickTime Player.app"))
		sentences.append(Sentence.wait(seconds:5))
		sentences.append(Sentence.quit(path:"/Applications/QuickTime Player.app"))
		sentences.append(Sentence.wait(seconds:5))
		timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(Statement.execute), userInfo: nil, repeats: true)
	}
	init(path:String) {
		condition = Condition.application(path: path, type: .isNotRunning)
		sentences = Array<Sentence>()
		sentences.append(Sentence.launch(path:path))
		sentences.append(Sentence.wait(seconds:5))
		sentences.append(Sentence.quit(path:path))
		sentences.append(Sentence.wait(seconds:5))
		timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(Statement.execute), userInfo: nil, repeats: true)
	}
	@objc func execute() {
		if condition.check() {
			sentences.forEach({ (s:Sentence) in
				guard s.execute() else {return}
			})
		}
	}
}
