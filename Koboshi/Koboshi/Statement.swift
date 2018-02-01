//
//  Statement.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2018/01/02.
//  Copyright © 2018年 annolab. All rights reserved.
//

import Foundation


class Statement : TriggerDelegate
{
	var op = Operator()
	func execute() -> Bool {
		return op.execute()
	}
}

class StatementInfo : NSObject
{
	var name : String = "New Item"
	var trigger : Trigger! {
		willSet {
			if trigger !== newValue {
				trigger.enable = false
			}
		}
		didSet { trigger.delegate = statement }
	}
	var statement = Statement() {
		didSet { trigger.delegate = statement }
	}
	var isRunning : Bool {
		set { trigger.enable = newValue }
		get { return trigger.enable }
	}
	
	init(withTrigger t:Trigger!) {
		trigger = t
		trigger.delegate = statement
	}
	deinit {
		trigger.enable = false
	}
	convenience init(launchApplicationIfNotRunning url:URL) {
		self.init(withTrigger: IntervalTrigger(withTimeInterval:1))
		name = "watchdog for " + url.lastPathComponent
		statement.op = Operator.ifelse(
			Operator.applicationState(url: url, .notRunning)
			,Operator.applicationProc(url: url, .launch)
			,Operator.applicationProc(url: url, .activate)
		)
		trigger.enable = true
	}
}

// MARK: - Json
import SwiftyJSON

extension StatementInfo {
	convenience init(withJSON json:JSON) {
		self.init(withTrigger:TriggerType(withJSON:json["trigger"]).toTrigger())
		name = json["name"].stringValue
		statement.json = json["statement"]
		isRunning = json["enabled"].boolValue
	}
	var json : JSON {
		return [
			"name" : name,
			"statement" : statement.json,
			"trigger" : trigger.type.json as Any,
			"enabled" : isRunning
		]
	}
}

extension Statement {
	var json : JSON {
		set(json) {
			op = Operator(withJSON:json["operator"])
		}
		get {
			return [
				"operator" : op.json,
			]
		}
	}
}
