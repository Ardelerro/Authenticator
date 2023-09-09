## Authenticator App

Authenticator is a cmobile app built with Flutter that allows you to securely store and manage Time-Based One-Time Passwords (TOTP). It has a simple for generating and managing TOTP codes for your accounts.


### Usage

- **Initial Setup**: When you first launch the app, you'll be prompted to create a password to protect your TOTP keys. This password will be used to encrypt your data.
- **Adding TOTP Keys**: Navigate to the "Add TOTP Key" screen by clicking the "+" symbol on the bottom right to add TOTP secrets for your accounts. These secrets will be securely stored in a SQLite database. You may either manually input the keys, or scan a QR code to input the keys. You can quickly copy the key to your clipboard by tapping the desired key.
- **Editing TOTP Keys or Name** long press the totp key that you want to edit. From there, click on either "Edit name" or "Edit Key" to change its value.
- **Settings**: Access the settings screen to toggle between dark and light modes or reset your password.

## Security

- Your TOTP secrets are stored in an encrypted SQLite database.
- The app uses a strong password hashing algorithm to protect your password.
- Data is encrypted using industry-standard encryption techniques.

## Contributing

Contributions are welcome! Please check the [contribution guidelines](CONTRIBUTING.md) before getting started.

## License

This project is licensed under the [MIT License](LICENSE).

## Acknowledgments

Special thanks to the Flutter community and the open-source contributors who have made this project possible.

Happy secure authentication!
