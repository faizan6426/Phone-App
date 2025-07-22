//
//  ContactDetailSheet.swift
//  ContactApp
//
//  Created by macbook on 16/07/2025.
//

import SwiftUI

struct ContactDetailSheet: View {
    @State private var editableContact: Contact
    @State private var showEditSheet = false
    var onUpdate: (Contact) -> Void
    init(contact: Contact, onUpdate: @escaping (Contact) -> Void) {
        self._editableContact = State(initialValue: contact)
        self.onUpdate = onUpdate
    }
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let image = editableContact.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                }

                Text("\(editableContact.firstName) \(editableContact.lastName)")
                    .font(.largeTitle)
                    .bold()

                if !editableContact.company.trimmingCharacters(in: .whitespaces).isEmpty {
                    Text(editableContact.company)
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showEditSheet = true
                    }
                }
            }
            .sheet(isPresented: $showEditSheet) {
                EditContactSheet(contact: editableContact) { updatedContact in
                    editableContact = updatedContact
                    onUpdate(updatedContact) 
                }
            }
        }
    }
}

#Preview {
    ContactDetailSheet(contact: dummyContact) { _ in }
}

let dummyContact = Contact(
    firstName: "Ali",
    lastName: "Raza",
    company: "Apple Inc.", gender: ""
)
