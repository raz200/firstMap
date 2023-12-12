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
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var markers: FetchedResults<MarkerEntity>
    @State private var text = ""
    @State private var isMapFullScreen = false

    var body: some View {
        VStack {
            TextField("Enter-address-string", text: $text)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            Button("Search-place-string") {
                mapAPI.getLocation(address: text, delta: 0.5)
            }
            Button("Add-marker-string") {
                mapAPI.addCurrentLocation()
            }
            // List to display saved locations
            List {
                            ForEach(mapAPI.savedLocations) { location in
                                HStack {
                                    Button(action: {
                                        mapAPI.focusOnLocation(location)
                                    }) {
                                        Text(location.name)
                                    }

                                    Spacer()

                                    Button(action: {
                                        mapAPI.deleteLocation(location)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(BorderlessButtonStyle()) // Use BorderlessButtonStyle for the delete button
                                }
                            }
                            .onDelete { indexSet in
                                // Handle delete action when swiping or using Edit button
                                if let index = indexSet.first {
                                    let location = mapAPI.savedLocations[index]
                                    mapAPI.deleteLocation(location)
                                }
                            }
                        }
                        .frame(height: 150) // Adjust the height as needed

            GeometryReader { geometry in
                Map(coordinateRegion: $mapAPI.region, annotationItems: mapAPI.locations) { location in
                    MapMarker(coordinate: location.coordinate, tint: .blue)
                }
                .frame(height: isMapFullScreen ? geometry.size.height : geometry.size.height/2)
            }


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
