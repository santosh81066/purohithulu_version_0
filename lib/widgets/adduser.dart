import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../model/categories.dart';
import 'text_widget.dart';

import '../controller/apicalls.dart';
import '../functions/flutterfunctions.dart';

import 'button.dart';
import 'insertpan.dart';
import 'insertprofile.dart';

class AddUser extends StatefulWidget {
  const AddUser({
    Key? key,
    this.mobileNo,
    this.userName,
    this.languages,
    this.adharId,
    this.languagesHint,
    this.mobileHint,
    this.userNameHint,
    this.panId,
    this.buttonName,
    this.scaffoldMessengerKey,
    this.description,
  }) : super(key: key);
  final TextEditingController? mobileNo;
  final TextEditingController? userName;
  final TextEditingController? languages;

  final TextEditingController? description;
  final String? panId;
  final String? adharId;
  final String? mobileHint;
  final String? userNameHint;
  final String? languagesHint;
  final String? buttonName;

  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    widget.mobileNo!.dispose();
    widget.userName!.dispose();
    widget.languages!.dispose();

    widget.description!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var flutterFunctions = Provider.of<FlutterFunctions>(context);
    var apicalls = Provider.of<ApiCalls>(context, listen: false);
    final ScaffoldMessengerState scaffoldKey =
        widget.scaffoldMessengerKey!.currentState as ScaffoldMessengerState;
    List<List<TextEditingController>> prices = List.generate(
      apicalls.categorieModel!.data!.length,
      (mainindex) {
        var subcatCount =
            apicalls.categorieModel!.data![mainindex].subcat!.length;
        return List.generate(
          subcatCount + 1, // add one for the main category price
          (subindex) => TextEditingController(),
        );
      },
    );
    List<TextEditingController> flattenedPrices =
        prices.expand((prices) => prices).toList();
    // String? errorMessage =
    //     apicalls.validateForm(flattenedPrices, apicalls.selectedCatId);
    List<Data> filteredCategories =
        apicalls.categorieModel!.data!.where((category) {
      // return true if the category meets the filter condition, false otherwise
      return category.cattype != "e"; // replace with your own filter condition
    }).toList();

    return Scrollbar(
      thickness: 4,
      radius: Radius.circular(4),
      thumbVisibility: true,
      trackVisibility: true,
      child: SingleChildScrollView(
        child: Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: widget.mobileHint,
                      labelStyle: TextStyle(color: Colors.grey),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    controller: widget.mobileNo!,
                    validator: (validator) {
                      final RegExp phoneRegex = RegExp(r'^\+?\d{10,12}$');
                      if (!phoneRegex.hasMatch(validator!)) {
                        return 'Please enter a valid phone number';
                      }
                      if (validator.isEmpty) {
                        return "please enter the mobile no";
                      }
                      return null;
                    },
                    cursorColor: Colors.grey),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: widget.userNameHint,
                      labelStyle: TextStyle(color: Colors.grey),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    controller: widget.userName!,
                    validator: (validator) {
                      if (validator == null || validator.isEmpty) {
                        return "please enter the username";
                      }
                      return null;
                    },
                    cursorColor: Colors.grey),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: widget.languagesHint,
                      labelStyle: TextStyle(color: Colors.grey),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    controller: widget.languages!,
                    validator: (validator) {
                      if (validator == null || validator.isEmpty) {
                        return "please enter languages";
                      }
                      return null;
                    },
                    cursorColor: Colors.grey),
              ),
              flutterFunctions.imageFileList!.isNotEmpty
                  ? SizedBox(
                      width: 30,
                      child: Image.file(
                          File(flutterFunctions.imageFileList![0].path)))
                  : TextButton.icon(
                      onPressed: () {
                        Provider.of<FlutterFunctions>(context, listen: false)
                            .onImageButtonPress(ImageSource.gallery);
                      },
                      icon: const Icon(Icons.image),
                      label: Text('select adhar image')),
              flutterFunctions.imageFileList!.isNotEmpty
                  ? TextButton(
                      onPressed: () {
                        Provider.of<FlutterFunctions>(context, listen: false)
                            .onImageButtonPress(ImageSource.gallery);
                      },
                      child: const Text("Change Icon"))
                  : Container(),
              Consumer<FlutterFunctions>(
                builder: (context, value, child) {
                  return value.imageFileList!.isEmpty
                      ? Container()
                      : InsertProfile(
                          imageIcon: () {
                            value.onImageButtonPress(ImageSource.gallery);
                          },
                          label: 'select profile pic',
                          index: 1,
                        );
                },
              ),
              TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: ' your expirience',
                    labelStyle: TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  controller: widget.description,
                  validator: (validator) {
                    if (validator == null || validator.isEmpty) {
                      return "please enter expirience";
                    }
                    return null;
                  },
                  cursorColor: Colors.grey),
              Consumer<ApiCalls>(
                builder: (context, value, child) {
                  return DropdownButton<String>(
                    elevation: 16,
                    isExpanded: true,
                    hint: Text('please select location'),
                    items: value.location == null
                        ? []
                        : value.location!.data.map((v) {
                            return DropdownMenuItem<String>(
                                onTap: () {
                                  value.locationId = v.id;
                                },
                                value: v.location,
                                child: Text(v.location));
                          }).toList(),
                    onChanged: (val) {
                      value.updatesubcat(val!);
                    },
                    value: value.sub,
                  );
                },
              ),
              TextFormField(
                validator: (validator) {
                  if (apicalls.locationId == null) {
                    return 'Please select a location';
                  }
                  return null;
                },
              ),
              const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Please select your services below')),
              Consumer<ApiCalls>(builder: (context, value, child) {
                //print(value.categories);
                return Flexible(
                  flex: 1,
                  child: Consumer<ApiCalls>(
                    builder: (context, validation, child) {
                      return ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        separatorBuilder: (context, mainindex) {
                          return Divider(
                            thickness: 3,
                            color: Colors.yellowAccent,
                          );
                        },
                        itemCount: filteredCategories.length,
                        itemBuilder: (cont, mainindex) {
                          //print("$price:$index");
                          //price.add(TextEditingController());
                          TextEditingController controller1 =
                              prices[mainindex].isNotEmpty
                                  ? prices[mainindex][0]
                                  : TextEditingController();

                          return value.categorieModel!.data![mainindex].subcat!
                                  .isNotEmpty
                              ? ExpansionTile(
                                  title: Text(value
                                      .categorieModel!.data![mainindex].title!),
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (contex, subindex) {
                                        TextEditingController controller =
                                            prices[mainindex][subindex];
                                        //print("$price:$index");
                                        return Column(
                                          children: [
                                            CheckboxListTile(
                                              value: value.selectedCatId
                                                  .contains(value
                                                      .categorieModel!
                                                      .data![mainindex]
                                                      .subcat![subindex]['id']),
                                              onChanged: (val) {
                                                value.selectedCat(value
                                                    .categorieModel!
                                                    .data![mainindex]
                                                    .subcat![subindex]['id']);
                                                print(value.selectedCatId);

                                                //value.updateId(subindex);
                                              },
                                              title: Text(value
                                                  .categorieModel!
                                                  .data![mainindex]
                                                  .subcat![subindex]['title']),
                                            ),
                                            TextFormField(
                                                validator: (validator) {
                                                  if (validator == null ||
                                                      validator.isEmpty) {
                                                    if (value.selectedCatId
                                                        .contains(value
                                                                .categorieModel!
                                                                .data![mainindex]
                                                                .subcat![
                                                            subindex]['id'])) {
                                                      return "please enter the price";
                                                    }
                                                  }
                                                  return null;
                                                },
                                                decoration: InputDecoration(
                                                  hintText:
                                                      "please enter ${value.categorieModel!.data![mainindex].subcat![subindex]['title']} price",
                                                  labelStyle: TextStyle(
                                                      color: Colors.grey),
                                                  focusedBorder:
                                                      const OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.grey),
                                                  ),
                                                ),
                                                controller: controller,
                                                cursorColor: Colors.grey),
                                          ],
                                        );
                                      },
                                      itemCount: apicalls.categorieModel!
                                          .data![mainindex].subcat!.length,
                                    )
                                  ],
                                )
                              : Column(
                                  children: [
                                    CheckboxListTile(
                                      value: value.selectedCatId.contains(value
                                          .categorieModel!.data![mainindex].id),
                                      onChanged: (val) {
                                        value.selectedCat(value.categorieModel!
                                            .data![mainindex].id!);
                                        print(
                                            "from on change:${value.selectedCatId}");

                                        value.updateId(mainindex);
                                      },
                                      title: Text(value.categorieModel!
                                          .data![mainindex].title!),
                                    ),
                                    TextFormField(
                                      validator: (validator) {
                                        if (validator == null ||
                                            validator.isEmpty) {
                                          if (value.selectedCatId.contains(value
                                              .categorieModel!
                                              .data![mainindex]
                                              .id)) {
                                            return "please enter the price";
                                          }
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText:
                                            "please enter ${value.categorieModel!.data![mainindex].title} price",
                                        labelStyle:
                                            TextStyle(color: Colors.grey),
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey),
                                        ),
                                      ),
                                      cursorColor: Colors.grey,
                                      controller: controller1,
                                    ),
                                  ],
                                );
                        },
                      );
                    },
                  ),
                );
              }),
              Consumer<ApiCalls>(
                builder: (context, value, child) {
                  // print(value.isloading);
                  return value.isloading == false
                      ? Button(
                          onTap: () async {
                            if (Form.of(context).validate()) {
                              flutterFunctions.registerPhoneAuth(
                                  context,
                                  "+91${widget.mobileNo!.text.trim()}",
                                  widget.description!.text.trim(),
                                  widget.languages!.text.trim(),
                                  widget.userName!.text.trim(),
                                  scaffoldKey,
                                  prices);

                              scaffoldKey.showSnackBar(SnackBar(
                                content: Text('${value.messages}'),
                                duration: Duration(seconds: 5),
                              ));
                            }
                          },
                          buttonname: widget.buttonName,
                        )
                      : const CircularProgressIndicator(
                          backgroundColor: Colors.yellow,
                        );
                },
              ),
              TextFormField(
                validator: (validator) {
                  if (apicalls.selectedCatId.isEmpty) {
                    return 'Please select atleast one service';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
