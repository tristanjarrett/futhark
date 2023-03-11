//
//  ContentView.swift
//  futhark
//
//  Created by Tristan Jarrett on 13/02/2023.
//

import SwiftUI

struct CustomPicker<T>: View where T: Hashable {
    let title: String
    let options: [T]
    @Binding var selection: T
    
    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(action: { selection = option }) {
                    HStack {
                        Text(String(describing: option))
                        if option == selection {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                    .foregroundColor(Color.primary)
                }
            }
        } label: {
            HStack {
                Text("\(String(describing: selection))")
                    .lineLimit(1)
                    .foregroundColor(Color.primary)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(Color.primary)
            }
        }
    }
}

struct ContentView: View {
    // Define the available languages in an array
    let languages = ["English", "Elder Futhark", "Younger Futhark", "Short-Twig Futhark", "Staveless Hälsinge Futhark", "Anglo-Saxon"]
    
    // Define the state variables to hold the selected languages
    @State private var selectedFromLanguage = "English"
    @State private var selectedToLanguage = "Elder Futhark"
    
    // Define the state variable to hold the input text
    @State private var inputText = ""
    
    // Define the state variable to hold the output text
    @State private var outputText = ""
    
    var body: some View {
        ZStack {
            // Main content
            TabView {
                // Translation view
                VStack {
                    HStack {
                        CustomPicker(title: "From", options: languages.filter { $0 != selectedToLanguage }, selection: $selectedFromLanguage)
                            .padding()
                            .frame(maxWidth: .infinity / 2)
                            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.4), lineWidth: 1))
                        
                        Button(action: {
                            let temp = self.selectedFromLanguage
                            self.selectedFromLanguage = self.selectedToLanguage
                            self.selectedToLanguage = temp
                        }) {
                            Image(systemName: "arrow.left.arrow.right")
                                .foregroundColor(.black)
                                .padding()
                        }
                        
                        CustomPicker(title: "To", options: languages.filter { $0 != selectedFromLanguage }, selection: $selectedToLanguage)
                            .padding()
                            .frame(maxWidth: .infinity / 2)
                            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.4), lineWidth: 1))
                    }
                    .padding(.horizontal)
                    
                    ZStack(alignment: .topLeading) {
                        if inputText.isEmpty {
                            Text("Enter text")
                                .font(.custom("Helvetica", size: 24))
                                .foregroundColor(Color(.placeholderText))
                                .padding(.all, 24)
                        }
                        
                        TextEditor(text: $inputText)
                            .font(.custom("Helvetica", size: 24))
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity / 2, alignment: .topLeading)
                            .background(Color.white)
                            .opacity(inputText.isEmpty ? 0.25 : 1)
                    }
                    
                    if !inputText.isEmpty {
                        VStack {
                            HStack(alignment: .top) {
                                Text(outputText)
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                                    .font(.system(size: 24, weight: .bold))
                                    .lineLimit(nil)
                                    .padding()
                                
                                Button(action: {
                                    UIPasteboard.general.string = outputText
                                }) {
                                    Image(systemName: "doc.on.doc.fill")
                                        .foregroundColor(Color.black)
                                        .padding(.all, 20)
                                }
                            }
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity / 2)
                        .background(Color.gray.opacity(0.1))
                        .gesture(
                            LongPressGesture(minimumDuration: 1)
                                .onEnded { _ in
                                    UIPasteboard.general.string = outputText
                                }
                        )
                    }
                    
                }
                .padding(.vertical)
                .tabItem {
                    Image(systemName: "square.and.pencil")
                    Text("Translation")
                }
                
                // Camera view
                Text("Camera View Goes Here")
                    .tabItem {
                        Image(systemName: "camera.viewfinder")
                        Text("Camera")
                    }
                
                // Favorites view
                Text("Favorites List Goes Here")
                    .tabItem {
                        Image(systemName: "star.fill")
                        Text("Favorites")
                    }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

