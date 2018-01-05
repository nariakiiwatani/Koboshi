//
//  FileOperator.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2018/01/02.
//  Copyright © 2018年 annolab. All rights reserved.
//

import Foundation
import AppKit

extension Operator {
	enum FileState {
		case exist
		func execute(_ url:URL) -> Bool {
			switch self {
			case .exist:
				return FileManager().fileExists(atPath: url.absoluteString)
			}
		}
	}
	enum FileProc {
		case open(withApp:URL)
		case move(to:URL)
		case copy(to:URL)
		case delete
		func execute(_ url:URL) -> Bool {
			switch self {
			case let .open(app):
				return NSWorkspace().openFile(url.absoluteString, withApplication:app.absoluteString)
			case let .move(to):
				return (try? FileManager().moveItem(at: url, to: to)) != nil
			case let .copy(to):
				return (try? FileManager().copyItem(at: url, to: to)) != nil
			case .delete:
				return (try? FileManager().removeItem(at: url)) != nil
			}
		}
	}
}
