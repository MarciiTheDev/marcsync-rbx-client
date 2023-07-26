# Collection

A class that represents collection exceptions.

:::info Note

This class is not meant to be used directly. It is used in the [MarcSyncClient](../classes/MarcSyncClient) class.

:::

:::caution Exceptions

Exceptions are cachable, meaning that you can use a `pcall` to catch them.

:::

## CollectionNotFound

Thrown when the `collectionName` does not exist.

## CollectionAlreadyExists

Thrown when the `collectionName` already exists.