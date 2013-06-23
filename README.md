jsdocy.vim
============

JsDocy helps you to generate comments for JsDoc.
You can use this like the followings:

```vim
:JsDocyAddJsDoc
```

For example, if the cursor is placed on the first line of the following code
and you execute `:JsDocyAddJsDoc`,

```js
function foo(bar, baz, qux) {
  // some code
}
```

then you get the result as below.

```js
/**
 * @param {} bar
 * @param {} baz
 * @param {} qux
 * @return {}
 */
function foo(bar, baz, qux) {
  // some code
}
```

