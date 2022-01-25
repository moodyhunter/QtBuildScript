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

- Compile Qt for Android, a static debug build

```bash
./build-qt.fish -p android static debug
# or:
# ./build-qt.fish --platform=android static debug
```

## License

WTFPL :)
