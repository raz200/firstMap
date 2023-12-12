//
//  DataController.swift
//  firstMap
//
//  Created by Walter on 12.12.2023.
//

import CoreData
import Foundation

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "LocationModel")

    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: (error.localizedDescription)")
            }
        }
    }
}
