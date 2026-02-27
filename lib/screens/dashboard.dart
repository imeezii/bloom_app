import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class BloomDashboard extends StatefulWidget {
  const BloomDashboard({super.key});

  @override
  State<BloomDashboard> createState() => _BloomDashboardState();
}

class _BloomDashboardState extends State<BloomDashboard> {
  final MarketStackService _service = MarketStackService();
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: r'$', decimalDigits: 2);
  
  bool _isLoading = true;
  Map<String, dynamic>? _eodData;
  Map<String, dynamic>? _tickerData;
  String _errorMessage = "";

  final List<String> _favCurrencies = ['USD', 'EUR', 'GBP', 'JPY', 'PHP', 'AUD', 'CAD'];

  @override
  void initState() {
    super.initState();
    _fetchRealMarketData();
  }

  Future<void> _fetchRealMarketData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      const String symbol = 'META'; 
      
      final results = await Future.wait([
        _service.getEOD(symbol),
        _service.getTickerDetails(symbol),
      ]);

      setState(() {
        if (results[0]['data'] != null && results[0]['data'].isNotEmpty) {
          _eodData = results[0]['data'][0];
        }
        _tickerData = results[1];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Connection Error. Check API Key.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "BLOOM",
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.w900, 
            letterSpacing: 4, 
            fontSize: 26
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purpleAccent))
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.redAccent)))
              : RefreshIndicator(
                  onRefresh: _fetchRealMarketData,
                  color: Colors.purpleAccent,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildPortfolioHeader(),
                        const SizedBox(height: 40),
                        _buildSectionLabel("LIVE MARKET DATA"),
                        const SizedBox(height: 16),
                        _buildAssetCard(),
                        const SizedBox(height: 40),
                        _buildSectionLabel("GLOBAL WATCHLIST"),
                        const SizedBox(height: 16),
                        _buildCurrencyGrid(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color.fromARGB(255, 50, 49, 49),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildPortfolioHeader() {
    double livePrice = _eodData?['close']?.toDouble() ?? 0.0;
    String symbol = _tickerData?['symbol'] ?? '---';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6200EA), Color(0xFF311B92)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 10),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            symbol,
            style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            _currencyFormat.format(livePrice),
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 40, 
              fontWeight: FontWeight.bold,
              letterSpacing: -1
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.bolt, color: Colors.greenAccent, size: 18),
              const SizedBox(width: 4),
              const Text(
                "LIVE FROM MARKETSTACK",
                style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssetCard() {
    double closePrice = _eodData?['close']?.toDouble() ?? 0.0;
    String name = _tickerData?['name'] ?? "Unknown Asset";
    String symbol = _tickerData?['symbol'] ?? "---";

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symbol, 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)
                ),
                const SizedBox(height: 4),
                Text(
                  name, 
                  style: const TextStyle(color: Colors.white38, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            _currencyFormat.format(closePrice),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 2.3,
      ),
      itemCount: _favCurrencies.length,
      itemBuilder: (context, i) {
        bool isUSD = _favCurrencies[i] == 'USD';
        return Container(
          decoration: BoxDecoration(
            color: isUSD ? Colors.purpleAccent : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isUSD ? Colors.white24 : Colors.white.withOpacity(0.05)),
          ),
          child: Center(
            child: Text(
              _favCurrencies[i],
              style: TextStyle(
                color: isUSD ? Colors.white : Colors.white54, 
                fontWeight: FontWeight.w800,
                fontSize: 14
              ),
            ),
          ),
        );
      },
    );
  }
}