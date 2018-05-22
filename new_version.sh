export LIB_VERSION="v0.0.1"
git commit -a -m "pushing new release comments at CHANGLELOG.md"
git tag -a ${LIB_VERSION} -m "version ${LIB_VERSION}"
git push origin master ${LIB_VERSION}
flutter packages pub publish --dry-run