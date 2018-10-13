

cd "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"

if [ "$ACTION" = "install" ]; then
  find . -name '*.bcsymbolmap' -type f -exec mv {} "${CONFIGURATION_BUILD_DIR}" \;
else
  find . -name '*.bcsymbolmap' -type f -exec rm -rf "{}" +\;
fi

framework="./Input.framework/Input"
archs="$(lipo -info "$framework" | rev | cut -d ':' -f1 | rev)"

for arch in $archs; do
    if ! [[ "${VALID_ARCHS}" == *"$arch"* ]]; then
        lipo -remove "$arch" -output "$framework" "$framework" || exit 1
    fi
done

if [ "${CODE_SIGNING_REQUIRED}" == "YES" ]; then
    /usr/bin/codesign --force --sign ${EXPANDED_CODE_SIGN_IDENTITY} --preserve-metadata=identifier,entitlements "$framework"
fi
