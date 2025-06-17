# Donow

A Nostr native todo list app.

## Nostr interoperability

The kind 713 is used to create a todo. For private todo, use [NIP-44](https://github.com/nostr-protocol/nips/blob/master/44.md) and optionaly add an encrypted tag with the encryption used.

```jsonc
// Example

{
    "kind": 713,
    "id": "<event-id-abc>",
    "tags": [["encrypted", "NIP-44"]], // optional
    "content": "Write this README file"
}
```

The kind 714 is used to mark a todo with a status. You can use `DOING` `DONE`. By default there is no marker for a todo, add one only il the status change.

```jsonc
// Example

{
    "kind": 714,
    "tags": [["e", "<event-id-abc>"]],
    "content": "DOING"
}
```

To delete a todo use [NIP-09](https://github.com/nostr-protocol/nips/blob/master/09.md)

## Contributing

Contributions are welcome! Please open issues or submit pull requests.
