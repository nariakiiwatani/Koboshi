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
	case bbreak
	case through

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
			_ = try? NSWorkspace().launchApplication(at: URL(fileURLWithPath: path), options: [], configuration: [:])
			return true
		case .quit(let path):
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
		case .iff(let cond, let s):
			return cond.check() ? s.execute() : true
		case .ifelse(let cond, let t, let f):
			return cond.check() ? t.execute() : f.execute()
		case .join(let s0, let s1):
			return s0.execute() && s1.execute()
		case .bbreak: return false
		default: return true
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
		sentence = Sentence.join(Sentence.ifelse(
			Condition.application(path: path, type: .isNotRunning) 
			,Sentence.launch(path:path)
			,Sentence.bbreak)
			,Sentence.launch(path:"/Applications/VLC.app")
			)
		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in 
			self.executeAsync()
		})
	}
	func execute() -> Bool {
		return self.sentence.execute()
	}
	func executeAsync() {
		DispatchQueue.global(qos:.background).async {
			_ = self.execute()
		}
	}
}
