import 'package:flutter/material.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/utils/constants.dart';
import 'package:laser_car_battle/viewmodels/player_viewmodel.dart';
import 'package:laser_car_battle/widgets/buttons/action_button.dart';
import 'package:laser_car_battle/widgets/custom/custom_app_bar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:laser_car_battle/viewmodels/game_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:laser_car_battle/models/game_session.dart';
import 'dart:async';

class GameModePage extends StatefulWidget {
  const GameModePage({super.key});

  @override
  State<GameModePage> createState() => _GameModePageState();
}

class _GameModePageState extends State<GameModePage> {
  String? selectedMode;
  int? timePickerValue = 3;
  int? pointPickerValue = 2;
  bool isHost = true; // Default to host/create mode

  // Add these new fields
  List<GameSession> _waitingGames = [];
  bool _isLoadingGames = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    
    // Set up a timer to refresh the game list every 30 seconds but only when in join mode
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!isHost && mounted) {
        _loadWaitingGames();
      }
    });
    
    // Listen for mode changes and load games when switching to join mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isHost) {
        _loadWaitingGames();
      }
    });
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
  
  /// Load waiting games from the server
  Future<void> _loadWaitingGames() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingGames = true;
    });
    
    try {
      // Use the existing GameViewModel's GameSyncService instead of creating a new one
      final gameViewModel = Provider.of<GameViewModel>(context, listen: false);
      
      // Call the method to get waiting games
      final games = await gameViewModel.getWaitingGamesFromServer();
      
      if (mounted) {
        setState(() {
          _waitingGames = games;
          _isLoadingGames = false;
        });
        
        // Debug output to verify games are being fetched
        print('Loaded ${games.length} waiting games');
        for (var game in games) {
          print('Game ID: ${game.id}, Host: ${game.player1Name}');
        }
      }
    } catch (e) {
      print('Error loading waiting games: $e');
      if (mounted) {
        setState(() {
          _isLoadingGames = false;
        });
      }
    }
  }

  Widget _buildToggleButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSizes.paddingLarge),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: CustomColors.background,
        borderRadius: BorderRadius.circular(AppSizes.borderLarge),
        border: Border.all(color: CustomColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption(
            text: 'Create Game',
            isSelected: isHost,
            onTap: () => setState(() => isHost = true),
          ),
          _buildToggleOption(
            text: 'Join Game',
            isSelected: !isHost,
            onTap: () {
              setState(() {
                isHost = false;
              });
              // Load waiting games when switching to join mode
              _loadWaitingGames();
            },
          ),
        ],
      ),
    );
  }

  final TextEditingController _gameCodeController = TextEditingController();

  Widget _buildJoinGameSection() {
    // Keep your existing theme definitions
    final defaultPinTheme = PinTheme(
      width: 60,
      height: 68,
      textStyle: const TextStyle(
        fontSize: 36,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CustomColors.border),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: CustomColors.mainButton, width: 2),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: CustomColors.mainButton.withOpacity(0.3),
          blurRadius: 8,
          spreadRadius: 2,
        ),
      ],
    );

    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: CustomColors.mainButton),
      borderRadius: BorderRadius.circular(16),
    );

    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppSizes.paddingLarge),
            const Padding(
              padding: EdgeInsets.all(AppSizes.paddingMedium),
              child: Text(
                'Enter 4-Digit Game Code',
                style: TextStyle(
                  fontSize: AppSizes.fontLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingLarge,
                vertical: AppSizes.paddingMedium,
              ),
              child: Pinput(
                controller: _gameCodeController,
                length: 4,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                showCursor: true,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onCompleted: (pin) {
                  print("Game code complete: $pin");
                },
              ),
            ),
            const SizedBox(height: AppSizes.paddingLarge),
            SizedBox(
              width: 200,
              child: ActionButton(
                onPressed: () async {
                  if (_gameCodeController.text.length < 4) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a 4-digit game code')),
                    );
                    return;
                  }
                  
                  final gameViewModel = context.read<GameViewModel>();
                  final playerName = context.read<PlayerViewModel>().playerName;
                  
                  final success = await gameViewModel.joinGame(_gameCodeController.text, playerName);
                  
                  if (!mounted) return;
                  
                  if (success) {
                    Navigator.pushNamed(context, '/controller');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Game not found or could not join')),
                    );
                  }
                },
                buttonText: "Join Game",
              ),
            ),
            
            // Add space between button and container
            const SizedBox(height: AppSizes.paddingLarge*2),
            
            Text(
              'Available Games to Join!',
              style: TextStyle(
                  color: CustomColors.buttonText, fontSize: AppSizes.fontMedium),
            ),
            
            // Game list container
            Container(
              height: 250,
              width: double.infinity, 
              margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: CustomColors.border, 
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: CustomColors.appBarBackgroundExtension,
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _isLoadingGames
                ? const Center(child: CircularProgressIndicator())
                : _waitingGames.isEmpty
                  ? Center(
                      child: Text(
                        'No games available to join.\nTry refreshing or host your own!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: CustomColors.textPrimary),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadWaitingGames,
                      child: ListView.builder(
                        itemCount: _waitingGames.length,
                        itemBuilder: (context, index) {
                          final game = _waitingGames[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(
                                'Host: ${game.player1Name}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${game.gameMode} - ${game.gameValue} ${game.gameMode == 'Time' ? 'min' : 'pts'}',
                              ),
                              trailing: Text(
                                game.id,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () {
                                // Auto-fill the game code
                                _gameCodeController.text = game.id;
                              },
                              // Add a join button for more clarity
                              leading: IconButton(
                                icon: Icon(Icons.login, color: CustomColors.mainButton),
                                onPressed: () async {
                                  final gameViewModel = context.read<GameViewModel>();
                                  final playerName = context.read<PlayerViewModel>().playerName;
                                  
                                  // Join this specific game
                                  final success = await gameViewModel.joinGame(game.id, playerName);
                                  
                                  if (!mounted) return;
                                  
                                  if (success) {
                                    Navigator.pushNamed(context, '/controller');
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Could not join the game')),
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
            
            // Add a refresh button at the bottom
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton.icon(
                onPressed: _loadWaitingGames,
                icon: Icon(Icons.refresh),
                label: Text('Refresh Game List'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingLarge,
          vertical: AppSizes.paddingMedium,
        ),
        decoration: BoxDecoration(
          color: isSelected ? CustomColors.mainButton : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.borderMedium),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : CustomColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Widget _buildJoiningIndicator() {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         const CircularProgressIndicator(),
  //         const SizedBox(height: AppSizes.paddingLarge),
  //         Text(
  //           'Waiting for host to setup the game...',
  //           style: TextStyle(
  //             color: CustomColors.textPrimary,
  //             fontSize: AppSizes.fontMedium,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20),
        child: CustomAppBar(
          titleText: "Game Setup",
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            children: [
              _buildToggleButtons(),
              Expanded(
                child: isHost
                    ? SingleChildScrollView(
                        child: Column(
                          children: [
                            DropdownButtonFormField2<String>(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Select Game Mode',
                              ),
                              items: <String>['Points', 'Time']
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  selectedMode = value;
                                });
                              },
                            ),
                            // Show different pickers based on selected mode
                          SizedBox(height: AppSizes.paddingLarge),
                            if (selectedMode != null) ...[
                              if (selectedMode == 'Points') ...[
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center, // Add this for better spacing
                                    children: <Widget>[
                                
                                      // Add NumberPicker for time selection
                                      Container(
                                        // color: CustomColors.border,
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(29, 79, 0, 0),
                                          border: Border.all(color: CustomColors.border,width: 5, ),
                                          borderRadius: BorderRadius.circular(AppSizes.borderLarge,),
                                        ),
                                        padding: const EdgeInsets.all(AppSizes.paddingLarge),
                                        child: NumberPicker(
                                          
                                          axis: Axis.horizontal ,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: CustomColors.border, width: 3),
                                            
                                            
                                          ),
                                          value: pointPickerValue!,
                                          minValue: 1,
                                          maxValue: 15,
                                          step: 1,
                                          haptics: true,
                                          textStyle: const TextStyle(
                                            fontSize: 40,
                                            color: CustomColors.buttonText,
                                          ),
                                          selectedTextStyle: const TextStyle(
                                            fontSize: 50,
                                            color: CustomColors.textPrimary,
                                          ),
                                          itemHeight: 80, // Makes the picker taller
                                          itemWidth: 80,  // Makes the picker wider
                                          onChanged: (value) {
                                            setState(() {
                                              pointPickerValue = value;
                                            });
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(AppSizes.paddingMedium),
                                        child: Text(
                                          'Win by $pointPickerValue point(s)',
                                          style: const TextStyle(fontSize: AppSizes.fontMedium),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                               
                              ] else if (selectedMode == 'Time') ...[
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center, // Add this for better spacing
                                    children: <Widget>[
                                
                                      // Add NumberPicker for time selection
                                      Container(
                                        // color: CustomColors.border,
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(29, 79, 0, 0),
                                          border: Border.all(color: CustomColors.border, width: 5),
                                          borderRadius: BorderRadius.circular(AppSizes.borderLarge),
                                        ),
                                        padding: const EdgeInsets.all(AppSizes.paddingLarge),
                                        child: NumberPicker(
                                          // axis: Axis.horizontal ,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: CustomColors.border),
                                            borderRadius: BorderRadius.circular(10),
                                            
                                          ),
                                          value: timePickerValue!,
                                          minValue: 1,
                                          maxValue: 15,
                                          step: 1,
                                          haptics: true,
                                          textStyle: const TextStyle(
                                            fontSize: 40,
                                            color: CustomColors.buttonText,
                                          ),
                                          selectedTextStyle: const TextStyle(
                                            fontSize: 50,
                                            color: CustomColors.textPrimary,
                                          ),
                                          itemHeight: 80, // Makes the picker taller
                                          itemWidth: 80,  // Makes the picker wider
                                          onChanged: (value) {
                                            setState(() {
                                              timePickerValue = value;
                                            });
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(AppSizes.paddingMedium),
                                        child: Text(
                                          'Time: $timePickerValue minutes',
                                          style: const TextStyle(fontSize: AppSizes.fontMedium),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                              SizedBox(height: AppSizes.paddingLarge),
                              ActionButton(
                                onPressed: () {
                                  if (selectedMode == null || 
                                      (selectedMode == 'Time' && timePickerValue == null) || 
                                      (selectedMode == 'Points' && pointPickerValue == null)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Please select a game mode and value')),
                                    );
                                    return;
                                  }
                                  
                                  final gameViewModel = context.read<GameViewModel>();
                                  final playerName = context.read<PlayerViewModel>().playerName;
                                  
                                  // Set as host
                                  gameViewModel.setIsHost(true);
                                  
                                  // Set game settings
                                  gameViewModel.setGameSettings(
                                    selectedMode!, 
                                    selectedMode == 'Time' ? timePickerValue! : pointPickerValue!
                                  );
                                  
                                  // Assign name as player1 (host)
                                  gameViewModel.player1Name = playerName;
                                  
                                  Navigator.pushNamed(context, '/controller');
                                },
                                buttonText: "Create Game",
                              ),
                            ],
                          ],
                        ),
                      )
                    : _buildJoinGameSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}