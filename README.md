# fs

[![Build Status][gh-actions-badge]][gh-actions]
[![Erlang Versions][erlang-badge]][versions]
[![Tag][github-tag-badge]][github-tag]

*A fork of 'fs': A native file system listener fo macos, win, & linux*

## Backends

* Mac [fsevent](https://github.com/thibaudgg/rb-fsevent)
* Linux [inotify](https://github.com/rvoicilas/inotify-tools/wiki)
* Windows [inotify-win](https://github.com/thekid/inotify-win)

NOTE: On Linux you need to install inotify-tools.

## Usage

### Subscribe to Notifications

```erlang
> fs:start_link(fs_watcher, "/Users/5HT/synrc/fs"). % need to start the fs watcher
> fs:subscribe(fs_watcher). % the pid will receive events as messages
> flush().
Shell got {<0.47.0>,
           {fs,file_event},
           {"/Users/5HT/synrc/fs/src/README.md",[closed,modified]}}
```

### List Events from Backend

```erlang
> fs:known_events(fs_watcher). % returns events known by your backend
[mustscansubdirs,userdropped,kerneldropped,eventidswrapped,
 historydone,rootchanged,mount,unmount,created,removed,
 inodemetamod,renamed,modified,finderinfomod,changeowner,
 xattrmod,isfile,isdir,issymlink,ownevent]
```

### Sample Subscriber

```erlang
> fs_demo:start_looper(). % starts a sample process that logs events
=INFO REPORT==== 28-Aug-2013::19:36:26 ===
file_event: "/tank/proger/erlfsmon/src/4913" [closed,modified]
```

### Receive in `gen_server`

If you configure `fs` to send to a `gen_server`'s PID, you can handle `fs` events with `gen_server:handle_info/2`, where the first argument is the `fs` message payload and the second is the `gen_server`'s state. The format of the message payload is as follows:

``` erlang
{SenderPid, {fs, file_event}, {FileName, EventTypes}}
```

and where `EventTypes` is a list one or more event types that were part of the event.

## Credits

* Vladimir Kirillov
* Maxim Sokhatsky
* Dominic Letz 

OM A HUM


[//]: ---Named-Links---

[github]: https://github.com/erlsci/fs
[gh-actions-badge]: https://github.com/erlsci/fs/workflows/ci%2Fcd/badge.svg
[gh-actions]: https://github.com/erlsci/fs/actions
[erlang-badge]: https://img.shields.io/badge/erlang-21%E2%88%9226-blue.svg
[versions]: https://github.com/erlsci/fs/blob/master/.github/workflows/cicd.yml
[github-tag]: https://github.com/erlsci/fs/tags
[github-tag-badge]: https://img.shields.io/github/tag/erlsci/fs.svg
[hex-badge]: https://img.shields.io/hexpm/v/fs_erlsci.svg?maxAge=2592000
[hex-package]: https://hex.pm/packages/fs_erlsci
