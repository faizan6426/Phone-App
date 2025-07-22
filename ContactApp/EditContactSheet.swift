//
//  EditContactSheet.swift
//  ContactApp
//
//  Created by macbook on 19/07/2025.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct EditContactSheet: View {
    @Environment(\.dismiss) private var dismiss
    var contact: Contact
    var onSave: (Contact) -> ()

    @State private var selectedImage: Image?
    @State private var selectedUIImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    @State private var showImageSourceMenu = false
    @State private var imageSource: ImageSourceType?
    @State private var selectedFileURL: URL? = nil

    @State private var firstName: String
    @State private var lastName: String
    @State private var company: String
    @State private var selectedGender: String

    enum ImageSourceType {
        case gallery, files
    }

    let genders = ["Male", "Female", "Unknown"]

    init(contact: Contact, onSave: @escaping (Contact) -> Void) {
        self.contact = contact
        self.onSave = onSave
        _firstName = State(initialValue: contact.firstName)
        _lastName = State(initialValue: contact.lastName)
        _company = State(initialValue: contact.company)
        _selectedGender = State(initialValue: contact.gender)
        _selectedImage = State(initialValue: contact.image)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                photoSectionView()
                formSectionView()
                Spacer()
            }
            .photosPicker(
                isPresented: Binding(
                    get: { imageSource == .gallery },
                    set: { if !$0 { imageSource = nil } }
                ),
                selection: $selectedItem,
                matching: .images
            )
            .fileImporter(
                isPresented: Binding(
                    get: { imageSource == .files },
                    set: { if !$0 { imageSource = nil } }
                ),
                allowedContentTypes: [.image],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result)
            }
            .onChange(of: selectedItem, handlePhotoSelectionChange)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: onDone)
                }
            }
        }
    }

    @ViewBuilder
    private func photoSectionView() -> some View {
        if let image = selectedImage {
            image
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

        Button("Change Photo") {
            showImageSourceMenu = true
        }
        .confirmationDialog("Select Photo Source", isPresented: $showImageSourceMenu, titleVisibility: .visible) {
            Button("Gallery") { imageSource = .gallery }
            Button("Files") { imageSource = .files }
        }
    }

    private func formSectionView() -> some View {
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
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first,
               let data = try? Data(contentsOf: url),
               let uiImage = UIImage(data: data) {
                selectedUIImage = uiImage
                selectedImage = Image(uiImage: uiImage)
            }
        case .failure(let error):
            print("❌ File import error: \(error)")
        }
    }

    private func handlePhotoSelectionChange(_: PhotosPickerItem?, newItem: PhotosPickerItem?) {
        Task {
            if let data = try? await newItem?.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                selectedUIImage = uiImage
                selectedImage = Image(uiImage: uiImage)
            }
        }
    }

    private func onDone() {
        var imagePath: String? = contact.imagePath

        if let uiImage = selectedUIImage,
           let data = uiImage.jpegData(compressionQuality: 0.8) {
            imagePath = FileManager.default.saveImage(data, for: contact.id)
        }

        let updatedContact = Contact(
            id: contact.id,
            firstName: firstName,
            lastName: lastName,
            company: company,
            gender: selectedGender,
            imagePath: imagePath
        )

        onSave(updatedContact)
        dismiss()
    }
    private func onCancel() {
        dismiss()
    }
}

#Preview {
    EditContactSheet(
        contact: Contact(
            firstName: "Preview",
            lastName: "User",
            company: "Example Inc.",
            gender: "Male"
        ),
        onSave: { updated in
            print("✅ Updated contact: \(updated)")
        }
    )
}
