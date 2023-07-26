# Authorization

A class that represents authorization exceptions.

:::info Note

This class is not meant to be used directly. It is used in the [MarcSyncClient](../classes/MarcSyncClient) class.

:::

:::caution Exceptions

Exceptions are cachable, meaning that you can use a `pcall` to catch them.

:::

## InvalidAccessToken

Thrown when the `accessToken` used to create the [MarcSyncClient](../classes/MarcSyncClient) is invalid.