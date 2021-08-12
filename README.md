# QShim

A queryExecute shim to work around LDEV-1564 and LDEV-3659. Use wisely.

## Usage

Inject shim:

```js
var shim = getInstance( "shim@qshim" );
```

call it:

```js
var result = shim._queryExecute(
    "
    SELECT id, name FROM students
    WHERE subject=:subject
    ",
    {
        subject : "History"
    }
);
```