import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rabbit_poop/features/rabbitDetails/bloc/rabbit_controller_bloc.dart';
import 'package:rabbit_poop/utility/constants.dart';

class RabbitHealthStatusScreen extends StatefulWidget {
  final int healthId;
  final int rabbitId;

  const RabbitHealthStatusScreen({super.key, required this.healthId, required this.rabbitId});

  @override
  State<RabbitHealthStatusScreen> createState() => _RabbitHealthStatusScreenState();
}

class _RabbitHealthStatusScreenState extends State<RabbitHealthStatusScreen> {
  final TextEditingController _healthStatusController = TextEditingController();
  late final RabbitControllerBloc _rabbitControllerBloc;

  @override
  void initState() {
    _rabbitControllerBloc = context.read<RabbitControllerBloc>();
    _rabbitControllerBloc.add(FetchHealthStatusEvent(
      healthId: widget.healthId,
      rabbitId: widget.rabbitId,
    ));

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
        _onBackPressed(androidPop: didPop);
      },
      child: BlocConsumer<RabbitControllerBloc, RabbitControllerState>(
        bloc: _rabbitControllerBloc,
        listener: (context, state) {
          if (state is NavigateToAddNewFecesDayScreenState) {
            Navigator.pushNamed(
              context,
              Constants.addRabbitFecesDay,
              arguments: {
                "healthId": widget.healthId,
                "rabbitId": widget.rabbitId,
                "date": state.date,
              },
            );
          } else if (state is ShowHealthStatusState) {
            _healthStatusController.text = state.healthStatus;
          }
        },
        builder: (context, state) {
          if (state is ShowHealthStatusState) {
            return Scaffold(
              backgroundColor: Colors.grey[100],
              // Light background
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: _onBackPressed,
                ),
                title: Text(
                  state.date,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Health Status
                      const Text("Health Status", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _healthStatusController,
                        readOnly: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Feces Today Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Feces Today",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),

                            // Header Row
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("time", style: TextStyle(color: Colors.blue)),
                                Text("quantity", style: TextStyle(color: Colors.blue)),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Show data if available, else show only the Add button
                            if (state.fecesTodayList.isNotEmpty)
                              Column(
                                children: state.fecesTodayList.map((feces) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(feces.time, style: const TextStyle(fontSize: 14)),
                                        Text(feces.quantity.toString(), style: const TextStyle(fontSize: 14)),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),

                            const SizedBox(height: 12),

                            // Add Entry Button
                            Center(
                              child: IconButton(
                                icon: const Icon(Icons.add, size: 30, color: Colors.black54),
                                onPressed: () {
                                  _rabbitControllerBloc.add(NavigateToAddFecesDayScreenEvent(date: state.date));
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Total and Recommendations
                      Text("Total: ${state.totalFeces}",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "อึเล็ก:",
                              style: TextStyle(fontSize: 14, color: Colors.black54),
                            ),
                            const Text(
                              "1",
                              style: TextStyle(fontSize: 14, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          // Show loading indicator while fetching data
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
