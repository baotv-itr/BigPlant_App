import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'AstroLingo',
      'copyright': 'Copyright 2025 © BigPlant',
      'login_page': 'Login Page',
      'register_page': 'Register Page',
      'forgot_password_page': 'Forgot Password',
      'verify_email': 'Verify Your Email',
      'create_new_pass': 'Create New Password',
      'enter_new_pass': 'Enter your new Password!',
      'login': 'Login',
      'register': 'Register',
      'next': 'Next',
      'got_it': 'Got it',
      'forgot_password': 'Forgot password?',
      'dont_have_account': "Don't you have an account?",
      'have_account': 'Do you have an account?',
      'username_hint': 'Enter your username or email *',
      'register_username_hint': 'Enter your username *',
      'password_hint': 'Enter your password *',
      'email_hint': 'Enter your email *',
      'phone_hint': 'Enter your telephone',
      're_password_hint': 'Re-enter your password *',
      'verify_desc': 'Please Enter The 4 Digit Code Sent To Your Email!',
      'reset_desc':
          "Provide your account's email for which your want to reset your password!",
      'verification_success': 'Verification Success',
      'verification_success_detail':
          'Your email address was successfully verified.',
      'resetpassword_success': 'Your password has been reset successfully.',
      'didnt_get_email': "Didn't you get e-mail?",
      'resend': 'Send it again',
      'language': 'Language',
      'toggle_language': 'VI / EN',
      'login_with_google': 'Login with Google',
      'google_coming_soon': 'Google login is not migrated yet',
      'terms':
          'By logging into AstroLingo, you agree to our Terms and Privacy Policy *',
      'register_terms':
          'By registering into AstroLingo, you agree to our Terms and Privacy Policy *',
      'error_username_empty': "Username field shouldn't be empty!",
      'error_password_empty': "Password field shouldn't be empty!",
      'error_password_invalid':
          "Password field shoundn't be less than 8 characters!",
      'error_email_empty': "Email field shouldn't be empty!",
      'error_email_invalid': "Email field isn't valid!",
      'error_repassword_empty': "Re-password field shouldn't be empty!",
      'error_repassword_invalid':
          "Re-password field isn't match with password!",
      'error_otp_invalid': 'Please enter 4 digits sent to your email!',
      'error_checkbox': 'You have to agree our term and privacy policy!',
      'session_title': 'Authenticated Session',
      'session_desc':
          'Auth-only app is active. Main feature modules were intentionally removed.',
      'logout': 'Log out',
      'toast_saved_clipboard': 'Saved to clipboard',
      'toast_success_default': 'Success',
    },
    'vi': {
      'app_name': 'AstroLingo',
      'copyright': 'Bản quyền 2025 © BigPlant',
      'login_page': 'Đăng nhập',
      'register_page': 'Đăng ký',
      'forgot_password_page': 'Quên mật khẩu',
      'verify_email': 'Xác thực email',
      'create_new_pass': 'Tạo mật khẩu mới',
      'enter_new_pass': 'Nhập mật khẩu mới của bạn!',
      'login': 'Đăng nhập',
      'register': 'Đăng ký',
      'next': 'Tiếp tục',
      'got_it': 'Hoàn thành',
      'forgot_password': 'Quên mật khẩu?',
      'dont_have_account': 'Bạn chưa có tài khoản?',
      'have_account': 'Bạn đã có tài khoản?',
      'username_hint': 'Nhập tên tài khoản hoặc email *',
      'register_username_hint': 'Nhập tên tài khoản của bạn *',
      'password_hint': 'Nhập mật khẩu của bạn *',
      'email_hint': 'Nhập email của bạn *',
      'phone_hint': 'Nhập số điện thoại của bạn',
      're_password_hint': 'Xác nhận mật khẩu của bạn *',
      'verify_desc': 'Hãy nhập 4 số mã đã được gửi đến email của bạn!',
      'reset_desc': 'Nhập email tài khoản bạn muốn đặt lại mật khẩu!',
      'verification_success': 'Xác thực thành công',
      'verification_success_detail':
          'Địa chỉ email của bạn đã được xác thực thành công.',
      'resetpassword_success':
          'Mật khẩu của bạn đã được thiết lập lại thành công.',
      'didnt_get_email': 'Bạn chưa nhận được email?',
      'resend': 'Gửi lại',
      'language': 'Ngôn ngữ',
      'toggle_language': 'VI / EN',
      'login_with_google': 'Đăng nhập với Google',
      'google_coming_soon': 'Đăng nhập Google chưa được chuyển logic',
      'terms':
          'Bằng việc đăng nhập vào AstroLingo, bạn đã đồng ý với Điều khoản và chính sách bảo mật *',
      'register_terms':
          'Bằng việc đăng ký vào AstroLingo, bạn đã đồng ý với Điều khoản và chính sách bảo mật *',
      'error_username_empty': 'Tên tài khoản không được để trống!',
      'error_password_empty': 'Mật khẩu không được để trống!',
      'error_password_invalid': 'Mật khẩu phải có ít nhất 8 ký tự!',
      'error_email_empty': 'Email không được để trống!',
      'error_email_invalid': 'Email không hợp lệ!',
      'error_repassword_empty': 'Xác nhận mật khẩu không được để trống!',
      'error_repassword_invalid': 'Xác nhận mật khẩu không khớp!',
      'error_otp_invalid': 'Hãy nhập 4 số mã đã được gửi đến email của bạn!',
      'error_checkbox': 'Bạn phải đồng ý với điều khoản và chính sách bảo mật!',
      'session_title': 'Phiên xác thực',
      'session_desc':
          'Ứng dụng hiện chỉ giữ luồng auth. Các module chức năng chính đã được loại bỏ theo yêu cầu.',
      'logout': 'Đăng xuất',
      'toast_saved_clipboard': 'Đã lưu vào bộ nhớ tạm',
      'toast_success_default': 'Thành công',
    },
  };

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String t(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key] ??
        key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'vi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
