#!/usr/bin/env bash

# Close System Preferences to make sure it doesn't interfere.
osascript -e 'tell application "System Preferences" to quit'

### Appearance
###########################################################
# Set sidebar icon size to small.
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1

### Finder
###########################################################
# Show icons for disks/servers/removable media on the desktop.
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
# Show the path bar.
defaults write com.apple.finder ShowPathbar -bool true
# Keep folders on top.
defaults write com.apple.finder _FXSortFoldersFirst -bool true
# Don't create .DS_Store files on network or USB volumes.
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
# Don't warn when emptying trash.
defaults write com.apple.finder WarnOnEmptyTrash -bool false
# Set default location to $HOME
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}"
# Search current folder by default.
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# Don't reopen windows when logging in.
defaults write com.apple.loginwindow TALLogoutSavesState -bool false
defaults write com.apple.loginwindow LoginwindowLaunchesRelaunchApps -bool false
# Show item info for desktop icons.
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
# Show item info to the right of the icons on the desktop
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:labelOnBottom false" ~/Library/Preferences/com.apple.finder.plist
# Enable snap-to-grid everywhere.
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
# Set grid spacing.
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 60" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 60" ~/Library/Preferences/com.apple.finder.plist
# Set icon size.
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 64" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 64" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 64" ~/Library/Preferences/com.apple.finder.plist

### Desktop & Dock
###########################################################
# Dock icon size.
defaults write com.apple.dock tilesize -int 40
# Dock position.
defaults write com.apple.dock orientation -string left
# Don't show recent apps.
defaults write com.apple.dock show-recents -bool FALSE
# Remove all apps from the Dock.
defaults write com.apple.dock persistent-apps -array

### Mouse & Trackpad
###########################################################
# Disable natural scrolling.
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

killall Finder
killall Dock
