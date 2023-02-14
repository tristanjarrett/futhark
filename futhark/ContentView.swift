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
    // Define the available languages in an array
    let languages = ["English", "Elder Furthark", "Younger Furthark", "Short-Twig Furthark", "Staveless Hälsinge Furthark", "Anglo-Saxon"]
    
    // Define the state variables to hold the selected languages
    @State private var selectedFromLanguage = "English"
    @State private var selectedToLanguage = "English"
    
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
                        Picker("From Language", selection: $selectedFromLanguage) {
                            ForEach(languages, id: \.self) { language in
                                Text(language)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity/2, alignment: .leading)
                        
                        Picker("To Language", selection: $selectedToLanguage) {
                            ForEach(languages.filter { $0 != selectedFromLanguage }, id: \.self) { language in
                                Text(language)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity/2, alignment: .leading)
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    VStack {
                        TextField("Enter text to translate", text: $inputText)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity / 2)
                            .background(Color.white)
                        
                        Text(outputText)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity / 2)
                            .background(Color.gray.opacity(0.2))
                            .font(.system(size: 20, weight: .bold))
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
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

