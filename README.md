# Apple Leaf Disease Detection

This repository contains a simple Flutter application for detecting diseases in apple leaves using a pre-trained `.tflite` model. The model was trained using [Teachable Machine](https://teachablemachine.withgoogle.com/), making it easy to implement and extend. The application allows users to capture images directly from their device's camera or select images from the gallery for disease detection.

---

## Features

- **Image Capture:** Take a photo of an apple leaf directly using your device’s camera.
- **Gallery Selection:** Choose an existing image from your gallery for analysis.
- **Disease Detection:** Analyze the selected image using a TensorFlow Lite model to identify apple leaf diseases.
- **User-Friendly Interface:** Simple and intuitive UI for seamless interaction.

---

## Prerequisites

Before you start, ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- A compatible IDE (e.g., [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/))
- A physical or virtual device for running the application

---

## Setup Instructions

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/vargheesk/apple-leaf-disease-detection.git
   cd apple-leaf-disease-detection
   ```

2. **Add the TensorFlow Lite Model:**
   - Download your trained `.tflite` model from Teachable Machine.
   - Place the `.tflite` file in the `assets` folder of the project.
   - Update the `pubspec.yaml` file to include the model:
     ```yaml
     assets:
       - assets/model.tflite
       - assets/labels.txt
     ```

3. **Install Dependencies:**
   Run the following command to fetch all necessary dependencies:
   ```bash
   flutter pub get
   ```

4. **Run the Application:**
   Use the following command to start the app on your device:
   ```bash
   flutter run
   ```

---

## Key Dependencies

- `tflite`: For integrating and using the TensorFlow Lite model.
- `image_picker`: For capturing images from the camera or selecting images from the gallery.

Add these dependencies to your `pubspec.yaml` file:
```yaml
dependencies:
  tflite_flutter: ^0.10.4
  image_picker: ^1.0.7
  image: ^4.1.7
  flutter_gemini: ^3.0.0
  flutter_markdown:
```

---

## How It Works

1. **Image Input:**
   - The user can take a photo using the device camera or select an image from the gallery.

2. **Model Inference:**
   - The selected image is passed to the `.tflite` model for processing.
   - The model predicts the presence of specific apple leaf diseases based on the input image.

3. **Results Display:**
   - The app displays the disease classification results to the user in a clear and concise format.

---

## Folder Structure

```
|-- assets
|   |-- labels.txt
|   |-- model.tflite
|-- lib
|   |-- main.dart
|-- pubspec.yaml
```

---

## Future Improvements

- Enhance the model’s accuracy by training it with a larger and more diverse dataset.
- Add support for multiple languages to make the app accessible to a wider audience.
- Include detailed disease descriptions and suggested treatments.
- Improve UI/UX for a more polished user experience.

---

## Contributing

Contributions are welcome! Please fork this repository and submit a pull request with your changes.

---

## License

This project is licensed under the MIT License. See the LICENSE file for details.

---

## Acknowledgements

- [Teachable Machine](https://teachablemachine.withgoogle.com/) for simplifying the model training process.
- The Flutter community for providing excellent resources and support.

