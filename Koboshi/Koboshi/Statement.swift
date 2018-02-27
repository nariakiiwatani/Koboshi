//
//  Statement.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2018/01/02.
//  Copyright © 2018年 annolab. All rights reserved.
//

import Foundation


class Statement : NSObject, TriggerDelegate
{
	var name = "New Item"
	var trigger : Trigger? {
		willSet {
			newValue?.enable = isRunning
			if trigger !== newValue {
				trigger?.enable = false
			}
		}
		didSet { trigger?.delegate = self }
	}
	var isRunning : Bool {
		set { trigger?.enable = newValue }
		get { return trigger?.enable ?? false }
	}

	var op = Operator()
	func execute() -> Bool {
		return op.execute()
	}
}

// MARK: - Json
import SwiftyJSON

extension Statement {
	convenience init(withJSON json:JSON) {
		self.init()
		self.json = json
	}
	var json : JSON {
		get {
			return [
				"name" : name,
				"trigger" : trigger?.type.json ?? {},
				"operator" : op.json,
				"isRunning" : isRunning
			]
		}
		set(_json) {
			name = _json["name"].string ?? name
			trigger = TriggerType(withJSON:_json["trigger"]).toTrigger()
			op = Operator(withJSON:_json["operator"])
			isRunning = _json["isRunning"].boolValue
		}
	}
}
