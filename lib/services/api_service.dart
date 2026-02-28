import 'package:dio/dio.dart';
import '../models/meal.dart';
import '../models/category.dart';
import '../models/meal_preview.dart';

class MealService {
  final Dio _dio;

  MealService()
      : _dio = Dio(BaseOptions(
          baseUrl: 'https://www.themealdb.com/api/json/v1/1',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Accept': 'application/json',
          },
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ));

  // Endpoint 1: Get all categories
  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/categories.php');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['categories'] != null) {
          return (data['categories'] as List)
              .map((json) => Category.fromJson(json))
              .toList();
        }
      }
      throw Exception('Invalid response from server');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }
      throw Exception('Failed to load categories: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Endpoint 2: Get meals by category
  Future<List<MealPreview>> getMealsByCategory(String category) async {
    try {
      final response = await _dio.get('/filter.php', queryParameters: {
        'c': category,
      });
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['meals'] == null) return [];
        return (data['meals'] as List)
            .map((json) => MealPreview.fromJson(json))
            .toList();
      }
      throw Exception('Invalid response from server');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }
      throw Exception('Failed to load meals: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Endpoint 3: Get meal details by ID
  Future<Meal?> getMealById(String id) async {
    try {
      final response = await _dio.get('/lookup.php', queryParameters: {
        'i': id,
      });
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['meals'] == null || data['meals'].isEmpty) return null;
        return Meal.fromJson(data['meals'][0]);
      }
      throw Exception('Invalid response from server');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }
      throw Exception('Failed to load meal: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Endpoint 4: Search meals by name
  Future<List<Meal>> searchMeals(String query) async {
    try {
      final response = await _dio.get('/search.php', queryParameters: {
        's': query,
      });
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['meals'] == null) return [];
        return (data['meals'] as List)
            .map((json) => Meal.fromJson(json))
            .toList();
      }
      throw Exception('Invalid response from server');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }
      throw Exception('Failed to search: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Endpoint 5: Get random meal
  Future<Meal?> getRandomMeal() async {
    try {
      final response = await _dio.get('/random.php');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['meals'] == null || data['meals'].isEmpty) return null;
        return Meal.fromJson(data['meals'][0]);
      }
      throw Exception('Invalid response from server');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }
      throw Exception('Failed to load random meal: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
