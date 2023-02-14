//
//  ContentView.swift
//  futhark
//
//  Created by Tristan Jarrett on 13/02/2023.
//

import SwiftUI
import Vision
import VisionKit

struct ContentView: View {
    
    @State private var inputText = ""
    @State private var outputText = ""
    @State private var errorMessage: String? = nil
    @State private var showImagePicker = false
    @State private var showCaptureImageView = false
    @State private var image: UIImage? = nil
    @State private var imageLoading = false

    let dictionary = [
        "ᚠ": "F",
        "ᚢ": "U",
        "ᚦ": "TH",
        "ᚨ": "A",
        "ᚱ": "R",
        "ᚲ": "K",
        "ᚷ": "G",
        "ᚹ": "W",
        "ᚺ": "H",
        "ᚾ": "N",
        "ᛁ": "I",
        "ᛃ": "J",
        "ᛇ": "EO",
        "ᛈ": "P",
        "ᛊ": "S",
        "ᛏ": "T",
        "ᛒ": "B",
        "ᛖ": "E",
        "ᛗ": "M",
        "ᛚ": "L",
        "ᛜ": "ING",
        "ᛣ": "C",
        "ᛦ": "Y",
        "ᛧ": "EA"
    ]
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack {
                    Color(.systemBackground)
                        .ignoresSafeArea()
                        .frame(height: 44)

                    HStack {
                        Button(action: {
                            print("Tapped cancel")
                        }, label: {
                            Text("Cancel")
                        })

                        Spacer()

                        Text("Futhark Translator")
                            .font(.headline)

                        Spacer()

                        Button(action: {
                            print("Tapped done")
                        }, label: {
                            Text("Done")
                        })
                    }
                    .padding(.horizontal, 16)
                }

                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .padding()
                } else {
                    VStack {
                        TextField("Enter text", text: $inputText)
                            .font(.headline)
                            .padding(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))
                    }
                    .background(Color(.secondarySystemBackground))
                    .padding(.horizontal, 16)
                }

                HStack {
                    if image != nil {
                        Button(action: {
                            outputText = ""
                            image = nil
                        }, label: {
                            Text("Remove")
                        })
                        .padding(16)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    } else {
                        if !imageLoading {
                            Button(action: {
                                self.showImagePicker.toggle()
                            }, label: {
                                Image(systemName: "photo")
                            })
                            .padding(16)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .sheet(isPresented: $showImagePicker) {
                                ImagePicker(image: $image)
                            }

                            Button(action: {
                                self.showCaptureImageView.toggle()
                            }, label: {
                                Image(systemName: "camera")
                            })
                            .padding(16)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .sheet(isPresented: $showCaptureImageView) {
                                CaptureImageView(image: $image)
                            }
                        }
                    }

                    Spacer()

                    Button(action: translate, label: {
                        Text("Translate")
                    })
                    .padding(16)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                Text(outputText)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
    }
    
    func translate() {
        errorMessage = nil

        if let image = image {
            guard let ciImage = CIImage(image: image) else {
                errorMessage = "Failed to create image from input"
                return
            }
            
            recognizeText(from: ciImage, with: dictionary)
        } else {
            let input = inputText.isEmpty ? " " : inputText
            let translatedText = input.map { dictionary[String($0)] ?? String($0) }.joined()
            outputText = translatedText
        }
    }


    func recognizeText(from image: CIImage, with dictionary: [String: String]) {
        let textRecognitionRequest = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        textRecognitionRequest.recognitionLevel = .accurate
        let roi = CGRect(x: 0, y: 0.4, width: 1, height: 0.2) // Add this line
        textRecognitionRequest.regionOfInterest = roi // Add this line
        let requests = [textRecognitionRequest]
        let imageRequestHandler = VNImageRequestHandler(ciImage: image, options: [:])
        
        do {
            try imageRequestHandler.perform(requests)
        } catch {
            errorMessage = error.localizedDescription
        }
    }


    func recognizeTextHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            errorMessage = "Recognition failed"
            return
        }
        
        var recognizedText = ""
        
        for observation in observations {
            guard let topCandidate = observation.topCandidates(1).first else { continue }
            
            recognizedText += topCandidate.string + " "
        }
        
        let translatedText = recognizedText.map { dictionary[String($0)] ?? String($0) }.joined()
        
        outputText = translatedText
    }

}

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let pickedImage = info[.originalImage] as? UIImage {
                parent.image = pickedImage
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }
}

struct CaptureImageView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: CaptureImageView
        
        init(_ parent: CaptureImageView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let pickedImage = info[.originalImage] as? UIImage {
                parent.image = pickedImage
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CaptureImageView>) -> UIImagePickerController {
        let cameraViewController = UIImagePickerController()
        cameraViewController.sourceType = .camera
        cameraViewController.allowsEditing = true
        cameraViewController.delegate = context.coordinator
        return cameraViewController
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<CaptureImageView>) {
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

