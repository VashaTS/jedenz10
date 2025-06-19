call flutter build web --release
call firebase deploy --only hosting
call flutter build apk --release
call flutter build windows --release
call dart run msix:create
call flutter build appbundle --release