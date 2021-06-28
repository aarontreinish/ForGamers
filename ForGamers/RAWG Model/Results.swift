/* 
Copyright (c) 2021 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct Results : Codable {
	let id : Int?
	let slug : String?
	let name : String?
	let released : String?
	let tba : Bool?
	let background_image : String?
	let rating : Double?
	let rating_top : Int?
	let ratings : [Ratings]?
	let ratings_count : Int?
	let reviews_text_count : Int?
	let added : Int?
	let added_by_status : Added_by_status?
	let metacritic : Int?
	let playtime : Int?
	let suggestions_count : Int?
	let updated : String?
	let user_game : String?
	let reviews_count : Int?
	let saturated_color : String?
	let dominant_color : String?
	//let platforms : [Platforms]?
	//let parent_platforms : [Parent_platforms]?
	let genres : [Genres]?
	//let stores : [Stores]?
	let clip : String?
	let tags : [Tags]?
	let esrb_rating : Esrb_rating?
	let short_screenshots : [Short_screenshots]?

}
