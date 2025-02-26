import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rabbit_poop/features/camera/view/take_picture_screen.dart';
import 'package:rabbit_poop/features/rabbitDetails/bloc/rabbit_controller_bloc.dart';
import 'package:rabbit_poop/utility/constants.dart';

class AddRabbitPoopEntryScreen extends StatefulWidget {
  final int rabbitId;

  const AddRabbitPoopEntryScreen({
    super.key,
    required this.rabbitId,
  });

  @override
  State<AddRabbitPoopEntryScreen> createState() => _AddRabbitPoopEntryScreenState();
}

class _AddRabbitPoopEntryScreenState extends State<AddRabbitPoopEntryScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  late final RabbitControllerBloc _rabbitControllerBloc;

  @override
  void initState() {
    _rabbitControllerBloc = context.read<RabbitControllerBloc>();
    _rabbitControllerBloc.add(FetchHealthStatusRecordEvent(rabbitId: widget.rabbitId));

    super.initState();
  }

  void _onBackPressed({bool androidPop = false}) {
    _rabbitControllerBloc.add(FetchRabbitInfoEvent(rabbitId: widget.rabbitId));
    if (!androidPop) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        _onBackPressed(androidPop: didPop); // Handle back press with custom logic
      },
      child: BlocConsumer<RabbitControllerBloc, RabbitControllerState>(
        bloc: _rabbitControllerBloc,
        listener: (context, state) {
          if (state is NavigateToHealthStatusScreenTakePictureEventState) {
            Navigator.pushReplacementNamed(
              context,
              Constants.healthStatusScreen,
              arguments: {"healthId": state.healthId, "rabbitId": widget.rabbitId},
            );
          }
        },
        builder: (context, state) {
          if (state is TotalHealthRecordState) {
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Scaffold(
                backgroundColor: Colors.grey[100], // Light background
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: _onBackPressed,
                  ),
                ),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Center(
                          child: Text(
                            "Day ${state.totalHealthRecord}",
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Date Field
                        const Text("Date", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _dateController,
                          readOnly: true, // 👈 Prevents manual typing
                          decoration: InputDecoration(
                            hintText: "dd/mm/yy",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: const Icon(Icons.calendar_today), // Calendar icon for better UX
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000), // 👈 Restrict past dates if needed
                              lastDate: DateTime(2100),
                            );

                            if (pickedDate != null) {
                              String formattedDate = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                              _dateController.text = formattedDate; // 👈 Display formatted date in TextField
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Note Field
                        const Text("Note", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _noteController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: "about rabbit health",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Feces Count Label
                        const Text("Feces Count", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),

                        // Action Buttons: Take Picture & Gallery
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  _clickOpenCameraOrGallery(ImageSource.camera);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[600],
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text("Take Picture", style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 10), // Divider space
                            Container(width: 1, height: 40, color: Colors.grey[300]), // Divider line
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  _clickOpenCameraOrGallery(ImageSource.gallery);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[600],
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text("Gallery", style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _clickOpenCameraOrGallery(ImageSource imageSource) async {
    String failReason =
        imageSource == ImageSource.camera ? "Failed to take picture" : "Failed to open picture from gallery";

    if (_dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select date."),
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
        image: image,
        date: _dateController.text,
        rabbitId: widget.rabbitId,
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
