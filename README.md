**mani.el** is yet another Emacs package to read Man page.


### "Why not `man.el` or `woman.el`"?

1. `man.el` does not support remote Man page.

    I frequently work in a remote environment (with TRAMP): a remote
    machine (usually Linux), from a macOS laptop.

    In that case, I prefer seeing Man pages in that machine,
    e.g. Linux system calls instead of BSD ones, and tools installed
    on servers not on my laptop.

2. One can manage `woman.el` to find remote man page file,
   but `woman.el` does not always parse correctly.

   For example, "woman ls" produces the following sequences in my
   machine:
   
   ```
    .Dd May 19, 2002
    .Dt LS 1
    .Os
    .Sh NAME
    .Nm ls
    .Nd list directory contents
    ...
    ```

### `mani.el` is a just-work Man page reader:

1. It invokes the `man` program to produce the content.  So if
   `man` works, `mani.el` works.

2. It uses `process-file` to run the `man` program.  So it is
   "remote-aware".  If the current `default-directory` is a remote
   one, `man` is invoked in that remote machine.


### Limitations

`mani.el` is not any feature-rich like `man.el` and `woman.el`.  It
does not support navigation, completion, highlight, and caching
functionalities.  I find it just work, and am less-motivated to push
it further.
