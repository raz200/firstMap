//
//  Details.swift
//  firstMap
//
//  Created by Walter on 13.12.2023.
//

import SwiftUI
import CoreData
import PhotosUI

struct Details: View {
    @Binding var editedNotes: String
    var location: Location

    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false

    //@Environment(.managedObjectContext) private var viewContext

    var body: some View {
        VStack {
            Text("Notes at (location.name)")
                .font(.title)
                .padding()

            TextField("Enter notes", text: $editedNotes)
                .textFieldStyle(.roundedBorder)
                .padding()

            Button(action: {
                showImagePicker.toggle()
            }) {
                Text("Add Photo")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .sheet(isPresented: $showImagePicker, onDismiss: {
                savePhoto()
            }) {
                //ImagePicker(selectedImage: $selectedImage)
            }

            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                    .padding()
            }

        }
        .padding()
    }

    private func savePhoto() {
        guard let selectedImage = selectedImage,
              let imageData = selectedImage.jpegData(compressionQuality: 1.0) else {
            return
        }

        let newLocationEntity = LocationEntity(context: viewContext)
        newLocationEntity.photo = imageData
        newLocationEntity.notes = editedNotes

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error (nsError), (nsError.userInfo)")
        }
    }
}
