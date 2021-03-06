### 
Задача: скопировать папку и седнуть в ней некоторые значения
--- 

Под OSX тоже нужно, чтобы работало. А там они немного отличаются по аргументам, потому типа такого сойдет
```
get_os(){
  unameOut="$(uname -s)"
  case "${unameOut}" in
      Linux*)     machine=Linux;;
      Darwin*)    machine=Mac;;
      CYGWIN*)    machine=Cygwin;;
      MINGW*)     machine=MinGw;;
      *)          machine="UNKNOWN:${unameOut}"
  esac
  echo ${machine}
}
if [ "$(get_os)" == "Mac" ] ; then
  SED="gsed";
else
  SED="sed";
fi
```
и потом можно юзать обычно
```
$SED -i "s/^APP_ENV=.*/APP_ENV=${APP_ENV}/g" .env.local
```
 
---
Нужны обязятальные аргументы и пример вызова:
```
./create_app

Usage: create_app.sh [arguments]

Global options:
-i,  --app-id     Unique Application ID. com.vaga.lucky_strike
-c,  --app-code   Unique Application code. lucky_strike
-n,  --app-name   App display name. Lucky Strike
-d,  --design_id  Design id. 1

./create_ap -i=com.vaga.lucky_strike -c=lucky_strike -n=Lucky Strike --d=1

```
---
1. Скопировать **skelethon** в **skelethon_apps** с названием:
    - если папка пуская, то **app_1_com.vaga.lucky_strike**
    - если не пустая, то **app_$next_app_id_com.vaga.lucky_strike**, 
    а $next_app_id = следующая цифра из
     ```
    app_1_com...
    app_2_com...
    app_3_com...
    ```

2. Заменить по проекту
    - Строку "com.vaga.skelethon" на --app-id
    - Заменить в **skelethon_apps/app_1_com.vaga.lucky_strike/android/app/src/main/AndroidManifest.xml** 
    'android:label="Skelethon"' на 'android:label="--app-name"'
    - Заменить в **skelethon_apps/app_1_com.vaga.lucky_strike/lib/common/AppConstantIntegration.dart**
    "const APP_CODE = 'skelethon';" на "const APP_CODE = '--app-code';"
    - Скопировать с заменой из **design/--design_id/*** в **skelethon_apps/app_1_com.vaga.lucky_strike/assets**

3. И в конце краснымы буквами ворнинги !!!
    1. Add app and download **google-service.json** https://console.firebase.google.com/project/zaebbapp/settings/general/android:com.vaga.joker_power?hl=ru 
    2. Add app attribution https://go.kochava.com/v/#/17993/55427/app/list

