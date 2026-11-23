import 'package:crafty_bay/data/models/brand_model.dart';
import 'package:crafty_bay/data/models/cart_item_model.dart';
import 'package:crafty_bay/data/models/category_model.dart';
import 'package:crafty_bay/data/models/order_model.dart';
import 'package:crafty_bay/data/models/product_model.dart';
import 'package:crafty_bay/data/models/review_model.dart';
import 'package:crafty_bay/data/models/slide_model.dart';
import 'package:crafty_bay/data/models/user_model.dart';
import 'package:crafty_bay/data/models/wishlist_item_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('API model deserialization', () {
    test('ProductModel handles empty arrays, null regular_price, and nested brand/categories', () {
      final json = {
        '_id': '681372b57aff1010848eea4c',
        'title': 'Mac mini m4',
        'brand': {
          '_id': '6799d84bceaaf5d3413a0989',
          'title': 'Apple',
          'slug': 'apple',
          'icon': 'https://example.com/apple.png',
        },
        'categories': [
          {
            '_id': '6812518cea40bfc6edc67356',
            'title': 'Apply',
            'slug': 'apply',
            'icon': 'https://example.com/cat.png',
          },
        ],
        'slug': 'macminim4',
        'meta_description': null,
        'description': 'Mac mini m4 16GB Ram',
        'photos': <dynamic>[],
        'colors': <dynamic>[],
        'sizes': <dynamic>[],
        'tags': <dynamic>[],
        'regular_price': null,
        'current_price': 70000,
        'quantity': 1,
      };

      final product = ProductModel.fromJson(json);
      expect(product.id, '681372b57aff1010848eea4c');
      expect(product.title, 'Mac mini m4');
      expect(product.brand?.title, 'Apple');
      expect(product.categories.length, 1);
      expect(product.photos, isEmpty);
      expect(product.primaryPhoto, isNull);
      expect(product.regularPrice, isNull);
      expect(product.currentPrice, 70000.0);
      expect(product.rating, 4.8);
    });

    test('ProductModel parses colors, sizes, photos, and numeric rating', () {
      final json = {
        '_id': '67c82f9532792bb7f4c68e20',
        'title': 'TUS Product 13',
        'slug': 'tus-product-13',
        'description': 'Awesome product',
        'photos': ['https://example.com/p1.jpg'],
        'colors': ['Red', 'Blue'],
        'sizes': ['XS', 'S', 'L'],
        'tags': ['new'],
        'regular_price': 18000,
        'current_price': 12000,
        'quantity': 2,
        'rating': 4.5,
      };

      final product = ProductModel.fromJson(json);
      expect(product.colors, ['Red', 'Blue']);
      expect(product.sizes, ['XS', 'S', 'L']);
      expect(product.primaryPhoto, 'https://example.com/p1.jpg');
      expect(product.regularPrice, 18000.0);
      expect(product.rating, 4.5);
    });

    test('ReviewModel handles int and double ratings and populated user', () {
      final intReview = ReviewModel.fromJson({
        '_id': 'r1',
        'product': {'_id': 'p1', 'title': 'Mac'},
        'user': {'_id': 'u1', 'first_name': 'Rabbil', 'last_name': 'Hasan'},
        'rating': 5,
        'comment': 'good product',
      });
      expect(intReview.rating, 5.0);
      expect(intReview.reviewerName, 'Rabbil Hasan');
      expect(intReview.productId, 'p1');

      final doubleReview = ReviewModel.fromJson({
        '_id': 'r2',
        'product': 'p1',
        'user': null,
        'rating': 3.5,
        'comment': 'nice product',
      });
      expect(doubleReview.rating, 3.5);
      expect(doubleReview.reviewerName, 'Customer');
    });

    test('SlideModel, CategoryModel, BrandModel, UserModel parse correctly', () {
      final slide = SlideModel.fromJson({
        '_id': 's1',
        'photo_url': 'https://example.com/slide.jpg',
        'description': 'Iphone 16 pro',
        'brand': 'b1',
      });
      expect(slide.brandId, 'b1');

      final cat = CategoryModel.fromJson({
        '_id': 'c1',
        'title': 'Books',
        'slug': 'books',
        'icon': 'https://example.com/book.png',
      });
      expect(cat.title, 'Books');

      final brand = BrandModel.fromJson({
        '_id': 'b1',
        'title': 'Apple',
        'slug': 'apple',
      });
      expect(brand.slug, 'apple');

      final user = UserModel.fromJson({
        '_id': 'u1',
        'first_name': 'Meskatul',
        'last_name': 'Islam',
        'email': 'meskatcse@gmail.com',
        'city': 'Chattogram',
      });
      expect(user.fullName, 'Meskatul Islam');
      expect(user.toJson()['email'], 'meskatcse@gmail.com');
    });

    test('CartItemModel, WishlistItemModel, and OrderModel compute totals', () {
      final cartItem = CartItemModel.fromJson({
        '_id': 'ci1',
        'product': {
          '_id': 'p1',
          'title': 'New Year Special Shoe',
          'current_price': 100,
        },
        'quantity': 3,
        'color': 'Red',
        'size': 'X',
      });
      expect(cartItem.totalPrice, 300.0);
      expect(cartItem.color, 'Red');

      final wishItem = WishlistItemModel.fromJson({
        '_id': 'wi1',
        'product': {
          '_id': 'p1',
          'title': 'Shoe',
          'current_price': 120,
        },
      });
      expect(wishItem.product.title, 'Shoe');

      final order = OrderModel.fromJson({
        '_id': 'o1',
        'status': 'pending',
        'payment_method': 'cod',
        'shipping_address': {
          'full_name': 'Meskatul Islam',
          'address': 'Patiya',
          'city': 'Chattogram',
          'postal_code': '4370',
          'phone': '01754658781',
        },
        'items': [
          {'title': 'Shoe', 'quantity': 2, 'price': 100},
        ],
      });
      expect(order.totalAmount, 200.0);
      expect(order.shippingAddress?.city, 'Chattogram');
    });
  });
}
