/*
String+split.swift
Koboshi

MIT LICENSE  

Copyright 2018 nariakiiwatani

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

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
