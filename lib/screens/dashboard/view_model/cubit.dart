import 'dart:developer';
import 'package:admin/core/dio_helper.dart';
import 'package:admin/screens/dashboard/model/portfolio_model.dart';
import 'package:admin/screens/dashboard/view_model/state.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PortofolioCubit extends Cubit<PortofolioState> {
  PortfolioModel? portfolioModel;

  PortofolioCubit() : super(PortofolioInitial());

  static PortofolioCubit get(context) => BlocProvider.of(context);
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController subservice = TextEditingController();
  TextEditingController valueText = TextEditingController();
  String? type;
  List<Map<String, String>> contentData = [];
  String? selectedType;
  String? selectedCover;
  bool isMost = false;
  String? dateTime;
  init(Data data) {
    title.text = data.title ?? "";
    description.text = data.description ?? "";
    subservice.text = data.subservice ?? "";
    type = data.type;
    selectedCover = data.cover;
    isMost = data.isMost == 1;
    contentData.addAll(data.content!
        .map((e) => Content(type: e.type, value: e.value).toJson()));
    emit(InitItemDetailsState());
  }

  Future<FilePickerResult?> pickMedia(BuildContext context,
      {bool isImage = true}) async {
    try {
      // showDialog(context: context, builder: (context) {
      //   return Center(child: CircularProgressIndicator(),);
      // },);
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: isImage ? FileType.image : FileType.video,
        allowMultiple: false,
      );

      return result;
    } catch (e) {
      log(e.toString());
      // Navigator.pop(context);
      return null;
    }
  }

  Future<String?> uploadMedia(BuildContext context,
      {bool isImage = true}) async {
    FilePickerResult? result = await pickMedia(context, isImage: isImage);
    BuildContext? contextt;
    if (result != null) {
      try {
        final dio = Dio();
        var formData;

        // Check if we're on the web platform
        if (kIsWeb) {
          // For web, use the `bytes` property
          formData = FormData.fromMap({
            "folder_name": "portfolio_" + selectedType!,
            "file": MultipartFile.fromBytes(
              result.files.single.bytes!,
              filename: result.files.single.name,
            ),
          });
        } else {
          // For mobile/desktop, use the `path` property
          formData = FormData.fromMap({
            "folder_name": "portfoio_" + selectedType!,
            "file": await MultipartFile.fromFile(
              result.files.single.path!,
              filename: result.files.single.name,
            ),
          });
        }
        showDialog(
          context: context,
          barrierDismissible: false, // Prevent dismissal by tapping outside
          builder: (context) {
            contextt = context;
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );
        var response = await dio.post("https://orikvision.com/backend/upload",
            data: formData);
        // selectedCover = response.data['file_url'].toString();
        print(response.data);

        return response.data['file_url'].toString();
      } catch (e) {
        log(e.toString());
        return null;
      } finally {
        Navigator.pop(contextt!);
      }
    } else {
      return null;
    }
  }

  getAllDataPortofolio() async {
    emit(PortofolioLoading()); // حالة تحميل البيانات
    try {
      var queryParameters = {
        "table_name": 'portfolios',
        // "type": '',
      };
      final Response response = await DioHelper.getData(
        url: 'https://orikvision.com/backend/get_data',
        queryParameters: queryParameters,
      );

      portfolioModel = PortfolioModel.fromJson(response.data);
      log(response.data.toString());

      emit(PortofolioLoaded());
    } on DioException catch (e) {
      log(e.message.toString());
      emit(PortofolioError(e.message.toString()));
    }
  }

  chooseCover(context) async {
    try {
      selectedCover = await uploadMedia(context);
      emit(ChooseCoverState());
    } catch (e) {}
  }

  addDataContent(context) async {
    if (selectedType != null) {
      final String? value = selectedType == "text"
          ? valueText.text.trim()
          : await uploadMedia(context, isImage: selectedType == "image");
      if (value != null) {
        contentData.add({
          "type": selectedType!,
          "value": value,
        });
        emit(AddNewItemState());
      } else {}
    } else {}
  }

  removeContentIndex(e) {
    contentData.removeAt(contentData.indexOf(e));
    emit(RemoveContentIndexState());
  }

  changeIsMost() {
    isMost = !isMost;
    emit(RemoveContentIndexState());
  }

  chooseDate(context) async {
    final DateTime? date = await showDatePicker(
        context: context, firstDate: DateTime.now(), lastDate: DateTime(2030));
    if (date != null) {
      dateTime =
          "${date.toUtc().year.toString().padLeft(4, '0')}-${date.toUtc().month.toString().padLeft(2, '0')}-${date.toUtc().day.toString().padLeft(2, '0')}";
      ;
      emit(ChooseCoverState());
    }
  }

  Future<void> addItem({required BuildContext context}) async {
    emit(PortofolioLoading());
    if (this.selectedCover == null ||
        subservice.text.isEmpty ||
        dateTime == null ||
        type == null ||
        contentData.isEmpty) {
      return;
    }
    BuildContext? contextt;
    try {
      showDialog(
        context: context,
        builder: (context) {
          contextt = context;
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      final response = await DioHelper.postData(
        url: 'https://orikvision.com/backend/add_item',
        data: {
          "title": title.text.isEmpty ? null : title.text.trim(),
          "description":
              description.text.isEmpty ? null : description.text.trim(),
          "subservice": subservice.text.trim(),
          "type": type,
          "isMost": isMost,
          "cover": selectedCover,
          "data": contentData,
          "date_time": dateTime,
          "table_name": "portfolios",
        },
      );

      if (response.statusCode == 200 && response.data['status']) {
        // log('Item added successfully: ${newData.toString()}');
        title.text = '';
        description.text = '';
        subservice.text = '';
        dateTime = null;
        type = null;
        this.selectedCover = null;
        contentData.clear();
        contentData = [];
        emit(PortofolioLoaded());
      } else {
        emit(PortofolioError(response.data['message'] ?? 'Error adding item'));
      }
    } catch (error) {
      log('Error adding item: $error');
      emit(PortofolioError(error.toString()));
    } finally {
      Navigator.pop(contextt!);
    }
  }

  Future<void> deleteItem(int id, int index) async {
    try {
      // Remove the item locally
      portfolioModel!.data.removeAt(index);
      emit(ChooseCoverState());

      // Dio configuration
      final dio = Dio(
        BaseOptions(
          headers: {'Content-Type': 'application/json'},
          // connectTimeout: Duration(milliseconds: 5000), // 5 seconds
          // receiveTimeout: Duration(milliseconds: 5000),
        ),
      );

      // Log the request
      log("Sending delete request with data: {\"table_name\": \"portfolios\", \"id\": $id}");

      // API call
      final response = await dio.delete(
        "https://orikvision.com/backend/delete_item",
        data: {
          "table_name": "portfolios",
          "id": id,
        },
      );

      // Log the response
      log("Response: ${response.data.toString()}");

      // Handle success
      if (response.statusCode == 200) {
        log("Item deleted successfully");
      } else {
        log("Failed to delete item: ${response.statusMessage}");
      }
    } catch (e) {
      // Handle errors
      log("Error: $e");
    }
  }
}
