import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rabbit_poop/features/home/bloc/home_bloc.dart';
import 'package:rabbit_poop/features/rabbitDetails/bloc/rabbit_controller_bloc.dart';
import 'package:rabbit_poop/utility/constants.dart';

class AddRabbitScreen extends StatefulWidget {
  final int? id;

  const AddRabbitScreen({
    super.key,
    this.id,
  });

  @override
  State<AddRabbitScreen> createState() => _AddRabbitScreenState();
}

class _AddRabbitScreenState extends State<AddRabbitScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  late final RabbitControllerBloc _rabbitControllerBloc;

  @override
  void initState() {
    _rabbitControllerBloc = context.read<RabbitControllerBloc>();
    if (widget.id != null) {
      _rabbitControllerBloc.add(FetchRabbitInfoEvent(rabbitId: widget.id!));
    }

    super.initState();
  }

  void _onBackPressed({bool androidPop = false}) {
    context.read<HomeBloc>().add(HomeFetchRabbitInfoEvent());
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
      child: BlocListener<RabbitControllerBloc, RabbitControllerState>(
        bloc: _rabbitControllerBloc,
        listener: (context, state) {
          if (state is AddRabbitResult) {
            if (state.isSuccess) {
              // Show success Snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Rabbit added successfully!"),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );

              // Navigate to rabbit details screen (replace with your navigation logic)
              // Navigator.pop(context);
            } else {
              // Show error Snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Failed to add rabbit."),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } else if (state is NavigateToRabbitDetailScreen) {
            Navigator.pushReplacementNamed(
              context,
              Constants.rabbitDetail,
              arguments: {"rabbitId": state.rabbitId},
            );
          } else if (state is ShowRabbitInfoAndHistoryState) {
            // Prefill values
            _nameController.text = state.name;
            _ageController.text = state.age.toString();
            _weightController.text = state.weight.toString();
            _heightController.text = state.height.toString();
            _aboutController.text = state.aboutRabbit.toString();
          }
        },
        child: GestureDetector(
          onTap: () {
            // Dismiss keyboard when tapping outside input fields
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.grey[100], // Light background
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: _onBackPressed,
              ),
              title: const Text(
                "Add Your Rabbit",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rabbit Name
                  _buildTextField(_nameController, "Rabbit Name", Icons.person, TextInputType.text),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Container(
                          width: 200,
                          child: _buildTextField(_ageController, "Age", Icons.person, TextInputType.number)),
                      const SizedBox(
                        width: 20,
                      ),
                      const Text("Months"),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                          width: 200,
                          child:
                              _buildTextField(_weightController, "Weight", Icons.fitness_center, TextInputType.number)),
                      const SizedBox(
                        width: 20,
                      ),
                      const Text("Kg"),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                          width: 200,
                          child: _buildTextField(_heightController, "Height", Icons.height, TextInputType.number)),
                      const SizedBox(
                        width: 20,
                      ),
                      const Text("cm"),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // About Rabbit
                  const Text(
                    "About Rabbit",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildLargeTextField(_aboutController, "Health/Nature/Character"),

                  const SizedBox(
                    height: 50,
                  ),
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitRabbit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("Save", style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Standard TextField
  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, TextInputType keyboardType,
      {String? suffix}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.black54),
        hintText: hint,
        suffixText: suffix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }

  // Large TextArea
  Widget _buildLargeTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }

  void _submitRabbit() {
    final String name = _nameController.text.trim();
    final int? age = int.tryParse(_ageController.text.trim());
    final double? weight = double.tryParse(_weightController.text.trim());
    final double? height = double.tryParse(_heightController.text.trim());
    final String about = _aboutController.text.trim();

    if (name.isEmpty || age == null || weight == null || height == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields correctly!")),
      );
      return;
    }

    _rabbitControllerBloc.add(
      AddRabbitInfoEvent(
        rabbitId: widget.id,
        name: name,
        age: age,
        weight: weight,
        height: height,
        about: about,
      ),
    );
  }
}
