import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mcc_frontend/pages/detail_page.dart';
import 'package:path/path.dart' as p;
import 'package:mime/mime.dart';
import 'dart:convert';
import 'dart:typed_data';

class AllProductsPage extends StatefulWidget {
  final bool isDarkTheme;
  final String username;
  final int userID;

  const AllProductsPage(
      {Key? key,
      required this.isDarkTheme,
      required this.username,
      required this.userID})
      : super(key: key);

  @override
  _AllProductsPageState createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  List _products = [];
  bool _isLoading = true;

  Future<void> _fetchProducts() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:3000/pizzas/'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        _products = jsonData;
        _isLoading = false;
      });
    } else {
      // Handle errors
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _addNewProduct() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String name = '';
        String description = '';
        double price = 0.0;
        String size = '';
        String category = '';
        String flavour = '';
        XFile? image;
        String? base64Image;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add New Product'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(labelText: 'Name'),
                      onChanged: (value) => name = value,
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Description'),
                      onChanged: (value) => description = value,
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>
                          price = double.tryParse(value) ?? 0.0,
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Size'),
                      onChanged: (value) => size = value,
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Flavour'),
                      onChanged: (value) => flavour = value,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      child: Text('Upload Image'),
                      onPressed: () async {
                        final pickedFile = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          final bytes = await pickedFile.readAsBytes();
                          setState(() {
                            image = pickedFile;
                            base64Image = base64Encode(bytes);
                          });
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    base64Image != null
                        ? Image.memory(
                            base64Decode(base64Image!),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : Text('No image selected'),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text('Add'),
                  onPressed: () async {
                    if (name.isNotEmpty &&
                        description.isNotEmpty &&
                        price > 0 &&
                        size.isNotEmpty &&
                        flavour.isNotEmpty &&
                        image != null) {
                      await _createProduct(
                          name, description, price, size, image!, flavour);
                      _fetchProducts();
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _createProduct(String name, String description, double price,
      String size, XFile image, String flavour) async {
    final uri = Uri.parse('http://127.0.0.1:3000/pizzas/create');
    final request = http.MultipartRequest('POST', uri);

    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['price'] = price.toString();
    request.fields['size'] = size;
    request.fields['flavour'] = flavour;

    final mimeTypeData =
        lookupMimeType(image.path, headerBytes: [0xFF, 0xD8])?.split('/');
    final imageFile = await http.MultipartFile.fromBytes(
      'image',
      await image.readAsBytes(),
      filename: image.name,
      contentType: mimeTypeData != null
          ? MediaType(mimeTypeData[0], mimeTypeData[1])
          : null,
    );

    request.files.add(imageFile);

    final response = await request.send();

    if (response.statusCode == 201) {
      print('New pizza successfully created');
    } else {
      print('Failed to create pizza: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = widget.isDarkTheme;
    final backgroundColor = isDarkTheme ? Color(0xFF121212) : Colors.white;
    final appBarColor = isDarkTheme ? Color(0xFF1E1E1E) : Colors.white;
    final containerColor = isDarkTheme ? Color(0xFF242424) : Colors.white;
    final textColor = isDarkTheme ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkTheme ? Colors.grey[300] : Colors.black54;

    return Scaffold(
      appBar: AppBar(
        title: Text('List Pizza',
            style: TextStyle(
                color: Color.fromARGB(255, 245, 245, 245),
                fontWeight: FontWeight.bold)),
        backgroundColor: Color.fromARGB(255, 39, 39, 39),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : buildProductsList(
              backgroundColor, appBarColor, containerColor, textColor),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewProduct,
        child: Icon(Icons.add),
        backgroundColor: appBarColor,
        elevation: 4,
      ),
    );
  }

  Widget buildProductsList(Color backgroundColor, Color appBarColor,
      Color containerColor, Color textColor) {
    return Container(
      color: backgroundColor,
      child: Column(
        children: [
          buildTitleRow(textColor),
          buildProductsGrid(appBarColor, containerColor, textColor),
        ],
      ),
    );
  }

  Widget buildTitleRow(Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
    );
  }

  Widget buildProductsGrid(
      Color appBarColor, Color containerColor, Color textColor) {
    return Expanded(
      child: GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) =>
            buildProductCard(index, appBarColor, containerColor, textColor),
      ),
    );
  }

  Widget buildProductCard(
      int index, Color appBarColor, Color containerColor, Color textColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              product: _products[index],
              userID: widget.userID,
              username: widget.username,
              isDarkTheme: widget.isDarkTheme,
              onProductUpdated: _fetchProducts,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Expanded(
                child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                image: DecorationImage(
                  image: NetworkImage(
                      'http://127.0.0.1:3000/${_products[index]['image']}'),
                  fit: BoxFit.contain,
                ),
              ),
            )),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _products[index]['name'],
                    style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '\$${_products[index]['price']}',
                    style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _products[index]['size'],
                    style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
