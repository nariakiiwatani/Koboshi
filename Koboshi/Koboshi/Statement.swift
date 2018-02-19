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
	init(withTrigger t:Trigger!) {
		super.init()
		trigger = t
		trigger.delegate = self
	}
	var trigger : Trigger!
	var isRunning : Bool {
		set { trigger.enable = newValue }
		get { return trigger.enable }
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
		self.init(withTrigger:TriggerType(withJSON:json["trigger"]).toTrigger())
		name = json["name"].stringValue
		op = Operator(withJSON:json["operator"])
	}
	var json : JSON {
		return [
			"name" : name,
			"trigger" : trigger.type.json as Any,
			"operator" : op.json,
		]
	}
}
