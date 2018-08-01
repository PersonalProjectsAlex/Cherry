import Foundation

struct Store : Codable {
	let id : Int?
	let name : String?
	let status : Bool?

	private enum CodingKeys: String, CodingKey {

		case id = "id"
		case name = "name"
		case status = "status"
	}


}
