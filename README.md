# QtBuildScript

A personal fish script to [cross-] compile Qt from source.

## Usage

### Concepts

- A "Platform" is an environment where the compiled Qt will be executed in.
- A "kit" is a set of CMake argument preset, which can be combined to form a "kit set", or "kits".

### Arguments

```
-p, --platform          Target platform, default value is 'desktop'
-a, --arch              Target architecture, default='x86_64', platform-specific.
-h, --host-path         Path to the Qt host build directory, can be automatically detected if unspecified.
-j, --parallel          Run N jobs at once, can be automatically detected from nproc if unspecified.
-k, --skip-cleanup      Skip cleanup the build directory.
```

### Defaults

Default Platform: `desktop`
Default KitSet: `ccache`, `shared`, `release` (See `./.default-kits`)

### Kits Applying Order

1. Apply base kits, stored in `./.base-kits`
2. Apply kits given from the argument
3. If kits are still empty, apply default kits

## Example

- Compile Qt for Linux desktop, a shared library debug build.

```bash
# desktop, shared, release is the default
./build-qt.fish
# or:
# ./build-qt.fish shared release
# ./build-qt.fish -pdesktop shared release
# ./build-qt.fish --platform=desktop shared release
```

- Compile Qt for Linux desktop, a shared library release build.

```bash
./build-qt.fish shared debug
# or:
# ./build-qt.fish -pdesktop shared debug
# ./build-qt.fish --platform=desktop shared debug
```

- Compile Qt for Android (default architecture x86_64), a static debug build, with parallel 128

```bash
./build-qt.fish -p android static debug -j128
# or:
# ./build-qt.fish --platform=android static debug --parallel=128
```

- Compile Qt for Android with architecture `arm64-v8a`, a static release build, keep previous build directory

```bash
./build-qt.fish -p android -a arm64-v8a static release -k
# or:
# ./build-qt.fish --platform=android --arch=arm64-v8a static release --skip-cleanup
```

- Compile Qt for Android with architecture `armeabi-v7a`, a static release build, keep previous build directory, with custom Qt host path

```bash
./build-qt.fish -p android -a armeabi-v7a static release -k -h /my/own/qt/installation
# or:
# ./build-qt.fish --platform=android --arch=armeabi-v7a static release --skip-cleanup --host-path=/my/own/qt/installation
```

## License

WTFPL :)
