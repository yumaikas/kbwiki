import markdown
import kb_config, views

echo(markdown("""
# This is an H1
## This is an H2


Do we support [hyperlinks?](https://junglecoder.com/)

- How well does this do lists?
 - With some ntesting?
- Hrm...


```
Does it do code formatting?
```
"""))

echo PORT
echo THEME
echo APP_TITLE
echo css()
