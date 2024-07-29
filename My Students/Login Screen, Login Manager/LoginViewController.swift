
import UIKit
import SnapKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    private var isLoggedIn: Bool = false
    private var viewModel: StudentViewModel
    
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to My Students!"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()
    
    private let welcomeSubLabel: UILabel = {
        let label = UILabel()
        label.text = "Please log in to your account or register a new one."
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()
    
    private var emailTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.placeholder = "Enter your Email"
        return textField
    }()
    
    private var passwordTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.placeholder = "Enter your Password"
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private var passwordEyeButton: UIButton = {
        let button = UIButton(type: .custom)
        let config = UIImage.SymbolConfiguration(pointSize: 16)
        let showPasswordImage = UIImage(systemName: "eye.fill", withConfiguration: config)
        let hidePasswordImage = UIImage(systemName: "eye.slash.fill", withConfiguration: config)
        button.setImage(showPasswordImage, for: .normal)
        button.setImage(hidePasswordImage, for: .selected)
        button.tintColor = .darkGray
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        
        return button
    }()
    
    // TODO: - func should be after lifycycle methods ( init, deinit )
    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        if let button = passwordTextField.rightView as? UIButton {
            button.isSelected.toggle()
        }
    }
    
    private var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log in", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.isEnabled = false
        button.alpha = 0.5
        return button
    }()
    
    private var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.isEnabled = false
        button.alpha = 0.5
        return button
    }()
    
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forgot password?", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return button
    }()
    
    init(viewModel: StudentViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("LoginViewController is being deallocated")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("LoginViewController received a memory warning")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupKeyboardNotifications()
        setupTextFieldObservers()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        let stackView = UIStackView(arrangedSubviews: [
            emailTextField,
            passwordTextField,
            loginButton,
            registerButton,
            forgotPasswordButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.bottom.equalToSuperview()
        }
        
        stackView.setCustomSpacing(35, after: emailTextField)
        stackView.setCustomSpacing(35, after: passwordTextField)
        
        emailTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        loginButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        registerButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "loginScreenBG")
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-110)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(1.5)
            make.height.equalTo(view.snp.height).multipliedBy(0.6)
        }
        
        contentView.addSubview(welcomeLabel)
        contentView.addSubview(welcomeSubLabel)
        
        welcomeLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(imageView.snp.bottom).offset(-50)
        }
        
        welcomeSubLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(welcomeLabel.snp.bottom).offset(10)
            make.bottom.equalTo(stackView.snp.top).offset(-30)
        }
        
        passwordTextField.rightView = passwordEyeButton
        
        registerButton.addTarget(self, action: #selector(registerButtonTapped(_:)), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped(_:)), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordButtonTapped(_:)), for: .touchUpInside)
        passwordEyeButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
    }
    
    private func setupTextFieldObservers() {
        emailTextField.textField.addTarget(self, action: #selector(textFieldsDidChange), for: .editingChanged)
        passwordTextField.textField.addTarget(self, action: #selector(textFieldsDidChange), for: .editingChanged)
    }
    
    //    @objc private func textFieldsDidChange() {
    //        emailTextField.setError(nil)
    //        passwordTextField.setError(nil)
    //
    //        let isFormValid = !(emailTextField.text?.isEmpty ?? true) && !(passwordTextField.text?.isEmpty ?? true)
    //
    //        loginButton.isEnabled = isFormValid
    //        registerButton.isEnabled = isFormValid
    //
    //        let alpha: CGFloat = isFormValid ? 1.0 : 0.5
    //        loginButton.alpha = alpha
    //        registerButton.alpha = alpha
    //    }
    
    @objc private func registerButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                let errorMessage = self.handleAuthError(error)
                //                self.emailTextField.setError(errorMessage)
                self.displayError(errorMessage)
                return
            }
            
            self.isLoggedIn = true
            LoginManager.shared.isLoggedIn = true
            self.showMainScreen()
        }
    }
    
    @objc private func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                let errorMessage = self.handleAuthError(error)
                //                self.emailTextField.setError(errorMessage)
                self.displayError(errorMessage)
                return
            }
            
            self.isLoggedIn = true
            LoginManager.shared.isLoggedIn = true
            self.showMainScreen()
        }
    }
    
    private func showMainScreen() {
        let containerVC = ContainerViewController(viewModel: viewModel)
        UIApplication.shared.windows.first?.rootViewController = containerVC
        UIApplication.shared.windows.first?.makeKeyAndVisible()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.resignFirstResponder()
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
            self.dismissKeyboard()
        }
    }
    
    @objc private func forgotPasswordButtonTapped(_ sender: UIButton) {
        let forgotPasswordVC = ForgotPasswordViewController()
        present(forgotPasswordVC, animated: true)
    }
}

extension LoginViewController {
    private func displayError(_ errorMessage: String) {
        var emailError = false
        var passwordError = false
        
        if errorMessage.contains("email") {
            emailError = emailTextField.setError(errorMessage)
        } else if errorMessage.contains("password") {
            passwordError = passwordTextField.setError(errorMessage)
        } else {
            // For general errors, you might want to set error on both fields or show a generic error somewhere else
            emailError = emailTextField.setError(errorMessage)
        }
        
        updateButtonStates(hasError: emailError || passwordError)
    }
    
    func updateButtonStates(hasError: Bool) {
            let emailIsEmpty = emailTextField.text?.isEmpty ?? true
            let passwordIsEmpty = passwordTextField.text?.isEmpty ?? true
            
            if hasError {
                loginButton.isEnabled = false
                registerButton.isEnabled = false
                loginButton.backgroundColor = .systemGray4
                registerButton.backgroundColor = .systemGray4
            } else if emailIsEmpty || passwordIsEmpty {
                loginButton.isEnabled = false
                registerButton.isEnabled = false
                loginButton.alpha = 0.5
                registerButton.alpha = 0.5
            } else {
                loginButton.isEnabled = true
                registerButton.isEnabled = true
                loginButton.backgroundColor = .systemBlue
                registerButton.backgroundColor = .systemGreen
                loginButton.alpha = 1.0
                registerButton.alpha = 1.0
            }
        }
    
    @objc private func textFieldsDidChange() {
        let emailError = emailTextField.setError(nil)
        let passwordError = passwordTextField.setError(nil)
        updateButtonStates(hasError: emailError || passwordError)
    }
}


// MARK: - Errors handler

extension LoginViewController {
    private func handleAuthError(_ error: Error) -> String {
        guard let errorCode = AuthErrorCode.Code(rawValue: error._code) else {
            return error.localizedDescription
        }
        
        switch errorCode {
        case .invalidEmail:
            return "The email address is badly formatted."
        case .emailAlreadyInUse:
            return "The email address is already in use by another account."
        case .weakPassword:
            return "The password must be 6 characters long or more."
        case .wrongPassword:
            return "The password is invalid or the user does not have a password."
        default:
            return "Login failed. Please check your email and password."
        }
    }
}

// MARK: - Keyboard Issue

extension LoginViewController {
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height + 50, right: 0)
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
