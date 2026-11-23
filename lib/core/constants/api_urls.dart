/// API endpoint constants for the CraftyBay e-commerce backend.
class ApiUrls {
  ApiUrls._();

  static const String baseUrl = 'https://ecom-rs8e.onrender.com/api';

  // Auth & Profile
  static const String login = '$baseUrl/auth/login';
  static const String signup = '$baseUrl/auth/signup';
  static const String verifyOtp = '$baseUrl/auth/verify-otp';
  static const String resendOtp = '$baseUrl/auth/resend-otp';
  static const String profile = '$baseUrl/auth/profile';

  // Catalog
  static const String slides = '$baseUrl/slides';
  static const String categories = '$baseUrl/categories';
  static String categoryById(String id) => '$baseUrl/categories/$id';
  static const String brands = '$baseUrl/brands';
  static String brandById(String id) => '$baseUrl/brands/$id';
  static const String products = '$baseUrl/products';
  static String productById(String id) => '$baseUrl/products/id/$id';
  static String productBySlug(String slug) => '$baseUrl/products/$slug';

  // Reviews
  static const String reviews = '$baseUrl/reviews';
  static const String createReview = '$baseUrl/review';
  static String reviewById(String id) => '$baseUrl/reviews/$id';

  // Cart
  static const String cart = '$baseUrl/cart';
  static String cartItemById(String id) => '$baseUrl/cart/$id';

  // Wishlist
  static const String wishlist = '$baseUrl/wishlist';
  static String wishlistItemById(String id) => '$baseUrl/wishlist/$id';

  // Orders
  static const String orders = '$baseUrl/orders';
  static String orderById(String id) => '$baseUrl/orders/$id';
  static const String createOrder = '$baseUrl/order';
  static String cancelOrder(String id) => '$baseUrl/orders/$id/cancel';

  // Known category IDs on the backend used for Home sections
  static const String popularCategoryId = '67c35af85e8a445235de197b';
  static const String specialCategoryId = '67c35b395e8a445235de197e';
  static const String newArrivalCategoryId = '67c7bec4623a876bc4766fea';
}
