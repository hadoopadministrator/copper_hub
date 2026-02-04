import 'package:flutter/material.dart';
import 'package:wealth_bridge_impex/routes/app_routes.dart';
import 'package:wealth_bridge_impex/widgets/drawer_widget.dart';
import 'package:wealth_bridge_impex/widgets/price_widget.dart';

class LiveRatesScreen extends StatelessWidget {
  const LiveRatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Live Prices',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
      ),
      drawer: DrawerWidget(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  PriceWidget(
                    title: "COPPER SPOT PRICE",
                    price: "₹ 742.50",
                    unit: "Per KG",
                  ),
                  const SizedBox(width: 10),
                  PriceWidget(
                    title: "Live Forex RATE",
                    price: '83.50',
                    unit: 'USD/INR',
                  ),
                  const SizedBox(width: 10),
                  PriceWidget(
                    title: 'COPPER COSTING',
                    price: '₹ 742500.00',
                    unit: 'Per MT',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListView.builder(
                itemCount: 5,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Copper Price",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "0.25 KG+",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffF9B236),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.checkOut);
                        },
                        child: const Text(
                          "BUY: 1442.50",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.checkOut);
                        },
                        child: const Text(
                          "SELL: 1092.50",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
