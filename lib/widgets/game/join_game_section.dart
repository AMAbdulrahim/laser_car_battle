// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/utils/constants.dart';
import 'package:laser_car_battle/viewmodels/game_viewmodel.dart';
import 'package:laser_car_battle/viewmodels/player_viewmodel.dart';
import 'package:laser_car_battle/widgets/buttons/action_button.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class JoinGameSection extends StatefulWidget {
  const JoinGameSection({super.key});

  @override
  State<JoinGameSection> createState() => _JoinGameSectionState();
}

class _JoinGameSectionState extends State<JoinGameSection> {
  final TextEditingController _gameCodeController = TextEditingController();

  @override
  void dispose() {
    _gameCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pin theme definitions
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
                horizontal: AppSizes.paddingSmall,
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
              ),
            ),
            const SizedBox(height: AppSizes.paddingLarge),
            SizedBox(
              width: 200,
              child: ActionButton(
                onPressed: () => _joinGame(context),
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
            _buildGamesList(),
            
            // Add a refresh button at the bottom
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton.icon(
                onPressed: () => context.read<GameViewModel>().loadWaitingGames(),
                icon: Icon(Icons.refresh, color: CustomColors.mainButton),
                label: Text(
                  'Refresh Game List', 
                  style: TextStyle(color: CustomColors.buttonText)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _joinGame(BuildContext context) async {
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
  }

  Widget _buildGamesList() {
    return Container(
      height: 260,
      width: double.infinity, 
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      padding: const EdgeInsets.all(AppSizes.paddingSmall),
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
      child: Consumer<GameViewModel>(
        builder: (context, gameViewModel, _) {
          if (gameViewModel.isLoadingWaitingGames) {
            return const Center(child: CircularProgressIndicator());
          } else if (gameViewModel.waitingGames.isEmpty) {
            return Center(
              child: Text(
                'No games available to join.\nTry refreshing or host your own!',
                textAlign: TextAlign.center,
                style: TextStyle(color: CustomColors.textPrimary),
              ),
            );
          } else {
            return RefreshIndicator(
              onRefresh: () => gameViewModel.loadWaitingGames(),
              child: ListView.builder(
                itemCount: gameViewModel.waitingGames.length,
                itemBuilder: (context, index) {
                  final game = gameViewModel.waitingGames[index];
                  return _buildGameListItem(context, game);
                },
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildGameListItem(BuildContext context, dynamic game) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        title: Text(
          game.player1Name,
          style: TextStyle(
            fontSize: AppSizes.fontMedium,
          ),
        ),
        subtitle: Text(
          '${game.gameMode} - ${game.gameValue} ${game.gameMode == 'Time' ? 'min' : 'pts'}',
        ),
        trailing: Text(
          game.id,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: CustomColors.actionButton,
          ),
        ),
        onTap: () {
          // Auto-fill the game code
          _gameCodeController.text = game.id;
        },
        leading: IconButton(
          icon: Icon(Icons.login, color: CustomColors.mainButton),
          onPressed: () => _joinSpecificGame(context, game.id),
        ),
      ),
    );
  }

  void _joinSpecificGame(BuildContext context, String gameId) async {
    final gameViewModel = context.read<GameViewModel>();
    final playerName = context.read<PlayerViewModel>().playerName;
    
    final success = await gameViewModel.joinGame(gameId, playerName);
    
    if (!mounted) return;
    
    if (success) {
      Navigator.pushNamed(context, '/controller');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not join the game')),
      );
    }
  }
}