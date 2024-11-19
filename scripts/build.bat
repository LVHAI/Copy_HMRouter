@echo off

call hvigorw assembleHar --mode module -p module=HMRouterLibrary@default -p product=default --daemon

echo "assembleHar build end"

set libFolder=.\libs
set srcFile=.\HMRouterLibrary\build\default\outputs\default

xcopy /E /I /Y %srcFile% %libFolder%