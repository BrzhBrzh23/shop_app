import 'package:flutter/material.dart';
import 'package:shop_app/helpers/custom_route.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/orders_provider.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/product_detail.dart';
import 'package:shop_app/screens/products_overview.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/splashscreen.dart';
import 'package:shop_app/screens/user_products_screen.dart';

import 'models/product_model.dart';
import 'providers/auth.dart';
import 'providers/products_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (context) => Products('', [], ''),
          update: (context, value, previous) => Products(value.token,
              previous == null ? [] : previous.items, value.userId),
        ),
        ChangeNotifierProvider(
          create: (context) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (context) => Orders('', [], ''),
          update: (context, value, previous) => Orders(value.token,
              previous == null ? [] : previous.orders, value.userId),
        )
      ],
      child: Consumer<Auth>(builder: (context, auth, child) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            pageTransitionsTheme: PageTransitionsTheme(builders: {
              TargetPlatform.android: CustomPageTransitionBuilder(),
              TargetPlatform.iOS: CustomPageTransitionBuilder(),
            }),
            textTheme: TextTheme(headline6: TextStyle(color: Colors.white)),
            fontFamily: 'Lato',
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
          ),
          home: auth.isAuth
              ? ProductsOverview()
              : FutureBuilder(
                  future: auth.tryAutoLogIn(),
                  builder: ((context, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen()),
                ),
          routes: {
            ProductsOverview.routeName: (context) => ProductsOverview(),
            ProductDetail.routeName: (context) => ProductDetail(),
            CartScreen.routeName: (context) => CartScreen(),
            OrdersScreen.routeName: (context) => OrdersScreen(),
            UserProductsScreen.routeName: (context) => UserProductsScreen(),
            EditProduct.routeName: (context) => EditProduct(),
          },
        );
      }),
    );
  }
}
