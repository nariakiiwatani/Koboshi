//
//  ViewController.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2017/12/27.
//  Copyright © 2017年 annolab. All rights reserved.
//

import Cocoa
import SwiftyJSON
import SwiftOSC

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

	@IBOutlet weak var tableView : NSTableView!
	@IBOutlet weak var editor : StatementEditor!
	var filepath : URL?
	var statements : [Statement] = []
	override func viewDidLoad() {
		super.viewDidLoad()

		if let data = UserDefaults.standard.value(forKey: "data") as? [Data] {
			data.forEach{
				if let json = try? JSON(data: $0) {
					statements.append(Statement(withJSON: json))
				}
			}
		}
		else {
			newStatement()
		}
		tableView.reloadData()
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
		if !statements.isEmpty {
			tableView.selectRowIndexes([0], byExtendingSelection: false)
		}
	}
	
	override func viewWillDisappear() {
		super.viewWillDisappear()
		UserDefaults.standard.setValue(statements.map{try? $0.json.rawData()}, forKey: "data")
	}


	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
	
	func newStatement() {
		let s = Statement()
		s.trigger = IntervalTrigger(withTimeInterval: 1)
		statements.append(s)
		tableView.reloadData()
		tableView.selectRowIndexes([tableView.numberOfRows-1], byExtendingSelection: false)
	}
	func delStatement() {
		if tableView.selectedRow >= 0 {
			let index = tableView.selectedRow
			statements.remove(at: index)
			tableView.reloadData()
			tableView.selectRowIndexes([min(tableView.numberOfRows-1, index)], byExtendingSelection: false)
		}
	}

	@IBAction func addremButton(_ sender: Any) {
		guard let button = sender as? NSSegmentedControl else {
			return
		}
		if button.isSelected(forSegment: 0) {
			newStatement()
		}
		if button.isSelected(forSegment: 1) {
			delStatement()
		}
	}
	func numberOfRows(in tableView: NSTableView) -> Int {
		return statements.count
	}
	
	func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
		return statements[row]
	}
	public func tableViewSelectionDidChange(_ notification: Notification) {
		if tableView.selectedRow >= 0 {
			editor.json = statements[tableView.selectedRow].json
		}
		else {
			editor.json = JSON({})
		}
	}
	public func selectionShouldChange(in tableView: NSTableView) -> Bool {
		if tableView.selectedRow >= 0 {
			if editor.edited {
				let alert = NSAlert()
				alert.messageText = "Save changes?"
				alert.alertStyle = .warning
				alert.addButton(withTitle: "Save")
				alert.addButton(withTitle: "Back to Edit")
				alert.addButton(withTitle: "Discard Changes")
				switch alert.runModal() {
				case NSAlertFirstButtonReturn:
					let statement = statements[tableView.selectedRow]
					statement.json = statement.json.merged(editor.json)
				case NSAlertSecondButtonReturn:
					return false
				case NSAlertThirdButtonReturn:
					break
				default:
					break
				}
			}
		}
		return true
	}
}

extension ViewController {
	func saveDocument(_ sender: Any) {
		if filepath == nil {
			saveDocumentAs(sender)
			return
		}
		assert(filepath != nil)
		if tableView.selectedRow >= 0 && editor.edited {
			let statement = statements[tableView.selectedRow]
			statement.json = statement.json.merged(editor.json)
			editor.edited = false
		}
		do {
			let data = statements.reduce(JSON([]), { (json, statement) -> JSON in
				return JSON(json.arrayValue + [statement.json])
			})
			try data.rawString()?.write(toFile: filepath!.path, atomically: false, encoding: .utf8)
		} catch {
		}
	}
	func saveDocumentAs(_ sender: Any) {
		let panel = NSSavePanel()
		panel.canCreateDirectories = true
		panel.showsTagField = false
		if let currentFile = filepath {
			panel.nameFieldStringValue = currentFile.lastPathComponent
			panel.directoryURL = currentFile.deletingLastPathComponent()
		}
		panel.begin { (result) in
			if result == NSFileHandlingPanelOKButton {
				guard let url = panel.url else { return }
				self.filepath = url
				self.saveDocument(sender)
			}
		}
	}
	func openDocument(_ sender: Any) {
		let panel = NSOpenPanel()
		panel.allowsMultipleSelection = false
		panel.canChooseDirectories = false
		panel.canCreateDirectories = true
		panel.canChooseFiles = true
		panel.allowedFileTypes = ["json"]
		if let currentFile = filepath {
			panel.nameFieldStringValue = currentFile.lastPathComponent
			panel.directoryURL = currentFile.deletingLastPathComponent()
		}
		panel.begin { (result) in
			if result == NSFileHandlingPanelOKButton {
				guard let url = panel.url else { return }
				self.filepath = url
				self.statements.removeAll()
				self.importFromFile(url)
				NSDocumentController.shared().noteNewRecentDocumentURL(url)
				if !self.statements.isEmpty {
					self.tableView.selectRowIndexes([0], byExtendingSelection: false)
				}
			}
		}
	}
	func importDocument(_ sender: Any) {
		let panel = NSOpenPanel()
		panel.allowsMultipleSelection = false
		panel.canChooseDirectories = false
		panel.canCreateDirectories = true
		panel.canChooseFiles = true
		panel.allowedFileTypes = ["json"]
		if let currentFile = filepath {
			panel.nameFieldStringValue = currentFile.lastPathComponent
			panel.directoryURL = currentFile.deletingLastPathComponent()
		}
		panel.begin { (result) in
			if result == NSFileHandlingPanelOKButton {
				guard let url = panel.url else { return }
				self.importFromFile(url)
			}
		}
	}
	func importFromFile(_ file:URL) {
		do {
			let data = try String(contentsOf: file, encoding: .utf8)
			let json = JSON(parseJSON: data)
			_ = json.array?.map{statements.append(Statement(withJSON: $0))}
			tableView.reloadData()
		} catch {                
		} 
	}
}

