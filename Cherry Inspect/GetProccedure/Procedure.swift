
import Foundation
struct Procedure : Codable {
	let id : Int?
	let name : String?
	let description : String?
	let csv_ids : String?

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case name = "name"
		case description = "description"
		case csv_ids = "csv_ids"
	}

}
