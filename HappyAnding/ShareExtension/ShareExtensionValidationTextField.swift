//
//  ShareExtensionValidationTextField.swift
//  ShareExtension
//
//  Created by 이지원 on 2022/10/20.
//

import SwiftUI

enum TextType {
    case optional
    case mandatory
    
    var isOptional: Bool {
        switch self {
        case .optional:
            return true
        case .mandatory:
            return false
        }
    }
}

enum TextFieldState {
    case notStatus
    case inProgressSuccess
    case inProgressFail
    case doneSuccess
    case doneFail
    
    var color: Color {
        switch self {
        case .notStatus:
            return Color.gray2
        case .inProgressSuccess:
            return Color.shortcutsZipPrimary
        case .inProgressFail:
            return Color.shortcutsZipError
        case .doneSuccess:
            return Color.gray4
        case .doneFail:
            return Color.shortcutsZipError
        }
    }
}

enum TextFieldError {
    case invalidLink
    case excessLimitLenth
    
    var message: String {
        switch self {
        case .invalidLink:
            return TextLiteral.validationCheckTextFieldInvalid
        case .excessLimitLenth:
            return TextLiteral.validationCheckTextFieldExcess
        }
    }
}

struct ShareExtensionValidationCheckTextField: View {
    let textType: TextType
    let isMultipleLines: Bool
    let title: String
    @State var placeholder: String
    let lengthLimit: Int?
    let isDownloadLinkTextField: Bool
    @State var inputHeight: CGFloat = 272
    
    @Binding var content: String
    @Binding var isValid: Bool
    
    @State private var strokeColor = Color.gray2
    @State private var isExceeded = false
    @State private var textFieldState = TextFieldState.notStatus
    @State private var textFieldError = TextFieldError.invalidLink
    
    @Binding var isFocused: [Bool]
    
    var index: Int
    
    var body: some View {
        VStack {
            
            HStack {
                
                textFieldTitle
                
                Spacer()
                
                if let lengthLimit {
                    Text("\(content.count)/\(lengthLimit)")
                        .Body2()
                        .foregroundColor(.gray4)
                        .padding(.trailing, 16)
                }
            }
            
            ZStack {
                if isMultipleLines {
                    multiLineEditor
                } else {
                    HStack(alignment: .center) {
                        oneLineEditor
                        stateIcon
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(lineWidth: 1)
                    .foregroundColor(strokeColor)
            )
            .padding(.horizontal, 16)
            
            HStack {
                if isExceeded {
                    Text(textFieldError.message)
                        .Body2()
                        .foregroundColor(.shortcutsZipError)
                        .padding(.leading)
                }
                
                Spacer()
                
            }
        }
        .onChange(of: self.textFieldState) { newValue in
            self.strokeColor = newValue.color
        }
    }
    
    var textFieldTitle: some View {
        HStack {
            Text(title)
                .Headline()
                .foregroundColor(.gray5)
                .padding(.leading, 16)
            
            if textType.isOptional {
                Text(TextLiteral.validationCheckTextFieldOption)
                    .Footnote()
                    .foregroundColor(.gray3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var oneLineEditor: some View {
        TextField(placeholder, text: $content) { _ in
            for index in isFocused.indices {
                isFocused[index] = index == self.index
            }
        }
        .disableAutocorrection(true)
        .textInputAutocapitalization(.never)
        .Body2()
        .frame(height: 24)
        .padding(16)
        .onAppear {
            checkValidation()
        }
        .onChange(of: isFocused) { newValue in
            checkValidation()
        }
        .onChange(of: content) { newValue in
            checkValidation()
        }
        .onSubmit {
            isFocused[index] = false
        }
    }
    
    var multiLineEditor: some View {
        
        ZStack(alignment: .topLeading) {
            
            ShareExtensionCustomTextEditor(text: $content,
                             inputHeight: $inputHeight,
                                           isFocused: $isFocused,
                                           index: .constant(3))
            .frame(height: inputHeight)
            .padding(16)
            
            if content.isEmpty && !isFocused[index] {
                Text(placeholder)
                    .Body2()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding(16)
                    .foregroundColor(.gray2)
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            checkValidation()
        }
        .onChange(of: isFocused) { newValue in
            checkValidation()
        }
        .onChange(of: content) { newValue in
            checkValidation()
        }
    }
    
    var stateIcon: some View {
        
        HStack(alignment: .center) {
            
            switch self.textFieldState {
            case .notStatus:
                EmptyView()
            case .doneSuccess:
                Image(systemName: "checkmark.circle.fill")
                    .SmallIcon()
                    .foregroundColor(.shortcutsZipSuccess)
                    .onTapGesture { }
            case .doneFail:
                Image(systemName: "exclamationmark.circle.fill")
                    .SmallIcon()
                    .foregroundColor(.shortcutsZipError)
            case .inProgressSuccess:
                Button {
                    content.removeAll()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .SmallIcon()
                        .foregroundColor(.gray5)
                }
            case .inProgressFail:
                Button {
                    content.removeAll()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .SmallIcon()
                        .foregroundColor(.gray5)
                }
            }
        }
        .padding()
    }
}

extension ShareExtensionValidationCheckTextField {
    
    func checkValidation() {
        if isFocused[index] {
            if content.isEmpty {
                isValid = textType.isOptional
                isExceeded = false
                self.textFieldState = .inProgressSuccess
            } else if content.count <= lengthLimit ?? 999 {
                if isDownloadLinkTextField {
                    if content.hasPrefix(TextLiteral.validationCheckTextFieldPrefix) {
                        isValid = true
                        isExceeded = false
                        self.textFieldState = .inProgressSuccess
                    } else {
                        isValid = textType.isOptional
                        isExceeded = true
                        self.textFieldState = .inProgressFail
                        self.textFieldError = .invalidLink
                    }
                } else {
                    isValid = true
                    isExceeded = false
                    self.textFieldState = .inProgressSuccess
                }
            } else {
                isValid = false
                isExceeded = true
                self.textFieldState = .inProgressFail
                self.textFieldError = .excessLimitLenth
            }
        } else {
            if isExceeded {
                textFieldState = .doneFail
            } else {
                if content.isEmpty {
                    isValid = textType.isOptional
                    isExceeded = false
                    self.textFieldState = .notStatus
                } else {
                    textFieldState = .doneSuccess
                    isValid = true
                }
            }
        }
    }
}
