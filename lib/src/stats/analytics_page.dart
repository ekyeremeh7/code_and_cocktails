import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/user_model.dart';

class AnimatedPieChart extends StatefulWidget {
  final Map<String, double> dataMap;
  final List<Color> colorList;
  final double height;
  final Function(int)? onSectionTapped;

  const AnimatedPieChart({
    Key? key,
    required this.dataMap,
    required this.colorList,
    required this.height,
    this.onSectionTapped,
  }) : super(key: key);

  @override
  State<AnimatedPieChart> createState() => _AnimatedPieChartState();
}

class _AnimatedPieChartState extends State<AnimatedPieChart> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: widget.height,
      child: PieChart(
        dataMap: widget.dataMap,
        animationDuration: const Duration(milliseconds: 1500),
        chartType: ChartType.ring,
        ringStrokeWidth: 32,
        colorList: widget.colorList,
        chartRadius: widget.height / 2,
        legendOptions: const LegendOptions(
          showLegends: false,
          
        ),
        chartValuesOptions: const ChartValuesOptions(
          showChartValueBackground: false,
          showChartValues: true,
          showChartValuesInPercentage: true,
          showChartValuesOutside: false,
          decimalPlaces: 1,
        ),
        centerText:
            widget.dataMap.length == 2 ? 'Ticket\nStats' : 'Ticket\nTypes',
        centerTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class AnalyticsPage extends StatelessWidget {
  final UserResponse? userData;

  const AnalyticsPage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    if (userData == null || userData!.results.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title:  Text(
            'Analytics',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 26),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text('No data available for analytics'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title:  Text(
          'Analytics',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 26),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).canvasColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            FadeInDown(
              delay: const Duration(milliseconds: 100),
              child: Text(
                'Ticket Statistics',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: _buildCheckInStats(context, userData!),
            ),
            const SizedBox(height: 32),
            FadeInDown(
              delay: const Duration(milliseconds: 300),
              child: Text(
                'Ticket Types Distribution',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: _buildTicketTypesPieChart(context, userData!),
            ),
            const SizedBox(height: 32),
            FadeInDown(
              delay: const Duration(milliseconds: 500),
              child: Text(
                'Top Insights',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              child: _buildTopInsights(context, userData!),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInStats(BuildContext context, UserResponse data) {
    final checkedIn = data.checkedInCount.toDouble();
    final notCheckedIn = (data.totalCount - data.checkedInCount).toDouble();

    final dataMap = <String, double>{
      'Checked In': checkedIn,
      'Not Checked In': notCheckedIn,
    };

    return SizedBox(
      height: 450,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FadeInLeft(
                  delay: const Duration(milliseconds: 100),
                  child: _buildStatCard(
                    'Checked In',
                    data.checkedInCount.toString(),
                    Colors.green,
                    context,
                  ),
                ),
                FadeInRight(
                  delay: const Duration(milliseconds: 150),
                  child: _buildStatCard(
                    'Not Checked In',
                    (data.totalCount - data.checkedInCount).toString(),
                    Colors.red,
                    context,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ZoomIn(
              delay: const Duration(milliseconds: 300),
              child: AnimatedPieChart(
                height: 450,
                dataMap: dataMap,
                colorList: const [Colors.green, Colors.red],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckInDetails(BuildContext context, int checkedIn,
      int notCheckedIn, double checkedInPercentage, int index) {
    final isCheckedIn = index == 0;
    final count = isCheckedIn ? checkedIn : notCheckedIn;
    final percentage =
        isCheckedIn ? checkedInPercentage : (100 - checkedInPercentage);
    final title = isCheckedIn ? 'Checked In' : 'Not Checked In';
    final color = isCheckedIn ? Colors.green : Colors.red;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ScaleTransition(
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent:
                ModalRoute.of(context)?.animation ?? kAlwaysCompleteAnimation,
            curve: Curves.easeOutBack,
          ),
        ),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle, color: color, size: 36),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'of total',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, Color color, BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  void _showTicketTypeDetails(
      BuildContext context,
      List<MapEntry<String, int>> ticketTypeEntries,
      Map<String, int> ticketTypeCount,
      int index) {
    if (index >= ticketTypeEntries.length) return;

    final entry = ticketTypeEntries[index];
    final typeName = entry.key;
    final count = entry.value;
    final total = ticketTypeEntries.fold<int>(0, (sum, e) => sum + e.value);
    final percentage = (count / total * 100);

    // Get the color for this ticket type
    Color getColorForType() {
      final colors = [
        Theme.of(context).primaryColor,
        Colors.blue,
        Colors.purple,
        Colors.orange,
        Colors.teal,
        Colors.pink,
      ];
      final typeIndex = ticketTypeEntries.indexWhere((e) => e.key == typeName);
      return colors[typeIndex % colors.length];
    }

    final color = getColorForType();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ScaleTransition(
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent:
                ModalRoute.of(context)?.animation ?? kAlwaysCompleteAnimation,
            curve: Curves.easeOutBack,
          ),
        ),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.event_seat, color: color, size: 36),
                ),
                const SizedBox(height: 16),
                Text(
                  typeName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'of total',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'out of $total total',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketTypesPieChart(BuildContext context, UserResponse data) {
    final Map<String, int> ticketTypeCount = {};
    final Map<String, Color> typeColors = {};

    for (var ticket in data.results) {
      final type = ticket.ticketType ?? 'Unknown';
      ticketTypeCount[type] = (ticketTypeCount[type] ?? 0) + 1;
    }

    final colors = [
      Theme.of(context).primaryColor,
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
    ];

    var colorIndex = 0;
    for (var type in ticketTypeCount.keys) {
      if (!typeColors.containsKey(type)) {
        typeColors[type] = colors[colorIndex % colors.length];
        colorIndex++;
      }
    }

    final ticketTypeEntries = ticketTypeCount.entries.toList();
    final colorList =
        ticketTypeEntries.map((entry) => typeColors[entry.key]!).toList();

    final dataMap = <String, double>{};
    for (var entry in ticketTypeEntries) {
      dataMap[entry.key] = entry.value.toDouble();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          ZoomIn(
            delay: const Duration(milliseconds: 500),
            child: AnimatedPieChart(
              height: 450,
              dataMap: dataMap,
              colorList: colorList,
            ),
          ),
          const SizedBox(height: 20),
          ...ticketTypeCount.entries.toList().asMap().entries.map((mapEntry) {
            final index = mapEntry.key;
            final entry = mapEntry.value;
            return FadeInLeft(
              delay: Duration(milliseconds: 600 + ((index) * 50)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: typeColors[entry.key],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '${entry.value}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTopInsights(BuildContext context, UserResponse data) {
    final Map<String, int> ticketTypeCount = {};
    final Map<String, int> buyerCount = {};
    final Map<String, String> emailToName = {};

    for (var ticket in data.results) {
      final type = ticket.ticketType ?? 'Unknown';
      ticketTypeCount[type] = (ticketTypeCount[type] ?? 0) + 1;

      // Count tickets by buyer email and store name mapping
      final buyerEmail = ticket.customer?.email ?? 'Unknown';
      final buyerName = ticket.customer?.name ?? 'Unknown';
      buyerCount[buyerEmail] = (buyerCount[buyerEmail] ?? 0) + 1;
      if (buyerEmail != 'Unknown' && buyerName != 'Unknown') {
        emailToName[buyerEmail] = buyerName;
      }
    }

    final sortedTypes = ticketTypeCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final sortedBuyers = buyerCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topTicketType =
        sortedTypes.isNotEmpty ? sortedTypes.first.key : 'N/A';
    final topBuyerEmail = sortedBuyers.isNotEmpty ? sortedBuyers.first.key : 'N/A';
    final topBuyerCount =
        sortedBuyers.isNotEmpty ? sortedBuyers.first.value : 0;
    final topBuyerName = emailToName[topBuyerEmail] ?? topBuyerEmail;
    final checkedIn = data.checkedInCount;
    final total = data.totalCount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          FadeInRight(
            delay: const Duration(milliseconds: 700),
            child: _buildInsightRow(
              Icons.person_outline,
              'Top Buyer',
              '$topBuyerName ($topBuyerCount tickets)',
              Colors.teal,
            ),
          ),
          const Divider(height: 24),
          FadeInRight(
            delay: const Duration(milliseconds: 750),
            child: _buildInsightRow(
              Icons.local_fire_department,
              'Most Popular Ticket',
              topTicketType,
              Colors.orange,
            ),
          ),
          const Divider(height: 24),
          FadeInRight(
            delay: const Duration(milliseconds: 800),
            child: _buildInsightRow(
              Icons.people_outline,
              'Total Attendees',
              '$checkedIn out of $total checked in',
              Theme.of(context).primaryColor,
            ),
          ),
          const Divider(height: 24),
          FadeInRight(
            delay: const Duration(milliseconds: 850),
            child: _buildInsightRow(
              Icons.percent,
              'Check-in Rate',
              '${total > 0 ? (checkedIn / total * 100).toStringAsFixed(1) : 0}%',
              Colors.blue,
            ),
          ),
          const Divider(height: 24),
          FadeInRight(
            delay: const Duration(milliseconds: 900),
            child: _buildInsightRow(
              Icons.category,
              'Ticket Varieties',
              '${ticketTypeCount.length} different types',
              Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow(
      IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
