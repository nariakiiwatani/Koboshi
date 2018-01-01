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
	var timer : Timer!
	var sentence : Operator
	
	convenience init() {
		self.init(url: URL(fileURLWithPath: "/Applications/QuickTime Player.app"))
	}
	init(url:URL) {
		sentence = 
			Operator.ifelse(
				Operator.applicationState(url: url, .notRunning)
				,Operator.applicationProc(url: url, .launch)
				,Operator.applicationProc(url: url, .activate)
		)
		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in 
			self.executeAsync()
		})
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
