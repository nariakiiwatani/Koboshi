//
//  SwiftyJSON+merge.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2018/02/21.
//  Copyright © 2018年 annolab. All rights reserved.
//

import Foundation
import SwiftyJSON

extension JSON {
	mutating func merge(_ other: JSON) {
		for (key, subJson) in other {
			self[key] = subJson
		}
	}
	
	func merged(_ other: JSON) -> JSON {
		var merged = self
		merged.merge(other)
		return merged
	}
}
