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
	
	init() {}
	func run(withTimeInterval: TimeInterval) {
		stop()
		timer = Timer.scheduledTimer(withTimeInterval: withTimeInterval, repeats: true, block: {_ in 
			self.executeAsync()
		})
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
