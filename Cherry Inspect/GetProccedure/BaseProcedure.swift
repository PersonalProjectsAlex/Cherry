

import Foundation
struct BaseProcedure : Codable {
	let id : Int?
	let min_total : Int?
	let max_total : Int?
	let mileage : String?
	let created_at : String?
	let pdf : String?
	let draft : Int?
	let store : Store?
	let vehicle : Vehicle?
	let procedure : Procedure?
	let inspections_services : [Inspections_services]?

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case min_total = "min_total"
		case max_total = "max_total"
		case mileage = "mileage"
		case created_at = "created_at"
		case pdf = "pdf"
		case draft = "draft"
		case store
		case vehicle
		case procedure
		case inspections_services = "inspections_services"
	}


}
