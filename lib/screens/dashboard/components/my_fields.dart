import 'package:admin/screens/add_screen.dart';
// import 'package:admin/screens/dashboard/model/portfolio_model.dart';
import 'package:admin/screens/dashboard/view_model/cubit.dart';
import 'package:admin/screens/dashboard/view_model/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyFiles extends StatelessWidget {
  const MyFiles({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // PortfolioModel? portfolioModel;
    return BlocProvider(
      create: (context) => PortofolioCubit()..getAllDataPortofolio(),
      child: SingleChildScrollView(
          child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "My Portfolio",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ElevatedButton.icon(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.add),
                label: Text("Add New"),
              ),
            ],
          ),
          SizedBox(height: 16.0),
  BlocBuilder<PortofolioCubit, PortofolioState>(
  builder: (context, state) {
    final cubit = PortofolioCubit.get(context);

    if (state is PortofolioLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (state is PortofolioError) {
      return Center(
        child: Text(
          state.error,
          style: TextStyle(color: Colors.red),
        ),
      );
    }

      if(cubit.portfolioModel != null){
        if (cubit.portfolioModel!.data.isEmpty) {
        return Center(
          child: Text(
            'No data available',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        );
      }
      }

      
      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          // childAspectRatio: 4 / 2,
          mainAxisExtent: 400
        ),
        itemCount: cubit.portfolioModel!.data.length,
        itemBuilder: (context, index) {
          final item = cubit.portfolioModel!.data[index];
          return InkWell(
            onLongPress: () {
              cubit.deleteItem(item.id!,index);
            },
            child: Card(
              margin: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 300,
                    child: item.cover != null
                        ? Image.network(
                            item.cover!,
                            width: double.infinity,
                            
                            fit: BoxFit.cover,
                          )
                        : Icon(Icons.image_not_supported, size: 100),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title ?? 'No Title',
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          item.description ?? 'No Description',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    // حالة افتراضية
    // return Center(child: Text('Unexpected state'));
),

        ],
      )),
    );
  }
}
