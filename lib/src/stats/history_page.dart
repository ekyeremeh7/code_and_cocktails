import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../models/ticket_model.dart';
import '../../models/ticket_request_success.dart';
import '../../models/user_model.dart';
import '../../requests/verifying_ticket.dart';
import '../../shared/services/sembast_service.dart';
import '../../shared/utils/assets.dart';
import '../../shared/utils/constants.dart';
import '../../shared/utils/debouncer.dart';
import '../../shared/utils/enums.dart';
import '../../shared/utils/helper.dart';
import '../../shared/utils/helper.dart';
import '../../shared/utils/styled_toast/selected_toast.dart';
import 'history_page_search.dart';

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
  bool showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool? _isCheckedIn;

  final Debouncer _debouncer =
      Debouncer(delay: const Duration(milliseconds: 800));

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
      filteredResults = results!.results.where((ticket) {
        final nameMatches = ticket.customer?.name
                ?.toLowerCase()
                .contains(query.toLowerCase()) ??
            false;

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

        return nameMatches && statusMatches;
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
    // _searchController.removeListener(_onSearchChanged);
    // _searchController.dispose();
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
          title: showSearch == true
              ? FadeInRight(
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.048,
                    child: TextFormField(
                      cursorColor: Colors.black,
                      controller: _searchController,
                      style: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'Manrope',
                          fontSize: 15),
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
                        if (value.isEmpty) {
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
                )
              : FadeInLeft(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          color: Theme.of(context).primaryColor,
                        ),
                        Text(
                          'History',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
          actions: [
            // showSearch == false
            //     ? InkWell(
            //         onTap: () {
            //           setState(() {
            //             showSearch = !showSearch;
            //           });
            //         },
            //         child: const Padding(
            //           padding: EdgeInsets.only(right: 8.0),
            //           child: Icon(
            //             Icons.search,
            //             size: 29,
            //           ),
            //         ),
            //       )
            //     : InkWell(
            //         onTap: () {
            //           setState(() {
            //             showSearch = !showSearch;
            //           });
            //         },
            //         child: Padding(
            //           padding: const EdgeInsets.only(right: 14.0),
            //           child: Container(
            //             height: 25,
            //             width: 25,
            //             decoration: BoxDecoration(
            //                 color: Colors.red,
            //                 borderRadius: BorderRadius.circular(60)),
            //             child: const Icon(
            //               Icons.close_outlined,
            //               color: Colors.white,
            //               size: 23,
            //             ),
            //           ),
            //         ),
            //       ),
          
          ],
        ),
        body: Column(
          children: [
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: HistoryPageSearch(onSearch: _onSearch),
            // ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Radio<bool?>(
                    value: null,
                    groupValue: _isCheckedIn,
                    onChanged: (value) async {
                      setState(() {
                        _isCheckedIn = value;
                      });
                      await _getAllUsers(context);
                      _onSearch(_searchController.text, _isCheckedIn);
                    },
                  ),
                  const Text('All'),
                  Radio<bool?>(
                    value: true,
                    groupValue: _isCheckedIn,
                    onChanged: (value) async {
                      filteredResults.clear();
                      setState(() {
                        _isCheckedIn = value;
                      });
                      _onSearch(_searchController.text, _isCheckedIn);
                    },
                  ),
                  const Text('Checked In'),
                  Radio<bool?>(
                    value: false,
                    groupValue: _isCheckedIn,
                    onChanged: (value) {
                      filteredResults.clear();
                      setState(() {
                        _isCheckedIn = value;
                      });
                      _onSearch(_searchController.text, _isCheckedIn);
                    },
                  ),
                  const Text('Not Checked In'),
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
        debugPrint(
            "server data first ${serverData.first.sId}Cached data first ${cachedData.first.sId}");
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
    return Column(
      children: [
        _buildCheckedTotalWidget(results, filteredResults, _isCheckedIn),
        Expanded(
          // height: MediaQuery.of(context).size.height * 0.84,
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: filteredResults.isEmpty
                ? results!.results.length
                : filteredResults.length,
            itemBuilder: (context, index) {
              final ticket = filteredResults.isEmpty
                  ? results!.results[index]
                  : filteredResults[index];
              final customer = ticket.customer;
              bool isCheckedIn = ticket.checkedIn ?? false;

              return _buildUser(customer, isCheckedIn, ticket);

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

_buildCheckedTotalWidget(UserResponse? results,
    List<TicketSuccessResponse> filteredList, bool? isCheckedIn) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isCheckedIn == null
              ? "All Users"
              : isCheckedIn
                  ? 'Checked-In Users'
                  : 'Not Checked Users',
          style: const TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Text(
          isCheckedIn == null
              // ? "${results!.results.length}/${results.results.length}"
              ? "${results!.results.length}"
              : "${filteredList.isNotEmpty ? filteredList.length : results!.checkedInCount.toString()}/${results!.totalCount.toString()}",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        )
      ],
    ),
  );
}

_buildUser(
  Customer? customer,
  bool isCheckedIn,
  TicketSuccessResponse ticket,
) {
  return Card(
    elevation: 0.0,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              customer?.name.toString() ?? "No name",
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  Image.asset(
                    Assets.email,
                    height: 18,
                    width: 18,
                  ),
                  const SizedBox(width: 8),
                  if (customer!.email != null)
                    Expanded(
                      child: Text(
                        customer.email!.isEmpty || customer.email == null
                            ? 'N/A'
                            : customer.email.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  if (customer.email == null)
                    const Expanded(
                      child: Text(
                        'N/A',
                        style: TextStyle(
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
                  Image.asset(
                    Assets.phone,
                    height: 18,
                    width: 18,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  if (customer.phone != null)
                    Text(
                      customer.phone!.isEmpty || customer.phone == null
                          ? 'N/A'
                          : customer.phone.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  if (customer.phone == null)
                    const Text(
                      'N/A',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          ),
          const SizedBox(
            height: 4,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    isCheckedIn ? "Checked In" : "Not Checked In",
                    style: TextStyle(
                      color: isCheckedIn ? Colors.green : Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    width: 2,
                  ),
                  Icon(
                    isCheckedIn ? Icons.check_circle : Icons.cancel,
                    color: isCheckedIn ? Colors.green : Colors.redAccent,
                    size: 18,
                  ),
                ],
              ),
              CustomPopup(
                showArrow: true,
                content: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Ticket Info",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      InfoRichText(
                        title: "Ticket Type",
                        value: ticket.ticketType ?? 'N/A',
                      ),
                      const SizedBox(height: 4),
                      InfoRichText(
                        title: "Price",
                        value: "GHS ${ticket.payment!.amount ?? "0.0"}",
                      ),
                      const SizedBox(height: 4),
                      InfoRichText(
                        title: "Coupon Code",
                        value: ticket.couponCode!.isEmpty ||
                                ticket.couponCode == null
                            ? 'N/A'
                            : ticket.couponCode!,
                      ),
                      const SizedBox(height: 4),
                      InfoRichText(
                        title: "Quantity",
                        value: ticket.quantity == null
                            ? 'N/A'
                            : ticket.quantity.toString(),
                      ),
                      const SizedBox(height: 4),
                      InfoRichText(
                        title: "Squad Limit",
                        value: ticket.squadLimit == null
                            ? 'N/A'
                            : ticket.squadLimit.toString(),
                      ),
                    ]),
                child: const Icon(
                  Icons.info,
                  color: Colors.grey,
                  size: 25,
                ),
              )
            ],
          ),
        ],
      ),
    ),
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
                  customer!.email ?? '',
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
              Text(
                customer.phone ?? 'N/A',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
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
