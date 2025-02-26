import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rabbit_poop/features/home/bloc/home_bloc.dart';
import 'package:rabbit_poop/features/rabbitDetails/bloc/rabbit_controller_bloc.dart';
import 'package:rabbit_poop/utility/constants.dart';

class RabbitDetailScreen extends StatefulWidget {
  final int rabbitId;

  const RabbitDetailScreen({
    super.key,
    required this.rabbitId,
  });

  @override
  State<RabbitDetailScreen> createState() => _RabbitDetailScreenState();
}

class _RabbitDetailScreenState extends State<RabbitDetailScreen> {
  late final RabbitControllerBloc _rabbitControllerBloc;

  @override
  void initState() {
    _rabbitControllerBloc = context.read<RabbitControllerBloc>();
    _rabbitControllerBloc.add(FetchRabbitInfoEvent(rabbitId: widget.rabbitId));

    super.initState();
  }

  void _onBackPressed({bool androidPop = false}) {
    context.read<HomeBloc>().add(HomeFetchRabbitInfoEvent());
    if (!androidPop) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Constants.homeScreen,
        (route) => false,
      );
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
          if (state is NavigateToRabbitDetailScreen) {
            Navigator.pushReplacementNamed(
              context,
              Constants.addRabbitScreen,
              arguments: {"id": state.rabbitId},
            );
          } else if (state is NavigateToAddNewPoopEntryState) {
            Navigator.pushNamed(
              context,
              Constants.addRabbitPoopEntry,
              arguments: {"id": widget.rabbitId},
            );
          } else if (state is NavigateToHealthStatusScreenState) {
            Navigator.pushNamed(
              context,
              Constants.healthStatusScreen,
              arguments: {"healthId": state.healthId, "rabbitId": widget.rabbitId},
            );
          }
        },
        builder: (context, state) {
          if (state is ShowRabbitInfoAndHistoryState) {
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
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Rabbit Name
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300], // Light grey background
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          state.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Edit Button
                      ElevatedButton(
                        onPressed: _clickEditRabbitData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Blue button color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Edit", style: TextStyle(color: Colors.white)),
                      ),

                      const SizedBox(height: 16),

                      // Rabbit Stats Row (Weight, Age, Height)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatCard("${state.weight.toStringAsFixed(1)} kg", "Weight"),
                          _buildStatCard("${state.age}", "Months"),
                          _buildStatCard("${state.height.toStringAsFixed(1)} cm", "Height"),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // History Section
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
                              "History",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 300, // Adjust height as needed
                              child: ListView.separated(
                                itemCount: state.healthHistoryItemList.length,
                                separatorBuilder: (context, index) => const Divider(),
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(state.healthHistoryItemList[index].date),
                                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                    onTap: () {
                                      _rabbitControllerBloc.add(NavigateToHealthStatusScreenEvent(
                                          healthId: state.healthHistoryItemList[index].healthId));
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: 20,
                      ),

                      // Add New Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _clickAddNewPoopToday,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            "ADD NEW",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
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

  // Widget for displaying the stats
  Widget _buildStatCard(String value, String label) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  void _clickEditRabbitData() {
    _rabbitControllerBloc.add(EditRabbitDataEvent(id: widget.rabbitId));
  }

  void _clickAddNewPoopToday() {
    _rabbitControllerBloc.add(NavigateToAddNewPoopTodayEvent());
  }
}
