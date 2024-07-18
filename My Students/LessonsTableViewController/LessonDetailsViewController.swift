//
//  LessonDetailsViewController.swift
//  Accounting
//
//  Created by Марк Кулик on 16.04.2024.
//

import UIKit
import SnapKit
import PhotosUI

class LessonDetailsViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var student: Student!
    var lesson: Lesson!
    
    var updatedlessonsForStudent: [Lesson] = []
    var homeworksArray = [String]()
    
    var photoImageViews: [UIImageView] = []
    var photoCollectionView: UICollectionView!
    
    var changesMade = false
    
    var enterHWLabel: UILabel!
    var clippedPhotosLabel: UILabel!
    var attendanceSwitch: UISwitch!
    var statusLabel: UILabel!
    var paperclipButton = UIButton(type: .system)
    var saveButton = UIButton(type: .system)
    
    
    let homeworkTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor.systemGroupedBackground
        textView.layer.cornerRadius = 10
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .darkGray
        return textView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Устанавливаем значение UISwitch равным значению lesson.attended
        attendanceSwitch.isOn = lesson.attended
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Lesson \(lesson.date)"
        
        // Заменяем кнопку "Back" на кастомную кнопку
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
        
        view.backgroundColor = .white
        setupUI()
        setupObservers()
        setupTapGesture()
        
        // Set the text view with the current homework
        homeworkTextView.text = lesson.homework
        // Устанавливаем значение UISwitch равным значению lesson.attended
        attendanceSwitch.isOn = lesson.attended
    }
    
    @objc func saveButtonTapped() {
        changesMade = false
        
        guard let updatedHomework = homeworkTextView.text else {
            print("Error: Failed to get updated homework")
            return
        }
        
        // Обновляем состояние attended
        lesson.attended = attendanceSwitch.isOn
        //        lesson.homework = updatedHomework
        lesson.homework = updatedHomework.isEmpty ? nil : updatedHomework
        
//        // Отправляем уведомление о обновлении урока
//        NotificationCenter.default.post(name: .lessonUpdatedNotification, object: nil, userInfo: ["updatedLesson": lesson!])
        
        navigationController?.popViewController(animated: true)
        
        print("Checking photoImageViews after saveButtonTapped \(photoImageViews)")
    }
    
    @objc private func backButtonTapped() {
       
    }
    
    @objc func attendanceSwitchValueChanged(_ sender: UISwitch) {
      
        lesson?.attended = sender.isOn
        statusLabel.text = sender.isOn ? "Student was present" : "Student was absent"
     
    }
}

// MARK: - Paper clip button: Photo Gallery methods

extension LessonDetailsViewController {
    
    @objc func paperclipButtonTapped() {
        let actionSheet = UIAlertController(title: "Add Photo", message: "Choose a source", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            self.presentImagePicker(sourceType: .photoLibrary)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    func presentCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images // Фильтр только для изображений
        configuration.selectionLimit = 0 // 0 означает неограниченное количество выбранных элементов
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            addImageForHW(image: selectedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func addImageForHW(image: UIImage) {
            print("Current number of images: \(lesson.photoUrls.count)")
            
            guard !lesson.photoUrls.contains(where: { $0.path == image.description }) else {
                let errorAlert = UIAlertController(title: "Error", message: "This photo has already been added.", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
                return
            }
            
            if let imageUrl = saveImageToFileSystem(image: image) {
                lesson.photoUrls.append(imageUrl)
                photoCollectionView.reloadData()
            }
        }
    
    // Метод для сохранения изображения в файловой системе и возврата URL
    func saveImageToFileSystem(image: UIImage) -> URL? {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to JPEG data")
            return nil
        }
        
        do {
            // Создаем URL для нового файла в директории документов приложения
            let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentsDirectory.appendingPathComponent("\(UUID().uuidString).jpg")
            
            // Сохраняем данные в файл
            try data.write(to: fileUrl)
            
            return fileUrl // Возвращаем URL сохраненного изображения
        } catch {
            print("Error saving image to file system: \(error.localizedDescription)")
            return nil
        }
    }

    @objc func deleteImage(_ sender: UIButton) {
           let point = sender.convert(CGPoint.zero, to: photoCollectionView)
           guard let indexPath = photoCollectionView.indexPathForItem(at: point) else { return }
           
           lesson.photoUrls.remove(at: indexPath.item)
           photoCollectionView.deleteItems(at: [indexPath])
       }
    
    @objc func openFullscreenImage(_ gesture: UITapGestureRecognizer) {
        guard let imageView = gesture.view,
              let cell = imageView.superview?.superview as? UICollectionViewCell,
              let indexPath = photoCollectionView.indexPath(for: cell) else {
            return
        }
        
        let images = lesson.photoUrls.compactMap { try? Data(contentsOf: $0) }.compactMap { UIImage(data: $0) }
        let fullscreenVC = FullscreenImageViewController(images: images, initialIndex: indexPath.item)
        present(fullscreenVC, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension LessonDetailsViewController {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lesson.photoUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! HWPhotoCollectionViewCell
        let imageUrl = lesson.photoUrls[indexPath.item]
        if let imageData = try? Data(contentsOf: imageUrl),
           let image = UIImage(data: imageData) {
            cell.imageView.image = image
        }
        cell.deleteButton.addTarget(self, action: #selector(deleteImage(_:)), for: .touchUpInside)
        cell.containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openFullscreenImage(_:))))
        cell.containerView.isUserInteractionEnabled = true
        return cell
    }
}

// MARK: - Расширение для работы с PHPickerViewController (только для iOS 14 и новее)
@available(iOS 14, *)
extension LessonDetailsViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        
        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            self.addImageForHW(image: image)
                        }
                    }
                }
            }
        }
    }
}


extension LessonDetailsViewController {
    
    func setupUI() {
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareHomework))
        let paperclipButton = UIBarButtonItem(image: UIImage(systemName: "paperclip"), style: .plain, target: self, action: #selector(paperclipButtonTapped))
        navigationItem.rightBarButtonItems = [shareButton, paperclipButton]
        
        let statusStackView = UIStackView()
               statusStackView.axis = .horizontal
               statusStackView.spacing = 10
               statusStackView.alignment = .fill
               statusStackView.distribution = .fill
        
        enterHWLabel = UILabel()
        enterHWLabel.font = UIFont.systemFont(ofSize: 14)
        enterHWLabel.textColor = .darkGray
        enterHWLabel.text = "Enter Homework here:"
        
        clippedPhotosLabel = UILabel()
        clippedPhotosLabel.font = UIFont.systemFont(ofSize: 14)
        clippedPhotosLabel.textColor = .darkGray
        clippedPhotosLabel.text = "Clipped photos"
        
        statusLabel = UILabel()
        enterHWLabel.font = UIFont.systemFont(ofSize: 14)
        enterHWLabel.textColor = .darkGray
        statusLabel.textAlignment = .left
        
        attendanceSwitch = UISwitch()
        attendanceSwitch.addTarget(self, action: #selector(attendanceSwitchValueChanged(_:)), for: .valueChanged)
        attendanceSwitch.isOn = lesson.attended
        statusLabel.text = attendanceSwitch.isOn ? "Student was present" : "Student was absent"
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: 60, height: 60)
        
        photoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.register(HWPhotoCollectionViewCell.self, forCellWithReuseIdentifier: "PhotoCell")
        photoCollectionView.backgroundColor = .systemGroupedBackground
        photoCollectionView.layer.cornerRadius = 10
        
        saveButton = UIButton(type: .system)
        saveButton.setTitle("Save Changes", for: .normal)
        saveButton.layer.cornerRadius = 10
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        view.addSubview(statusStackView)
        statusStackView.addArrangedSubview(statusLabel)
        statusStackView.addArrangedSubview(attendanceSwitch)
        
        view.addSubview(enterHWLabel)
        view.addSubview(homeworkTextView)
        view.addSubview(clippedPhotosLabel)
        view.addSubview(saveButton)
        view.addSubview(photoCollectionView)
        
        // Constraints:
        enterHWLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        homeworkTextView.snp.makeConstraints { make in
            make.top.equalTo(enterHWLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(300)
        }
        
        clippedPhotosLabel.snp.makeConstraints { make in
            make.top.equalTo(homeworkTextView.snp.bottom).offset(16)
            make.leading.equalToSuperview().inset(16)
        }
        
        photoCollectionView.snp.makeConstraints { make in
            make.top.equalTo(clippedPhotosLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(80)
        }
        
        photoCollectionView.layer.cornerRadius = 10
        
        statusStackView.snp.makeConstraints { make in
            make.bottom.equalTo(saveButton.snp.top).offset(-20)
            make.trailing.leading.equalToSuperview().inset(16)
        }
        
        saveButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
                       make.leading.trailing.equalToSuperview().inset(20)
                       make.height.equalTo(44)
        }
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleKeyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        // Рассчитываем сдвиг для текстового поля
        let keyboardHeight = keyboardFrame.height
        let textViewBottomY = homeworkTextView.frame.origin.y + homeworkTextView.frame.height
        let overlap = textViewBottomY - (view.frame.height - keyboardHeight)
        
        if overlap > 0 {
            view.frame.origin.y = -overlap
        }
    }

    @objc func handleKeyboardWillHide(notification: Notification) {
        view.frame.origin.y = 0
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func shareHomework() {
        guard let homeworkText = homeworkTextView.text else { return }
        
        let activityVC = UIActivityViewController(activityItems: [homeworkText], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
}
