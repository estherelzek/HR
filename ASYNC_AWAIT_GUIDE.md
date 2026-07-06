# Async/Await Guide for TimeOff Feature

## 📚 What is Async/Await?

**Async/await** is a modern Swift feature (Swift 5.5+) that makes asynchronous code look and behave like synchronous code. It's much cleaner and easier to read than completion handlers.

### Before (Completion Handlers) ❌
```swift
func loadData(completion: @escaping () -> Void) {
    apiCall1 { result1 in
        apiCall2 { result2 in
            apiCall3 { result3 in
                // Nested callbacks = "Pyramid of Doom"
                completion()
            }
        }
    }
}
```

### After (Async/Await) ✅
```swift
func loadData() async throws {
    let result1 = try await apiCall1()
    let result2 = try await apiCall2()
    let result3 = try await apiCall3()
    // Clean, sequential code!
}
```

---

## 🔑 Key Concepts

### 1. **async** keyword
- Marks a function that performs asynchronous work
- Can be "awaited" by callers
```swift
func fetchData() async throws -> Data {
    // async work here
}
```

### 2. **await** keyword
- Suspends execution until async function completes
- Only works inside async context
```swift
let data = try await fetchData()  // ⏸ waits here
print("Got data!")                // ▶️ continues here
```

### 3. **Task** wrapper
- Allows calling async code from non-async context (like viewDidLoad)
```swift
override func viewDidLoad() {
    super.viewDidLoad()
    
    Task {
        do {
            try await loadAllData()
        } catch {
            print("Error: \(error)")
        }
    }
}
```

### 4. **@MainActor** annotation
- Ensures code runs on the main thread (required for UI updates)
```swift
@MainActor
func updateUI() async {
    label.text = "Updated!"  // ✅ Safe to update UI
}
```

### 5. **Parallel execution with async let**
```swift
// ❌ Sequential (slower)
let data1 = try await fetchAPI1()  // wait 2s
let data2 = try await fetchAPI2()  // wait 2s
// Total: 4 seconds

// ✅ Parallel (faster!)
async let data1 = fetchAPI1()  // start immediately
async let data2 = fetchAPI2()  // start immediately
try await data1  // wait for both
try await data2
// Total: 2 seconds (they run simultaneously!)
```

---

## 🏗 What We Changed in Your Project

### 1. **NetworkManager.swift**
Added async/await versions alongside existing completion-based methods:

```swift
// Old way (still available)
func requestDecodable<T>(_ endpoint: Endpoint, as type: T.Type, 
                         completion: @escaping (Result<T, APIError>) -> Void)

// New way ✅
func requestDecodable<T>(_ endpoint: Endpoint, as type: T.Type) async throws -> T
```

**How it works:** Uses `withCheckedThrowingContinuation` to bridge completion handlers to async/await.

---

### 2. **TimeOffViewModel.swift**
Added async versions of API methods:

```swift
// ✅ Clean async version
func fetchTimeOff(token: String) async throws -> TimeOffResponse {
    let endpoint = API.requestTimeOff(token: token, action: "get_employee_leave_type")
    return try await NetworkManager.shared.requestDecodable(endpoint, as: TimeOffResponse.self)
}

// ✅ With error handling
func fetchHolidays(token: String) async throws -> HolidayResult {
    let endpoint = API.requestTimeOff(token: token, action: "weekend_request")
    let response = try await NetworkManager.shared.requestDecodable(endpoint, as: HolidayResponse.self)
    
    guard let result = response.result else {
        throw APIError.noData
    }
    return result
}
```

---

### 3. **TimeOffViewController.swift** - The Main Changes

#### **viewDidLoad**
```swift
override func viewDidLoad() {
    super.viewDidLoad()
    setUpTexts()
    loaderIndicator.startAnimating()
    
    // ✅ Use Task to call async code from sync context
    Task {
        do {
            try await loadAllData()  // ← No completion handler!
            print("✅ All APIs finished")
        } catch {
            print("❌ Error: \(error)")
            if let apiError = error as? APIError {
                showAPIError(apiError)
            }
        }
        loaderIndicator.stopAnimating()  // ← Always runs
    }
    
    // ... rest of setup
}
```

#### **loadAllData** - Parallel API Calls
```swift
@MainActor
func loadAllData() async throws {
    print("🚀 Starting to load all data...")
    
    // ✅ Run two APIs in parallel using async let
    async let holidaysTask: Void = loadHolidays()
    async let timeOffTask: Void = loadTimeOffData()
    
    // Wait for both (they run simultaneously!)
    try await holidaysTask
    try await timeOffTask
    
    // ✅ Now fetch employee records (needs leaveTypes loaded first)
    await setupBindings()
    updateEmptyState()
    
    print("✅ All data loaded!")
}
```

**Why parallel?** 
- `loadHolidays()` and `loadTimeOffData()` don't depend on each other
- They can run at the same time = **faster loading!**
- `setupBindings()` needs `leaveTypes` from `loadTimeOffData()`, so it runs after

#### **Individual loaders**
```swift
@MainActor
private func loadHolidays() async throws {
    guard let token = UserDefaults.standard.employeeToken else { return }
    
    print("📡 Fetching holidays...")
    
    // ✅ Simply await - no nested closures!
    let data = try await viewModel.fetchHolidays(token: token)
    
    // ✅ Update properties directly
    if let offs = data.weekly_offs {
        weekendDays = offs.keys.compactMap { Int($0) }
    }
    
    if let holidays = data.public_holidays {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        publicHolidays = holidays.compactMap { formatter.date(from: $0.start_date) }
    }
    
    calender.reloadData()
}
```

#### **Error handling**
```swift
@MainActor
private func setupBindings() async {
    guard let token = UserDefaults.standard.string(forKey: "employeeToken") else {
        return
    }
    
    do {
        // ✅ Await the result
        let result = try await viewModelTimeOff.fetchEmployeeTimeOffs(token: token)
        
        // Process the data...
        employeeTimeOffRecords = result.records
        // ... rest of processing
        
        calender.reloadData()
        
    } catch {
        print("❌ Error: \(error)")
        if let apiError = error as? APIError {
            showAPIError(apiError)
        }
    }
}
```

---

## 🎯 Benefits You Get

### 1. **Cleaner Code**
- No nested completion handlers
- No `[weak self]` capture lists needed
- Linear, easy-to-read flow

### 2. **Better Error Handling**
- Use standard `try/catch` instead of Result types
- Errors propagate naturally up the call stack

### 3. **Automatic Thread Safety**
- `@MainActor` ensures UI updates happen on main thread
- No manual `DispatchQueue.main.async` needed

### 4. **Faster Loading**
- Parallel API calls with `async let`
- Your 3 APIs can load simultaneously instead of sequentially

### 5. **Built-in Cancellation**
- Tasks can be cancelled automatically
- Better handling when view disappears

---

## 🧪 Testing Your Changes

1. **Build the project** - Should compile without errors
2. **Run the app** - Loader should animate while data loads
3. **Check console** - Should see:
   ```
   🚀 Starting to load all data...
   📡 Fetching holidays...
   ✅ Holiday API Success
   🔄 Calendar reloaded
   ✅ All data loaded successfully!
   ```
4. **Verify calendar** - Should display weekends, holidays, and leave records

---

## 🚀 Next Steps - Apply This Pattern Elsewhere

You can apply the same async/await pattern to other ViewControllers in your app:

### Example: Login Flow
```swift
@MainActor
func performLogin(username: String, password: String) async {
    loaderIndicator.startAnimating()
    
    do {
        let result = try await authViewModel.login(username: username, password: password)
        
        // ✅ Handle success directly
        UserDefaults.standard.employeeToken = result.token
        navigateToHome()
        
    } catch {
        showAPIError(error as? APIError ?? .unknown)
    }
    
    loaderIndicator.stopAnimating()
}
```

### Example: Submit Form
```swift
@IBAction func submitButtonTapped(_ sender: Any) {
    Task {
        do {
            let response = try await viewModel.submitTimeOffRequest(
                leaveType: selectedLeaveType,
                startDate: startDate,
                endDate: endDate
            )
            
            showSuccessMessage(response.message)
            dismiss(animated: true)
            
        } catch {
            showAPIError(error as? APIError ?? .unknown)
        }
    }
}
```

---

## 📖 Common Patterns

### Pattern 1: Simple API Call
```swift
Task {
    do {
        let data = try await fetchData()
        updateUI(with: data)
    } catch {
        showError(error)
    }
}
```

### Pattern 2: Multiple Sequential Calls
```swift
do {
    let user = try await fetchUser()
    let profile = try await fetchProfile(userID: user.id)
    let posts = try await fetchPosts(userID: user.id)
    display(user, profile, posts)
} catch {
    showError(error)
}
```

### Pattern 3: Multiple Parallel Calls
```swift
async let user = fetchUser()
async let settings = fetchSettings()
async let notifications = fetchNotifications()

let (userData, settingsData, notificationData) = try await (user, settings, notifications)
```

### Pattern 4: Optional Async Work
```swift
func refreshData() {
    Task {
        await loadData()
    }
}
```

---

## ⚠️ Common Pitfalls to Avoid

### 1. ❌ Don't use `await` in non-async context
```swift
func regularFunction() {
    let data = await fetchData()  // ❌ Error!
}
```
✅ **Fix:** Wrap in Task
```swift
func regularFunction() {
    Task {
        let data = await fetchData()  // ✅ Works!
    }
}
```

### 2. ❌ Don't forget @MainActor for UI updates
```swift
func updateLabel() async {
    label.text = "New text"  // ⚠️ May crash!
}
```
✅ **Fix:** Add @MainActor
```swift
@MainActor
func updateLabel() async {
    label.text = "New text"  // ✅ Safe!
}
```

### 3. ❌ Don't use synchronous calls in async context
```swift
func loadData() async {
    let semaphore = DispatchSemaphore(value: 0)
    apiCall { result in
        semaphore.signal()
    }
    semaphore.wait()  // ❌ Blocks thread!
}
```
✅ **Fix:** Use async/await all the way
```swift
func loadData() async {
    let result = try await apiCall()  // ✅ Non-blocking!
}
```

---

## 🎓 Learning Resources

1. **Apple's Docs:** [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
2. **WWDC Videos:**
   - [Meet async/await in Swift](https://developer.apple.com/videos/play/wwdc2021/10132/)
   - [Explore structured concurrency in Swift](https://developer.apple.com/videos/play/wwdc2021/10134/)
3. **Practice:** Try converting one more ViewController in your app!

---

## 📝 Summary

**Before (Completion Handlers):**
- Nested callbacks ("Pyramid of Doom")
- Manual thread management
- Hard to read and maintain

**After (Async/Await):**
- Clean, linear code
- Automatic thread safety
- Built-in error handling
- Parallel execution support

**Your TimeOffViewController now:**
- Loads 3 APIs efficiently (2 in parallel!)
- Has clean, readable code
- Properly handles errors
- Updates UI safely on main thread

Great job learning modern Swift concurrency! 🎉
