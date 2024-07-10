import UIKit
import SnapKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
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
        label.text = "Welcome to My Stydents!"
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
    
    private var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your Email"
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your Password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log in", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    private var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forgot password?", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return button
    }()
    
    private var isLoggedIn: Bool = false
    private var viewModel: StudentViewModel
    
    init(viewModel: StudentViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupKeyboardNotifications()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        // Установка высоты для текстовых полей и кнопок
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
        
        // Добавляем картинку
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
        
        registerButton.addTarget(self, action: #selector(registerButtonTapped(_:)), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped(_:)), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordButtonTapped(_:)), for: .touchUpInside)
    }
    
    // MARK: - Login / Register Logic
    
    @objc private func registerButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Oops...Try again.", message: "Please enter both email and password.")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    let errorMessage = self.handleAuthError(error)
                    self.showAlert(title: "Oops...Try again.", message: errorMessage)
                    return
                }
            // Регистрация прошла успешно
            self.isLoggedIn = true
            LoginManager.shared.isLoggedIn = true
            self.showMainScreen()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                }
    }
    
    @objc private func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Oops...Try again.", message: "Please enter both email and password.")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    let errorMessage = self.handleAuthError(error)
                    self.showAlert(title: "Oops...Try again.", message: errorMessage)
                    return
                }
            // Вход выполнен успешно
            self.isLoggedIn = true
            LoginManager.shared.isLoggedIn = true
            self.showMainScreen()
        }
        // Очистка полей после перехода на следующий экран
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                }
    }
    
    private func showMainScreen() {
        let studentsVC = StudentsCollectionViewController(viewModel: viewModel)
        navigationController?.pushViewController(studentsVC, animated: true)
    }
    
    @objc private func forgotPasswordButtonTapped(_ sender: UIButton) {
        let forgotPasswordVC = ForgotPasswordViewController()
        navigationController?.pushViewController(forgotPasswordVC, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
