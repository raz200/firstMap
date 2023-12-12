//
//  MarkerEntity+CoreDataProperties.swift
//  firstMap
//
//  Created by Walter on 12.12.2023.
//
//

import Foundation
import CoreData


extension MarkerEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MarkerEntity> {
        return NSFetchRequest<MarkerEntity>(entityName: "MarkerEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double

}

extension MarkerEntity : Identifiable {

}
