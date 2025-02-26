import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rabbit_poop/features/rabbitDetails/bloc/rabbit_controller_bloc.dart';

class AddFecesDayScreen extends StatefulWidget {
  final int healthId;
  final int rabbitId;
  final String date;

  const AddFecesDayScreen({super.key, required this.healthId, required this.rabbitId, required this.date});

  @override
  State<AddFecesDayScreen> createState() => _AddFecesDayScreenState();
}

class _AddFecesDayScreenState extends State<AddFecesDayScreen> {
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _fecesCountController = TextEditingController();

  late final RabbitControllerBloc _rabbitControllerBloc;

  @override
  void initState() {
    _rabbitControllerBloc = context.read<RabbitControllerBloc>();

    super.initState();
  }

  void _pickTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _timeController.text = pickedTime.format(context);
      });
    }
  }

  void _onBackPressed({bool androidPop = false}) {
    _rabbitControllerBloc.add(FetchHealthStatusEvent(
      healthId: widget.healthId,
      rabbitId: widget.rabbitId,
    ));
    if (!androidPop) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        _onBackPressed(androidPop: didPop);
      },
      child: BlocConsumer<RabbitControllerBloc, RabbitControllerState>(
          bloc: _rabbitControllerBloc,
          listener: (context, state) {
            if (state is NavigateToHealthStatusScreenTakePictureEventState) {
              _onBackPressed();
            }
          },
          builder: (context, state) {
            if (state is RabbitControllerInitial) {
              // Show loading indicator while fetching data
              return const Center(child: CircularProgressIndicator());
            }
            return Scaffold(
              backgroundColor: Colors.grey[100], // Light background
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: _onBackPressed,
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time Field
                    const Text(
                      "Time",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _timeController,
                      readOnly: true,
                      onTap: () => _pickTime(context),
                      decoration: InputDecoration(
                        hintText: "Select time",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Feces Count
                    const Text(
                      "Feces Count",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // Take Picture & Gallery Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              _clickOpenCameraOrGallery(ImageSource.camera);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[700],
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text("Take Picture", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(height: 30, width: 2, color: Colors.grey[400]), // Vertical Divider
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              _clickOpenCameraOrGallery(ImageSource.gallery);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[700],
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text("Gallery", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  void _clickOpenCameraOrGallery(ImageSource imageSource) async {
    String failReason =
        imageSource == ImageSource.camera ? "Failed to take picture" : "Failed to open picture from gallery";
    if (_timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select time."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return null;
    }
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: imageSource);

    if (image != null) {
      _rabbitControllerBloc.add(TakePictureEvent(
        healthId: widget.healthId,
        image: image,
        date: widget.date,
        rabbitId: widget.rabbitId,
        time: _timeController.text,
      ));
      // Do something with the captured image
      debugPrint("Captured Image Path: ${image.path}");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(failReason),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
