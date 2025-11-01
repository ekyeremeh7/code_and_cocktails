import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_popup/flutter_popup.dart';
import '../../models/user_model.dart';

class AnimatedPieChart extends StatefulWidget {
  final List<PieChartSectionData> sections;
  final double height;
  final int sectionsSpace;
  final double centerSpaceRadius;
  final Function(int)? onSectionTapped;

  const AnimatedPieChart({
    Key? key,
    required this.sections,
    required this.height,
    this.sectionsSpace = 3,
    this.centerSpaceRadius = 50,
    this.onSectionTapped,
  }) : super(key: key);

  @override
  State<AnimatedPieChart> createState() => _AnimatedPieChartState();
}

class _AnimatedPieChartState extends State<AnimatedPieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          height: widget.height,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                enabled: widget.onSectionTapped != null,
                touchCallback: widget.onSectionTapped != null
                    ? (FlTouchEvent event, pieTouchResponse) {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          return;
                        }
                        widget.onSectionTapped!(
                            pieTouchResponse.touchedSection!.touchedSectionIndex);
                      }
                    : null,
              ),
              sectionsSpace: widget.sectionsSpace.toDouble(),
              centerSpaceRadius: widget.centerSpaceRadius,
              sections: widget.sections.map((section) {
                return PieChartSectionData(
                  value: section.value,
                  title: section.title,
                  color: section.color,
                  radius: section.radius * _animation.value,
                  titleStyle: section.titleStyle,
                );
              }).toList(),
            ),
          ),
        );
      },
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
          title: const Text('Analytics'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
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
        title: const Text('Analytics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
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
    final checkedIn = data.checkedInCount;
    final total = data.totalCount;
    final notCheckedIn = total - checkedIn;
    final checkedInPercentage = total > 0 ? (checkedIn / total * 100) : 0.0;

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
                    checkedIn.toString(),
                    Colors.green,
                    context,
                  ),
                ),
                FadeInRight(
                  delay: const Duration(milliseconds: 150),
                  child: _buildStatCard(
                    'Not Checked In',
                    notCheckedIn.toString(),
                    Colors.red,
                    context,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            ZoomIn(
              delay: const Duration(milliseconds: 300),
              child: AnimatedPieChart(
                height: 171,
                sectionsSpace: 4,
                centerSpaceRadius: 51,
                onSectionTapped: (index) {
                  _showCheckInDetails(context, checkedIn, notCheckedIn,
                      checkedInPercentage, index);
                },
                sections: [
                  PieChartSectionData(
                    value: checkedIn.toDouble(),
                    title: '${checkedInPercentage.toStringAsFixed(1)}%',
                    color: Colors.green,
                    radius: 86,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: notCheckedIn.toDouble(),
                    title:
                        '${(100 - checkedInPercentage).toStringAsFixed(1)}%',
                    color: Colors.red,
                    radius: 86,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckInDetails(BuildContext context, int checkedIn, int notCheckedIn,
      double checkedInPercentage, int index) {
    final isCheckedIn = index == 0;
    final count = isCheckedIn ? checkedIn : notCheckedIn;
    final percentage = isCheckedIn ? checkedInPercentage : (100 - checkedInPercentage);
    final title = isCheckedIn ? 'Checked In' : 'Not Checked In';
    final color = isCheckedIn ? Colors.green : Colors.red;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ScaleTransition(
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: ModalRoute.of(context)?.animation ?? kAlwaysCompleteAnimation,
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
                  padding: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: 20),
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

  void _showTicketTypeDetails(BuildContext context,
      List<MapEntry<String, int>> ticketTypeEntries,
      Map<String, int> ticketTypeCount, int index) {
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
            parent: ModalRoute.of(context)?.animation ?? kAlwaysCompleteAnimation,
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
                  padding: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: 20),
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

    final sections = ticketTypeEntries.map((entry) {
      final percentage = (entry.value / data.results.length * 100);
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
        color: typeColors[entry.key],
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

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
          ZoomIn(
            delay: const Duration(milliseconds: 500),
            child: AnimatedPieChart(
              height: 250,
              sectionsSpace: 3,
              centerSpaceRadius: 50,
              onSectionTapped: (index) {
                _showTicketTypeDetails(
                    context, ticketTypeEntries, ticketTypeCount, index);
              },
              sections: sections,
            ),
          ),
          const SizedBox(height: 20),
          ...ticketTypeCount.entries.toList().asMap().entries.map((mapEntry) {
            final index = mapEntry.key;
            final entry = mapEntry.value;
            return FadeInLeft(
              delay: Duration(milliseconds: 600 + ((index as int) * 50)),
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

    for (var ticket in data.results) {
      final type = ticket.ticketType ?? 'Unknown';
      ticketTypeCount[type] = (ticketTypeCount[type] ?? 0) + 1;
    }

    final sortedTypes = ticketTypeCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topTicketType =
        sortedTypes.isNotEmpty ? sortedTypes.first.key : 'N/A';
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
              Icons.local_fire_department,
              'Most Popular Ticket',
              topTicketType,
              Colors.orange,
            ),
          ),
          const Divider(height: 24),
          FadeInRight(
            delay: const Duration(milliseconds: 750),
            child: _buildInsightRow(
              Icons.people_outline,
              'Total Attendees',
              '$checkedIn out of $total checked in',
              Theme.of(context).primaryColor,
            ),
          ),
          const Divider(height: 24),
          FadeInRight(
            delay: const Duration(milliseconds: 800),
            child: _buildInsightRow(
              Icons.percent,
              'Check-in Rate',
              '${total > 0 ? (checkedIn / total * 100).toStringAsFixed(1) : 0}%',
              Colors.blue,
            ),
          ),
          const Divider(height: 24),
          FadeInRight(
            delay: const Duration(milliseconds: 850),
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
