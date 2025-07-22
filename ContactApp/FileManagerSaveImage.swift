//
//  FileManagerSaveImage.swift
//  ContactApp
//
//  Created by macbook on 22/07/2025.
//

import SwiftUI
import Foundation
extension FileManager {
    func saveImage(_ data: Data, for id: UUID) -> String? {
        let documentsDirectory = urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "\(id.uuidString).jpg"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL)
            return fileURL.path  
        } catch {
            print("❌ Failed to save image:", error)
            return nil
        }
    }
}

struct FileManagerSaveImage: View {
    var body: some View {
        AddContactSheet { newContact in
            print("Added contact: \(newContact.firstName) \(newContact.lastName)")
        }
    }
}


#Preview {
    FileManagerSaveImage()
}
