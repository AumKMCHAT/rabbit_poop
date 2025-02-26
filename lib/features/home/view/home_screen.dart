import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rabbit_poop/features/home/bloc/home_bloc.dart';
import 'package:rabbit_poop/features/home/model/rabbit_info.dart';
import 'package:rabbit_poop/utility/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeBloc _homeBloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _homeBloc = context.read<HomeBloc>();
    _homeBloc.add(HomeFetchRabbitInfoEvent()); // Fetch all rabbits on init
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      bloc: _homeBloc,
      listener: (context, state) {
        if (state is HomeNavigateToAddRabbitScreenState) {
          Navigator.pushNamed(context, Constants.addRabbitScreen);
        } else if (state is HomeNavigateToOpenRabbitDetailScreenState) {
          Navigator.pushNamed(
            context,
            Constants.rabbitDetail,
            arguments: {"rabbitId": state.rabbitId},
          );
        }
      },
      builder: (context, state) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: Colors.grey[100],
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🏡 Welcome Back Text
                    const Text(
                      "WELCOME BACK",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 🔍 Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red[300], // Background color
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (query) {
                                _homeBloc.add(HomeSearchRabbitNameEvent(query: query));
                              },
                              decoration: const InputDecoration(
                                hintText: "Search",
                                hintStyle: TextStyle(color: Colors.white),
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              _searchController.clear();
                              _homeBloc.add(HomeFetchRabbitInfoEvent());
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 🐰 Section Title: Your Rabbits
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Your Rabbits",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () {
                            _homeBloc.add(HomeAddRabbitEvent());
                          },
                          child: const Icon(Icons.add, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // 📋 Display List of Rabbits
                    Expanded(
                      child: state is HomeLoading
                          ? const Center(child: CircularProgressIndicator())
                          : (state is HomeShowRabbitListState && state.rabbitInfos.isNotEmpty)
                              ? ListView.builder(
                                  itemCount: state.rabbitInfos.length,
                                  itemBuilder: (context, index) {
                                    final RabbitInfoHomeScreenModel rabbit = state.rabbitInfos[index];
                                    return GestureDetector(
                                      onTap: () => _clickOpenRabbitDetail(rabbitId: rabbit.rabbitId),
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.red[100],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              rabbit.name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Age: ${rabbit.age} months",
                                              style: const TextStyle(fontSize: 14, color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : const Center(child: Text("No rabbits found")),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _clickOpenRabbitDetail({required int rabbitId}) {
    _homeBloc.add(HomeOpenRabbitDetailEvent(rabbitId: rabbitId));
  }
}
