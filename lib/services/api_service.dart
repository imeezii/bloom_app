import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MarketStackService {
  final String _apiKey = 'f3070b391f1c18416447b060363f65bd';
  final String _baseUrl = 'http://api.marketstack.com/v1';

  // Basic EOD
  Future<Map<String, dynamic>> getEOD(String symbol) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/eod?access_key=$_apiKey&symbols=$symbol'),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load EOD');
  }

  // Tickers
  Future<Map<String, dynamic>> getTickerDetails(String symbol) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/tickers/$symbol?access_key=$_apiKey'),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load Ticker Details');
  }

  // Exchanges
  Future<Map<String, dynamic>> getExchanges() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/exchanges?access_key=$_apiKey'),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load Exchanges');
  }

  // Currencies
  Future<Map<String, dynamic>> getCurrencies() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/currencies?access_key=$_apiKey'),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load Currencies');
  }
}
