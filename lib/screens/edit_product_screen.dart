import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import '../providers/product.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _form = GlobalKey<FormState>();

  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();

  var _editedProduct = Product(
    id: null,
    title: "",
    price: 0,
    description: "",
    imageUrl: "",
  );

  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  var _isInit = true;
  var isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct = Provider.of<Products>(context).findById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
//          'imageUrl': _editedProduct.imageUrl,
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('png') &&
              !_imageUrlController.text.endsWith("jpg") &&
              !_imageUrlController.text.endsWith("jpeg"))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      isLoading = true;
    });

    if (_editedProduct.id != null) {
      //editing
      await Provider.of<Products>(context)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      //adding
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text("Error Occured"),
                  content: Text("Something went wrong."),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Ok"),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    )
                  ],
                ));
      } 
      // finally {
      //   setState(() {
      //     isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    }
    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _saveForm();
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: InputDecoration(labelText: "Title"),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide a value.';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      //will allow user to move to the next text
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            title: value,
                            price: _editedProduct.price,
                            description: _editedProduct.description,
                            imageUrl: _editedProduct.imageUrl,
                            isFavourite: _editedProduct.isFavourite);
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      decoration: InputDecoration(
                        labelText: "Price",
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please enter a price.";
                        }
                        if (double.tryParse(value) == null) {
                          return "Please enter a valid number.";
                        }
                        if (double.parse(value) <= 0) {
                          return "Please enter a number greater than zero.";
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            price: double.parse(value),
                            description: _editedProduct.description,
                            imageUrl: _editedProduct.imageUrl,
                            isFavourite: _editedProduct.isFavourite);
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration: InputDecoration(
                        labelText: "Description",
                      ),
                      maxLines: 3,
                      focusNode: _descriptionFocusNode,
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please enter a description";
                        }
                        if (value.length < 10) {
                          return "Should be atleast 10 characters";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            price: _editedProduct.price,
                            description: value,
                            imageUrl: _editedProduct.imageUrl,
                            isFavourite: _editedProduct.isFavourite);
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Text("Enter a URL")
                              : FittedBox(
                                  child:
                                      Image.network(_imageUrlController.text),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: "Image URL"),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Please enter an image Url";
                              }
                              if (!value.startsWith('http') ||
                                  !value.startsWith('https')) {
                                return "Please enter a valid URL";
                              }
                              if (!value.endsWith('png') &&
                                  !value.endsWith("jpg") &&
                                  !value.endsWith("jpeg")) {
                                return "Please enter a valid image URL";
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            onSaved: (value) {
                              _editedProduct = Product(
                                  id: _editedProduct.id,
                                  title: _editedProduct.title,
                                  price: _editedProduct.price,
                                  description: _editedProduct.description,
                                  imageUrl: value,
                                  isFavourite: _editedProduct.isFavourite);
                            },
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
