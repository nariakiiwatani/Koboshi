//
//  Statement.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2018/01/02.
//  Copyright © 2018年 annolab. All rights reserved.
//

import Foundation

class Statement
{
	var timer : Timer?
	var sentence = Operator()
	var isRunning : Bool {
		return timer?.isValid ?? false
	}
	var interval : Double = 1
	
	init() {}
	private func run(withTimeInterval interval:TimeInterval) {
		stop()
		timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: {_ in 
			self.executeAsync()
		})
	}
	func run() {
		run(withTimeInterval:interval)
	}
	func stop() {
		timer?.invalidate()
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

class StatementInfo : NSObject
{
	var name : String = "new item"
	var enabled : Bool {
		set {
			newValue ? statement.run() : statement.stop()
		}
		get {
			return statement.isRunning
		}
	}
	
	var statement : Statement = Statement()
	
	init(launchApplicationIfNotRunning url:URL) {
		name = "watchdog for " + url.lastPathComponent
		statement.sentence = Operator.ifelse(
			Operator.applicationState(url: url, .notRunning)
			,Operator.applicationProc(url: url, .launch)
			,Operator.applicationProc(url: url, .activate)
		)
	}
}

// MARK: - Json
import SwiftyJSON

protocol JsonConvertible {
	var json : JSON{get set}
}

extension StatementInfo : JsonConvertible {
	var json : JSON {
		set(json) {
			name = json["name"].stringValue
			statement.json = json["statement"]
			enabled = json["enabled"].boolValue
		}
		get {
			return [
				"name" : name,
				"statement" : statement.json,
				"enabled" : enabled
			]
		}
	}
}

extension Statement : JsonConvertible {
	var json : JSON {
		set(json) {
			sentence = Operator(withJSON:json["sentence"])
			interval = json["interval"].doubleValue
		}
		get {
			return [
				"sentence" : sentence.json,
				"interval" : interval
			]
		}
	}
}
