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
	var type : String{get}
	var args : Any{get}
}

extension JsonConvertibleType {
	var json : JSON {
		return [
			"type" : JSON(type),
			"args" : JSON(args)
		]
	}
}
