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
	case always
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
		case .always:
			return true
		default:
			return true
		}
	}
}

enum Operation {
	case launch(path:String)
	case activate(path:String)
	case quit(path:String)
	case shell(path:String)
	case shellString(script:String)
	case open(file:String, app:String)
	case wait(seconds:Int)
	case through
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
		case .through:
			return true
		default:
			return true
		}
	}
}

class Sentence {
	var operation : Operation!
	init(_ op:Operation) {
		operation = op
	}
	func proc() -> Bool {
		return operation.execute()
	}
}

class SentenceWithCondition : Sentence {
	var condition = Condition.always
	var sentences = [Sentence]()
	init() {
		super.init(Operation.through)
	}
	override init(_ op:Operation) {
		super.init(op);
		assert(false);
	}
	override func proc() -> Bool {
		if(condition.check()) {
			for s in sentences {
				if(!s.proc()) {
					return false
				}
			}
		}
		return true
	}
}


class Statement
{
	var timer : Timer!
	var sentence = SentenceWithCondition()
	
	convenience init() {
		self.init(path:"/Applications/QuickTime Player.app")
	}
	init(path:String) {
		sentence.condition = Condition.application(path: path, type: .isNotRunning)
		sentence.sentences = Array<Sentence>()
		sentence.sentences.append(Sentence(Operation.launch(path:path)))
		sentence.sentences.append(Sentence(Operation.wait(seconds:5)))
		sentence.sentences.append(Sentence(Operation.quit(path:path)))
		sentence.sentences.append(Sentence(Operation.wait(seconds:5)))
		timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(Statement.execute), userInfo: nil, repeats: true)
	}
	@objc func execute() {
		sentence.proc()
	}
}
