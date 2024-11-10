import 'package:flutter/material.dart';
import 'dart:async';

class HistoryPageSearch extends StatefulWidget {
  final Function(String, bool?) onSearch;

  const HistoryPageSearch({Key? key, required this.onSearch}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HistoryPageSearchState createState() => _HistoryPageSearchState();
}

class _HistoryPageSearchState extends State<HistoryPageSearch> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool? _isCheckedIn;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.length > 3) {
        widget.onSearch(_searchController.text, _isCheckedIn);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TextField(
        //   controller: _searchController,
        //   decoration: InputDecoration(
        //     hintText: 'Search by name',
        //     prefixIcon: Icon(Icons.search),
        //     border: OutlineInputBorder(
        //       borderRadius: BorderRadius.circular(10),
        //     ),
        //   ),
        // ),
        // SizedBox(height: 10),
        Row(
          children: [
            Radio<bool?>(
              value: null,
              groupValue: _isCheckedIn,
              onChanged: (value) {
                setState(() {
                  _isCheckedIn = value;
                });
                widget.onSearch(_searchController.text, _isCheckedIn);
              },
            ),
            Text('All'),
            Radio<bool?>(
              value: true,
              groupValue: _isCheckedIn,
              onChanged: (value) {
                setState(() {
                  _isCheckedIn = value;
                });
                widget.onSearch(_searchController.text, _isCheckedIn);
              },
            ),
            Text('Checked In'),
            Radio<bool?>(
              value: false,
              groupValue: _isCheckedIn,
              onChanged: (value) {
                setState(() {
                  _isCheckedIn = value;
                });
                widget.onSearch(_searchController.text, _isCheckedIn);
              },
            ),
            Text('Not Checked In'),
          ],
        ),
      ],
    );
  }
}