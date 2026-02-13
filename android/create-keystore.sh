#!/bin/bash
# Создаёт release keystore для подписи AAB/APK.
# Требуется: установленный Java (Android Studio или brew install openjdk@17).

set -e
cd "$(dirname "$0")"

KEYTOOL=""
if [ -x "/Users/user/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/keytool" ]; then
  KEYTOOL="/Users/user/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/keytool"
elif [ -x "/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/keytool" ]; then
  KEYTOOL="/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/keytool"
elif [ -x "/Applications/Android Studio.app/Contents/jre/Contents/Home/bin/keytool" ]; then
  KEYTOOL="/Applications/Android Studio.app/Contents/jre/Contents/Home/bin/keytool"
elif command -v keytool >/dev/null 2>&1; then
  KEYTOOL="keytool"
elif [ -n "$JAVA_HOME" ] && [ -x "$JAVA_HOME/bin/keytool" ]; then
  KEYTOOL="$JAVA_HOME/bin/keytool"
fi

if [ -z "$KEYTOOL" ]; then
  echo "Java/keytool не найден. Установите JDK:"
  echo "  brew install openjdk@17"
  echo "или откройте Android Studio (он ставит свой JDK)."
  exit 1
fi

if [ -f "upload-keystore.jks" ]; then
  echo "Файл upload-keystore.jks уже есть. Удалите его, если нужно пересоздать."
  exit 0
fi

# Пароль по умолчанию — замените на свой и сохраните в key.properties
STOREPASS="${KEYSTORE_PASSWORD:-orynaiRelease2025}"
KEYPASS="${KEY_PASSWORD:-orynaiRelease2025}"

"$KEYTOOL" -genkey -v \
  -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload \
  -storepass "$STOREPASS" -keypass "$KEYPASS" \
  -dname "CN=Orynai, OU=Mobile, O=Orynai, L=Almaty, ST=Almaty, C=KZ"

echo ""
echo "Готово: upload-keystore.jks создан."
echo "Пароль хранилища и ключа: $STOREPASS"
echo ""
echo "Создайте android/key.properties с содержимым:"
echo "  storePassword=$STOREPASS"
echo "  keyPassword=$KEYPASS"
echo "  keyAlias=upload"
echo "  storeFile=upload-keystore.jks"
