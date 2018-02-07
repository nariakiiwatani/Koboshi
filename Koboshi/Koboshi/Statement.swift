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
	init(withTrigger t:Trigger!) {
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
		op = Operator(withJSON:json["operator"])
	}
	var json : JSON {
		return [
			"trigger" : trigger.type.json as Any,
			"operator" : op.json,
		]
	}
}
