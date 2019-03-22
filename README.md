## Supervisor Updater

Tooling to update the supervisor on one device or multiple Balena devices. It uses
the relevant API calls to update the supervisor release for the device.

### Usage

* update the settings in `supervisor-update.sh`, to add the required supervisor tag,
  API key or session token, and optionally the required API endpoint
* If updating a single device, can just run `./supervisor-update.sh UUID`, adding the
  target device's UUID as a parameter
* To facilitate multi-device updates, add the required list of UUIDs (one per line)
  in a new file called `batch`. Then execute `./run.sh` which will run the update
  for all those listed, parallelized, and the logs are saved in `supervisor-update.log`.

Please note that the `TAG` can be only one of those that are released to the API. That
can be checked by the `/v4/supervisor_release` endpoint, for example
[this one for balenaCloud](https://api.balena-cloud.com/v4/supervisor_release).
The output of you can filter by device slug. Updates to any other version/tag than
what is in the API is not supported.

**Also note**, that the device will not immediately update the supervisor. There's
an updater service running on the device, that queries the target supervisor
version a) 15 minutes after boot, b) then repeatedly every 24h later. Thus you can
reboot the device for the update to happen soon (in ~15 minutes time), or wait on
average 24h until an update cycle has passed.
