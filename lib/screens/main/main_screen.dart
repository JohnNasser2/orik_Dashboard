import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/side_menu.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: SideMenu(), // SideMenu for all pages
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display SideMenu only for large screen
            if (Responsive.isDesktop(context))
              Expanded(
                child: SideMenu(), // SideMenu on the left
              ),
            Expanded(
              flex: 5,
              child: Navigator(
                onGenerateRoute: (settings) {
                  // Define the routes for the pages you want to navigate to
                  switch (settings.name) {
                    case '/':
                      return MaterialPageRoute(builder: (context) => DashboardScreen());
                    // Add more routes here as needed
                    default:
                      return MaterialPageRoute(builder: (context) => DashboardScreen());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
