//
//  AddContactSheet.swift
//  ContactApp
//
//  Created by macbook on 16/07/2025.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct AddContactSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedUIImage: UIImage? = nil
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var showPhotoPicker = false
    @State private var showFileImporter = false
    @State private var showPhotoSourceDialog = false

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var company = ""
    @State private var selectedGender = ""
    let genders = ["Male", "Female", "Unknown"]

    let onAdd: (Contact) -> Void

    private var shouldDisableDoneButton: Bool {
        firstName.trimmingCharacters(in: .whitespaces).isEmpty ||
        lastName.trimmingCharacters(in: .whitespaces).isEmpty ||
        selectedGender.isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let image = selectedUIImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .foregroundColor(.gray)
                }

                Button("Add Photo") {
                    showPhotoSourceDialog = true
                }

                Form {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Company", text: $company)

                    Section(header: Text("Select Gender")) {
                        Picker("Gender", selection: $selectedGender) {
                            ForEach(genders, id: \.self) { gender in
                                Text(gender).tag(gender)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }

                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: onDone)
                        .disabled(shouldDisableDoneButton)
                }
            }
            .confirmationDialog("Select Photo Source", isPresented: $showPhotoSourceDialog) {
                Button("Photo Library") {
                    showPhotoPicker = true
                }
                Button("Browse Files") {
                    showFileImporter = true
                }
            }
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [.image],
                onCompletion: handleFileImport)
            .photosPicker(isPresented: $showPhotoPicker, selection: $selectedItem, matching: .images)
            .onChange(of: selectedItem, perform: handleOnChangeOfSelectedItem)
        }
    }

    private func onCancel() {
        dismiss()
    }

    private func onDone() {
        let id = UUID()
        var imagePath: String? = nil

        if let selectedUIImage,
           let data = selectedUIImage.jpegData(compressionQuality: 0.8) {
            imagePath = FileManager.default.saveImage(data, for: id)
        }

        let newContact = Contact(
            id: id,
            firstName: firstName,
            lastName: lastName,
            company: company,
            gender: selectedGender,
            imagePath: imagePath
        )

        onAdd(newContact)
        dismiss()
    }

    private func handleFileImport(_ result: Result<URL, any Error>) {
        do {
            let url = try result.get()
            let data = try Data(contentsOf: url)
            if let uiImage = UIImage(data: data) {
                selectedUIImage = uiImage
            }
        } catch {
            print("❌ Failed to import image:", error)
        }
    }

    private func handleOnChangeOfSelectedItem(_ item: PhotosPickerItem?) {
        Task {
            if let data = try? await item?.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                selectedUIImage = uiImage
            }
        }
    }
}

#Preview {
    AddContactSheet { _ in }
}
