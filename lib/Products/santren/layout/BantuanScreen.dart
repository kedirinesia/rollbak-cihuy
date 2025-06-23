import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class BantuanScreen extends StatefulWidget {
  const BantuanScreen({super.key});

  @override
  State<BantuanScreen> createState() => _BantuanScreenState();
}

class _BantuanScreenState extends State<BantuanScreen> {
  List<dynamic> customerServices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCustomerServices();
  }

  Future<void> fetchCustomerServices() async {
    final response = await http.get(
  Uri.parse('https://santren-app.findig.id/api/v1/cs/list/public'),
  headers: {
    'merchantcode': '66f3c061b83af34d76ec85e3',  
    'Accept': 'application/json',             
  },
);

      print('Response: ${response.body}'); 

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        customerServices = data['data'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil data customer service')),
      );
    }
  }

  void _launchUrl(BuildContext context, String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Customer Services'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '\nHubungi Layanan Support Dengan klik tombol dibawah ini:',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : customerServices.isNotEmpty
                      ? ListView.separated(
                          itemCount: customerServices.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final item = customerServices[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 2,
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: item["icon"] != ""
                                      ? Image.network(
                                          item["icon"],
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.support_agent, size: 40, color: Colors.grey),
                                        )
                                      : const Icon(Icons.support_agent, size: 40, color: Colors.grey),
                                ),
                                title: Text(
                                  item["title"] ?? '-',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                subtitle: Text(
                                  item["contact"] ?? '-',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                ),
                                trailing: item["link"] != "."
                                    ? IconButton(
                                        icon: const Icon(Icons.chat_bubble, color: Colors.blue, size: 28),
                                        tooltip: "Hubungi via ${item["title"]}",
                                        onPressed: () => _launchUrl(context, item["link"] ?? ''),
                                      )
                                    : null,
                              ),
                            );
                          },
                        )
                      : const Center(child: Text('Data tidak ditemukan')),
            ),
          ],
        ),
      ),
    );
  }
}
