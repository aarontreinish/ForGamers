/* 
Copyright (c) 2021 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct Added_by_status : Codable {
	let yet : Int?
	let owned : Int?
	let beaten : Int?
	let toplay : Int?
	let dropped : Int?
	let playing : Int?

	enum CodingKeys: String, CodingKey {

		case yet = "yet"
		case owned = "owned"
		case beaten = "beaten"
		case toplay = "toplay"
		case dropped = "dropped"
		case playing = "playing"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		yet = try values.decodeIfPresent(Int.self, forKey: .yet)
		owned = try values.decodeIfPresent(Int.self, forKey: .owned)
		beaten = try values.decodeIfPresent(Int.self, forKey: .beaten)
		toplay = try values.decodeIfPresent(Int.self, forKey: .toplay)
		dropped = try values.decodeIfPresent(Int.self, forKey: .dropped)
		playing = try values.decodeIfPresent(Int.self, forKey: .playing)
	}

}