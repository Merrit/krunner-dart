## Compile plugin to self-contained executable

From project root folder run:

```bash
dart pub get
```

```bash
dart compile exe -o package/time_runner bin/time_runner.dart
```


## Install plugin

```bash
package/install.sh
```


## Test plugin

- Launch KRunner with `Alt` + `Space`.
- type in `time`, our chosen match keyword for this example.
- Find your match in this list of results.
  - `Enter` will display a notification with the current time.
  - `Shift` + `Enter` (or clicking the icon on the right side of the results)
    will show a notification with the local timezone.


## Uninstall plugin

```bash
package/uninstall.sh
```


## Debug plugin

Make sure the plugin is not installed, then:

```bash
touch package/time_runner   # Create dummy package to "install".
```

```bash
package/install.sh
```

Now run the program in debug mode in your IDE, or by running `dart run
bin/time_runner.dart` and KRunner calls will connect to the debug version; add
breakpoints, inspect, etc.
