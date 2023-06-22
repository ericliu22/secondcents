#!/bin/sh

xcode-select --install
me=$(whoami)
if ! which flutter > /dev/null; then
   echo -e "Flutter not installed (or not on path)! Install? (y/n) \c"
   read
   if "$REPLY" = "y"; then
      cd ~
      git clone https://github.com/flutter/flutter.git -b stable
      echo '\nPATH="/Users/'${me}'/flutter/bin:${PATH}"\nexport PATH\n' >> .zprofile
      sudo gem update --system
      sudo gem install cocoapods
    else
      echo "Please install flutter (or add it to your path)"
      exit 1
   fi
fi

if ! which brew > /dev/null; then
   echo -e "Homebrew not installed! Install? (y/n) \c"
   read
   if "$REPLY" = "y"; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
      echo "Please install homebrew to continue"
      exit 1
   fi
fi

brew tap mongodb/brew
brew install mongodb-community@6.0
cd ~/Downloads
curl -O https://downloads.mongodb.com/compass/mongodb-compass-1.38.0-darwin-x64.dmg
curl -O https://downloads.mongodb.com/compass/mongosh-1.10.1-darwin-x64.zip
unzip mongosh-1.10.1-darwin-x64.zip
rm mongosh-1.10.1-darwin-x64.zip
echo '\nPATH="/Users/'${me}'/mongosh-1.10.1-darwin-x64/bin:${PATH}"\nexport PATH\nalias mongo="mongosh"' >> .zprofile

open mongodb-compass-1.38.0-darwin-x64.dmg
say Done installing you bitch
sleep 15
rm mongodb-compass-1.38.0-darwin-x64.dmg
