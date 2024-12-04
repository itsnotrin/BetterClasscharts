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
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var navigateToWelcome = false
    @State private var studentName = ""
    @AppStorage("appTheme") private var appTheme: AppTheme = .catppuccinMacchiato
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.loginState) var loginState
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundColor(for: appTheme, colorScheme: colorScheme).ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("Login")
                        .font(.largeTitle.bold())
                        .foregroundColor(Theme.textColor(for: appTheme, colorScheme: colorScheme))
                        .padding(.top, 40)
                    
                    VStack(spacing: 20) {
                        // Date of Birth Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date of Birth")
                                .font(.headline)
                                .foregroundColor(Theme.textColor(for: appTheme, colorScheme: colorScheme))
                            
                            CustomDatePicker(selectedDate: $dateOfBirth)
                        }
                        .padding(.horizontal)
                        
                        // Pupil Code Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Pupil Code")
                                .font(.headline)
                                .foregroundColor(Theme.textColor(for: appTheme, colorScheme: colorScheme))
                            
                            TextField("", text: $pupilCode)
                                .textFieldStyle(.plain)
                                .frame(height: 40)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Theme.surfaceColor(for: appTheme, colorScheme: colorScheme))
                                .cornerRadius(12)
                                .foregroundColor(Theme.textColor(for: appTheme, colorScheme: colorScheme))
                                .tint(Theme.accentColor(for: appTheme))
                        }
                        .padding(.horizontal)
                        
                        if let error = errorMessage {
                            Text(error)
                                .foregroundColor(Theme.red)
                                .font(.subheadline)
                                .padding(.horizontal)
                        }
                        
                        Button(action: performLogin) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(Theme.textColor(for: appTheme, colorScheme: colorScheme))
                                } else {
                                    Text("Continue")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(pupilCode.isEmpty ? Theme.surfaceColor(for: appTheme, colorScheme: colorScheme) : Theme.accentColor(for: appTheme))
                            .foregroundColor(Theme.textColor(for: appTheme, colorScheme: colorScheme))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        .disabled(pupilCode.isEmpty || isLoading)
                        
                        Spacer()
                    }
                }
            }
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
    
    private func performLogin() {
        isLoading = true
        errorMessage = nil
        
        StudentClient.login(dateOfBirth: dateOfBirth, pupilCode: pupilCode) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let firstName):
                    StudentClient.saveCredentials(pupilCode: pupilCode, dateOfBirth: dateOfBirth)
                    studentName = firstName
                    loginState.isLoggedIn = true
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
                        case .sessionExpired:
                            errorMessage = "Session expired, please try again"
                        }
                    } else {
                        errorMessage = error.localizedDescription
                    }
                }
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
    
    private func getPreferredColorScheme() -> ColorScheme? {
        switch appTheme {
        case .light, .catppuccinLatte:
            return .light
        case .dark, .dracula, .catppuccinFrappe, .catppuccinMacchiato, .catppuccinMocha:
            return .dark
        }
    }
}

struct CustomDatePicker: View {
    @Binding var selectedDate: Date
    @AppStorage("appTheme") private var appTheme: AppTheme = .catppuccinMacchiato
    @Environment(\.colorScheme) var colorScheme
    @State private var showingPicker = false
    
    var body: some View {
        Button(action: { showingPicker = true }) {
            HStack {
                Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                    .foregroundColor(Theme.textColor(for: appTheme, colorScheme: colorScheme))
                Spacer()
            }
            .contentShape(Rectangle())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Theme.surfaceColor(for: appTheme, colorScheme: colorScheme))
        .cornerRadius(12)
        .sheet(isPresented: $showingPicker) {
            NavigationStack {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .tint(Theme.accentColor(for: appTheme))
                    .padding()
                    .navigationTitle("Select Date of Birth")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                showingPicker = false
                            }
                        }
                    }
            }
            .presentationDetents([.medium])
        }
    }
}

#Preview {
    ContentView()
}
