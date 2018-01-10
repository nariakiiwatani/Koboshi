//
//  ViewController.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2017/12/27.
//  Copyright © 2017年 annolab. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDataSource {

	var statements : [StatementInfo] = []
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		statements.append(StatementInfo(launchApplicationIfNotRunning: URL(fileURLWithPath: "/Applications/System Preferences.app")))
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

