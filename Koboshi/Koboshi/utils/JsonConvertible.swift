//
//  JsonConvertible.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2018/02/19.
//  Copyright © 2018年 annolab. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol JsonConvertible {
	init(withJSON json:JSON)
	var json : JSON{get}
}

protocol JsonConvertibleType : JsonConvertible {
	var typename : String{get}
	var flatten : Bool{get}
	var type : String{get}
	var args : Any{get}
}

extension JsonConvertibleType {
	var typename : String { return "type" }
	var flatten : Bool { return false }
	var json : JSON {
		return JSON([typename : type]).merged(JSON(flatten ? args : ["args":args]))
	}
}
