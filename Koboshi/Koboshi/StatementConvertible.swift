//
//  StatementConvertible.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2018/01/12.
//  Copyright © 2018年 annolab. All rights reserved.
//

import Foundation
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
