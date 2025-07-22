//
//  ContactListView.swift
//  ContactApp
//
//  Created by macbook on 14/07/2025.
//

import SwiftUI
import PhotosUI
struct Contact: Identifiable, Equatable, Codable {
    let id: UUID
    var firstName: String
    var lastName: String
    var company: String
    var gender: String
    var imagePath: String?

    var image: Image? {
        if let path = imagePath, let uiImage = UIImage(contentsOfFile: path) {
            Image(uiImage: uiImage)
        } else {
            Image(systemName: "person.crop.circle.fill")
        }
    }

    init(
        id: UUID = UUID(),
        firstName: String,
        lastName: String,
        company: String,
        gender: String,
        imagePath: String? = nil // 🔄 this replaces systemImageName
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.company = company
        self.gender = gender
        self.imagePath = imagePath
    }
}

extension UserDefaults {
    private var contactKey: String {"savedContacts"}
    
    func saveContacts(_ contacts: [Contact]) {
        if let data = try? JSONEncoder().encode(contacts) {
            set(data, forKey: contactKey)
        }
    }
    func loadContacts() -> [Contact] {
        if let data = data(forKey: contactKey),
           let contacts = try? JSONDecoder().decode([Contact].self, from: data) {
            return contacts
        }
        return []
    }
}
let defaultContacts: [Contact] = [
    Contact(
        firstName: "Faizan",
        lastName: "Shakeel",
        company: "iOS",
        gender: "",
        imagePath: nil // or use a default system image if needed
    ),
    Contact(
        firstName: "Hassan",
        lastName: "Shahid",
        company: "iOS",
        gender: "",
        imagePath: nil
    )
]
struct ContactListView: View {
    @State private var addContactSheet = false
    @State private var contacts: [Contact] = {
        let saved = UserDefaults.standard.loadContacts()
        return saved.isEmpty ? defaultContacts : saved
    } ()
    @State private var searchText = ""
    @State private var selectedContact: Contact? = nil
    private var filteredContacts: [Contact] {
        contacts.filter {
            searchText.isEmpty ||
            $0.firstName.lowercased().contains(searchText.lowercased()) ||
            $0.lastName.lowercased().contains(searchText.lowercased()) ||
            $0.company.lowercased().contains(searchText.lowercased())
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                if filteredContacts.isEmpty && !searchText.isEmpty {
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                    Text("No Results for \"\(searchText)\"")
                        .foregroundColor(.gray)
                        .font(.title3)
                    Text("Check the spelling or try a new search")
                        .font(.title3)
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    List {
                        ForEach(filteredContacts) { contact in
                            NavigationLink(destination:
                                ContactDetailSheet(contact: contact) { updatedContact in
                                    if let index = contacts.firstIndex(where: { $0.id == updatedContact.id }) {
                                        contacts[index] = updatedContact
                                    }
                                }
                            ) {
                                HStack(spacing: 12) {
                                    if let image = contact.image {
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                    } else {
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)
                                    }

                                    VStack(alignment: .leading) {
                                        Text("\(contact.firstName) \(contact.lastName)")
                                            .font(.headline)
                                        if !contact.company.trimmingCharacters(in: .whitespaces).isEmpty {
                                            Text(contact.company)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }

                        }
                        .onDelete(perform: deleteContacts)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Contacts")
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        addContactSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $addContactSheet) {
                AddContactSheet { newContact in
                    contacts.append(newContact)
                    UserDefaults.standard.saveContacts(contacts)
                }
            }

        }
    }

    func deleteContacts(at offsets: IndexSet) {
        contacts.remove(atOffsets: offsets)
        UserDefaults.standard.saveContacts(contacts)
    }

}

#Preview {
    ContactListView()
}
