//
//  ContentView.swift
//  GeminiAPI
//
//  Created by 陳昱安 on 2025/3/13.
//

import SwiftUI
import PhotosUI
import GoogleGenerativeAI
struct ContentView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: Image?
    let model = GenerativeModel(name: "gemini-1.5-flash", apiKey: APIKey.default)
    @State private var analyzedResult: String?
    @State private var isAnalyzing: Bool = false
    @MainActor func analyze() {
        print("Analyzing function called!")
        self.analyzedResult = nil
        self.isAnalyzing = true
        
        Task {
            guard let selectedItem = selectedItem,
                  let data = try? await selectedItem.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else {
                print("Failed to load image.")
                return
            }
            
            print("Image successfully loaded.")
            
            let fixedImage = fixImageOrientation(uiImage)
            print("Fixed image orientation.")
            
            let prompt = "用中文描述圖片"
            
            do {
                print("Calling GoogleGenerativeAI API...")
                let response = try await model.generateContent([prompt, fixedImage])
                if let text = response.text {
                    print("Response received: \(text)")
                    self.analyzedResult = text
                } else {
                    print("No text response from API")
                }
            } catch {
                print("Error during API call: \(error.localizedDescription)")
            }
            
            self.isAnalyzing = false
        }
    }
    var body: some View {
        VStack {
            
            if let selectedImage {
                selectedImage
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 20.0))
            } else {
                
                Image(systemName: "photo")
                    .imageScale(.large)
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 20.0))
            }
            ScrollView {
                Text(analyzedResult ?? (isAnalyzing ? "Analyzing..." : "Select a photo to get started"))
                    .font(.system(.title2, design: .rounded))
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 20.0))
            Spacer()
            
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Label("Select Photo", systemImage: "photo")
                    .frame(maxWidth: .infinity)
                    .bold()
                    .padding()
                    .foregroundStyle(.white)
                    .background(.indigo)
                    .clipShape(RoundedRectangle(cornerRadius: 20.0))
            }
        }
        .padding(.horizontal)
        .onChange(of: selectedItem) { oldItem, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    print("Image selected, updating UI and analyzing...")
                    selectedImage = Image(uiImage: uiImage)
                    analyze() // 確保這行有執行
                } else {
                    print("Failed to convert selected item to UIImage")
                }
            }
        }
    }
    func fixImageOrientation(_ image: UIImage) -> UIImage {
        if image.imageOrientation == .up {
            return image
        }
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let correctedImage = normalizedImage else {
            print("Failed to correct image orientation")
            return image
        }
        
        return correctedImage
    }
}

#Preview {
    ContentView()
}
