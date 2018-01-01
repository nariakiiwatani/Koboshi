//
//  Sentence.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2017/12/27.
//  Copyright © 2017年 annolab. All rights reserved.
//

import Foundation
import AppKit

indirect enum Condition
{
	enum appType {
		case isRunning
		case isNotRunning
	}
	enum shellType {
		case succceed
		case failed
	}
	case always
	case application(path:String, type:appType)
	case shellfile(file:String, type:shellType)
	case shellscript(script:String, type:shellType)
	case and(Condition, Condition)
	case or(Condition, Condition)

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
		case .and(let c0, let c1):
			return c0.check() && c1.check()
		case .or(let c0, let c1):
			return c0.check() || c1.check()
		case .always:
			return true
		default:
			return true
		}
	}
}

indirect enum Sentence {
	case iff(Condition, Sentence)
	case ifelse(Condition, Sentence, Sentence)
	case join(Sentence, Sentence)
	case launch(path:String)
	case activate(path:String)
	case quit(path:String)
	case shell(path:String)
	case shellString(script:String)
	case open(file:String, app:String)
	case wait(seconds:Int)
	case through
	func execute() {
		switch self {
		case .launch(let path):
			let result = try? NSWorkspace().launchApplication(at: URL(fileURLWithPath: path), options: [], configuration: [:])			
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
		case .wait(let seconds):
			Thread.sleep(forTimeInterval: TimeInterval(seconds))
		case .iff(let cond, let s):
			if(cond.check()) { s.execute() }
		case .ifelse(let cond, let t, let f):
			cond.check() ? t.execute() : f.execute()
		case .join(let s0, let s1):
			s0.execute()
			s1.execute()
		default:
			break;
		}
	}
}

class Statement
{
	var timer : Timer!
	var sentence : Sentence
	
	convenience init() {
		self.init(path:"/Applications/QuickTime Player.app")
	}
	init(path:String) {
		sentence = Sentence.ifelse(
			Condition.application(path: path, type: .isNotRunning) 
			,Sentence.launch(path:path)
			,Sentence.quit(path:path)
		)
		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in 
			self.executeAsync()
		})
	}
	func execute() {
		self.sentence.execute()
	}
	func executeAsync() {
		DispatchQueue.global(qos:.background).async {
			self.execute()
		}
	}
}
