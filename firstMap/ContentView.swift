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
            TextField("Enter an address", text: $text)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            Button("Search for a place") {
                mapAPI.getLocation(address: text, delta: 0.5)
            }
            Button("Add a marker to this location") {
                           mapAPI.addCurrentLocation()
                       }
            // List to display saved locations
            List(mapAPI.savedLocations) { location in
                Button(action: {
                    mapAPI.focusOnLocation(location)
                }) {
                    Text(location.name)
                }
            }
            .frame(height: 150) // Adjust the height as needed

            GeometryReader { geometry in
                Map(coordinateRegion: $mapAPI.region, annotationItems: mapAPI.locations) { location in
                    MapMarker(coordinate: location.coordinate, tint: .blue)
                }
                .frame(height: isMapFullScreen ? geometry.size.height : geometry.size.height / 2)
                .onTapGesture {}
            }
            .disabled(isMapFullScreen)

            Button("Toggle Fullscreen") {
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
