import 'package:admin/constants.dart';
import 'package:admin/screens/dashboard/view_model/cubit.dart';
import 'package:admin/screens/dashboard/view_model/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({Key? key}) : super(key: key);

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _formKey = GlobalKey<FormState>();

  // متغيرات البيانات
  // String title = '';
  // String description = '';
  // String subservice = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
      ),
      body: BlocConsumer<PortofolioCubit, PortofolioState>(
        listener: (context, state) {
          if (state is PortofolioLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Item added successfully!')),
            );
            Navigator.pop(context);
          } else if (state is PortofolioError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          if (state is PortofolioLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          var cubit = PortofolioCubit.get(context);
          return LayoutBuilder(
            builder: (context, constraints) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // حقل العنوان
                    TextField(
                      decoration: const InputDecoration(labelText: 'Title'),
                      controller: cubit.title,
                    ),
                    const SizedBox(height: 10),

                    // حقل الوصف
                    TextField(
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      controller: cubit.description,
                    ),
                    const SizedBox(height: 10),

                    // حقل نوع الخدمة الفرعية
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Subservice *'),
                      controller: cubit.subservice,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter a subservice'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    if (cubit.selectedType == 'text')
                      TextField(
                        decoration:
                            const InputDecoration(labelText: 'Content Value *'),
                        controller: cubit.valueText,
                      ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        cubit.changeIsMost();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Set to both (Portfolios & Home page)?',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              )),
                          Expanded(
                            child:
                                Checkbox(value: cubit.isMost, onChanged: null),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildDropdownField(
                      value: cubit.type ?? 'choose type *',
                      items: ['drafting', 'rendering', 'cgi'],
                      onChanged: (newValue) {
                        setState(() {
                          cubit.type = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildDropdownField(
                      value: cubit.selectedType ?? 'choose value type *',
                      items: ['text', 'image', 'video'],
                      onChanged: (newValue) {
                        setState(() {
                          cubit.selectedType = newValue;
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 20),
                      child: ElevatedButton(
                        // style: ButtonStyle(
                        //     overlayColor: WidgetStatePropertyAll(secondaryColor),
                        //     backgroundColor:
                        //         WidgetStatePropertyAll(secondaryColor)),
                        onPressed: () {
                          cubit.addDataContent(context);
                        },
                        child: const Text(
                          'Add Index',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      children: cubit.contentData
                          .map(
                            (e) => InkWell(
                              onLongPress: () {
                                cubit.removeContentIndex(e);
                              },
                              child: Container(
                                width: constraints.maxWidth / 4,
                                height: constraints.maxWidth / 4,
                                padding: const EdgeInsets.all(10.0),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(25)),
                                child: e['type'].toString() == "text"
                                    ? Expanded(
                                        child: Text(
                                        e['value'].toString(),
                                        style: TextStyle(color: Colors.white),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ))
                                    : Image.network(e['value'].toString()),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 100),

                    ElevatedButton(
                      onPressed: () {
                        cubit.chooseCover(context);
                      }, // استدعاء وظيفة اختيار الصورة
                      child: const Text(
                        'Pick Cover Image *',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // زر الإرسال
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          // طباعة البيانات للتأكد

                          // استدعاء الكيوبت لإضافة البيانات
                          PortofolioCubit.get(context)
                              .addItem(context: context);
                        } else {
                          print("empty");
                        }
                      },
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required void Function(String?)? onChanged,
  }) {
    return Container(
      width: double.infinity,
      height: 35,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 50),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: PopupMenuButton<String>(
        color: bgColor,
        child: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        itemBuilder: (context) {
          return items.map((item) {
            return PopupMenuItem(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            );
          }).toList();
        },
        onSelected: (value) {
          if (onChanged != null) onChanged(value);
        },
      ),
    );
  }
}
