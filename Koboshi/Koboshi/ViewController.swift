//
//  ViewController.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2017/12/27.
//  Copyright © 2017年 annolab. All rights reserved.
//

import Cocoa
import SwiftyJSON

class ViewController: NSViewController, NSTableViewDataSource {

	var statements : [StatementInfo] = []
	override func viewDidLoad() {
		super.viewDidLoad()

		statements.append(StatementInfo(launchApplicationIfNotRunning: URL(fileURLWithPath: "/Applications/System Preferences.app")))
		let statement = StatementInfo()
		let url = URL(fileURLWithPath:"/Users/nariakiiwatani/Desktop/success.sh")
		let outurl = URL(fileURLWithPath:"/Users/nariakiiwatani/Desktop/tmp.txt")
		statement.statement.sentence = Operator.ifelse(
			Operator.shellScriptExec(program: URL(fileURLWithPath:"/bin/sh"), .command("echo", ["0"]))
			,Operator.fileProc(url: outurl, .create)
			,Operator.fileProc(url: outurl, .delete)
			)
		statement.statement.interval = 5
		statements.append(statement)
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}

	func numberOfRows(in tableView: NSTableView) -> Int {
		return statements.count
	}
	
	func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
		return statements[row]
	}
}

