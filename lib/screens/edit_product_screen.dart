import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/product_model.dart';

import '../providers/products_provider.dart';

class EditProduct extends StatefulWidget {
  static const routeName = '/edit-product';
  const EditProduct({super.key});

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final priceFocusNode = FocusNode();
  final descriptionFocusNode = FocusNode();
  final imageUrlController = TextEditingController();
  final imageUrlFocusNode = FocusNode();
  final form = GlobalKey<FormState>();
  var editedProduct = Product(
    id: '',
    title: '',
    price: 0,
    description: '',
    imageUrl: '',
  );
  var initValues = {
    'title': '',
    'price': '',
    'description': '',
    'imageUrl': '',
  };

  var isInit = true;
  var isLoading = false;

  @override
  void initState() {
    imageUrlFocusNode.addListener(updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInit = true) {
      final productId = ModalRoute.of(context)!.settings.arguments as String;
      if (productId != '') {
        editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        initValues = {
          'title': editedProduct.title,
          'description': editedProduct.description,
          'price': editedProduct.price.toString(),
        };
        imageUrlController.text = editedProduct.imageUrl;
      }
    }
    isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    imageUrlFocusNode.removeListener(updateImageUrl);
    descriptionFocusNode.dispose();
    priceFocusNode.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  void updateImageUrl() {
    if (!imageUrlFocusNode.hasFocus) {
      if ((imageUrlController.text.isEmpty) ||
              (!imageUrlController.text.startsWith('http') &&
                  !imageUrlController.text.startsWith('https'))
          // ||
          // ((!imageUrlController.text.endsWith('.png') &&
          //     !imageUrlController.text.endsWith('.jpeg') &&
          //     !imageUrlController.text.endsWith('jpg')))
          ) {
        return;
      }
      setState(() {});
    }
  }

  Future saveForm() async {
    final isValid = form.currentState!.validate();
    if (isValid) form.currentState!.save();
    setState(() {
      isLoading = true;
    });

    if (editedProduct.id != '') {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(editedProduct.id, editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(editedProduct);
      } catch (error) {
        await showDialog<Null>(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An error occured!'),
                  content: Text(error.toString()),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                ));
      } 
      // finally {
      //   setState(() {
      //     isLoading = false;
      //   });
      //   Navigator.pop(context);
      // }
    }
    setState(() {
      isLoading = false;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: () {
              saveForm();
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: isLoading == true
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                child: Form(
                    key: form,
                    child: ListView(
                      children: [
                        TextFormField(
                          initialValue: initValues['title'],
                          decoration: InputDecoration(
                            labelText: 'Title',
                          ),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(priceFocusNode);
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please provide a value';
                            }
                          },
                          onSaved: (value) => editedProduct = Product(
                            id: editedProduct.id,
                            isFavorite: editedProduct.isFavorite,
                            title: value!,
                            description: editedProduct.description,
                            price: editedProduct.price,
                            imageUrl: editedProduct.imageUrl,
                          ),
                        ),
                        TextFormField(
                          initialValue: initValues['price'],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Price',
                          ),
                          textInputAction: TextInputAction.next,
                          focusNode: priceFocusNode,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(descriptionFocusNode);
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please provide a value';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please provide a valid number';
                            }
                            if (double.parse(value) < 0) {
                              return 'Please provide a valid number';
                            }
                            return null;
                          },
                          onSaved: (value) => editedProduct = Product(
                            id: editedProduct.id,
                            isFavorite: editedProduct.isFavorite,
                            title: editedProduct.title,
                            description: editedProduct.description,
                            price: double.parse(value!),
                            imageUrl: editedProduct.imageUrl,
                          ),
                        ),
                        TextFormField(
                          initialValue: initValues['description'],
                          keyboardType: TextInputType.multiline,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Description',
                          ),
                          textInputAction: TextInputAction.next,
                          focusNode: descriptionFocusNode,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please provide a value';
                            }
                            if (value.length < 10) {
                              return 'Please enter full description, at least 10 character long';
                            }
                            return null;
                          },
                          onSaved: (value) => editedProduct = Product(
                            id: editedProduct.id,
                            isFavorite: editedProduct.isFavorite,
                            title: editedProduct.title,
                            description: value!,
                            price: editedProduct.price,
                            imageUrl: editedProduct.imageUrl,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              margin: EdgeInsets.only(top: 8, right: 10),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.grey),
                              ),
                              child: imageUrlController.text.isEmpty
                                  ? Text('Enter URL')
                                  : Image.network(
                                      imageUrlController.text,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            Expanded(
                              child: TextFormField(
                                onEditingComplete: () {
                                  setState(() {});
                                },
                                decoration:
                                    InputDecoration(labelText: 'Image URL'),
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.done,
                                controller: imageUrlController,
                                focusNode: imageUrlFocusNode,
                                onFieldSubmitted: (_) {
                                  updateImageUrl();
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please provide a value';
                                  }
                                  if (!value.startsWith('http') ||
                                      !value.startsWith('https')) {
                                    return 'Please enter valid URL';
                                  }
                                  // if (!value.endsWith('.png') ||
                                  //     !value.endsWith('.jpeg') ||
                                  //     !value.endsWith('jpg')) {
                                  //   return 'Please enter valid forman of Image';
                                  // }
                                  return null;
                                },
                                onSaved: (value) => editedProduct = Product(
                                  id: editedProduct.id,
                                  isFavorite: editedProduct.isFavorite,
                                  title: editedProduct.title,
                                  description: editedProduct.description,
                                  price: editedProduct.price,
                                  imageUrl: value!,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
              ),
            ),
    );
  }
}
