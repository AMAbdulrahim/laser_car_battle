# Laser Car Battle - TODO List

## Bugs to Fix
- [ ] Render box when changing from portrait to landscape
- [ ] Fixing Small Value Detection in Arrow Controls
- [ ] Fixing Control Behavior and Debug Spam


## Features to Add
- [x] Share game results as image
- [x] Add game modes (Time/Points)
- [x] Add player names
- [ ] Add sound effects
- [ ] Add background music
- [ ] Add animations for hits
- [ ] Add xyz buttons for advanced gaming 
- [ ] Add visual for speed and direction
  - it will be half circle normalizing the x value that is [-1,1] but to be in [0,1] and add indication of forward and backward and im not sure about the direction indicator yet.
- [ ] Add accuracy rate at the end
  - as we already counts the number of fire and hits so it will be [(#hit/#fire)*100] then save it


## General improvements
- [ ] Github pages if achievable
- [ ] Arabic language 
- [ ] Add README.md

## UI Improvements
- [x] Add score board
- [x] Implement settings dropdown
- [x] Make game over page portrait only
- [ ] Add loading indicators
- [ ] Improve button feedback
- [ ] Add visual effects for hits
- [ ] Improve the game over page 
- [ ] Create and integrate a Logo
- [ ] Add catching phrases in the pages
- [ ] More appealing view of the leaderboard
- [ ] Add sensitivity adjustment slider


## Code Refactoring
- [x] Extract settings dropdown to separate widget
- [x] Improve provider structure
- [ ] Add proper error handling
- [ ] Implement proper logging
- [ ] Add documentation
- [ ] Add unit tests
- [ ] Concise sizings add to the AppSizes class
- [ ] Concise named colors in Colors class

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



## Core Bluetooth Features
- [ ] Implement BLE service discovery
- [ ] Add characteristic read/write operations
- [ ] Add MTU size negotiation
- [ ] Add GATT cache clearing for Android
- [ ] Implement connection priority requests for Android
- [ ] Add auto-reconnect functionality
- [ ] Implement BLE status monitoring

### Communication Layer
- [ ] Implement command/response protocol
- [ ] Add command callback registration system
- [ ] Create message serialization/deserialization
- [ ] Add message queuing system
- [ ] Implement retry mechanism for failed commands
- [ ] Add timeout handling for commands
- [ ] Create bidirectional communication channel

### Game-Specific Features
- [ ] Implement player discovery protocol
- [ ] Add game state synchronization
- [ ] Create hit detection and reporting
- [ ] Implement score synchronization
- [ ] Add game settings synchronization
- [ ] Create player name exchange protocol
- [ ] Implement game start/end synchronization

### Error Handling & Recovery
- [ ] Add connection loss recovery
- [ ] Implement automatic reconnection
- [ ] Create error reporting system
- [ ] Add connection quality monitoring
- [ ] Implement fallback mechanisms
- [ ] Create user-friendly error messages
- [ ] Add diagnostic logging system

### Testing & Validation
- [ ] Create BLE connection tests
- [ ] Add command protocol tests
- [ ] Implement game state sync tests
- [ ] Create end-to-end gameplay tests
- [ ] Add stress tests for connection handling
- [ ] Implement battery drain tests
- [ ] Create interference handling tests

### Future Enhancements
- [ ] Add support for multiple simultaneous connections
- [ ] Implement device bonding
- [ ] Create secure communication channel
- [ ] Add power management optimizations
- [ ] Implement background operation mode
- [ ] Add support for device firmware updates
- [ ] Create device configuration management
