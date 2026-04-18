import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'BigPlant',
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
          'By logging into BigPlant, you agree to our Terms and Privacy Policy *',
      'register_terms':
          'By registering into BigPlant, you agree to our Terms and Privacy Policy *',
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
      'home_tab': 'Home',
      'scan_tab': 'Scan',
      'cart_tab': 'Cart',
      'settings_tab': 'Settings',
      'home_title': 'Discover Greenery',
      'home_subtitle': 'Pick healthy plants for your space',
      'home_search_hint': 'Search plants, pots or accessories',
      'popular_plants': 'Popular this week',
      'category_indoor': 'Indoor',
      'category_outdoor': 'Outdoor',
      'category_pot': 'Pots',
      'category_air': 'Air purifier',
      'cart_title': 'Your Cart',
      'checkout_now': 'Checkout now',
      'settings_title': 'Settings',
      'notify_deals': 'Deal notifications',
      'notify_tips': 'Plant care tips',
      'scan_placeholder_title': 'Scan module is coming next',
      'scan_placeholder_desc':
          'Camera and photo upload flow will be implemented in the next step.',
      'scan_title': 'Plant Scanner',
      'scan_subtitle': 'Capture or upload a plant photo for instant analysis',
      'scan_empty_state': 'Your selected image will appear here',
      'scan_camera': 'Take photo',
      'scan_gallery': 'Upload photo',
      'scan_tips_title': 'Tips for better scan quality',
      'scan_tip_1': 'Use bright natural light and avoid blur.',
      'scan_tip_2': 'Keep one main plant object in frame.',
      'scan_tip_3': 'Capture leaves and stem clearly for better matching.',
      'scan_result_title': 'Scan Result',
      'plant_identity': 'Plant identity',
      'field_common_name': 'Common name',
      'field_scientific_name': 'Scientific name',
      'field_family': 'Family',
      'field_order': 'Order',
      'field_genus': 'Genus',
      'field_species': 'Species',
      'field_description': 'Description',
      'field_uses': 'Uses',
      'field_advantages': 'Advantages',
      'field_note': 'Note (raw response)',
      'distribution_map': 'Distribution map',
      'distribution_not_available': 'No geolocation distribution provided yet.',
      'distribution_view_details': 'View details',
      'distribution_detail_title': 'Distribution locations',
      'distribution_location': 'Location',
      'confidence': 'Confidence',
      'confidence_unknown': 'Confidence: Unknown',
      'scan_camera_realtime_title': 'Realtime Camera Scan',
      'scan_camera_init_failed': 'Unable to initialize camera.',
      'scan_local_mode_badge': 'Local ONNX realtime mode',
      'scan_realtime_waiting': 'Point camera to a plant...',
      'scan_open_result': 'Open result details',
    },
    'vi': {
      'app_name': 'BigPlant',
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
          'Bằng việc đăng nhập vào BigPlant, bạn đã đồng ý với Điều khoản và chính sách bảo mật *',
      'register_terms':
          'Bằng việc đăng ký vào BigPlant, bạn đã đồng ý với Điều khoản và chính sách bảo mật *',
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
      'home_tab': 'Trang chủ',
      'scan_tab': 'Quét',
      'cart_tab': 'Giỏ hàng',
      'settings_tab': 'Cài đặt',
      'home_title': 'Khám phá cây xanh',
      'home_subtitle': 'Chọn cây khỏe đẹp cho không gian của bạn',
      'home_search_hint': 'Tìm cây, chậu hoặc phụ kiện',
      'popular_plants': 'Sản phẩm nổi bật tuần này',
      'category_indoor': 'Trong nhà',
      'category_outdoor': 'Ngoài trời',
      'category_pot': 'Chậu cây',
      'category_air': 'Lọc không khí',
      'cart_title': 'Giỏ hàng của bạn',
      'checkout_now': 'Thanh toán ngay',
      'settings_title': 'Cài đặt',
      'notify_deals': 'Thông báo khuyến mãi',
      'notify_tips': 'Mẹo chăm sóc cây',
      'scan_placeholder_title': 'Chức năng quét sẽ triển khai tiếp theo',
      'scan_placeholder_desc':
          'Luồng camera và tải ảnh sẽ được triển khai ở bước tiếp theo.',
      'scan_title': 'Quét cây',
      'scan_subtitle': 'Chụp hoặc tải ảnh cây để phân tích nhanh',
      'scan_empty_state': 'Ảnh bạn chọn sẽ hiển thị ở đây',
      'scan_camera': 'Chụp ảnh',
      'scan_gallery': 'Tải ảnh lên',
      'scan_tips_title': 'Mẹo để quét chính xác hơn',
      'scan_tip_1': 'Chụp nơi đủ sáng và tránh rung tay.',
      'scan_tip_2': 'Đặt một cây chính vào trung tâm khung hình.',
      'scan_tip_3': 'Hiển thị rõ lá và thân cây để nhận diện tốt hơn.',
      'scan_result_title': 'Kết quả quét',
      'plant_identity': 'Định danh cây',
      'field_common_name': 'Tên thường gọi',
      'field_scientific_name': 'Tên khoa học',
      'field_family': 'Họ',
      'field_order': 'Bộ',
      'field_genus': 'Chi',
      'field_species': 'Loài',
      'field_description': 'Mô tả',
      'field_uses': 'Công dụng',
      'field_advantages': 'Ưu điểm',
      'field_note': 'Ghi chú (raw response)',
      'distribution_map': 'Bản đồ phân bố',
      'distribution_not_available': 'Chưa có dữ liệu tọa độ phân bố.',
      'distribution_view_details': 'Xem chi tiết',
      'distribution_detail_title': 'Danh sách địa điểm phân bố',
      'distribution_location': 'Địa điểm',
      'confidence': 'Độ tin cậy',
      'confidence_unknown': 'Độ tin cậy: Chưa rõ',
      'scan_camera_realtime_title': 'Quét camera thời gian thực',
      'scan_camera_init_failed': 'Không thể khởi tạo camera.',
      'scan_local_mode_badge': 'Chế độ ONNX cục bộ thời gian thực',
      'scan_realtime_waiting': 'Đưa camera vào cây để nhận diện...',
      'scan_open_result': 'Mở chi tiết kết quả',
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
