import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final bool isDarkTheme;
  final int userID;
  final String username;
  final VoidCallback onProductUpdated;

  const ProductDetailPage({
    Key? key,
    required this.userID,
    required this.username,
    required this.product,
    required this.isDarkTheme,
    required this.onProductUpdated,
  }) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _editFormKey = GlobalKey<FormState>();

  // Form field controllers
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _sizeController;
  late TextEditingController _flavourController;

  List<dynamic> _reviews = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _initializeFormControllers();
    _fetchReviews(widget.product['id'].toString());
  }

  void _initializeFormControllers() {
    _nameController = TextEditingController(text: widget.product['name']);
    _descriptionController =
        TextEditingController(text: widget.product['description']);
    _priceController =
        TextEditingController(text: widget.product['price'].toString());
    _sizeController = TextEditingController(text: widget.product['size']);
    _flavourController = TextEditingController(text: widget.product['flavour']);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _sizeController.dispose();
    _flavourController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (_formKey.currentState?.validate() ?? false) {
      await _createReview(
        widget.product['id'].toString(),
        widget.userID,
        widget.username,
        _commentController.text,
      );
      _commentController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a valid comment')));
    }
  }

  Future<void> _createReview(
      String pizzaId, int userId, String username, String reviewText) async {
    final uri = Uri.parse('http://127.0.0.1:3000/reviews/create');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'pizza_id': pizzaId,
        'user_id': userId,
        'username': username,
        'review_text': reviewText,
      }),
    );

    if (response.statusCode == 201) {
      _fetchReviews(pizzaId); // Refresh reviews
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to create review')));
    }
  }

  Future<void> _fetchReviews(String pizzaId) async {
    final response =
        await http.get(Uri.parse('http://127.0.0.1:3000/reviews/get/$pizzaId'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        _reviews = jsonData;
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to fetch reviews')));
    }
  }

  Future<void> _editProduct() async {
    if (_editFormKey.currentState?.validate() ?? false) {
      final id = widget.product['id'];
      final name = _nameController.text;
      final description = _descriptionController.text;
      final price = double.tryParse(_priceController.text) ?? 0.0;
      final size = _sizeController.text;
      final flavour = _flavourController.text;

      final response = await http.put(
        Uri.parse('http://127.0.0.1:3000/pizzas/edit/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'description': description,
          'price': price,
          'size': size,
          'flavour': flavour,
        }),
      );

      if (response.statusCode == 200) {
        widget.onProductUpdated();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Pizza updated')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to update pizza')));
      }
    }
  }

  Future<void> _deleteProduct() async {
    final id = widget.product['id'];
    final response = await http.delete(
      Uri.parse('http://127.0.0.1:3000/pizzas/delete/$id'),
    );

    if (response.statusCode == 200) {
      widget.onProductUpdated();
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Pizza deleted')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to delete pizza')));
    }
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Product'),
        content: Form(
          key: _editFormKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(_nameController, 'Name'),
                SizedBox(height: 8),
                _buildTextField(_descriptionController, 'Description'),
                SizedBox(height: 8),
                _buildTextField(_priceController, 'Price',
                    keyboardType: TextInputType.number),
                SizedBox(height: 8),
                _buildTextField(_sizeController, 'Size'),
                SizedBox(height: 8),
                _buildTextField(_flavourController, 'Flavour'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: Text('Save Changes'),
            onPressed: () {
              Navigator.of(context).pop();
              _editProduct();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: label,
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a $label';
        }
        return null;
      },
    );
  }

  Widget _buildProductDetails(Color textColor, Color appBarColor) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              'http://127.0.0.1:3000/${widget.product['image']}',
              height: 300,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 16),
            Text(
              widget.product['name'],
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '\$${widget.product['price']}',
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16),
            _buildSectionTitle('Description', textColor),
            Text(
              widget.product['description'] ?? 'No description available.',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
            _buildSectionTitle('Size', textColor),
            Text(
              widget.product['size'] ?? 'No size available.',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
            _buildSectionTitle('Flavour', textColor),
            Text(
              widget.product['flavour'] ?? 'No flavour available.',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 24),
            _buildReviewForm(textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildReviewForm(Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Add a Review', textColor),
            SizedBox(height: 8),
            TextFormField(
              controller: _commentController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Write your review here',
                hintStyle: TextStyle(color: textColor),
              ),
              style: TextStyle(color: textColor),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a comment';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitComment,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsList(Color textColor) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Reviews', textColor),
            SizedBox(height: 16),
            _reviews.isEmpty
                ? Text(
                    'No reviews yet.',
                    style: TextStyle(color: textColor),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _reviews.length,
                    itemBuilder: (context, index) {
                      final review = _reviews[index];
                      return Card(
                        color: widget.isDarkTheme
                            ? Color(0xFF333333)
                            : Colors.white,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(8.0),
                          title: Text(
                            review['username'] ?? 'Unknown User',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            review['review_text'] ?? 'No review text.',
                            style: TextStyle(color: textColor),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        widget.isDarkTheme ? Color(0xFF121212) : Colors.white;
    final appBarColor = widget.isDarkTheme ? Color(0xFF1E1E1E) : Colors.white;
    final textColor = widget.isDarkTheme ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product['name'],
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: appBarColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.info_sharp, color: textColor)),
            Tab(icon: Icon(Icons.reviews_sharp, color: textColor)),
          ],
        ),
      ),
      body: Container(
        color: backgroundColor,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildProductDetails(textColor, appBarColor),
            _buildReviewsList(textColor),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showProductActions();
        },
        child: Icon(Icons.edit),
        backgroundColor: appBarColor,
      ),
    );
  }

  void _showProductActions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Actions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Product'),
              onTap: () {
                Navigator.of(context).pop();
                _showEditDialog();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete Product'),
              onTap: () {
                Navigator.of(context).pop();
                _deleteProduct();
              },
            ),
          ],
        ),
      ),
    );
  }
}
