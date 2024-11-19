#!/bin/zsh

hvigorw assembleHar --mode module -p module=HMRouterLibrary@default -p product=default --daemon

echo "assembleHar build end"

cp ./HMRouterLibrary/build/default/outputs/default/*.har ./libs