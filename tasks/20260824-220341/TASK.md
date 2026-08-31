# fix opening greppable file links

- STATUS: OPEN
- PRIORITY: 100
- TAGS: bug

./src/foo.c:3:4<stuff>

opens src/foo:3 and not ./src/foo.c at the line 3 col 4
