//
//  ContentView.swift
//  BetterClasscharts
//
//  Created by Ryan Wiecz on 21/11/24.
//

import SwiftUI

struct ContentView: View {
    @State private var dateOfBirth = Date()
    @State private var pupilCode = ""
    @Environment(\.colorScheme) var colorScheme
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var navigateToWelcome = false
    @State private var studentName = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Login")
                    .font(.largeTitle)
                    .padding(.bottom, 30)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                DatePicker(
                    "Date of Birth",
                    selection: $dateOfBirth,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.compact)
                .transformEffect(.identity)
                .labelsHidden()
                
                TextField("Pupil Code", text: $pupilCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .onChange(of: pupilCode) { oldValue, newValue in
                        pupilCode = newValue.filter { !$0.isWhitespace }
                    }
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: {
                    isLoading = true
                    errorMessage = nil
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd-MM-yyyy"
                    let formattedDate = formatter.string(from: dateOfBirth)
                    print("DOB: \(formattedDate)")
                    print("Pupil Code: \(pupilCode)")
                    print("Making request to ClassCharts API...")
                    
                    guard let url = URL(string: "https://www.classcharts.com/apiv2student/ping") else {
                        errorMessage = "Invalid URL"
                        print("Error: Invalid URL")
                        return
                    }
                    
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("Basic YOURTOKENHERE", forHTTPHeaderField: "Authorization")
                    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                    request.setValue("cc-session=YOURCOOKIEHERE", forHTTPHeaderField: "Cookie")
                    
                    URLSession.shared.dataTask(with: request) { data, response, error in
                        DispatchQueue.main.async {
                            isLoading = false
                            
                            if let error = error {
                                errorMessage = "Network error: \(error.localizedDescription)"
                                print("Network error: \(error.localizedDescription)")
                                return
                            }
                            
                            guard let httpResponse = response as? HTTPURLResponse else {
                                errorMessage = "Invalid response"
                                print("Error: Invalid response")
                                return
                            }
                            
                            print("Response status code: \(httpResponse.statusCode)")
                            
                            if !(200...299).contains(httpResponse.statusCode) {
                                errorMessage = "Server error: \(httpResponse.statusCode)"
                                print("Server error: \(httpResponse.statusCode)")
                                return
                            }
                            
                            if let data = data {
                                do {
                                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                        if let data = json["data"] as? [String: Any],
                                           let user = data["user"] as? [String: Any] {
                                            print("Response JSON:", user)
                                            if let lastName = user["last_name"] as? String {
                                                //studentName = user["first_name"] as? String ?? "" + " " + lastName
                                                studentName = user["name"] as? String ?? ""
                                                navigateToWelcome = true
                                            } else {
                                                errorMessage = "Could not find user's last name"
                                                print("Error: last_name not found in response")
                                            }
                                        }
                                    }
                                } catch {
                                    errorMessage = "Could not parse response data"
                                    print("JSON parsing error:", error)
                                }
                            } else {
                                errorMessage = "Could not read response data"
                                print("Error: Could not read response data")
                            }
                        }
                    }.resume()
                    
                }) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Continue")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(pupilCode.isEmpty || isLoading)
            }
            .padding()
            .background(colorScheme == .dark ? Color(.systemBackground) : .white)
            .navigationDestination(isPresented: $navigateToWelcome) {
                WelcomeView(studentName: studentName)
            }
        }
    }
}

struct WelcomeView: View {
    let studentName: String
    
    var body: some View {
        VStack {
            Text("Welcome \(studentName)")
                .font(.largeTitle)
                .padding()
        }
    }
}

#Preview {
    ContentView()
}
