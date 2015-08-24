---
layout: raw
extension: .sh
---
#!/bin/sh

[%- PROCESS include_macros.tmpl ~%]
[%~ MACRO shellquote(str) BLOCK ~%]'[% str.replace("'", "'\\''") %]'[%~ END ~%]

[% FOR post in posts ~%]
  mv [% shellquote(post.filename) %] _output/posts[% shellquote(post.url) %].html
[% END ~%]

rm [% page.filename %]
