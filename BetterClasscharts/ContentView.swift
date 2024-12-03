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
                    
                    StudentClient.login(dateOfBirth: dateOfBirth, pupilCode: pupilCode) { result in
                        DispatchQueue.main.async {
                            isLoading = false
                            
                            switch result {
                            case .success(let firstName):
                                StudentClient.saveCredentials(pupilCode: pupilCode, dateOfBirth: dateOfBirth)
                                studentName = firstName
                                navigateToWelcome = true
                            case .failure(let error):
                                StudentClient.clearSavedCredentials()
                                if let networkError = error as? NetworkError {
                                    switch networkError {
                                    case .incorrectDOB:
                                        errorMessage = "The date of birth you provided is incorrect"
                                    case .incorrectCode:
                                        errorMessage = "Invalid Login Code"
                                    case .invalidCredentials:
                                        errorMessage = "Invalid credentials"
                                    case .invalidURL:
                                        errorMessage = "Invalid URL"
                                    case .invalidResponse:
                                        errorMessage = "Invalid response"
                                    case .serverError(let code):
                                        errorMessage = "Server error: \(code)"
                                    case .noData:
                                        errorMessage = "Could not read response data"
                                    case .missingUserData:
                                        errorMessage = "Could not find user's name"
                                    }
                                } else {
                                    errorMessage = error.localizedDescription
                                }
                            }
                        }
                    }
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
                MainTabView(studentName: studentName)
            }
        }
        .onAppear {
            if let saved = StudentClient.getSavedCredentials() {
                dateOfBirth = saved.dateOfBirth
                pupilCode = saved.pupilCode
                attemptAutoLogin(dateOfBirth: saved.dateOfBirth, pupilCode: saved.pupilCode)
            }
        }
    }
    
    private func attemptAutoLogin(dateOfBirth: Date, pupilCode: String) {
        isLoading = true
        StudentClient.login(dateOfBirth: dateOfBirth, pupilCode: pupilCode) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let firstName):
                    studentName = firstName
                    navigateToWelcome = true
                case .failure:
                    StudentClient.clearSavedCredentials()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
