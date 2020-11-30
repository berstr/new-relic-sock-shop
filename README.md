# new-relic-sock-shop

## Script Details

This script will deploy the New Relic Infrastructure agent and all the applications of the sock shop stack..

| Parameter                      | Required                      | Description                                                                                                                                                                                                                                       | Default                         |
| -------------------------------| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------| --------------------------------|
| `-a` - `--apps` | No |List of application to deploy. By default, it will deploy all the apps located in the [`charts folder`](./charts).                                                                                                                                                                           |                                 |
| `-c` - `--cluster-name` | Yes |The cluster name for the Kubernetes cluster.                                                                                                                                                                                                                                        |                                 |
| `-l` - `--license-key` | Yes |The [license key](https://docs.newrelic.com/docs/accounts/install-new-relic/account-setup/license-key) for your New Relic Account. This will be preferred configuration option if the `NEW_RELIC_LICENSE_KEY` environment variable is specified.                                     |                                 |
| `-n` - `--namespace` | No |Namespace that will be used to deploy the application. The New Relic Infra bundle will be always deployed in the `default` namespace                                                                                                                                                    |default                          |
| `-p` - `--prefix` | No |Prefix for the application name. That will only apply for the New Relic App Name UI                                                                                                                                                                                                        |""                               |
| `--install-newrelic-infra` | No |Install the New Relic Infrastructure bundle                                                                                                                                                                                                                                       |false                            |

## Example

Make sure you have [added the New Relic chart repository.](../../README.md#installing-charts)

Then, to install this chart, run the following command:

```
./bootstrap.sh --install-newrelic-infra true -l YOUR_LICENSE_KEY -n my-namespace -c new-cluster -p someprefix
```




Make sure that you have NEW_RELIC_LICENSE_KEY as an environment variable

After than, run `./boostrap.sh`
