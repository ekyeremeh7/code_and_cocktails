import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../models/ticket_request_success.dart';
import '../../models/user_model.dart';
import '../../requests/verifying_ticket.dart';
import '../../shared/services/sembast_service.dart';
import '../../shared/utils/assets.dart';
import '../../shared/utils/debouncer.dart';
import '../../shared/utils/enums.dart';
import '../../shared/utils/helper.dart';
import '../../shared/utils/styled_toast/selected_toast.dart';
import 'analytics_page.dart';

class HistoryPage extends StatefulWidget {
  final Barcode? result;

  const HistoryPage({super.key, required this.result});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int selectedTicketIndex = 0;
  bool selectCategory = false;
  UserStatus? userStatus;
  UserResponse? results;
  final SembastService _sembastService = SembastService();
  List<TicketSuccessResponse> filteredResults = [];
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool? _isCheckedIn;
  bool _showClearButton = false;

  final Debouncer _debouncer =
      Debouncer(delay: const Duration(milliseconds: 800));
  bool _isSearching = false;

  userFallback() async {
    try {
      final cachedData = await _sembastService.getUserResponse();
      debugPrint("userFallback icalled ${cachedData!.length}");
      if (cachedData.isNotEmpty) {
        loadCachedUserResponse(cachedData);
      } else {
        debugPrint("If no cached data, fetch from server");
        setState(() {
          userStatus = UserStatus.loading;
        });
      }
    } catch (e) {
      debugPrint("Error fetching users: $e");
      setState(() {
        userStatus = UserStatus.error;
      });
    }
  }

  void cacheUserResponse(UserResponse? users) async {
    if (results != null) {
      final usersJsonList =
          results?.results.map((user) => user.toJson()).toList();
      final userJson = {
        'checkedInCount': results?.checkedInCount,
        'totalCount': results?.totalCount,
        'tickets': usersJsonList,
        // 'tickets': results?.results.map((ticket) => ticket.toJson()).toList(),
      };

      await _sembastService.saveUserResponse(userJson);
    }
  }

  void loadCachedUserResponse(Map<String, dynamic> cachedData) {
    final cachedUserResponse = UserResponse.fromJson(cachedData);
    debugPrint("loadCachedUserResponse icalled ${cachedData.length}");
    setState(() {
      results = cachedUserResponse;
      userStatus = UserStatus.success;
    });
  }

  void _onSearch(String query, bool? isCheckedIn) {
    setState(() {
      _isSearching = query.isNotEmpty;
      filteredResults = results!.results.where((ticket) {
        final searchQuery = query.toLowerCase();

        // Search by name
        final nameMatches =
            ticket.customer?.name?.toLowerCase().contains(searchQuery) ?? false;

        // Search by email
        final emailMatches =
            ticket.customer?.email?.toLowerCase().contains(searchQuery) ??
                false;

        // Search by phone
        final phoneMatches =
            ticket.customer?.phone?.toLowerCase().contains(searchQuery) ??
                false;

        // Combined search matches
        final searchMatches = nameMatches || emailMatches || phoneMatches;

        // Filter by checked-in status
        bool statusMatches;
        if (isCheckedIn == null) {
          // If null, don't filter by status
          statusMatches = true;
        } else {
          // Check if the ticket status matches the isCheckedIn value
          // Treat missing `checkedIn` field as 'false' (unchecked)
          statusMatches = (ticket.checkedIn ?? false) == isCheckedIn;
        }

        return searchMatches && statusMatches;
      }).toList();
      debugPrint(
          "Filtered list $_isCheckedIn ${filteredResults.length} ${results!.results.length}");
    });
  }

  // void _onSearchChanged() {
  //   if (_debounce?.isActive ?? false) _debounce!.cancel();
  //   _debounce = Timer(const Duration(milliseconds: 500), () {
  //     if (_searchController.text.length > 3) {
  //       _onSearch(_searchController.text, _isCheckedIn);
  //     }
  //   });
  // }

  @override
  void initState() {
    super.initState();
    _isCheckedIn = null;
    // _searchController.addListener(_onSearchChanged);
    _getAllUsers(context);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black.withOpacity(0.5)),
          centerTitle: false,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: Theme.of(context).primaryColor,
              size: 26,
            ),
          ),
          title: Text(
            'History',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AnalyticsPage(userData: results),
                  ),
                );
              },
              icon: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.analytics_outlined,
                  size: 30,
                  color: Colors.black,
                ),
              ),
              tooltip: 'View Analytics',
            ),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.049,
                child: TextFormField(
                  cursorColor: Colors.black,
                  controller: _searchController,
                  style: const TextStyle(
                      color: Colors.black, fontFamily: 'Manrope', fontSize: 15),
                  cursorHeight: 20,
                  cursorWidth: 0.8,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.grey,
                      size: 20,
                    ),
                    suffixIcon: _showClearButton
                        ? IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _showClearButton = false;
                                _isSearching = false;
                              });
                              filteredResults.clear();
                              _getAllUsers(context);
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _showClearButton = value.isNotEmpty;
                    });
                    if (value.isEmpty) {
                      setState(() {
                        _isSearching = false;
                      });
                      _debouncer.run(() {
                        filteredResults.clear();
                        _isCheckedIn == null
                            ? results!.results.length
                            : filteredResults.isNotEmpty
                                ? filteredResults.length
                                : results!.checkedInCount;
                        _getAllUsers(context);
                      });
                    } else {
                      debugPrint("Query $value");
                      if (Helper.isGreaterThan(value.length, 3)) {
                        _debouncer.run(() {
                          _onSearch(value, _isCheckedIn);
                        });
                      }
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ToggleButtons(
                borderRadius: BorderRadius.circular(8),
                borderColor: Colors.grey.shade300,
                selectedBorderColor: Theme.of(context).primaryColor,
                fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
                color: Colors.grey.shade600,
                selectedColor: Theme.of(context).primaryColor,
                constraints: const BoxConstraints(
                  minHeight: 40,
                  minWidth: 100,
                ),
                isSelected: [
                  _isCheckedIn == null,
                  _isCheckedIn == true,
                  _isCheckedIn == false,
                ],
                onPressed: (int index) async {
                  setState(() {
                    if (index == 0) {
                      _isCheckedIn = null;
                    } else if (index == 1) {
                      _isCheckedIn = true;
                    } else {
                      _isCheckedIn = false;
                    }
                  });
                  if (index == 0) {
                    await _getAllUsers(context);
                  }
                  _onSearch(_searchController.text, _isCheckedIn);
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('All'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Checked In'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Not Checked In'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: userStatus == UserStatus.loading
                  ? _buildLoader()
                  : userStatus == UserStatus.error
                      ? _buildErrorWidget()
                      : results != null
                          ? _buildUserList()
                          : _buildNoUserWidget(),
            ),
          ],
        ));
  }

  _getAllUsers(BuildContext ctx) {
    Future.microtask(() async {
      // Existing working ccode

      // VerifyingTicketSingleton verifyingTicketSingleton =
      //     VerifyingTicketSingleton();
      // setState(() {
      //   userStatus = UserStatus.loading;
      // });

      // results = await verifyingTicketSingleton.getAllUsers();
      // debugPrint(
      //     "CheckInCount ${results!.checkedInCount.toString()} totalUsers ${results!.totalCount.toString()}");
      // if (results == null) {
      //   setState(() {
      //     userStatus = UserStatus.error;
      //   });
      //   return null;
      // }

      // if (results != null) {
      //   debugPrint("RESP OK:");
      //   setState(() {
      //     userStatus = UserStatus.success;
      //   });
      // }

      //new change
      VerifyingTicketSingleton verifyingTicketSingleton =
          VerifyingTicketSingleton();
      await userFallback();
      List<TicketSuccessResponse> cachedData = results?.results ?? [];

      results = await verifyingTicketSingleton.getAllUsers();
      if (results == null) {
        setState(() {
          userStatus = UserStatus.error;
        });
        return null;
      }

      if (results != null) {
        debugPrint("RESP OK: ${results!.results.length}");

        List<TicketSuccessResponse> serverData = results?.results ?? [];
        if (Helper.isServerDataUpdated(serverData, cachedData)) {
          debugPrint(
              "New or updated data is available! ${serverData.length} ${cachedData.length}");
          if (context.mounted) {
            failed(ctx, 'History updated');
          }
        } else {
          debugPrint("No new or updated data is available!");
        }
        cacheUserResponse(results);
        setState(() {
          userStatus = UserStatus.success;
        });
      }
    });
  }

  _buildUserList() {
    final displayList = _isSearching ? filteredResults : results!.results;
    final itemCount = displayList.length;

    return Column(
      children: [
        _buildCheckedTotalWidget(
            results, filteredResults, _isCheckedIn, _isSearching),
        Expanded(
          // height: MediaQuery.of(context).size.height * 0.84,
          child: itemCount == 0 && _isSearching
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No results found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    final ticket = displayList[index];
                    final customer = ticket.customer;
                    bool isCheckedIn = ticket.checkedIn ?? false;

                    return _buildUser(context, customer, isCheckedIn, ticket,
                        ticket.sId ?? 'N/A');

                    // return _buildAttendanceCard(customer, isCheckedIn);
                  },
                ),
        ),
      ],
    );
  }
}

_buildErrorWidget() {
  return Container(
    alignment: Alignment.center,
    child: const Text(
      "Error Making request",
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xffEA1154),
        fontSize: 18.0,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

_buildLoader() {
  return Container(
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
          // strokeWidth: 3,
          ));
}

_buildNoUserWidget() {
  return Container(
    alignment: Alignment.center,
    child: const Text("No user found"),
  );
}

_buildCheckedTotalWidget(
    UserResponse? results,
    List<TicketSuccessResponse> filteredList,
    bool? isCheckedIn,
    bool isSearching) {
  // Determine display text and count
  String displayText;
  String displayCount;

  if (isSearching) {
    displayText = "Search Results";
    displayCount = filteredList.length.toString();
  } else if (isCheckedIn == null) {
    displayText = "All Users";
    displayCount = "${results!.results.length}";
  } else if (isCheckedIn) {
    displayText = 'Checked-In Users';
    displayCount =
        "${results!.checkedInCount.toString()}/${results.totalCount.toString()}";
  } else {
    displayText = 'Not Checked Users';
    displayCount =
        "${filteredList.isNotEmpty ? filteredList.length : (results!.totalCount - results.checkedInCount).toString()}/${results!.totalCount.toString()}";
  }

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (isSearching)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.search,
                  size: 14,
                  color: Colors.blue.shade600,
                ),
              ),
            Text(
              displayText,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontStyle: isSearching ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ],
        ),
        Text(
          displayCount,
          style: TextStyle(
            color:
                isSearching && filteredList.isEmpty ? Colors.red : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        )
      ],
    ),
  );
}

_buildUser(
  BuildContext context,
  Customer? customer,
  bool isCheckedIn,
  TicketSuccessResponse ticket,
  String ticketId,
) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  customer?.name.toString() ?? "No name",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isCheckedIn
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCheckedIn ? Icons.check_circle : Icons.cancel,
                      color: isCheckedIn ? Colors.green : Colors.redAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isCheckedIn ? "Checked In" : "Not Checked In",
                      style: TextStyle(
                        color: isCheckedIn ? Colors.green : Colors.redAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Image.asset(
                Assets.email,
                height: 18,
                width: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  customer?.email?.isEmpty ?? true
                      ? 'N/A'
                      : customer!.email.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Image.asset(
                Assets.phone,
                height: 18,
                width: 18,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  customer?.phone?.isEmpty ?? true
                      ? 'N/A'
                      : customer!.phone.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade200, thickness: 1),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: CustomPopup(
              showArrow: true,
              content: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.confirmation_number,
                            size: 20, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          "Ticket Details",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTicketInfoRow(
                      Icons.category_outlined,
                      "Type",
                      ticket.ticketType ?? 'N/A',
                    ),
                    const SizedBox(height: 12),
                    _buildTicketInfoRow(
                      Icons.currency_exchange,
                      "Price",
                      "GHS ${ticket.payment!.amount ?? "0.0"}",
                    ),
                    const SizedBox(height: 12),
                    _buildTicketInfoRow(
                      Icons.local_offer_outlined,
                      "Coupon",
                      ticket.couponCode!.isEmpty || ticket.couponCode == null
                          ? 'N/A'
                          : ticket.couponCode!,
                    ),
                    const SizedBox(height: 12),
                    _buildTicketInfoRow(
                      Icons.shopping_cart_outlined,
                      "Quantity",
                      ticket.quantity == null
                          ? 'N/A'
                          : ticket.quantity.toString(),
                    ),
                    const SizedBox(height: 12),
                    _buildTicketInfoRow(
                      Icons.group_outlined,
                      "Squad Limit",
                      ticket.squadLimit == null
                          ? 'N/A'
                          : ticket.squadLimit.toString(),
                    ),
                  ],
                ),
              ),
              child: const Icon(
                Icons.info_outline,
                color: Colors.grey,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildTicketInfoRow(IconData icon, String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 18, color: Colors.grey.shade600),
      const SizedBox(width: 10),
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
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

_buildAttendanceCard(
  Customer? customer,
  bool isCheckedIn,
) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  customer!.name ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isCheckedIn
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isCheckedIn ? Icons.check_circle : Icons.cancel,
                  color: isCheckedIn ? Colors.green : Colors.red,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.email_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  customer.email ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  (customer.phone?.isEmpty ?? true) ? 'N/A' : customer.phone!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isCheckedIn ? 'Checked In' : 'Not Checked In',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isCheckedIn ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    ),
  );
}

class InfoRichText extends StatelessWidget {
  final String title;
  final String value;

  const InfoRichText({
    required this.title,
    required this.value,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "$title: ",
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.normal,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}
