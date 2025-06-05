

# Project 

This is a Flutter project that utilizes third-party APIs, including Firebase for authentication and a Large Language Model (LLM) provider. Please follow the steps below to configure and run the project.

-----

## Prerequisites

  * Flutter SDK installed.
  * Android Studio / VS Code (or your preferred IDE) installed.
  * Firebase CLI installed.
  * Access to a Firebase account.
  * An API key/token from your chosen LLM provider.

-----

## Setup Instructions

Before building and running the application, please complete the following configuration steps:

### 1\. Firebase Project Setup

  * Go to the [Firebase console](https://console.firebase.google.com/).
  * Create a new project or select an existing one.

### 2\. Application Signing and Firebase Configuration

  * **Sign your application**: Generate a keystore and sign your Android application. You can find detailed instructions in the [official Android documentation](https://www.google.com/search?q=https://developer.android.com/studio/publish/app-signing%23generate-key).
  * **Obtain SHA-1 and SHA-256 fingerprints**:
      * For **debug** certificate (usually located at `~/.android/debug.keystore`):
        ```bash
        keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
        ```
      * For **release** certificate (replace `your_keystore_name`, `your_alias_name` with your actual keystore name and alias):
        ```bash
        keytool -list -v -keystore your_keystore_name.jks -alias your_alias_name
        ```
  * **Add fingerprints to Firebase**:
      * In the Firebase console, navigate to **Project settings** \> **General**.
      * Scroll down to "Your apps" and select your Android app (or add a new one if you haven't already).
      * Add the **SHA-1** and **SHA-256** fingerprints you obtained.

### 3\. Download `google-services.json`

  * In your Firebase project settings, under the "Your apps" section for your Android app, download the `google-services.json` file.
  * Place this file in the `android/app/` directory of your Flutter project.

### 4\. Initialize Firebase with Firebase CLI

  * Open your terminal in the root directory of your Flutter project.
  * Log in to Firebase:
    ```bash
    firebase login
    ```
  * Initialize Firebase in your project (select your existing Firebase project when prompted):
    ```bash
    firebase init
    ```
    or if you are targeting a specific Firebase project:
    ```bash
    flutterfire configure
    ```
    Follow the CLI prompts to connect your Flutter app with your Firebase project.

### 5\. Configure Firebase Authentication

  * In the Firebase console, navigate to **Authentication** (under Build).
  * Go to the **Sign-in method** tab.
  * Enable the **Email/Password** provider.
  * Enable the **Google** provider and configure it with the necessary support email.

### 6\. Configure LLM Provider API

  * In the `lib/config/` directory, you will find a file named `api_config.example.dart`.
  * **Duplicate** this file and rename the copy to `api_config.dart` in the same directory.
  * Open `api_config.dart` and enter your LLM provider's token/API key according to the structure defined in the file.
    ```dart
    // Example structure in lib/config/api_config.dart
    class ApiConfig {
    static const String apiToken = 'your-api-token-here';
    static const String apiEndpoint = 'https://api.deepseek.com/v1/chat/completions';
    } 
    ```
    **Important:** `api_config.dart` is likely gitignored to prevent accidental sharing of sensitive keys. Ensure it remains so.

-----

## Standard Flutter Project Startup

Once all the above configuration steps are completed, you can run the project using standard Flutter commands:

1.  **Get dependencies:**
    ```bash
    flutter pub get
    ```
2.  **Run the app:**
    ```bash
    flutter run
    ```

-----

## Troubleshooting

  * Ensure all Firebase setup steps were followed correctly, especially the `google-services.json` placement and SHA fingerprint configuration.
  * Verify that your LLM API key in `api_config.dart` is correct and has the necessary permissions.
  * Check `flutter doctor` for any environment issues.

-----

# Название Проекта

Это Flutter-проект, который использует сторонние API, включая Firebase для аутентификации и провайдера Большой Языковой Модели (LLM). Пожалуйста, следуйте приведенным ниже шагам для настройки и запуска проекта.

-----

## Необходимые условия

  * Установленный Flutter SDK.
  * Установленная Android Studio / VS Code (или предпочитаемая вами IDE).
  * Установленный Firebase CLI.
  * Доступ к аккаунту Firebase.
  * API-ключ/токен от выбранного вами провайдера LLM.

-----

## Инструкции по настройке

Перед сборкой и запуском приложения, пожалуйста, выполните следующие шаги настройки:

### 1\. Настройка проекта Firebase

  * Перейдите в [консоль Firebase](https://console.firebase.google.com/).
  * Создайте новый проект или выберите существующий.

### 2\. Подпись приложения и конфигурация Firebase

  * **Подпишите ваше приложение**: Создайте хранилище ключей (keystore) и подпишите ваше Android-приложение. Подробные инструкции можно найти в [официальной документации Android](https://www.google.com/search?q=https://developer.android.com/studio/publish/app-signing%23generate-key).
  * **Получите SHA-1 и SHA-256 отпечатки**:
      * Для **отладочного** сертификата (обычно находится по пути `~/.android/debug.keystore`):
        ```bash
        keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
        ```
      * Для **релизного** сертификата (замените `your_keystore_name`, `your_alias_name` на ваши актуальные имя хранилища ключей и псевдоним):
        ```bash
        keytool -list -v -keystore your_keystore_name.jks -alias your_alias_name
        ```
  * **Добавьте отпечатки в Firebase**:
      * В консоли Firebase перейдите в **Настройки проекта** \> **Общие**.
      * Прокрутите вниз до раздела "Ваши приложения" и выберите ваше Android-приложение (или добавьте новое, если еще не сделали этого).
      * Добавьте полученные **SHA-1** и **SHA-256** отпечатки.

### 3\. Загрузите `google-services.json`

  * В настройках вашего проекта Firebase, в разделе "Ваши приложения" для вашего Android-приложения, загрузите файл `google-services.json`.
  * Поместите этот файл в директорию `android/app/` вашего Flutter-проекта.

### 4\. Инициализация Firebase с помощью Firebase CLI

  * Откройте терминал в корневой директории вашего Flutter-проекта.
  * Войдите в Firebase:
    ```bash
    firebase login
    ```
  * Инициализируйте Firebase в вашем проекте (выберите ваш существующий проект Firebase при запросе):
    ```bash
    firebase init
    ```
    или, если вы нацеливаетесь на конкретный проект Firebase:
    ```bash
    flutterfire configure
    ```
    Следуйте инструкциям CLI для подключения вашего Flutter-приложения к вашему проекту Firebase.

### 5\. Настройка Firebase Authentication

  * В консоли Firebase перейдите в раздел **Authentication** (в разделе Build).
  * Перейдите на вкладку **Sign-in method** (Способ входа).
  * Включите провайдера **Email/Password** (Электронная почта/Пароль).
  * Включите провайдера **Google** и настройте его, указав необходимый адрес электронной почты для поддержки.

### 6\. Настройка API провайдера LLM

  * В директории `lib/config/` вы найдете файл с именем `api_config.example.dart`.
  * **Скопируйте** этот файл и переименуйте копию в `api_config.dart` в той же директории.
  * Откройте `api_config.dart` и введите токен/API-ключ вашего провайдера LLM в соответствии со структурой, определенной в файле.
    ```dart
    // Example structure in lib/config/api_config.dart
    class ApiConfig {
    static const String apiToken = 'your-api-token-here';
    static const String apiEndpoint = 'https://api.deepseek.com/v1/chat/completions';
    } 
    ```
    **Важно:** Файл `api_config.dart`, скорее всего, добавлен в `.gitignore`, чтобы предотвратить случайную утечку конфиденциальных ключей. Убедитесь, что это так.

-----

## Стандартный запуск Flutter-проекта

После выполнения всех вышеописанных шагов настройки вы можете запустить проект, используя стандартные команды Flutter:

1.  **Получить зависимости:**
    ```bash
    flutter pub get
    ```
2.  **Запустить приложение:**
    ```bash
    flutter run
    ```

-----

## Устранение неполадок

  * Убедитесь, что все шаги настройки Firebase выполнены правильно, особенно размещение файла `google-services.json` и конфигурация SHA-отпечатков.
  * Проверьте, что ваш API-ключ LLM в файле `api_config.dart` указан верно и имеет необходимые разрешения.
  * Проверьте вывод команды `flutter doctor` на наличие проблем с окружением.

-----