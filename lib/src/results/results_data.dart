import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:convert';
import '../../models/ticket_request_success.dart';

class ResultsData extends StatefulWidget {
  final TicketSuccessResponse? successResponse;
  final Barcode? result;  
  const ResultsData({super.key, required this.successResponse,required this.result});

  @override
  State<ResultsData> createState() => _ResultsDataState();
}

class _ResultsDataState extends State<ResultsData> {




  @override
  Widget build(BuildContext context) {
    String base64String = widget.successResponse?.qrCodeBase64 ?? '';
    Image? qrImage;
    if (base64String.isNotEmpty) {
      qrImage = convertBase64StringToImage(base64String.split(',')[1]);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: base64String.isNotEmpty == true
            ? _buildSuccessCard(qrImage)
            : _buildErrorCard(context),
      ),
    );
  }

  Widget _buildSuccessCard(Image? qrImage) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // QR Code
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SizedBox(
                height: 120,
                width: 120,
                child: Center(child: qrImage),
              ),
            ),
            const SizedBox(height: 24),

            // Ticket Type
            Text(
              widget.successResponse?.ticketType ?? "Ticket Type",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    widget.successResponse?.payment?.status?.toUpperCase() ??
                        'VERIFIED',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Customer Details Section
            _buildSectionTitle('Customer Details'),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.person_outline,
              'Name',
              widget.successResponse?.customer?.name ?? 'N/A',
            ),
            _buildInfoRow(
              Icons.phone_outlined,
              'Phone',
              widget.successResponse?.customer?.phone ?? 'N/A',
            ),
            _buildInfoRow(
              Icons.email_outlined,
              'Email',
              widget.successResponse?.customer?.email ?? 'N/A',
            ),
            const SizedBox(height: 24),

            // Ticket Details Section
            _buildSectionTitle('Ticket Details'),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.confirmation_number_outlined,
              'Reference',
              widget.successResponse?.payment?.reference ?? 'N/A',
            ),
            _buildInfoRow(
              Icons.shopping_cart_outlined,
              'Quantity',
              widget.successResponse?.quantity.toString() ?? '0',
            ),
            _buildInfoRow(
              Icons.group_outlined,
              'Squad Limit',
              widget.successResponse?.squadLimit.toString() ?? '0',
            ),
            const SizedBox(height: 32),

            // Price Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "GHS ${widget.successResponse?.payment?.amount ?? '0'}",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.confirmation_number,
                    color: Theme.of(context).primaryColor,
                    size: 32,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            "Error Verifying Ticket",
            style: TextStyle(
              color: Colors.red,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Please ensure the QR code is valid and try again",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}



Image convertBase64StringToImage(String base64String) {
  Uint8List decodedBytes = base64.decode(base64String);
  return Image.memory(decodedBytes);
}