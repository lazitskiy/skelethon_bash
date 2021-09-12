#!/bin/bash

SRC_DIR=skelethon
DST_DIR=skelethon_apps
DESIGN_DIR=design
ASSETS_DIR=assets

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    -i|--app-id)
      APP_ID="$2"
      shift
      shift
      ;;
    -c|--app-code)
      APP_CODE="$2"
      shift
      shift
      ;;
    -n|--app-name)
      APP_NAME="$2"
      shift
      shift
      ;;
    -d|--design_id)
      DESIGN_ID="$2"
      shift
      shift
      ;;
    -sd|--src-dir)
      SRC_DIR="$2"
      shift
      shift
      ;;
    -dd|--dst-dir)
      DST_DIR="$2"
      shift
      shift
      ;;
    --design-dir)
      DESIGN_DIR="$2"
      shift
      shift
      ;;
    *)    # unknown option
      POSITIONAL+=("$1") # save it in an array for later
      shift
      ;;
  esac
done

[[ -d "$SRC_DIR" ]] && [[ -r "$SRC_DIR" ]] || {
    echo "Can not access src dir '$SRC_DIR'"
    exit 1
}

[[ -d "$DST_DIR" ]] && [[ -w "$DST_DIR" ]] || {
    echo "Can not access dst dir '$DST_DIR'"
    exit 1
}

[[ ! -z "$DESIGN_ID" ]] && {
    [[ -d "$DESIGN_DIR/$DESIGN_ID" ]] && [[ -r "$DESIGN_DIR/$DESIGN_ID" ]] || {
        echo "Can not access design dir '$DESIGN_DIR'"
        exit 1
    }
}

[[ -z "$APP_ID" ]] && {
    echo "app-id is empty"
    exit 2
}

NEXT_APP_ID=0
while : ; do
  NEXT_APP_ID=$((NEXT_APP_ID+1))

  FOUND=0
  for i in ${DST_DIR}/app_${NEXT_APP_ID}_*; do
    [[ -e "$i" ]] && FOUND=1
    break
  done
  [[ $FOUND -eq 1 ]] && continue

  mkdir "$DST_DIR/app_"$NEXT_APP_ID"_"$APP_ID 2>/dev/null
  [[ $? -eq 0 ]] && break

APP_DIR="$DST_DIR/app_"$NEXT_APP_ID"_"$APP_ID

cp -R "$SRC_DIR"/* "$APP_DIR"
[[ ! -z "$DESIGN_ID" ]] && {
    APP_ASSETS_DIR="$APP_DIR"/$ASSETS_DIR
    [[ -d "$APP_ASSETS_DIR" ]] || mkdir "$APP_ASSETS_DIR"
    cp -R "$DESIGN_DIR/$DESIGN_ID"/* "$APP_ASSETS_DIR"
}

replace_data() {
    FILE=$1
    FIND_STR=$2
    NEW_STR=${3//\"/\\\"}
    SEARCH_STR=${FIND_STR//\"/\\\"}
    awk "/${FIND_STR}/ {gsub(\"$SEARCH_STR\", \"${NEW_STR}\")} {print}" <"$FILE" >$APP_DIR/tmpfile
    mv $APP_DIR/tmpfile "$FILE"
}

find "$APP_DIR" -type f | while read filename
do
    replace_data "$filename" "com.vaga.skelethon" ${APP_ID}
    [[ "${filename#$APP_DIR/}" = "android/app/src/main/AndroidManifest.xml" ]] && {
        replace_data "$filename" "android:label=\"Skelethon\"" "android:label=\"${APP_NAME}\""
    }
    [[ "${filename#$APP_DIR/}" = "lib/common/AppConstantIntegration.dart" ]] && {
        replace_data "$filename" "const APP_CODE = 'skelethon';" "const APP_CODE = '${APP_CODE}';"
    }
done
echo -e "\e[31;1m
    1. Add app and download **google-service.json** https://console.firebase.google.com/project/zaebbapp/settings/general/android:${APP_ID}?hl=ru 
    2. Add app attribution https://go.kochava.com/v/#/17993/55427/app/list
\e[0m"