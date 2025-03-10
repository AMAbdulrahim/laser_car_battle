# Laser Car Battle - TODO List

## Bugs to Fix
- [] Render box when changing from portrait to landscape

## Features to Add
- [x] Share game results as image
- [x] Add game modes (Time/Points)
- [x] Add player names
- [ ] Add sound effects
- [ ] Add background music
- [ ] Add animations for hits

## UI Improvements
- [x] Add score board
- [x] Implement settings dropdown
- [x] Make game over page portrait only
- [ ] Add loading indicators
- [ ] Improve button feedback
- [ ] Add visual effects for hits
- [ ] Add joystick sensitivity adjustment slider
  - [ ] Add sensitivity control to settings dropdown
  - [ ] Save sensitivity preferences
  - [ ] Add visual feedback for sensitivity changes
  - [ ] Implement per-player sensitivity settings

## Code Refactoring
- [x] Extract settings dropdown to separate widget
- [x] Improve provider structure
- [ ] Add proper error handling
- [ ] Implement proper logging
- [ ] Add documentation
- [ ] Add unit tests

## Future Enhancements
- [ ] Add multiplayer over network
- [ ] Add power-ups
- [ ] Add tournament mode
- [ ] Add statistics tracking
- [ ] Add achievements

## Performance Optimizations
- [ ] Reduce unnecessary rebuilds
- [ ] Improve asset loading
- [ ] Optimize memory usage

## Documentation
- [ ] Add README.md

# Bluetooth Implementation TODOs

## Core Bluetooth Features
- [ ] Implement BLE service discovery
- [ ] Add characteristic read/write operations
- [ ] Add MTU size negotiation
- [ ] Add GATT cache clearing for Android
- [ ] Implement connection priority requests for Android
- [ ] Add auto-reconnect functionality
- [ ] Implement BLE status monitoring

## Communication Layer
- [ ] Implement command/response protocol
- [ ] Add command callback registration system
- [ ] Create message serialization/deserialization
- [ ] Add message queuing system
- [ ] Implement retry mechanism for failed commands
- [ ] Add timeout handling for commands
- [ ] Create bidirectional communication channel

## Game-Specific Features
- [ ] Implement player discovery protocol
- [ ] Add game state synchronization
- [ ] Create hit detection and reporting
- [ ] Implement score synchronization
- [ ] Add game settings synchronization
- [ ] Create player name exchange protocol
- [ ] Implement game start/end synchronization

## Error Handling & Recovery
- [ ] Add connection loss recovery
- [ ] Implement automatic reconnection
- [ ] Create error reporting system
- [ ] Add connection quality monitoring
- [ ] Implement fallback mechanisms
- [ ] Create user-friendly error messages
- [ ] Add diagnostic logging system

## Testing & Validation
- [ ] Create BLE connection tests
- [ ] Add command protocol tests
- [ ] Implement game state sync tests
- [ ] Create end-to-end gameplay tests
- [ ] Add stress tests for connection handling
- [ ] Implement battery drain tests
- [ ] Create interference handling tests

## Future Enhancements
- [ ] Add support for multiple simultaneous connections
- [ ] Implement device bonding
- [ ] Create secure communication channel
- [ ] Add power management optimizations
- [ ] Implement background operation mode
- [ ] Add support for device firmware updates
- [ ] Create device configuration management
