

import Foundation
struct Inspections_services : Codable {
	let id : Int?
	let inspection_id : Int?
	let service_id : Int?
	let qty : Int?
	let comment : String?
	let status : Int?
	let service_name : String?
	let min_price : Int?
	let max_price : Int?
	let image_url : String?
	let image_thumb_url : String?
	let image_medium_url : String?
	let item_type : String?

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case inspection_id = "inspection_id"
		case service_id = "service_id"
		case qty = "qty"
		case comment = "comment"
		case status = "status"
		case service_name = "service_name"
		case min_price = "min_price"
		case max_price = "max_price"
		case image_url = "image_url"
		case image_thumb_url = "image_thumb_url"
		case image_medium_url = "image_medium_url"
		case item_type = "item_type"
	}


}
