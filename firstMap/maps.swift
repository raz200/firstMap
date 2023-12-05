//
//  maps.swift
//  firstMap
//
//  Created by iosdev on 5.12.2023.
//

import Foundation
import MapKit

// Address Data Model
struct Address: Codable {
    let data: [Datum]
}

struct Datum: Codable {
    let latitude, longitude: Double
    let name: String?
}

// Our Pin Locations
struct Location: Identifiable, Codable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

extension CLLocationCoordinate2D: Codable {
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}
class MapAPI: ObservableObject {
    private let BASE_URL = "http://api.positionstack.com/v1/forward"
    private let API_KEY = "92d0989cebd26dea67f59db3a280d7a6"
    
    @Published var region: MKCoordinateRegion
    @Published var coordinates = []
    @Published var locations: [Location] = []
    @Published var savedLocations: [Location] = []
    
    init() {
        // Default Info
        self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5))

        self.locations.insert(Location(name: "Pin", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275)), at: 0)

        // Load and display saved locations when initializing
        loadAndDisplaySavedLocations()
    }

    
    // Method to focus on a specific location on the map
    func focusOnLocation(_ location: Location) {
        region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    }
    
    func saveLocations() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(savedLocations) {
            UserDefaults.standard.set(encoded, forKey: "savedLocations")
        }
    }
    
    // Method to load locations from UserDefaults
    func loadLocations() {
        if let data = UserDefaults.standard.data(forKey: "savedLocations") {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([Location].self, from: data) {
                savedLocations = decoded
            }
        }
    }
    
    func loadAndDisplaySavedLocations() {
           loadLocations()

           // Update the locations array to display the saved markers on the map
           DispatchQueue.main.async {
               self.locations = self.savedLocations
           }
       }
    
    // API request
    func getLocation(address: String, delta: Double) {
        let pAddress = address.replacingOccurrences(of: " ", with: "%20")
        let url_string = "\(BASE_URL)?access_key=\(API_KEY)&query=\(pAddress)"
        
        guard let url = URL(string: url_string) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("Invalid status code: \(httpResponse.statusCode)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let newCoordinates = try JSONDecoder().decode(Address.self, from: data)
                if newCoordinates.data.isEmpty {
                    print("Could not find address...")
                    return
                }
                
                DispatchQueue.main.async {
                    let details = newCoordinates.data[0]
                    let lat = details.latitude
                    let lon = details.longitude
                    
                    self.coordinates = [lat, lon]
                    self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lon), span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta))
                    
                    let new_location = Location(name: "\(details.name ?? "Unnamed")", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                    self.locations.removeAll()
                    self.locations.append(new_location)
                    
                    print("Successfully loaded location: \(details.name ?? "Unnamed")")
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }
        .resume()
    }
    
    // Method to add the current location to saved locations
    func addCurrentLocation() {
        guard let currentLocation = locations.first else {
            print("No location to add.")
            return
        }
        
        savedLocations.append(currentLocation)
        print("Location added: \(currentLocation.name)")
        
        DispatchQueue.main.async {
            self.locations.append(currentLocation)
            self.saveLocations() // Save locations after adding a new one
        }
    }
    
    // Method to add a specific location to saved locations
    func addLocation(location: Location) {
        savedLocations.append(location)
        print("Location added: \(location.name)")
        
        DispatchQueue.main.async {
            self.saveLocations() // Save locations after adding a new one
        }
    }
}
