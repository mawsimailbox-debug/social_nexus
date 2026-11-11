# integration_test — device/emulator job

`auth_flow_test.dart` exercises the G3 auth journeys (device-login 200 and the
202 → email → OTP → home recovery chain) across data + domain + presentation.
It runs headless in CI with:

```sh
flutter test integration_test
```

Full widget-tree journeys on a real device/emulator require a runner with an
Android emulator or iOS simulator:

```sh
flutter test integration_test -d <device-id>
```

Real-device execution is a release gate (G2/G3) and is not claimed by local runs.
