# Archer C7 v2 Builder

Build OpenWrt for Archer C7 v2 router.

## Usage

Basic:

```shell
bin/build
```

Using profiles to alter the build settings:

```shell
PROFILES="full-build" bin/build
```

See the list of profiles at `profiles` dir.

## Troubleshooting

### `build-debug` profile

Use `build-debug` profile for troubleshooting the build process:

```shell
PROFILES="full-build build-debug" bin/build
```
