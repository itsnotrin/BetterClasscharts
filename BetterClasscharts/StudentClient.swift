import Foundation

enum ClassChartsAPI {
    static let BASE_URL = "https://www.classcharts.com"
    static let API_BASE_STUDENT = "\(BASE_URL)/apiv2student"
    static let API_BASE_PARENT = "\(BASE_URL)/apiv2parent"
    static let PING_INTERVAL: TimeInterval = 180 // 3 minutes in seconds
}

class StudentClient {
    private static var sessionId: String?
    private static var authCookies: [String]?
    private static var studentId: Int?
    private static var lastPing: Date?
    private static var currentSessionId: String?
    private static let defaults = UserDefaults.standard
    private static let PUPIL_CODE_KEY = "pupilCode"
    private static let DOB_KEY = "dateOfBirth"
    
    static func login(dateOfBirth: Date, pupilCode: String, completion: @escaping (Result<String, Error>) -> Void) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let formattedDate = formatter.string(from: dateOfBirth)
        
        // First, perform login
        loginStudent(dateOfBirth: formattedDate, pupilCode: pupilCode) { result in
            switch result {
            case .success(let cookies):
                // After successful login, fetch student info using the cookies
                fetchStudentInfo(cookies: cookies) { infoResult in
                    switch infoResult {
                    case .success(let firstName):
                        completion(.success(firstName))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private static func loginStudent(dateOfBirth: String, pupilCode: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(ClassChartsAPI.API_BASE_STUDENT)/login") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let formData = [
            "code": pupilCode,
            "dob": dateOfBirth,
            "recaptcha-token": "no-token-available"
        ]
        
        let formBody = formData.map { key, value in
            let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
            let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
            return "\(encodedKey)=\(encodedValue)"
        }.joined(separator: "&")
        
        request.httpBody = formBody.data(using: .utf8)
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            if httpResponse.statusCode == 200 {
                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                let jsonString = String(data: data, encoding: .utf8) ?? "No data"
                
                if jsonString.contains("The date of birth you have provided is incorrect") {
                    completion(.failure(NetworkError.incorrectDOB))
                    return
                }
                if jsonString.contains("The pupil code you have provided is incorrect") {
                    completion(.failure(NetworkError.incorrectCode))
                    return
                }
                
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let meta = json["meta"] as? [String: Any] else {
                    completion(.failure(NetworkError.missingUserData))
                    return
                }
                
                guard let sessionId = meta["session_id"] as? String else {
                    completion(.failure(NetworkError.missingUserData))
                    return
                }
                
                currentSessionId = sessionId
                lastPing = Date()
                completion(.success(sessionId))
            } else {
                completion(.failure(NetworkError.serverError(httpResponse.statusCode)))
            }
        }
        task.resume()
    }
    
    private static func fetchStudentInfo(cookies: String, completion: @escaping (Result<String, Error>) -> Void) {
        checkAndRefreshSession { result in
            switch result {
            case .success:
                guard let sessionId = currentSessionId else {
                    completion(.failure(NetworkError.invalidCredentials))
                    return
                }
                
                guard let url = URL(string: "\(ClassChartsAPI.API_BASE_STUDENT)/ping") else {
                    completion(.failure(NetworkError.invalidURL))
                    return
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.setValue("Basic \(sessionId)", forHTTPHeaderField: "Authorization")
                
                let formData = "include_data=true"
                request.httpBody = formData.data(using: .utf8)
                
                let config = URLSessionConfiguration.default
                config.waitsForConnectivity = true
                let session = URLSession(configuration: config)
                
                let task = session.dataTask(with: request) { data, response, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    guard let data = data,
                          let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                          let userData = json["data"] as? [String: Any],
                          let user = userData["user"] as? [String: Any],
                          let firstName = user["first_name"] as? String,
                          let id = user["id"] as? Int else {
                        completion(.failure(NetworkError.missingUserData))
                        return
                    }
                    
                    studentId = id
                    completion(.success(firstName))
                }
                task.resume()
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private static func parseCookies(_ cookieString: String) -> [String: String] {
        var cookies: [String: String] = [:]
        let cookieParts = cookieString.split(separator: ",")
        
        for cookie in cookieParts {
            let parts = String(cookie).split(separator: ";")[0].split(separator: "=")
            if parts.count == 2 {
                let key = String(parts[0]).trimmingCharacters(in: .whitespaces)
                let value = String(parts[1])
                cookies[key] = value
            }
        }
        return cookies
    }
    
    static func checkAndRefreshSession(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let sessionId = currentSessionId else {
            completion(.failure(NetworkError.invalidCredentials))
            return
        }
        
        // Check if we need to ping (3 minutes passed)
        if let lastPing = lastPing,
           Date().timeIntervalSince(lastPing) < ClassChartsAPI.PING_INTERVAL {
            completion(.success(()))
            return
        }
        
        guard let url = URL(string: "\(ClassChartsAPI.API_BASE_STUDENT)/ping") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(sessionId)", forHTTPHeaderField: "Authorization")
        
        let formData = "include_data=true"
        request.httpBody = formData.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            if httpResponse.statusCode == 200 {
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let meta = json["meta"] as? [String: Any],
                   let newSessionId = meta["session_id"] as? String {
                    currentSessionId = newSessionId
                    lastPing = Date()
                    completion(.success(()))
                } else {
                    completion(.failure(NetworkError.missingUserData))
                }
            } else {
                completion(.failure(NetworkError.serverError(httpResponse.statusCode)))
            }
        }
        task.resume()
    }
    
    static func saveCredentials(pupilCode: String, dateOfBirth: Date) {
        defaults.setValue(pupilCode, forKey: PUPIL_CODE_KEY)
        defaults.setValue(dateOfBirth.timeIntervalSince1970, forKey: DOB_KEY)
    }
    
    static func getSavedCredentials() -> (pupilCode: String, dateOfBirth: Date)? {
        guard let pupilCode = defaults.string(forKey: PUPIL_CODE_KEY),
              let dobTimestamp = defaults.object(forKey: DOB_KEY) as? TimeInterval else {
            return nil
        }
        return (pupilCode, Date(timeIntervalSince1970: dobTimestamp))
    }
    
    static func clearSavedCredentials() {
        defaults.removeObject(forKey: PUPIL_CODE_KEY)
        defaults.removeObject(forKey: DOB_KEY)
    }
    
    private static func retryRequestIfNeeded<T>(
        completion: @escaping (Result<T, Error>) -> Void,
        request: @escaping (@escaping (Result<T, Error>) -> Void) -> Void
    ) {
        request { result in
            if case .failure(let error) = result,
               let networkError = error as? NetworkError,
               networkError == .sessionExpired {
                // Session expired, refresh and retry once
                checkAndRefreshSession { refreshResult in
                    switch refreshResult {
                    case .success:
                        // Token refreshed, retry the original request
                        request(completion)
                    case .failure(let refreshError):
                        // Token refresh failed, return the error
                        completion(.failure(refreshError))
                    }
                }
            } else {
                // Not a session expiration or second attempt, return the result
                completion(result)
            }
        }
    }
    
    private static func handleResponse(data: Data, completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        do {
            // First try to parse as error response
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let success = json["success"] as? Int,
               let expired = json["expired"] as? Int,
               success == 0 && expired == 1 {
                completion(.failure(NetworkError.sessionExpired))
                return
            }
            
            // Parse the response
            let responseData = try JSONParser.parseResponse(data)
            completion(.success(responseData))
        } catch {
            completion(.failure(error))
        }
    }
    
    static func fetchHomework(completion: @escaping (Result<[HomeworkTask], Error>) -> Void) {
        retryRequestIfNeeded(completion: completion) { completion in
            checkAndRefreshSession { result in
                switch result {
                case .success:
                    guard let sessionId = currentSessionId else {
                        completion(.failure(NetworkError.invalidCredentials))
                        return
                    }
                    
                    guard let url = URL(string: "\(ClassChartsAPI.API_BASE_STUDENT)/homeworks") else {
                        completion(.failure(NetworkError.invalidURL))
                        return
                    }
                    
                    var request = URLRequest(url: url)
                    request.httpMethod = "GET"
                    request.setValue("Basic \(sessionId)", forHTTPHeaderField: "Authorization")
                    
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        
                        guard let data = data else {
                            completion(.failure(NetworkError.noData))
                            return
                        }
                                                
                        handleResponse(data: data) { result in
                            switch result {
                            case .success(let homeworks):
                                let tasks = homeworks.compactMap { homework -> HomeworkTask? in
                                    guard let title = homework["title"] as? String,
                                          let status = homework["status"] as? [String: Any],
                                          let id = status["id"] as? Int,
                                          let subject = homework["subject"] as? String,
                                          let dueDateString = homework["due_date"] as? String,
                                          let description = homework["description"] as? String,
                                          let completed = status["ticked"] as? String else {
                                        return nil
                                    }
                                    
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd"
                                    if let dueDate = dateFormatter.date(from: dueDateString) {
                                        return HomeworkTask(
                                            id: id,
                                            title: title,
                                            subject: subject,
                                            dueDate: dueDate,
                                            description: description,
                                            completed: completed == "yes"
                                        )
                                    }
                                    return nil
                                }
                                completion(.success(tasks))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    }
                    task.resume()
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    static func toggleHomeworkCompletion(homeworkId: Int, completed: Bool, completion: @escaping (Result<Bool, Error>) -> Void) {
        retryRequestIfNeeded(completion: completion) { completion in
            checkAndRefreshSession { result in
                switch result {
                case .success:
                    guard let sessionId = currentSessionId else {
                        completion(.failure(NetworkError.invalidCredentials))
                        return
                    }
                    
                    guard let url = URL(string: "\(ClassChartsAPI.API_BASE_STUDENT)/homeworkticked/\(homeworkId)?pupil_id=\(studentId ?? 0)&value=\(completed ? "yes" : "no")") else {
                        completion(.failure(NetworkError.invalidURL))
                        return
                    }
                    
                    var request = URLRequest(url: url)
                    request.httpMethod = "GET"
                    request.setValue("Basic \(sessionId)", forHTTPHeaderField: "Authorization")
                    
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        
                        guard let httpResponse = response as? HTTPURLResponse else {
                            completion(.failure(NetworkError.invalidResponse))
                            return
                        }
                        
                        if httpResponse.statusCode == 200 {
                            completion(.success(!completed))
                        } else {
                            completion(.failure(NetworkError.serverError(httpResponse.statusCode)))
                        }
                    }
                    task.resume()
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    static func fetchTimetable(for date: Date, completion: @escaping (Result<[Lesson], Error>) -> Void) {
        retryRequestIfNeeded(completion: completion) { completion in
            checkAndRefreshSession { result in
                switch result {
                case .success:
                    guard let sessionId = currentSessionId else {
                        completion(.failure(NetworkError.invalidCredentials))
                        return
                    }
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let formattedDate = dateFormatter.string(from: date)
                    
                    guard let url = URL(string: "\(ClassChartsAPI.API_BASE_STUDENT)/timetable/\(studentId ?? 0)?date=\(formattedDate)") else {
                        completion(.failure(NetworkError.invalidURL))
                        return
                    }
                    
                    var request = URLRequest(url: url)
                    request.httpMethod = "GET"
                    request.setValue("Basic \(sessionId)", forHTTPHeaderField: "Authorization")
                    
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        
                        guard let data = data else {
                            completion(.failure(NetworkError.noData))
                            return
                        }
                        
                        handleResponse(data: data) { result in
                            switch result {
                            case .success(let lessonsData):
                                let lessons = lessonsData.compactMap { lessonDict -> Lesson? in
                                    guard let id = lessonDict["lesson_id"] as? Int,
                                          let title = lessonDict["lesson_name"] as? String,
                                          let subject = lessonDict["subject_name"] as? String,
                                          let startTime = lessonDict["start_time"] as? String,
                                          let endTime = lessonDict["end_time"] as? String,
                                          let teacherName = lessonDict["teacher_name"] as? String,
                                          let roomName = lessonDict["room_name"] as? String else {
                                        return nil
                                    }
                                    
                                    return Lesson(
                                        apiId: id,
                                        title: title,
                                        subject: subject,
                                        startTime: startTime,
                                        endTime: endTime,
                                        teacherName: teacherName,
                                        roomName: roomName
                                    )
                                }
                                
                                completion(.success(lessons))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    }
                    task.resume()
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}

enum NetworkError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case noData
    case invalidCredentials
    case missingUserData
    case incorrectDOB
    case incorrectCode
    case sessionExpired
    
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.noData, .noData),
             (.invalidCredentials, .invalidCredentials),
             (.missingUserData, .missingUserData),
             (.incorrectDOB, .incorrectDOB),
             (.incorrectCode, .incorrectCode),
             (.sessionExpired, .sessionExpired):
            return true
        case (.serverError(let lhsCode), .serverError(let rhsCode)):
            return lhsCode == rhsCode
        default:
            return false
        }
    }
}
