import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../models/ticket_request_success.dart';
import '../../models/user_model.dart';
import '../../requests/verifying_ticket.dart';
import '../../shared/services/sembast_service.dart';
import '../../shared/utils/assets.dart';
import '../../shared/utils/enums.dart';

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

  userFallback() async {
    final cachedData = await _sembastService.getUserResponse();
    debugPrint("userFallback icalled ${cachedData!.length}");
    if (cachedData.isNotEmpty) {
      loadCachedUserResponse(cachedData);
    } else {
      debugPrint("userFallback else ");
      setState(() {
        userStatus = UserStatus.loading;
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

  @override
  void initState() {
    super.initState();
    _getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.chevron_left,
              color: Theme.of(context).primaryColor,
              size: 38,
            )),
        elevation: 0,
        backgroundColor: Theme.of(context).canvasColor,
        centerTitle: true,
        title: Text(
          "History",
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: userStatus == UserStatus.loading
          ? _buildLoader()
          : userStatus == UserStatus.error
              ? _buildErrorWidget()
              : results != null
                  ? _buildUserList()
                  : _buildNoUserWidget(),
    );
  }

  _getAllUsers() {
    Future.microtask(() async {
      try {
        VerifyingTicketSingleton verifyingTicketSingleton =
            VerifyingTicketSingleton();
        userFallback();
        final results = await verifyingTicketSingleton.getAllUsers();
        if (results != null) {
          cacheUserResponse(results);
          setState(() {
            userStatus = UserStatus.success;
          });
        } else {
          final cachedData = await _sembastService.getUserResponse();
          debugPrint("result is null ${cachedData!.length}");
          if (cachedData.isNotEmpty) {
            loadCachedUserResponse(cachedData);
          } else {
            setState(() {
              userStatus = UserStatus.error;
            });
          }
        }
      } catch (e) {
        debugPrint("getAllUsers error ${e.toString()} ");
        final cachedData = await _sembastService.getUserResponse();
        debugPrint("result is null ${cachedData!.length}");
        if (cachedData.isNotEmpty) {
          loadCachedUserResponse(cachedData);
        } else {
          setState(() {
            userStatus = UserStatus.error;
          });
        }
      }
    });
  }

  _buildUserList() {
    return Column(
      children: [
        _buildCheckedTotalWidget(results),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.84,
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: results!.results.length,
            itemBuilder: (context, index) {
              final ticket = results!.results[index];
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

_buildCheckedTotalWidget(UserResponse? results) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total Checked-in Users',
          style: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Text(
          "${results!.checkedInCount.toString()}/${results.totalCount.toString()}",
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
                      // Text(
                      //   "Ticket Type: ${ticket.ticketType ?? 'N/A'}",
                      //   style: const TextStyle(
                      //       color: Colors.black,
                      //       fontWeight: FontWeight.bold,
                      //       fontSize: 14),
                      // ),
                      // Text(
                      //   "Price: GHS ${ticket.payment!.amount ?? "0.0"}",
                      //   style: const TextStyle(
                      //       color: Colors.black,
                      //       fontWeight: FontWeight.bold,
                      //       fontSize: 14),
                      // ),
                      // Text(
                      //   "Coupon Code: ${ticket.couponCode!.isEmpty || ticket.couponCode == null ? 'N/A' : ticket.couponCode}",
                      //   style: const TextStyle(
                      //       color: Colors.black,
                      //       fontWeight: FontWeight.bold,
                      //       fontSize: 14),
                      // ),
                      // Text(
                      //   "Quantity : ${ticket.quantity.toString() ?? 'N/A'}",
                      //   style: const TextStyle(
                      //       color: Colors.black,
                      //       fontWeight: FontWeight.bold,
                      //       fontSize: 14),
                      // ),

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
                        value: ticket.quantity.toString() ?? 'N/A',
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
