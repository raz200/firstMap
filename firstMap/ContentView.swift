//
//  ContentView.swift
//  firstMap
//
//  Created by iosdev on 5.12.2023.
//

import SwiftUI
import MapKit
import Combine

struct ContentView: View {
    @StateObject private var mapAPI = MapAPI()
    @State private var text = ""
    @State private var isMapFullScreen = false
    
    var body: some View {
        VStack {
            
            // Searchbar
            TextField("Enter-address-string", text: $text)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            // Search a place
            Button("Search-place-string") {
                mapAPI.getLocation(address: text, delta: 0.5)
            }
            
            // Add a marker
            Button("Add-marker-string") {
                mapAPI.addCurrentLocation()
            }
            
            // List to display saved locations
            List {
                ForEach(mapAPI.savedLocations) { location in
                    HStack {
                        // Clickable location, zoom in to the location when pressed
                        Button(action: {
                            mapAPI.focusOnLocation(location)
                        }) {
                            Text(location.name)
                        }
                        
                        Spacer()
                        
                        // Delete location from list of added locations
                        Button(action: {
                            mapAPI.deleteLocation(location)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                .onDelete { indexSet in
                    
                    // Handle delete action when swiping left or using trashcan button
                    if let index = indexSet.first {
                        let location = mapAPI.savedLocations[index]
                        mapAPI.deleteLocation(location)
                    }
                }
            }
            .frame(height: 150) // Adjust the height as needed
            
            // Container for map size
            GeometryReader { geometry in
                Map(coordinateRegion: $mapAPI.region, annotationItems: mapAPI.locations) { location in
                    MapMarker(coordinate: location.coordinate, tint: .blue)
                }
                .frame(height: isMapFullScreen ? geometry.size.height : geometry.size.height/2)
            }
            
            // Map size button
            Button("Fullscreen-string") {
                withAnimation {
                    isMapFullScreen.toggle()
                }
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
