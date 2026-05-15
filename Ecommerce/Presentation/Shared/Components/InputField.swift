//
//  InputField.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import SwiftUI

// MARK: - Input Field Types

public enum InputFieldType {
    case text
    case secure
    case email
    case phone
    case number
    case decimal
    case multiline
}

public enum KeyboardType {
    case defaultKeyboard
    case numeric
    case phonePad
    case decimalPad
    case emailAddress
    case webSearch
}

// MARK: - Validation Rules

public protocol ValidationRule {
    var errorMessage: String { get }
    func validate(_ input: String) -> Bool
}

public struct RequiredRule: ValidationRule {
    public let errorMessage: String
    
    public init(errorMessage: String = "This field is required") {
        self.errorMessage = errorMessage
    }
    
    public func validate(_ input: String) -> Bool {
        return !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

public struct MinimumLengthRule: ValidationRule {
    public let errorMessage: String
    private let minLength: Int
    
    public init(minLength: Int, errorMessage: String = "Must be at least %d characters") {
        self.minLength = minLength
        self.errorMessage = String(format: errorMessage, minLength)
    }
    
    public func validate(_ input: String) -> Bool {
        return input.count >= minLength
    }
}

public struct MaximumLengthRule: ValidationRule {
    public let errorMessage: String
    private let maxLength: Int
    
    public init(maxLength: Int, errorMessage: String = "Must be at most %d characters") {
        self.maxLength = maxLength
        self.errorMessage = String(format: errorMessage, maxLength)
    }
    
    public func validate(_ input: String) -> Bool {
        return input.count <= maxLength
    }
}

public struct EmailRule: ValidationRule {
    public let errorMessage: String
    
    public init(errorMessage: String = "Please enter a valid email address") {
        self.errorMessage = errorMessage
    }
    
    public func validate(_ input: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: input)
    }
}

public struct PhoneRule: ValidationRule {
    public let errorMessage: String
    
    public init(errorMessage: String = "Please enter a valid phone number") {
        self.errorMessage = errorMessage
    }
    
    public func validate(_ input: String) -> Bool {
        // Basic phone validation - at least 10 digits
        let phoneRegex = "^\\d{10,15}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: input.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression))
    }
}

public struct PasswordRule: ValidationRule {
    public let errorMessage: String
    
    public init(errorMessage: String = "Password must contain at least 8 characters with one uppercase, one lowercase, and one number") {
        self.errorMessage = errorMessage
    }
    
    public func validate(_ input: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d).{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: input)
    }
}

// MARK: - Input Field Component

public struct InputField: View {
    @Binding private var text: String
    private let placeholder: String
    private let type: InputFieldType
    private let keyboardType: KeyboardType
    private let icon: String?
    private let rules: [ValidationRule]
    private let onCommit: () -> Void
    private let onChange: (String) -> Void
    
    @State private var isSecure: Bool
    @State private var showError: Bool = false
    @FocusState private var isFocused: Bool
    
    public var errorMessage: String? {
        for rule in rules {
            if !rule.validate(text) {
                return rule.errorMessage
            }
        }
        return nil
    }
    
    public var isValid: Bool {
        errorMessage == nil
    }
    
    public init(
        text: Binding<String>,
        placeholder: String = "",
        type: InputFieldType = .text,
        keyboardType: KeyboardType = .defaultKeyboard,
        icon: String? = nil,
        rules: [ValidationRule] = [],
        onCommit: @escaping () -> Void = {},
        onChange: @escaping (String) -> Void = { _ in }
    ) {
        self._text = text
        self.placeholder = placeholder
        self.type = type
        self.keyboardType = keyboardType
        self.icon = icon
        self.rules = rules
        self.onCommit = onCommit
        self.onChange = onChange
        
        switch type {
        case .secure: self._isSecure = State(initialValue: true)
        default: self._isSecure = State(initialValue: false)
        }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            ZStack(alignment: .leading) {
                if icon != nil {
                    HStack(spacing: AppSpacing.small) {
                        Image(systemName: icon!)
                            .foregroundColor(isFocused ? AppColor.primary : AppColor.textSecondary)
                            .frame(width: 20)
                        
                        inputField
                    }
                } else {
                    inputField
                }
            }
            .background(AppColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.medium)
                    .stroke(isFocused ? AppColor.primary : (errorMessage != nil && showError ? AppColor.error : AppColor.border), lineWidth: 1)
            )
            .onTapGesture {
                isFocused = true
            }
            
            if let errorMessage = errorMessage, showError {
                Text(errorMessage)
                    .font(AppFont.bodySmall())
                    .foregroundColor(AppColor.error)
                    .transition(.opacity)
            }
        }
        .onChange(of: text) { newValue in
            onChange(newValue)
            validate()
        }
        .onAppear {
            validate()
        }
    }
    
    @ViewBuilder
    private var inputField: some View {
        switch type {
        case .text:
            textField
        case .secure:
            secureField
        case .multiline:
            textEditor
        default:
            textField
        }
    }
    
    private var textField: some View {
        TextField(placeholder, text: $text, onCommit: onCommit)
            .font(AppFont.bodyMedium())
            .foregroundColor(AppColor.textPrimary)
            .keyboardType(mapKeyboardType(keyboardType))
            .textContentType(mapTextContentType(type))
            .disableAutocorrection(true)
            .focused($isFocused)
            .submitLabel(.done)
    }
    
    private var secureField: some View {
        HStack {
            if isSecure {
                SecureField(placeholder, text: $text, onCommit: onCommit)
                    .font(AppFont.bodyMedium())
                    .foregroundColor(AppColor.textPrimary)
                    .keyboardType(mapKeyboardType(keyboardType))
                    .textContentType(.password)
                    .disableAutocorrection(true)
                    .focused($isFocused)
                    .submitLabel(.done)
            } else {
                TextField(placeholder, text: $text, onCommit: onCommit)
                    .font(AppFont.bodyMedium())
                    .foregroundColor(AppColor.textPrimary)
                    .keyboardType(mapKeyboardType(keyboardType))
                    .textContentType(.password)
                    .disableAutocorrection(true)
                    .focused($isFocused)
                    .submitLabel(.done)
            }
            
            Button(action: { isSecure.toggle() }) {
                Image(systemName: isSecure ? "eye" : "eye.slash")
                    .foregroundColor(AppColor.textSecondary)
                    .frame(width: 20)
            }
        }
    }
    
    private var textEditor: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(AppFont.bodyMedium())
                    .foregroundColor(AppColor.textSecondary)
                    .padding(.horizontal, AppSpacing.small)
                    .padding(.vertical, AppSpacing.small + 4)
            }
            
            TextEditor(text: $text)
                .font(AppFont.bodyMedium())
                .foregroundColor(AppColor.textPrimary)
                .keyboardType(mapKeyboardType(keyboardType))
                .focused($isFocused)
                .padding(.horizontal, AppSpacing.small)
                .padding(.vertical, AppSpacing.small)
                .frame(minHeight: 100)
        }
    }
    
    private func validate() {
        withAnimation {
            showError = !isValid && text.hasContent
        }
    }
    
    private func mapKeyboardType(_ type: KeyboardType) -> UIKeyboardType {
        switch type {
        case .defaultKeyboard: return .default
        case .numeric: return .numberPad
        case .phonePad: return .phonePad
        case .decimalPad: return .decimalPad
        case .emailAddress: return .emailAddress
        case .webSearch: return .webSearch
        }
    }
    
    private func mapTextContentType(_ type: InputFieldType) -> UITextContentType? {
        switch type {
        case .email: return .emailAddress
        case .phone: return .telephoneNumber
        case .secure: return .password
        default: return nil
        }
    }
}

// MARK: - Extensions

private extension String {
    var hasContent: Bool {
        !self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Search Field Component

public struct SearchField: View {
    @Binding private var text: String
    private let placeholder: String
    private let onSearch: (String) -> Void
    private let onClear: () -> Void
    
    @FocusState private var isFocused: Bool
    
    public init(
        text: Binding<String>,
        placeholder: String = "Search...",
        onSearch: @escaping (String) -> Void = { _ in },
        onClear: @escaping () -> Void = {}
    ) {
        self._text = text
        self.placeholder = placeholder
        self.onSearch = onSearch
        self.onClear = onClear
    }
    
    public var body: some View {
        HStack(spacing: AppSpacing.small) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColor.textSecondary)
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .font(AppFont.bodyMedium())
                .foregroundColor(AppColor.textPrimary)
                .keyboardType(.webSearch)
                .focused($isFocused)
                .submitLabel(.search)
                .onSubmit {
                    onSearch(text)
                }
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                    onClear()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColor.textSecondary)
                        .frame(width: 20)
                }
            }
        }
        .padding(EdgeInsets(top: AppSpacing.small, leading: AppSpacing.medium, bottom: AppSpacing.small, trailing: AppSpacing.medium))
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.pill))
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.pill)
                .stroke(isFocused ? AppColor.primary : AppColor.border, lineWidth: 1)
        )
        .onTapGesture {
            isFocused = true
        }
    }
}

// MARK: - Form Input Component (Label + Input)

public struct FormInput: View {
    let label: String
    @Binding var text: String
    let placeholder: String
    let type: InputFieldType
    let keyboardType: KeyboardType
    let rules: [ValidationRule]
    
    public init(
        label: String,
        text: Binding<String>,
        placeholder: String = "",
        type: InputFieldType = .text,
        keyboardType: KeyboardType = .defaultKeyboard,
        rules: [ValidationRule] = []
    ) {
        self.label = label
        self._text = text
        self.placeholder = placeholder
        self.type = type
        self.keyboardType = keyboardType
        self.rules = rules
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(label)
                .font(AppFont.labelMedium(weight: .medium))
                .foregroundColor(AppColor.textPrimary)
            
            InputField(
                text: $text,
                placeholder: placeholder,
                type: type,
                keyboardType: keyboardType,
                rules: rules
            )
        }
    }
}

// MARK: - Preview

#Preview {
    Form {
        VStack(spacing: AppSpacing.medium) {
            FormInput(
                label: "Email",
                text: .constant(""),
                placeholder: "Enter your email",
                type: .text,
                keyboardType: .emailAddress,
                rules: [RequiredRule(), EmailRule()]
            )
            
            FormInput(
                label: "Password",
                text: .constant(""),
                placeholder: "Enter your password",
                type: .secure,
                rules: [RequiredRule(), PasswordRule()]
            )
            
            FormInput(
                label: "Phone",
                text: .constant(""),
                placeholder: "Enter your phone number",
                type: .phone,
                keyboardType: .phonePad,
                rules: [RequiredRule(), PhoneRule()]
            )
            
            SearchField(text: .constant("Search query"))
            
            InputField(
                text: .constant("Multiline text\nLine 2"),
                placeholder: "Enter description",
                type: .multiline
            )
            .frame(height: 150)
        }
        .padding()
    }
}
