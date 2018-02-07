//
//  String+split.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2018/02/07.
//  Copyright © 2018年 annolab. All rights reserved.
//

import Foundation

extension String {
	func regexEscaped() -> String {
		var str: String = self
		"\\*+.?{}()[]-|$".characters.forEach{
			let s = String($0)
			str = str.replacingOccurrences(of: s, with: "\\"+s)
		}
		return str
	}
	func trimming(withString str:String) -> String {
		let str = str.regexEscaped()
		return self.replacingOccurrences(of: "^"+str+"|"+str+"$", with: "", options: NSString.CompareOptions.regularExpression, range: nil)
	}
	public func split(withDelimiters delimiters:[String]=[" ", ","], andQuotes quotes:[String]=["\"", "'"]) -> [String] {
		var dels = delimiters
		dels.append(contentsOf: quotes)
		dels = dels.map{$0.regexEscaped()}
		var patterns = ["((?!"+dels.joined(separator:"|")+").)+"]
		quotes.forEach{
			let src = $0.regexEscaped()
			patterns.append(src + "((?!" + src + ").)*" + src)
		}
		let regex = try! NSRegularExpression(pattern: patterns.joined(separator: "|"), options: [])
		var arr = [String]()
		regex.matches(in: self, options: [], range: NSRange(location: 0, length: (self as NSString).length))
			.forEach{
				var src = (self as NSString).substring(with: $0.rangeAt(0))
				let quote = quotes.filter{src.hasPrefix($0) && src.hasSuffix($0)}
				if !quote.isEmpty {
					src = src.trimming(withString:quote[0])
				}
				arr.append(src)
		}
		return arr
	}
}
